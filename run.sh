#!/bin/bash

git lfs install

# download the model if you need
# git clone https://www.modelscope.cn/AI-ModelScope/bge-small-zh-v1.5.git && mv bge-small-zh-v1.5 model/BAAI/bge-small-zh-v1.5

# download the data
git clone https://www.modelscope.cn/datasets/issaccv/aiops2024-challenge-dataset.git data

unzip data/data.zip -d data/

# build docker image
docker build -t team-name .

# run docker container with model and data volume with sub network
docker run --gpus=all -itd --network=aiops24 --name team-name -v $PWD/src:/app -v $PWD/model/BAAI:/app/BAAI -v $PWD/data:/data team-name 

docker wait team-name

# copy the output file from the container to the host
docker cp team-name:/app/submit_result.jsonl answer.jsonl

# remove the container
docker stop team-name && docker rm team-name