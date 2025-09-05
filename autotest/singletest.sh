#!/bin/bash
source utils/util.sh

# 預設值 (可選)
benchmark=""
concurrency=1
engine=""
model_owner=""
model_name=""
interval=0
input_tokens=0
output_tokens=0
port=0
device_amount=1

# 參數解析，支援 --arg value 和 --arg=value 兩種格式
while [[ $# -gt 0 ]]; do
  case "$1" in
    --benchmark) benchmark="$2"; shift 2 ;;
    --benchmark=*) benchmark="${1#*=}"; shift ;;
    --concurrency) concurrency="$2"; shift 2 ;;
    --concurrency=*) concurrency="${1#*=}"; shift ;;
    --engine) engine="$2"; shift 2 ;;
    --engine=*) engine="${1#*=}"; shift ;;
    --model-owner) model_owner="$2"; shift 2 ;;
    --model-owner=*) model_owner="${1#*=}"; shift ;;
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
    --device-amount) device_amount="$2"; shift 2 ;;
    --device-amount=*) device_amount="${1#*=}"; shift ;;
    *) echo "未知參數: $1"; exit 1;;
  esac
done

# 輸出解析結果
echo "benchmark: $benchmark"
echo "concurrency: $concurrency"
echo "engine: $engine"
echo "model_owner: $model_owner"
echo "model_name: $model_name"
echo "interval: $interval"
echo "input_tokens: $input_tokens"
echo "output_tokens: $output_tokens"
echo "port: $port"
echo "device_amount: $device_amount"

# call engine/${engine}.sh
bash engine/${engine}/entrypoint_outer.sh --model-owner "$model_owner" --model-name "$model_name" --port "$port" --devices "$device_amount"

# wait until server is ready
check_server http://127.0.0.1:${port}/v1/models

# call benchmark/${benchmark}.sh
bash benchmark/${benchmark}/entrypoint_outer.sh --concurrency "$concurrency" --model-owner "$model_owner"  --model-name "$model_name" --interval "$interval" --input-tokens "$input_tokens" --output-tokens "$output_tokens" --port "$port" --device-amount "$device_amount"

# exit engine
bash engine/${engine}/exit.sh

log "Completed test: benchmark=$benchmark, concurrency=$concurrency, engine=$engine, model: $model_owner/$model_name, interval=$interval, input_tokens=$input_tokens, output_tokens=$output_tokens, port=$port, device_amount=$device_amount"
bash export/entrypoint_outer.sh --name "tmp" --start-date "19700101-000000" --end-date "99991231-235959"