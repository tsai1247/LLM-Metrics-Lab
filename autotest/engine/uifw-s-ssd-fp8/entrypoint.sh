#!/bin/bash
echo "engine: ${ENGINE}, model: ${MODEL_OWNER}/${MODEL_NAME}, tp_size: ${TP_SIZE}, port: ${PORT}"
unieai s0410 --model-path ${MODEL_OWNER}/${MODEL_NAME} --model-name ${MODEL_NAME} --tp ${TP_SIZE} --host 0.0.0.0 --port ${PORT} --quantization fp8 --no-enable-torch-compile --ssd /mnt/nvme0/uifw &

SERVER_PID=$!
echo "Server PID: $SERVER_PID"
wait $SERVER_PID