#!/bin/bash
source utils/util.sh

# allowed_args="graph worksheet type target service-account"
# parse_args "$allowed_args" "$@"

# # if graph is empty, set default "google-sheet"
graph=${graph:-google-sheet}

# export WORKSHEET=$worksheet
# export TYPE=$type
# export TARGET=$target
# export SERVICE_ACCOUNT=$service_account

docker compose -f graph/$graph/docker-compose.yml up