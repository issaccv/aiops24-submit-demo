# Use the official Python base image
FROM python:3.10-slim

ENV COLLECTION_NAME=aiops24
ENV VECTOR_SIZE=512
ENV OLLAMA_URL=http://ollama:11434

RUN mkdir -p /app

COPY src/requirements-3.10.txt /app

WORKDIR /app

RUN pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple uv && \
    uv pip sync --python $(which python) --no-cache -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple requirements-3.10.txt

# expose /data and /model as volumes
VOLUME [ "/data", "/model", "/app" ]

# Set the entrypoint to run the main.py file
CMD ["python", "main.py"]