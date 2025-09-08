#!/bin/bash
echo "engine: ${ENGINE}, model: ${MODEL_OWNER}/${MODEL_NAME}, tp_size: ${TP_SIZE}, port: ${PORT}"
python -m vllm.entrypoints.openai.api_server --port=${PORT} --model ${MODEL_OWNER}/${MODEL_NAME} --served-model-name ${MODEL_NAME} --tensor-parallel-size ${TP_SIZE} &

SERVER_PID=$!
echo "Server PID: $SERVER_PID"
wait $SERVER_PID

# sleep infinity