check_server (){
	server=$1
	while true; do
	  HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" $server --connect-timeout 3 --max-time 5)
	  #if [[ "$HTTP_CODE" -eq 200 ]]; then
	  RET_CODE=$?
	  if [ "$RET_CODE" -eq 0 ]; then
	      echo "✅ Server is ready (HTTP 200)"
	      break
	  else
	      echo "Wait for server ready."
	      echo "Status $HTTP_CODE. RET: $RET_CODE"
	      sleep 3
	  fi
	done
}

log() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local log_date=$(date +"%Y-%m-%d")
    local log_dir="logs"
    local log_file="$log_dir/$log_date.log"

    mkdir -p "$log_dir"

    echo "[$timestamp] $message" >> "$log_file"
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
      *)
        echo "未知參數: $1"
        exit 1
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

    if [[ $found -eq 0 ]]; then
      echo "未知參數: $key"
      exit 1
    fi

    shift
  done
}