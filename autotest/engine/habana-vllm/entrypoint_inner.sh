#!/bin/bash
echo $PORT
python -m vllm.entrypoints.openai.api_server --port=${PORT} --model ${MODEL_PATH} --served-model-name ${MODEL_NAME} --tensor-parallel-size ${TP_SIZE} &

SERVER_PID=$!
echo "Server PID: $SERVER_PID"
wait $SERVER_PID

# sleep infinity