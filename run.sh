#!/bin/bash

TEAM_NAME=team-name

git lfs install

# download the model if you need
# git clone https://www.modelscope.cn/AI-ModelScope/bge-small-zh-v1.5.git && mv bge-small-zh-v1.5 model/BAAI/bge-small-zh-v1.5

# download the data
git clone https://www.modelscope.cn/datasets/issaccv/aiops2024-challenge-dataset.git data

unzip data/data.zip -d data/

# build docker image
docker build -t "$TEAM_NAME" .

# run docker container with model and data volume with sub network
docker run --gpus=all -itd --network=aiops24 --name "$TEAM_NAME" -v $PWD/src:/app -v $PWD/model/BAAI:/app/BAAI -v $PWD/data:/data "$TEAM_NAME" 

docker wait "$TEAM_NAME"

# copy the output file from the container to the host
docker cp "$TEAM_NAME":/app/submit_result.jsonl answer.jsonl

# remove the container
docker stop "$TEAM_NAME" && docker rm "$TEAM_NAME"