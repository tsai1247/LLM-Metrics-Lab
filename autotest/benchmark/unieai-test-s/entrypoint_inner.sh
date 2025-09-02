#!/bin/bash
python scripts/s.py --model-name ${MODEL_NAME} --tokenizer ${MODEL_PATH} --max-new-tokens ${OUTPUT_TOKENS} --concurrency ${CONCURRENCY} --port ${PORT}

date_dir=$(date +%Y%m%d-%H%M%S)
mkdir -p ${RESULT_DIR}/${date_dir}
mv ${RESULT_DIR}/result.json \
        ${RESULT_DIR}/${date_dir}

# 將參數寫到 ${RESULT_DIR}/${date_dir}/parameter.json
echo "{
  \"benchmark\": \"unieai-test-s\",
  \"concurrency\": ${CONCURRENCY},
  \"model_path\": \"${MODEL_PATH}\",
  \"model_name\": \"${MODEL_NAME}\",
  \"output_tokens\": ${OUTPUT_TOKENS},
  \"device_amount\": ${DEVICE_AMOUNT}
}" > ${RESULT_DIR}/${date_dir}/parameter.json