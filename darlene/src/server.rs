use std::path::Path;
use std::process::exit;
use std::sync::{Arc, Mutex};
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::UnixListener;
use tokio::sync::mpsc::Receiver;
use chrono::Local;

use crate::config::{load_projects_config, save_projects_config, resolve_path};

pub struct ServerState {
    pub active_project: Mutex<Option<String>>,
    pub shutdown_tx: tokio::sync::mpsc::Sender<()>,
}

pub async fn start(socket_path: String, mut shutdown_receiver: Receiver<()>) {
    let socket_path_buf = Path::new(&socket_path).to_path_buf();
    let socket_path_buf_clone = socket_path_buf.clone();

    // Remove existing socket file if it exists
    if socket_path_buf.exists() {
        let _ = std::fs::remove_file(&socket_path_buf);
    }

    let listener = UnixListener::bind(socket_path_buf).expect("Could not create unix socket");
    println!("Listening on {}", socket_path);

    let (internal_shutdown_tx, mut internal_shutdown_rx) = tokio::sync::mpsc::channel(1);

    let server_state = Arc::new(ServerState {
        active_project: Mutex::new(None),
        shutdown_tx: internal_shutdown_tx,
    });

    tokio::spawn(async move {
        tokio::select! {
            _ = shutdown_receiver.recv() => {}
            _ = internal_shutdown_rx.recv() => {}
        }
        if socket_path_buf_clone.exists() {
            let _ = tokio::fs::remove_file(socket_path_buf_clone).await;
        }
        exit(0);
    });

    while let Ok((mut stream, _)) = listener.accept().await {
        let state_clone = Arc::clone(&server_state);
        tokio::spawn(async move {
            let mut command_str = String::new();
            match stream.read_to_string(&mut command_str).await {
                Ok(_) => {
                    let command_str = command_str.trim().to_string();
                    if command_str.is_empty() {
                        let _ = stream.write_all(b"Error: Command is empty").await;
                        return;
                    }

                    if command_str.starts_with("open ") {
                        let project_name = command_str["open ".len()..].trim();
                        let mut config = match load_projects_config() {
                            Ok(cfg) => cfg,
                            Err(e) => {
                                let _ = stream.write_all(format!("Error loading config: {}", e).as_bytes()).await;
                                return;
                            }
                        };

                        let project_index = config.projects.iter().position(|p| p.name.to_lowercase() == project_name.to_lowercase());
                        if let Some(idx) = project_index {
                            let (project_name_str, script_path) = {
                                let project = &config.projects[idx];
                                (project.name.clone(), resolve_path(&project.path))
                            };
                            
                            // Check if script file exists
                            if !script_path.exists() {
                                let _ = stream.write_all(format!("Error: Launch script not found at {:?}", script_path).as_bytes()).await;
                                return;
                            }

                            // Execute script in background
                            let mut cmd = std::process::Command::new("sh");
                            cmd.arg(&script_path);
                            if let Some(parent) = script_path.parent() {
                                cmd.current_dir(parent);
                            }

                            match cmd.spawn() {
                                Ok(_) => {
                                    // Update last opened timestamp
                                    config.projects[idx].last_opened = Local::now().format("%Y-%m-%dT%H:%M:%S").to_string();
                                    
                                    // Save configuration
                                    if let Err(e) = save_projects_config(&config) {
                                        let _ = stream.write_all(format!("Warning: Failed to save config: {}. But script launched.", e).as_bytes()).await;
                                    } else {
                                        // Update active project
                                        {
                                            let mut active = state_clone.active_project.lock().unwrap();
                                            *active = Some(project_name_str.clone());
                                        }
                                        let _ = stream.write_all(format!("Opened project: {}", project_name_str).as_bytes()).await;
                                    }
                                }
                                Err(e) => {
                                    let _ = stream.write_all(format!("Error: Failed to execute script: {}", e).as_bytes()).await;
                                }
                            }
                        } else {
                            let _ = stream.write_all(format!("Error: Project '{}' not found", project_name).as_bytes()).await;
                        }
                    } else if command_str == "status" {
                        let active = state_clone.active_project.lock().unwrap().clone();
                        let response = active.unwrap_or_else(|| "No active project".to_string());
                        let _ = stream.write_all(response.as_bytes()).await;
                    } else if command_str == "stop" {
                        let _ = stream.write_all(b"Server shutting down...").await;
                        let _ = state_clone.shutdown_tx.send(()).await;
                        return;
                    } else {
                        // Fallback: Run as arbitrary shell command
                        println!("Executing command: {}", command_str);
                        let cmd_output = tokio::task::spawn_blocking(move || {
                            std::process::Command::new("sh")
                                .arg("-c")
                                .arg(&command_str)
                                .output()
                        })
                        .await;

                        match cmd_output {
                            Ok(Ok(out)) => {
                                let mut response = out.stdout;
                                if !out.stderr.is_empty() {
                                    if !response.is_empty() {
                                        response.push(b'\n');
                                    }
                                    response.extend_from_slice(&out.stderr);
                                }
                                if response.is_empty() {
                                    response.extend_from_slice(b"Command executed with no output.");
                                }
                                let _ = stream.write_all(&response).await;
                            }
                            Ok(Err(e)) => {
                                let _ = stream.write_all(format!("Failed to run command: {}", e).as_bytes()).await;
                            }
                            Err(e) => {
                                let _ = stream.write_all(format!("Task join error: {}", e).as_bytes()).await;
                            }
                        }
                    }
                }
                Err(e) => {
                    eprintln!("Error reading from stream: {}", e);
                }
            }
        });
    }
}
