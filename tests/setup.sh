#! /bin/bash

# trap "docker compose down" EXIT

cd "$(dirname "$0")"

source ./.env

docker compose up -d
