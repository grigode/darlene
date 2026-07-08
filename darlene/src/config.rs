use std::path::{Path, PathBuf};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Project {
    pub name: String,
    pub path: String,
    pub tags: Vec<String>,
    #[serde(rename = "lastOpened")]
    pub last_opened: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ProjectsConfig {
    pub projects: Vec<Project>,
}

pub fn resolve_path(path: &str) -> PathBuf {
    if path == "~" {
        if let Ok(home) = std::env::var("HOME") {
            return Path::new(&home).to_path_buf();
        }
    } else if path.starts_with("~/") {
        if let Ok(home) = std::env::var("HOME") {
            return Path::new(&home).join(&path[2..]);
        }
    }
    Path::new(path).to_path_buf()
}

pub fn load_projects_config() -> Result<ProjectsConfig, String> {
    let config_path = resolve_path("~/.config/workspaces/projects.json");
    if !config_path.exists() {
        if let Some(parent) = config_path.parent() {
            if let Err(e) = std::fs::create_dir_all(parent) {
                return Err(format!("Failed to create config directory: {}", e));
            }
        }
        let default_config = ProjectsConfig { projects: vec![] };
        let default_json = serde_json::to_string_pretty(&default_config).unwrap();
        if let Err(e) = std::fs::write(&config_path, default_json) {
            return Err(format!("Failed to write default config file: {}", e));
        }
        return Ok(default_config);
    }

    let content = std::fs::read_to_string(&config_path)
        .map_err(|e| format!("Failed to read projects.json: {}", e))?;
    serde_json::from_str(&content)
        .map_err(|e| format!("Failed to parse projects.json: {}", e))
}

pub fn save_projects_config(config: &ProjectsConfig) -> Result<(), String> {
    let config_path = resolve_path("~/.config/workspaces/projects.json");
    let content = serde_json::to_string_pretty(config)
        .map_err(|e| format!("Failed to serialize projects config: {}", e))?;
    std::fs::write(&config_path, content)
        .map_err(|e| format!("Failed to write projects.json: {}", e))
}
