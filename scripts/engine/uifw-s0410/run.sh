#!/bin/bash

# 預設值
MODEL_SERIES="mistralai"
MODEL_NAME="Mixtral-8x7B-Instruct-v0.1"
TP=4

# 解析參數
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --model-series) MODEL_SERIES="$2"; shift ;;
        --model-name) MODEL_NAME="$2"; shift ;;
        --tp) TP="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

unieai s0410 --model-path ${MODEL_SERIES}/${MODEL_NAME} --host=0.0.0.0 --port=8999 --tp=${TP}
