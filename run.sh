#!/bin/sh

# Exit immediately if a simple command exits with a nonzero exit value
set -e

docker build -f docker/dockerfile -t harborreplication .
docker compose -f docker/docker-compose.yml run --rm mainservice
