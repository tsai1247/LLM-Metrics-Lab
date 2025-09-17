#!/bin/bash
set -euo pipefail
source utils/util.sh


allowed_args="model-path"
parse_args "$allowed_args" "$@"

if [[ -z "$model_path" ]]; then
  model_path="/weight"
fi
port=8999
available_engine=""
engine_success=()
engine_failed=()
benchmark_tested=0
benchmark_success=()
benchmark_failed=()

log "stop all testing containers"
docker stop $(docker ps --format '{{.Names}}' | grep for-autotest) || true
visualize_sleep 5

# 遍歷 engine 下的所有資料夾
for dir_name in engine/*/; do
    dir_name=$(basename "$dir_name")
    log "開始檢查 engine ${dir_name}"

    bash engine/entrypoint.sh \
        --engine "$dir_name" \
        --model-path "$model_path" || {
        log "❌ Engine ${dir_name} 有異常"
        bash engine/exit.sh --engine "$dir_name" || {
            log "Engine ${dir_name} 已關閉"
        }
        continue
    }

    visualize_sleep 5

    # wait until server is ready
    check_server "http://127.0.0.1:${port}/v1/models" "${dir_name}-for-autotest" 300 || {
        log "❌ Engine ${dir_name} 有異常"
        engine_failed+=("$dir_name")

        bash engine/exit.sh --engine "$dir_name"
        continue
    }
    exit_code=$?

    if [[ "$exit_code" -eq 0 ]]; then
        log "✅ Engine ${dir_name} 正常運作"
        engine_success+=("$dir_name")
        available_engine="$dir_name"
    else
        log "❌ Engine ${dir_name} 有異常"
        engine_failed+=("$dir_name")
    fi
    
    bash engine/exit.sh --engine "$dir_name"
    
    visualize_sleep 5
done

if [[ -z "$available_engine" ]]; then
    log "❓ 沒有可使用的 engine，無法測試 benchmark"
else
    # 啟動 engine
    log "✅ 啟動 Engine ${available_engine} 以供測試"
    bash engine/entrypoint.sh \
        --engine "$available_engine" \
        --model-path "$model_path" \
        --model-owner Qwen \
        --model-name Qwen3-0.6B \
        --port "$port" \
        --tp-size 1
    
    check_server "http://127.0.0.1:${port}/v1/models" "${available_engine}-for-autotest" 300 || {
        log "❌ Engine ${available_engine} 有異常，無法測試 benchmark"
        bash engine/exit.sh --engine "$available_engine"
        exit 1
    }
    exit_code=$?

    if [[ "$exit_code" -eq 0 ]]; then
        log "✅ Engine ${available_engine} 正常運作，開始測試 benchmark"
        benchmark_tested=1
        if [[ -z "$available_engine" ]]; then
            available_engine="$dir_name"
        fi
    else
        log "❌ Engine ${available_engine} 有異常，無法測試 benchmark"
        bash engine/exit.sh --engine "$available_engine"
    fi
    
    visualize_sleep 5

    # 遍歷 benchmark 下的所有資料夾
    for dir_name in benchmark/*/; do
        dir_name=$(basename "$dir_name")
        log "開始檢查 benchmark ${dir_name}"
        
        benchmark_date="tmp"
        bash benchmark/entrypoint.sh --benchmark "$dir_name" --model-path "$model_path"
        wait_for_benchmark "$dir_name" "$benchmark_date"
        ret_code=$?
        if [[ "$ret_code" -eq 0]]; then
            log "✅ Benchmark ${dir_name} 正常運作"
            benchmark_success+=("$dir_name")
        else
            log "❌ Benchmark ${dir_name} 有異常，ret_code: $ret_code"
            benchmark_failed+=("$dir_name")
        fi
    done

    # force stop benchmark container 
    docker stop "$container_name" >/dev/null 2>&1 || true
    visualize_sleep 5
fi

echo "可以使用的 engine:" "${engine_success[@]}"
echo "不能使用的 engine:" "${engine_failed[@]}"
if [[ "$benchmark_tested" -eq 1 ]]; then
    echo "可以使用的 benchmark:" "${benchmark_success[@]}"
    echo "不能使用的 benchmark:" "${benchmark_failed[@]}"
else
    echo "engine啟動失敗，無法測試 benchmark"
fi
