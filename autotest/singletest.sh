#!/bin/bash
source utils/util.sh

allowed_args="benchmark port"
parse_args "$allowed_args" "$@"

# call engine/${engine}.sh
bash engine/entrypoint.sh "$@"

# wait until server is ready
check_server http://127.0.0.1:${port}/v1/models

# call benchmark/${benchmark}.sh
bash benchmark/entrypoint.sh "$@"

# exit engine
bash engine/exit.sh "$@"

bash export/entrypoint.sh "$@" --name "tmp" --start-date "19700101-000001" --end-date "99991231-235958" 