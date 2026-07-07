use std::env::args;
use std::path::Path;
use std::process::exit;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::{UnixListener, UnixStream};
use tokio::signal;
use tokio::sync::mpsc::{Receiver, channel};

const SOCKET_PATH: &str = "/tmp/darlene.sock";

async fn server(socket_path: String, mut shutdown_receiver: Receiver<()>) {
    let socket_path_buf = Path::new(&socket_path).to_path_buf();
    let socket_path_buf_clone = socket_path_buf.clone();

    // Remove existing socket file if it exists
    if socket_path_buf.exists() {
        let _ = std::fs::remove_file(&socket_path_buf);
    }

    let listener = UnixListener::bind(socket_path_buf).expect("Could not create unix socket");
    println!("Listening on {}", socket_path);

    tokio::spawn(async move {
        match shutdown_receiver.recv().await {
            Some(()) => {
                if socket_path_buf_clone.exists() {
                    let _ = tokio::fs::remove_file(socket_path_buf_clone).await;
                }
                exit(0);
            }
            None => {
                eprintln!(
                    "received nothing from the shutdown receiver. This should not be possible"
                )
            }
        }
    });

    while let Ok((mut stream, _)) = listener.accept().await {
        tokio::spawn(async move {
            let mut command_str = String::new();
            match stream.read_to_string(&mut command_str).await {
                Ok(_) => {
                    let command_str = command_str.trim().to_string();
                    if command_str.is_empty() {
                        let _ = stream.write_all(b"Error: Command is empty").await;
                        return;
                    }

                    println!("Executing command: {}", command_str);

                    // Execute command using spawn_blocking to avoid blocking the executor
                    let cmd_output = tokio::task::spawn_blocking(move || {
                        std::process::Command::new("sh")
                            .arg("-c")
                            .arg(&command_str)
                            .output()
                    })
                    .await;

                    match cmd_output {
                        Ok(Ok(out)) => {
                            // Send stdout and stderr back to the client
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
                            let _ = stream
                                .write_all(format!("Failed to run command: {}", e).as_bytes())
                                .await;
                        }
                        Err(e) => {
                            let _ = stream
                                .write_all(format!("Task join error: {}", e).as_bytes())
                                .await;
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

async fn client(socket_path: String, message: String) {
    let mut unixstream = UnixStream::connect(Path::new(&socket_path))
        .await
        .expect("Could not connect to the socket path. Ensure that the server is running.");

    if let Err(e) = unixstream.write_all(message.as_bytes()).await {
        eprintln!("Failed to send command to socket: {}", e);
        exit(1);
    }

    // Shutdown write stream to signal EOF to the server
    if let Err(e) = unixstream.shutdown().await {
        eprintln!("Failed to shutdown write stream: {}", e);
        exit(1);
    }

    let mut response = String::new();
    if let Err(e) = unixstream.read_to_string(&mut response).await {
        eprintln!("Failed to read response from server: {}", e);
        exit(1);
    }

    println!("{}", response);
}

#[tokio::main]
async fn main() {
    let args_list: Vec<String> = args().collect();
    if args_list.len() < 2 {
        eprintln!("Usage:");
        eprintln!("  darlene start [socket_path]");
        eprintln!("  darlene send <message...>");
        exit(1);
    }

    let mode = &args_list[1];

    if mode == "start" {
        let socket_path = args_list.get(2).cloned().unwrap_or_else(|| {
            std::env::var("DARLENE_SOCKET").unwrap_or_else(|_| SOCKET_PATH.to_string())
        });

        let (shutdown_sender, shutdown_receiver) = channel(1);

        tokio::spawn(async move {
            match signal::ctrl_c().await {
                Ok(()) => {
                    shutdown_sender.send(()).await.unwrap();
                }
                Err(e) => {
                    eprintln!("{}", e)
                }
            }
        });

        server(socket_path, shutdown_receiver).await;
    } else if mode == "send" {
        if args_list.len() < 3 {
            eprintln!("Error: Message to send is required.");
            exit(1);
        }
        let message = args_list[2..].join(" ");
        let socket_path =
            std::env::var("DARLENE_SOCKET").unwrap_or_else(|_| SOCKET_PATH.to_string());

        client(socket_path, message).await;
    } else {
        eprintln!("Invalid operation. Use 'start' or 'send'.");
        exit(1);
    }
}
