#!/bin/bash
source utils/util.sh

allowed_args="name start-date end-date"
parse_args "$allowed_args" "$@"

export EXPORT_NAME=$name
export EXPORT_START_DATE=$start_date
export EXPORT_END_DATE=$end_date

docker compose -f export/docker-compose.yml up