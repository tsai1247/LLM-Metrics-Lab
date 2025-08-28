#!/bin/bash
# usage
# bash autotest.sh --file-path a.json

# 預設值 (可選)
file_path=""

# 參數解析，支援 --arg value 和 --arg=value 兩種格式
while [[ $# -gt 0 ]]; do
  case "$1" in
    --file-path) file_path="$2"; shift 2 ;;
    --file-path=*) file_path="${1#*=}"; shift ;;
    *) echo "未知參數: $1"; exit 1;;
  esac
done
# 輸出解析結果
echo "file_path: $file_path"

if [[ -z "$file_path" ]]; then
  echo "請提供 --file-path 參數"
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "請安裝 jq 工具"
  exit 1
fi

# 讀取 JSON 檔案並遍歷每個物件
jq -c '.[]' "$file_path" | while read -r item; do
  # 解析每個欄位
  benchmark=$(echo "$item" | jq -r '.benchmark')
  concurrency=$(echo "$item" | jq -r '.concurrency')
  engine=$(echo "$item" | jq -r '.engine')
  model_path=$(echo "$item" | jq -r '.model_path')
  model_name=$(echo "$item" | jq -r '.model_name')
  interval=$(echo "$item" | jq -r '.interval')
  input_tokens=$(echo "$item" | jq -r '.input_tokens')
  output_tokens=$(echo "$item" | jq -r '.output_tokens')
  port=$(echo "$item" | jq -r '.port')
  device_amount=$(echo "$item" | jq -r '.device_amount')

  # echo
  echo "=============================="
  echo "benchmark: $benchmark"
  echo "concurrency: $concurrency"
  echo "engine: $engine"
  echo "model_path: $model_path"
  echo "model_name: $model_name"
  echo "interval: $interval"
  echo "input_tokens: $input_tokens"
  echo "output_tokens: $output_tokens"
  echo "port: $port"
  echo "device_amount: $device_amount"
  echo "=============================="

  # 組合參數並執行 singletest.sh
  bash singletest.sh \
    --benchmark "$benchmark" \
    --concurrency "$concurrency" \
    --engine "$engine" \
    --model-path "$model_path" \
    --model-name "$model_name" \
    --interval "$interval" \
    --input-tokens "$input_tokens" \
    --output-tokens "$output_tokens" \
    --port "$port" \
    --device-amount "$device_amount"
done
