# 使用 Python 3.11 slim 版本作為基底
FROM python:3.11-slim

# 設定工作目錄
WORKDIR /app

# 複製 requirements.txt 到容器
COPY requirements.txt .

# 更新 pip 並安裝 requirements.txt 內的套件
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# 預設執行 bash
CMD ["bash"]