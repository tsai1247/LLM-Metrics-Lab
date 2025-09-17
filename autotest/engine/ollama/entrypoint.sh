#!/bin/bash
echo "engine: ${ENGINE}, model: ${MODEL_OWNER}/${MODEL_NAME}, tp_size: ${TP_SIZE}, port: ${PORT}"

ollama serve &
# wait
echo "Waiting for Ollama server to start..."
until ollama list &>/dev/null; do
    sleep 1
done
echo "Ollama server is ready."

expected="FROM /weights/${MODEL_OWNER}/${MODEL_NAME}/${GGUF_NAME}"
echo "$expected" > /Modulefile

while true; do
  if [ -f /Modulefile ]; then
    actual=$(cat /Modulefile)
    if [ "$actual" = "$expected" ]; then
      break
    fi
  fi
  echo "等待 Modelfile 寫入正確內容..."
  sleep 1
done

echo create model

ollama create ${MODEL_NAME} -f /Modulefile

# ollama run ${MODEL_NAME} "Ping(just response pong and eof)"

sleep infinity