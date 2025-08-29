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