#!/bin/bash
source utils/util.sh

allowed_args="benchmark port engine model-name"
parse_args "$allowed_args" "$@"

# call engine/${engine}.sh
bash engine/entrypoint.sh "$@"

visualize_sleep 5

# wait until server is ready
if [[ "$engine" == "ollama" ]]; then
    echo check_ollama_server
    # check_server "http://127.0.0.1:11434/v1/models" "$engine-for-autotest"  1200
    check_ollama_server "http://127.0.0.1:${port}" "$model_name"  1200
else
    echo check_server
    check_server "http://127.0.0.1:${port}/v1/models" "$engine-for-autotest" 1200
fi

# call benchmark/${benchmark}.sh
bash benchmark/entrypoint.sh "$@"
ret_code=$?
log "ret_code $ret_code"
if [[ $ret_code -eq 0 ]]; then
    echo "benchmark success $ret_code"
    echo $(date +%Y%m%d-%H%M%S) "success $@" >> logs/failed_record.log
else
    echo "benchmark failed $ret_code"
    echo $(date +%Y%m%d-%H%M%S) "failed $@" >> logs/failed_record.log
fi

visualize_sleep 5

# exit engine
echo "stop engine"
bash engine/exit.sh "$@"

visualize_sleep 5

exit $ret_code