#!/bin/bash
echo "engine: ${ENGINE}, model: ${MODEL_OWNER}/${MODEL_NAME}, tp_size: ${TP_SIZE}, port: ${PORT}"
unieai l090 --model-path /weights/${MODEL_OWNER}/${MODEL_NAME} --model-name ${MODEL_NAME} --tp ${TP_SIZE} --host 0.0.0.0 --port ${PORT} --backend pytorch &

SERVER_PID=$!
echo "Server PID: $SERVER_PID"
wait $SERVER_PID