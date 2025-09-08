#!/bin/bash
source utils/util.sh

allowed_args="model_path model-owner model-name port tp-size"
parse_args "$allowed_args" "$@"

echo "run uifw-s-fp8 server on port $port with model $model_owner / $model_name using $tp_size devices"
# set env PORT MODEL_PATH MODEL_NAME TP_SIZE
export PORT=$port
export MODEL_PATH=$model_path
export MODEL_OWNER=$model_owner
export MODEL_NAME=$model_name
export TP_SIZE=$tp_size

docker compose -f engine/uifw-s-fp8/docker-compose.yml up -d