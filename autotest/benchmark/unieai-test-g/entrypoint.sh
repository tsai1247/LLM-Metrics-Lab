#!/bin/bash
python scripts/g.py --model-name ${MODEL_NAME} --tokenizer ${MODEL_OWNER}/${MODEL_NAME} --max-new-tokens ${OUTPUT_TOKENS} --concurrency ${CONCURRENCY} --port ${PORT}

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
