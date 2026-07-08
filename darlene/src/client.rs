use std::path::Path;
use std::process::exit;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::UnixStream;

pub async fn run(socket_path: String, message: String) {
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
