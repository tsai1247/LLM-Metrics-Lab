# Dockerfile
FROM registry.unieai.com/unieverse/uifw-one:2.1

WORKDIR /app

COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app
