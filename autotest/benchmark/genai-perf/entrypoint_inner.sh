#!/bin/bash
genai-perf profile \
        --endpoint-type completions \
        --streaming \
        --url http://localhost:${PORT} \
        -m ${MODEL_NAME} \
        --tokenizer ${MODEL_OWNER}/${MODEL_NAME} \
        --extra-inputs ignore_eos:true \
        --extra-inputs temperature:0 \
        --synthetic-input-tokens-mean ${INPUT_TOKENS} \
        --output-tokens-mean ${OUTPUT_TOKENS} \
        --measurement-interval ${INTERVAL} \
        --concurrency ${CONCURRENCY} \
        --artifact-dir=${RESULT_DIR}

date=$(date +%Y%m%d-%H%M%S)
mv ${RESULT_DIR}/${MODEL_NAME}-openai-completions-concurrency${CONCURRENCY} \
        ${RESULT_DIR}/${date}

# 將參數寫到 ${RESULT_DIR}/${date}/parameter.json
echo "{
  \"benchmark\": \"genai-perf\",
  \"concurrency\": ${CONCURRENCY},
  \"model_owner\": \"${MODEL_OWNER}\",
  \"model_name\": \"${MODEL_NAME}\",
  \"interval\": ${INTERVAL},
  \"input_tokens\": ${INPUT_TOKENS},
  \"output_tokens\": ${OUTPUT_TOKENS},
  \"device_amount\": ${DEVICE_AMOUNT}
}" > ${RESULT_DIR}/${date}/parameter.json