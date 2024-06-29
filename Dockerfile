# Use the official Python base image
FROM python:3.10-slim

ENV COLLECTION_NAME=aiops24
ENV VECTOR_SIZE=512
ENV OLLAMA_URL=http://ollama:11434

RUN mkdir -p /app

COPY src/* /app

WORKDIR /app

RUN pip install --no-cache-dir --index-url https://mirrors.aliyun.com/pypi/simple/ -r requirements-3.10.txt

# expose /data and /model as volumes
VOLUME [ "/data", "/model" ]

# Set the entrypoint to run the main.py file
CMD ["python", "main.py"]