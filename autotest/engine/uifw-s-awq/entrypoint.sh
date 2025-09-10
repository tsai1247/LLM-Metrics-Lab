#!/bin/bash
echo "engine: ${ENGINE}, model: ${MODEL_OWNER}/${MODEL_NAME}, tp_size: ${TP_SIZE}, port: ${PORT}"
python3 -m sglang.launch_server \
        --model-path /weights/${MODEL_OWNER}/${MODEL_NAME} \
        --served-model-name ${MODEL_NAME} \
        --tp-size ${TP_SIZE} \
        --host 0.0.0.0 \
        --port ${PORT}

SERVER_PID=$!
echo "Server PID: $SERVER_PID"
wait $SERVER_PID


