#!/bin/bash
source utils/util.sh

allowed_args="benchmark port engine"
parse_args "$allowed_args" "$@"

# call engine/${engine}.sh
bash engine/entrypoint.sh "$@"

visualize_sleep 5

# wait until server is ready
check_server "http://127.0.0.1:${port}/v1/models" "$engine-for-autotest" 1200

# call benchmark/${benchmark}.sh
bash benchmark/entrypoint.sh "$@"

visualize_sleep 5

# exit engine
bash engine/exit.sh "$@"

visualize_sleep 5

bash export/entrypoint.sh "$@" --name "tmp" --start-date "19700101-000001" --end-date "99991231-235958" 