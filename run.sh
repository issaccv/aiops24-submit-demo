#!/bin/bash

git lfs install

# download the model if you need
# git clone https://www.modelscope.cn/AI-ModelScope/bge-small-zh-v1.5.git model

# download the data
git clone https://www.modelscope.cn/datasets/issaccv/aiops2024-challenge-dataset.git data

# build docker image
docker build -t team-name .

# run docker container with model and data volume with sub network
docker run -it --network=aiops24 --name team-name -v $PWD/model:/model -v $PWD/data:/data team-name 

# copy the output file from the container to the host
docker cp team-name:/app/submit_result.jsonl answer.jsonl

# remove the container
docker stop team-name && docker rm team-name