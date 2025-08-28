# 使用 Python 3.11 slim 版本作為基底
FROM python:3.11-slim

# 設定工作目錄
WORKDIR /app

# 更新 pip 並安裝 genai-perf
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir genai-perf

# 預設執行 bash
CMD ["bash"]