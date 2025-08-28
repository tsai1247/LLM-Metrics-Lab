
# 預設值 (可選)
port=0
model_path=""
model_name=""
input_tokens=1
output_tokens=1
interval=1
concurrency=1
device_amount=1

# 參數解析，支援 --arg value 和 --arg=value 兩種格式
while [[ $# -gt 0 ]]; do
  case "$1" in
    --concurrency) concurrency="$2"; shift 2 ;;
    --concurrency=*) concurrency="${1#*=}"; shift ;;
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
    --device-amount) device_amount="$2"; shift 2 ;;
    --device-amount=*) device_amount="${1#*=}"; shift ;;
    --port) port="$2"; shift 2 ;;
    --port=*) port="${1#*=}"; shift ;;
    *) echo "未知參數: $1"; exit 1;;
  esac
done

echo "run genai-perf benchmark on port $port with model from $model_path (model name is $model_name) using $concurrency concurrency, $input_tokens input tokens, $output_tokens output tokens, $interval ms interval"
# set env PORT MODEL_PATH MODEL_NAME TP_SIZE
export CONCURRENCY=$concurrency
export MODEL_PATH=$model_path
export MODEL_NAME=$model_name
export INTERVAL=$interval
export INPUT_TOKENS=$input_tokens
export OUTPUT_TOKENS=$output_tokens
export DEVICE_AMOUNT=$device_amount
export PORT=$port

docker compose -f "benchmark/genai-perf/docker-compose.yml" up
