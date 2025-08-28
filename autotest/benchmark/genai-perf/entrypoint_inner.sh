#!/bin/bash
genai-perf profile \
        --endpoint-type completions \
        --streaming \
        --url http://localhost:${PORT} \
        -m ${MODEL_NAME} \
        --tokenizer ${MODEL_PATH} \
        --extra-inputs ignore_eos:true \
        --extra-inputs temperature:0 \
        --synthetic-input-tokens-mean ${INPUT_TOKENS} \
        --output-tokens-mean ${OUTPUT_TOKENS} \
        --measurement-interval ${INTERVAL} \
        --concurrency ${CONCURRENCY} \
        --artifact-dir=${RESULT_DIR}
        