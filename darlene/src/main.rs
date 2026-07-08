use std::env::args;
use std::process::exit;
use tokio::signal;
use tokio::sync::mpsc::channel;

mod config;
mod server;
mod client;

const SOCKET_PATH: &str = "/tmp/darlene.sock";

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
        let socket_path = args_list.get(2)
            .cloned()
            .unwrap_or_else(|| std::env::var("DARLENE_SOCKET").unwrap_or_else(|_| SOCKET_PATH.to_string()));

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

        server::start(socket_path, shutdown_receiver).await;
    } else if mode == "send" {
        if args_list.len() < 3 {
            eprintln!("Error: Message to send is required.");
            exit(1);
        }
        let message = args_list[2..].join(" ");
        let socket_path = std::env::var("DARLENE_SOCKET").unwrap_or_else(|_| SOCKET_PATH.to_string());

        client::run(socket_path, message).await;
    } else {
        eprintln!("Invalid operation. Use 'start' or 'send'.");
        exit(1);
    }
}
