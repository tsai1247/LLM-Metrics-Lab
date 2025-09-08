#!/bin/bash
source utils/util.sh

allowed_args="concurrency model-path model-owner model-name interval input-tokens output-tokens tp-size port"
parse_args "$allowed_args" "$@"echo "run unieai-test-g benchmark on port $port with model $model_owner/$model_name using $concurrency concurrency, $output_tokens output tokens"

export CONCURRENCY=$concurrency
export MODEL_PATH=$model_path
export MODEL_NAME=$model_name
export OUTPUT_TOKENS=$output_tokens
export TP_SIZE=$tp_size
export PORT=$port

docker compose -f benchmark/unieai-test-g/docker-compose.yml up