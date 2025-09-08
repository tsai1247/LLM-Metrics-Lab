#!/bin/bash
source utils/util.sh

allowed_args="concurrency model-owner model-name interval input-tokens output-tokens tp-size port"
parse_args "$allowed_args" "$@"

echo "run genai-perf benchmark on port $port with model from $model_path/$model_name using $concurrency concurrency, $input_tokens input tokens, $output_tokens output tokens, $interval ms interval"
# set env PORT MODEL_PATH MODEL_NAME TP_SIZE
export CONCURRENCY=$concurrency
export MODEL_PATH=$model_path
export MODEL_OWNER=$model_owner
export MODEL_NAME=$model_name
export INTERVAL=$interval
export INPUT_TOKENS=$input_tokens
export OUTPUT_TOKENS=$output_tokens
export TP_SIZE=$tp_size
export PORT=$port

docker compose -f "benchmark/genai-perf/docker-compose.yml" up
