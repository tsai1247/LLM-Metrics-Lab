#!/bin/bash
source utils/util.sh

allowed_args="engine benchmark concurrency model-path model-owner model-name tokenizer interval input-tokens output-tokens tp-size port"
parse_args "$allowed_args" "$@"
echo "run unieai-test-g benchmark on port $port with model $model_owner/$model_name using $concurrency concurrency, $output_tokens output tokens"

if [ "$engine" != "ollama" ]; then
    tokenizer="${model_owner}/${model_name}"
fi

log "start benchmark: $benchmark"
log "\t engine: $engine"
log "\t model path: $model_path"
log "\t model: $model_owner/$model_name"
log "\t tokenizer: $tokenizer"
log "\t concurrency: $concurrency"
log "\t input_tokens: $input_tokens"
log "\t output_tokens: $output_tokens"
log "\t interval: $interval"
log "\t tp_size: $tp_size"
log "\t port: $port"

benchmark_date=$(date +%Y%m%d-%H%M%S)

export ENGINE=$engine
export BENCHMARK=$benchmark
export MODEL_PATH=$model_path
export MODEL_OWNER=$model_owner
export MODEL_NAME=$model_name
export TOKENIZER=$tokenizer
export CONCURRENCY=$concurrency
export INPUT_TOKENS=$input_tokens
export OUTPUT_TOKENS=$output_tokens
export INTERVAL=$interval
export TP_SIZE=$tp_size
export PORT=$port
export BENCHMARK_DATE=$benchmark_date

docker compose -f benchmark/$benchmark/docker-compose.yml up -d

results_dir="$HOME/results/${benchmark}/${benchmark_date}"
container_name="${benchmark}-for-autotest"

# 計算 timeout (毫秒轉換成秒)
timeout_ms=$(( interval + $(ilog2 "$concurrency") * 400000 ))
alt_timeout_ms=$(( interval * 4 ))
if (( alt_timeout_ms > timeout_ms )); then
    timeout_ms=$alt_timeout_ms
fi
if (( 0 > timeout_ms )); then
    timeout_ms=300000
fi

timeout_s=$(( timeout_ms / 1000 ))

log "等待 benchmark 完成，最長 $timeout_s 秒"
echo "等待 benchmark 完成，最長 $timeout_s 秒"

start_time=$(date +%s)
while true; do
    now=$(date +%s)
    elapsed=$(( now - start_time ))

    # 條件 1: profile_export.json + parameter.json 存在
    if [[ -f "$results_dir/profile_export.json" && -f "$results_dir/parameter.json" ]]; then
        log "偵測到 profile_export.json 與 parameter.json"
        break
    fi

    # 條件 2: result.json + parameter.json 存在
    if [[ -f "$results_dir/result.json" && -f "$results_dir/parameter.json" ]]; then
        log "偵測到 result.json 與 parameter.json"
        break
    fi

    # 條件 3: 超過 timeout
    if (( elapsed > timeout_s )); then
        log "等待超時 ($elapsed 秒)"
        break
    fi
    printf "\r$elapsed s"

    # 條件 4: container 已經停止
    if ! docker ps --format '{{.Names}}' | grep -q "^${container_name}\$"; then
        log "container $container_name 已停止"
        break
    fi

    sleep 5
done

visualize_sleep 5

# 停止 container
log "停止 container: $container_name"
docker stop "$container_name" >/dev/null 2>&1 || true

# 驗證 benchmark 是否成功
if [[ ( -f "$results_dir/profile_export.json" && -f "$results_dir/parameter.json" ) \
   || ( -f "$results_dir/result.json" && -f "$results_dir/parameter.json" ) ]]; then
    log "✅ benchmark succeeded"
    exit 0
else
    log "❌ benchmark failed"
    if rm -rf "$results_dir"; then
        log "$results_dir removed"
    else
        log "$results_dir 刪除失敗"
    fi
    exit 1
fi
