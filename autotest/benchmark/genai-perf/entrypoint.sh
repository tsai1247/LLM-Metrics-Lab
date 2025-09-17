#!/bin/bash
echo "benchmark: ${BENCHMARK}, model: ${MODEL_OWNER}/${MODEL_NAME}, port: ${PORT}, \
input_tokens: ${INPUT_TOKENS}, output_tokens: ${OUTPUT_TOKENS}, interval: ${INTERVAL}, concurrency: ${CONCURRENCY}, \
result_dir: ${RESULT_DIR}"

genai-perf profile \
        --endpoint-type ${ENDPOINT_TYPE} \
        --streaming \
        --url http://localhost:${PORT} \
        -m ${MODEL_NAME} \
        --tokenizer ${TOKENIZER} \
        --extra-inputs ignore_eos:true \
        --synthetic-input-tokens-mean ${INPUT_TOKENS} \
        --output-tokens-mean ${OUTPUT_TOKENS} \
        --measurement-interval ${INTERVAL} \
        --concurrency ${CONCURRENCY} \
        --artifact-dir=${RESULT_DIR}

mv ${RESULT_DIR}/${MODEL_NAME}-openai-${ENDPOINT_TYPE}-concurrency${CONCURRENCY} \
        ${RESULT_DIR}/${BENCHMARK_DATE}

# 將參數寫到 ${RESULT_DIR}/${BENCHMARK_DATE}/parameter.json
echo "{
  \"engine\": \"${ENGINE}\",
  \"benchmark\": \"${BENCHMARK}\",
  \"concurrency\": ${CONCURRENCY},
  \"model_owner\": \"${MODEL_OWNER}\",
  \"model_name\": \"${MODEL_NAME}\",
  \"interval\": ${INTERVAL},
  \"input_tokens\": ${INPUT_TOKENS},
  \"output_tokens\": ${OUTPUT_TOKENS},
  \"tp_size\": ${TP_SIZE}
}" > ${RESULT_DIR}/${BENCHMARK_DATE}/parameter.json
