pub mod config;
pub mod db;

use axum::{
    Json, Router,
    body::Body,
    extract::State,
    http::{Request, Response, StatusCode},
    middleware::Next,
    response::IntoResponse,
    routing::{delete, get, post, put},
};
use config::Settings;

use serde_json::json;
use sqlx::Column;
use sqlx::PgPool;
use sqlx::Row;
use tokio::net::TcpListener;
use tracing::{Level, info, warn};
use tracing_subscriber::FmtSubscriber;
use uuid::Uuid;

use crate::db::connect;


#[tokio::main]
async fn main() -> eyre::Result<()> {
    let subscriber = FmtSubscriber::builder()
        .with_max_level(Level::INFO)
        .with_env_filter("info")
        .finish();
    tracing::subscriber::set_global_default(subscriber).expect("setting tracing subscriber failed");

    let settings = Settings::load()?;
    info!("Config loaded: {:?}", settings);

    info!("Connecting to database...");
    let pool = connect(&settings.database.url).await?;
    info!("Successfully connected to the database!");
    sqlx::migrate!("./migrations").run(&pool).await?;
    info!("Migrations applied!");

    let app = Router::new()
        .route("/health", get(health_check))
        .layer(axum::middleware::from_fn(tracing_middleware));

    let addr = format!("{}:{}", settings.server.host, settings.server.port);
    let listener = TcpListener::bind(&addr).await?;
    info!("Starting server at http://{}", addr);

    axum::serve(listener, app).await?;

    Ok(())
}

async fn health_check() -> &'static str {
    "200 - OK"
}

async fn fallback() -> impl IntoResponse {
    (StatusCode::NOT_FOUND, "404 - Not Found")
}

async fn tracing_middleware(req: Request<Body>, next: Next) -> Response<Body> {
    info!(method = %req.method(), path = %req.uri(), "Incoming request");

    let res = next.run(req).await;

    match res.status() {
        status => info!(status = %status, "Response status"),
    }

    res
}