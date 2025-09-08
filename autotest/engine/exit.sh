#!/bin/bash
source utils/util.sh
allowed_args="engine"
parse_args "$allowed_args" "$@"

log "stop engine $engine"
docker compose -f engine/$engine/docker-compose.yml down