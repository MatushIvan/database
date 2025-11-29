use sqlx::{Pool, Postgres};

pub async fn connect(database_url: &str) -> Result<Pool<Postgres>, sqlx::Error> {
    let pool = Pool::<Postgres>::connect(database_url).await?;
    Ok(pool)
}
