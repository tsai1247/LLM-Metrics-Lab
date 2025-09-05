#!/bin/bash
unieai s0410 --model-path /weights/${MODEL_OWNER}/${MODEL_NAME} --model-name ${MODEL_NAME} --tp ${TP_SIZE} --host 0.0.0.0 --port ${PORT} --quantization fp8 --no-enable-torch-compile &

SERVER_PID=$!
echo "Server PID: $SERVER_PID"
wait $SERVER_PID