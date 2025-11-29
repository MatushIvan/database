FROM rust:1.90 as builder

WORKDIR /app

COPY Cargo.toml Cargo.lock ./
COPY src ./src
COPY migrations ./migrations
COPY config ./config

RUN cargo build --release

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y ca-certificates tzdata postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY wait-for-db.sh /app/wait-for-db.sh
RUN chmod +x /app/wait-for-db.sh

COPY --from=builder /app/target/release/rust_db_indexing /app/rust_db_indexing
COPY config ./config

EXPOSE 8080

CMD ["/app/wait-for-db.sh", "./rust_db_indexing"]
