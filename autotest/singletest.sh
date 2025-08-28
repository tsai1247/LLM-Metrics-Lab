#!/bin/bash
source utils/server_check.sh

# 預設值 (可選)
benchmark=""
concurrency=1
engine=""
model_path=""
model_name=""
interval=0
input_tokens=0
output_tokens=0
port=0
devices=1

# 參數解析，支援 --arg value 和 --arg=value 兩種格式
while [[ $# -gt 0 ]]; do
  case "$1" in
    --benchmark) benchmark="$2"; shift 2 ;;
    --benchmark=*) benchmark="${1#*=}"; shift ;;
    --concurrency) concurrency="$2"; shift 2 ;;
    --concurrency=*) concurrency="${1#*=}"; shift ;;
    --engine) engine="$2"; shift 2 ;;
    --engine=*) engine="${1#*=}"; shift ;;
    --model-path) model_path="$2"; shift 2 ;;
    --model-path=*) model_path="${1#*=}"; shift ;;
    --model-name) model_name="$2"; shift 2 ;;
    --model-name=*) model_name="${1#*=}"; shift ;;
    --interval) interval="$2"; shift 2 ;;
    --interval=*) interval="${1#*=}"; shift ;;
    --input-tokens) input_tokens="$2"; shift 2 ;;
    --input-tokens=*) input_tokens="${1#*=}"; shift ;;
    --output-tokens) output_tokens="$2"; shift 2 ;;
    --output-tokens=*) output_tokens="${1#*=}"; shift ;;
    --port) port="$2"; shift 2 ;;
    --port=*) port="${1#*=}"; shift ;;
    --devices) devices="$2"; shift 2 ;;
    --devices=*) devices="${1#*=}"; shift ;;
    *) echo "未知參數: $1"; exit 1;;
  esac
done

# 輸出解析結果
echo "benchmark: $benchmark"
echo "concurrency: $concurrency"
echo "engine: $engine"
echo "model_path: $model_path"
echo "model_name: $model_name"
echo "interval: $interval"
echo "input_tokens: $input_tokens"
echo "output_tokens: $output_tokens"
echo "port: $port"
echo "devices: $devices"

# call engine/${engine}.sh
bash engine/${engine}/entrypoint_outer.sh --model-path "$model_path" --model-name "$model_name" --port "$port" --devices "$devices"

# wait until server is ready
check_server http://127.0.0.1:${port}/v1/models

# call benchmark/${benchmark}.sh
bash benchmark/${benchmark}/entrypoint_outer.sh --concurrency "$concurrency" --model-path "$model_path"  --model-name "$model_name" --interval "$interval" --input-tokens "$input_tokens" --output-tokens "$output_tokens" --port "$port"

# exit engine
bash engine/${engine}/exit.sh 