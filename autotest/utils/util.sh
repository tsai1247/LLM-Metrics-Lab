log() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local log_date=$(date +"%Y-%m-%d")
    local log_dir="logs"
    local log_file="$log_dir/$log_date.log"

    mkdir -p "$log_dir"

    # echo -e "[s$timestamp] $message"
    echo -e "[$timestamp] $message" >> "$log_file"
}

check_server (){
    server=$1
    container_id=$2
    max_wait=${3:-60}
    waited=0

    while true; do
        # 檢查 container 是否還活著
        if ! docker ps --format "{{.Names}}" | grep -q "^${container_id}$"; then
            echo "❌ Docker container $container_id 已經停止，停止等待。"
            log "❌ Docker container $container_id 已經停止，停止等待。"
            return 1
        fi

        # 檢查 server 是否回應
        HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" "$server" --connect-timeout 3 --max-time 5) || {
          waited=$((waited+3))
          if [ $waited -ge $max_wait ]; then
              echo "❌ Timeout after ${max_wait} seconds, server not ready."
              log "❌ Timeout after ${max_wait} seconds, server not ready."
              return 1
          fi

          printf "\r⏳ Wait for server ready... (status=$HTTP_CODE, ret=$RET_CODE, waited=$waited s)"
          sleep 3
          continue
        }

        RET_CODE=$?

        if [ "$RET_CODE" -eq 0 ] && [ "$HTTP_CODE" -eq 200 ]; then
            echo "✅ Server is ready (HTTP 200)"
            log "✅ Server is ready (HTTP 200)"
            break
        else
            echo "⏳ Wait for server ready... (status=$HTTP_CODE, ret=$RET_CODE)"
        fi

        # timeout 判斷
        waited=$((waited+3))
        if [ $waited -ge $max_wait ]; then
            echo "❌ Timeout after ${max_wait} seconds, server not ready."
            log "❌ Timeout after ${max_wait} seconds, server not ready."
            return 1
        fi

        sleep 3
    done
    return 0
}

check_ollama_server() {
    local target="$1"      # e.g. http://127.0.0.1:11434
    local model_name="$2"  # e.g. qwen2:7b
    local timeout="$3"     # e.g. 1200 秒
    local start_time=$(date +%s)

    echo "🔍 Checking Ollama server at $target for model '$model_name' (timeout ${timeout}s)..."

    while true; do
        # timeout 判斷
        local now=$(date +%s)
        local elapsed=$((now - start_time))

        if [ "$elapsed" -ge "$timeout" ]; then
            echo "⏰ Timeout after ${timeout}s: model '$model_name' not found."
            return 1
        fi

        # 檢查 server 是否回應
        response=$(curl -s --max-time 5 "${target}/v1/models")
        if [ $? -ne 0 ] || [ -z "$response" ]; then
            printf "\r⚠️ Server not responding yet... (${elapsed}s)"
            sleep 2
            continue
        fi

        # 用 jq 檢查模型是否存在
        echo "$response" | jq -e ".data[]?.id" | grep -q "\"${model_name}:"
        if [ $? -eq 0 ]; then
            echo "✅ Model '$model_name' is available on $target (elapsed ${elapsed}s)."
            return 0
        fi

        printf "\r⏳ Server up, but model '$model_name' not available yet... (elapsed ${elapsed}s)"
        sleep 2
    done
}

parse_args() {
  local allowed="$1"   # 第一個參數是允許的參數清單 (空白分隔)
  shift                # 移掉 $1，剩下的才是真正傳入的參數

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --*=*)
        key="${1%%=*}"   # 取等號左邊 (--model-path)
        val="${1#*=}"    # 取等號右邊 (/path)
        ;;
      --*)
        key="$1"         # --model-path
        val="$2"         # /path
        shift
        ;;
    esac

    local found=0
    for arg in $allowed; do
      if [[ "$key" == "--$arg" ]]; then
        var_name="${arg//-/_}"   # 把 dash 轉成底線
        eval "$var_name=\"$val\""
        found=1
        break
      fi
    done

    shift
  done
}

visualize_sleep() {
  seconds=$1
  bar_length=50
  for ((i=1; i<=seconds; i++)); do
    sleep 1
    percent=$(( i * 100 / seconds ))
    filled=$(( i * bar_length / seconds ))
    bar=$(printf "%${filled}s" | tr ' ' '#')
    spaces=$(printf "%$((bar_length-filled))s")
    printf "\rwait for %d seconds [%-s%-s] %3d%%" "$seconds" "$bar" "$spaces" "$percent"
  done
  echo    # 換行
}

# 整數 log2
ilog2() {
    local n=$1
    local p=0
    while (( n > 1 )); do
        (( n >>= 1 ))
        (( p++ ))
    done
    echo $p
}