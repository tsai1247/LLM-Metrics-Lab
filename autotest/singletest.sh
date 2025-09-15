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
ret_code=$?
log "ret_code $ret_code"
if [[ $ret_code -eq 0 ]]; then
    echo "benchmark success $ret_code"
    echo $(date +%Y%m%d-%H%M%S) "success $@" >> logs/failed_record.txt
else
    echo "benchmark failed $ret_code"
    echo $(date +%Y%m%d-%H%M%S) "failed $@" >> logs/failed_record.txt
fi

visualize_sleep 5

# exit engine
echo "stop engine"
bash engine/exit.sh "$@"

visualize_sleep 5

exit $ret_code