#!/bin/bash
source utils/util.sh

allowed_args="benchmark concurrency model-path model-owner model-name interval input-tokens output-tokens tp-size port"
parse_args "$allowed_args" "$@"echo "run unieai-test-g benchmark on port $port with model $model_owner/$model_name using $concurrency concurrency, $output_tokens output tokens"

log "start benchmark: $benchmark"
log "\t model path: $model_path"
log "\t model: $model_owner/$model_name"
log "\t concurrency: $concurrency"
log "\t input_tokens: $input_tokens"
log "\t output_tokens: $output_tokens"
log "\t interval: $interval"
log "\t tp_size: $tp_size"
log "\t port: $port"

export BENCHMARK=$benchmark
export MODEL_PATH=$model_path
export MODEL_OWNER=$model_owner
export MODEL_NAME=$model_name
export CONCURRENCY=$concurrency
export INPUT_TOKENS=$input_tokens
export OUTPUT_TOKENS=$output_tokens
export INTERVAL=$interval
export TP_SIZE=$tp_size
export PORT=$port

docker compose -f benchmark/$benchmark/docker-compose.yml up