#!/bin/bash
source utils/util.sh

allowed_args="export name start-date end-date"
parse_args "$allowed_args" "$@"

log "start export: $export"
log "\t name: $name"
log "\t start_date: $start_date"
log "\t end_date: $end_date"
export EXPORT_TYPE=$export
export EXPORT_NAME=$name
export EXPORT_START_DATE=$start_date
export EXPORT_END_DATE=$end_date

docker compose -f export/$export/docker-compose.yml up