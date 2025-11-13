#!/bin/bash
source utils/util.sh
allowed_args="engine"
parse_args "$allowed_args" "$@"

log "stop engine $engine"
if [[ -f ./engine/$engine/docker-compose.yml ]]; then
    engine_path=./engine/$engine
else
    engine_path=$engine/docker-compose.yml
fi

docker compose -f $engine_path down