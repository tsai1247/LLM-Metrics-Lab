
# 預設值 (可選)
export_name=""
export_start_date=""
export_end_date=""

# 參數解析，支援 --arg value 和 --arg=value 兩種格式
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) export_name="$2"; shift 2 ;;
    --name=*) export_name="${1#*=}"; shift ;;
    --start-date) export_start_date="$2"; shift 2 ;;
    --start-date=*) export_start_date="${1#*=}"; shift ;;
    --end-date) export_end_date="$2"; shift 2 ;;
    --end-date=*) export_end_date="${1#*=}"; shift ;;
    *) echo "未知參數: $1"; exit 1;;
  esac
done

echo ""
export EXPORT_NAME=$export_name
export EXPORT_START_DATE=$export_start_date
export EXPORT_END_DATE=$export_end_date

docker compose -f export/docker-compose.yml up