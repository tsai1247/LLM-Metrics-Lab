
# 預設值 (可選)
model_owner=""
model_name=""
port=0
tp_size=1

# 參數解析，支援 --arg value 和 --arg=value 兩種格式
while [[ $# -gt 0 ]]; do
  case "$1" in
    --model-owner) model_owner="$2"; shift 2 ;;
    --model-owner=*) model_owner="${1#*=}"; shift ;;
    --model-name) model_name="$2"; shift 2 ;;
    --model-name=*) model_name="${1#*=}"; shift ;;
    --port) port="$2"; shift 2 ;;
    --port=*) port="${1#*=}"; shift ;;
    --tp-size) tp_size="$2"; shift 2 ;;
    --tp-size=*) tp_size="${1#*=}"; shift ;;
    *) echo "未知參數: $1"; exit 1;;
  esac
done

# 輸出解析結果
echo "model_owner: $model_owner"
echo "model_name: $model_name"
echo "port: $port"
echo "tp_size: $tp_size"


echo "run uifw-s-ssd-fp8 server on port $port with model $model_owner / $model_name using $tp_size devices"
# set env PORT MODEL_PATH MODEL_NAME TP_SIZE
export PORT=$port
export MODEL_OWNER=$model_owner
export MODEL_NAME=$model_name
export TP_SIZE=$tp_size

docker compose -f engine/uifw-s-ssd-fp8/docker-compose.yml up -d