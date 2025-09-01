#!/bin/bash
echo $PORT
unieai s0410 --model-path ${MODEL_PATH} --host=0.0.0.0 --port=${PORT} --tp=${TP_SIZE} &

SERVER_PID=$!
echo "Server PID: $SERVER_PID"
wait $SERVER_PID