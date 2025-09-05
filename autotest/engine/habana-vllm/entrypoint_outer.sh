
# 預設值 (可選)
model_owner=""
model_name=""
port=0
devices=1

# 參數解析，支援 --arg value 和 --arg=value 兩種格式
while [[ $# -gt 0 ]]; do
  case "$1" in
    --model-owner) model_owner="$2"; shift 2 ;;
    --model-owner=*) model_owner="${1#*=}"; shift ;;
    --model-name) model_name="$2"; shift 2 ;;
    --model-name=*) model_name="${1#*=}"; shift ;;
    --port) port="$2"; shift 2 ;;
    --port=*) port="${1#*=}"; shift ;;
    --devices) devices="$2"; shift 2 ;;
    --devices=*) devices="${1#*=}"; shift ;;
    *) echo "未知參數: $1"; exit 1;;
  esac
done

# 輸出解析結果
echo "model_owner: $model_owner"
echo "model_name: $model_name"
echo "port: $port"
echo "devices: $devices"


echo "run vllm server on port $port with model $model_path/$model_name using $devices devices"
# set env PORT MODEL_PATH MODEL_NAME TP_SIZE
export PORT=$port
export MODEL_OWNER=$model_owner
export MODEL_NAME=$model_name
export TP_SIZE=$devices

docker compose -f engine/habana-vllm/docker-compose.yml up -d