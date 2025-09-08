#!/bin/bash
# usage
# bash autotest.sh --file-path a.json

# 預設值 (可選)
file_path=""
name=""

# 參數解析，支援 --arg value 和 --arg=value 兩種格式
while [[ $# -gt 0 ]]; do
  case "$1" in
    --file-path) file_path="$2"; shift 2 ;;
    --file-path=*) file_path="${1#*=}"; shift ;;
    --name) name="$2"; shift 2 ;;
    --name=*) name="${1#*=}"; shift ;;
    *) echo "未知參數: $1"; exit 1;;
  esac
done
# 輸出解析結果
echo "file_path: $file_path"

if [[ -z "$file_path" ]]; then
  echo "請提供 --file-path 參數"
  exit 1
fi

# start_date = now:YYYYMMDD-HHMMSS
start_date=$(date +%Y%m%d-%H%M%S)

if ! command -v jq &> /dev/null; then
  echo "請安裝 jq 工具"
  exit 1
fi

model_path=$(jq -r '.model_path' "$file_path")

# 讀取 JSON 檔案並遍歷每個物件
jq -c '.testcases[]' "$file_path" | while read -r item; do
  # 解析每個欄位
  benchmark=$(echo "$item" | jq -r '.benchmark')
  concurrency=$(echo "$item" | jq -r '.concurrency')
  engine=$(echo "$item" | jq -r '.engine')
  model_id=$(echo "$item" | jq -r '.model_id')
  interval=$(echo "$item" | jq -r '.interval')
  input_tokens=$(echo "$item" | jq -r '.input_tokens')
  output_tokens=$(echo "$item" | jq -r '.output_tokens')
  port=$(echo "$item" | jq -r '.port')
  tp_size=$(echo "$item" | jq -r '.tp_size')

  # get model_owner and model_name from model_id
  model_owner="${model_id%%/*}"
  model_name="${model_id#*/}"

  # echo
  echo "=============================="
  echo "benchmark: $benchmark"
  echo "concurrency: $concurrency"
  echo "engine: $engine"
  echo "model_owner: $model_owner"
  echo "model_name: $model_name"
  echo "interval: $interval"
  echo "input_tokens: $input_tokens"
  echo "output_tokens: $output_tokens"
  echo "port: $port"
  echo "tp_size: $tp_size"
  echo "=============================="

  # 組合參數並執行 singletest.sh
  bash singletest.sh \
    --benchmark "$benchmark" \
    --concurrency "$concurrency" \
    --engine "$engine" \
    --model-path "$model_path" \
    --model-owner "$model_owner" \
    --model-name "$model_name" \
    --interval "$interval" \
    --input-tokens "$input_tokens" \
    --output-tokens "$output_tokens" \
    --port "$port" \
    --tp-size "$tp_size"
done

# end_date = now:YYYYMMDD-HHMMSS
end_date=$(date +%Y%m%d-%H%M%S)
if [ -z "$name" ]; then
  name="result_${start_date}_${end_date}"
fi

bash export/entrypoint_outer.sh --name "$name" --start-date "$start_date" --end-date "$end_date"