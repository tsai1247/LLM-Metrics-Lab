
# 預設值 (可選)
port=0
model_owner=""
model_name=""
output_tokens=1
concurrency=1
device_amount=1

# 參數解析，支援 --arg value 和 --arg=value 兩種格式
while [[ $# -gt 0 ]]; do
  case "$1" in
    --concurrency) concurrency="$2"; shift 2 ;;
    --concurrency=*) concurrency="${1#*=}"; shift ;;
    --model-owner) model_owner="$2"; shift 2 ;;
    --model-owner=*) model_owner="${1#*=}"; shift ;;
    --model-name) model_name="$2"; shift 2 ;;
    --model-name=*) model_name="${1#*=}"; shift ;;
    --output-tokens) output_tokens="$2"; shift 2 ;;
    --output-tokens=*) output_tokens="${1#*=}"; shift ;;
    --device-amount) device_amount="$2"; shift 2 ;;
    --device-amount=*) device_amount="${1#*=}"; shift ;;
    --port) port="$2"; shift 2 ;;
    --port=*) port="${1#*=}"; shift ;;
    --input-tokens) shift 2 ;;
    --input-tokens=*) shift ;;
    --interval) shift 2 ;;
    --interval=*) shift ;;
    *) echo "未知參數: $1"; exit 1;;
  esac
done

echo "run unieai-test-g benchmark on port $port with model $model_owner/$model_name using $concurrency concurrency, $output_tokens output tokens"
export CONCURRENCY=$concurrency
export MODEL_OWNER=$model_owner
export MODEL_NAME=$model_name
export OUTPUT_TOKENS=$output_tokens
export DEVICE_AMOUNT=$device_amount
export PORT=$port

docker compose -f benchmark/unieai-test-g/docker-compose.yml up