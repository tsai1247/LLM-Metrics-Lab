#!/bin/bash
source utils/util.sh

allowed_args="engine model-path model-owner model-name gguf-name port tp-size"
parse_args "$allowed_args" "$@"

log "start engine: $engine"
log "\t model path: $model_path"
log "\t model: $model_owner/$model_name (/$gguf_name)"
log "\t port: $port"
log "\t tp_size: $tp_size"
export ENGINE=$engine
export PORT=$port
export MODEL_OWNER=$model_owner
export MODEL_NAME=$model_name
export GGUF_NAME=$gguf_name
export TP_SIZE=$tp_size

if [[ -f ./engine/$engine/docker-compose.yml ]]; then
    engine_path=./engine/$engine
else
    engine_path=$engine/docker-compose.yml
fi

docker compose -f $engine_path up -d