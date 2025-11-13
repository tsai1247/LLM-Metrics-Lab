#!/bin/bash
python r.py --tokenizer=/weights/${MODEL_OWNER}/${MODEL_NAME} --model-name=${MODEL_NAME} --concurrency=${CONCURRENCY} --port=${PORT}

mkdir -p ${RESULT_DIR}/${BENCHMARK_DATE}
mv ${RESULT_DIR}/result.json \
        ${RESULT_DIR}/${BENCHMARK_DATE}

# 將參數寫到 ${RESULT_DIR}/${BENCHMARK_DATE}/parameter.json
echo "{
  \"engine\": \"${ENGINE}\",
  \"benchmark\": \"${BENCHMARK}\",
  \"concurrency\": ${CONCURRENCY},
  \"model_owner\": \"${MODEL_OWNER}\",
  \"model_name\": \"${MODEL_NAME}\",
  \"input_tokens\": ${INPUT_TOKENS},
  \"output_tokens\": ${OUTPUT_TOKENS},
  \"tp_size\": ${TP_SIZE}
}" > ${RESULT_DIR}/${BENCHMARK_DATE}/parameter.json
