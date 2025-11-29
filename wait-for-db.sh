#!/bin/sh

echo "Waiting for Postgres at $DATABASE_URL ..."

until pg_isready -d "$DATABASE_URL"; do
  sleep 1
done

echo "Postgres is ready!"
exec "$@"
