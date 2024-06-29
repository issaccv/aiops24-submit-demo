# 提交指南

为了保证复现环境的一致性，我们使用Docker对选手的代码进行复现，要求如下

1. 将包含Dockerfile和启动复现环境的shell脚本打包为 zip 格式，并命名为“队伍名称+队长手机号”
2. 将打包好的压缩包上传到给定的网盘地址

最终的压缩包内结构如下：

```shell
teamname-phone.zip
├── README.md # 代码文档
├── domain.conf # 需要访问的外网域名及对应域名的功能
├── src/ # 复现需要代码等
├── data/ # 使用到的数据文件/数据集
├── Dockerfile # 用于构建Docker镜像
└── run.sh # 构建和启动docker使用的命令
```

为了方便参赛选手理解，我们提供了对[baseline demo](https://github.com/issaccv/aiops24-RAG-demo)的提交实例，可以到[github url]()查看。复现时评委只需要运行`run.sh`即可完成环境构建，答案生成等操作，并将最后的答案拷贝到Dockerfile同级的目录下。



代码文档中需要包含复现过程中可能会遇到的问题以及解决方案



## 复现环境

- 网络环境

  原则上在答案生成过程中无法访问网络（即进入docker run阶段后是没有网络访问权限的），所有模型需要在构建Docker镜像时已经加载完成，**请选手注意模型加载过程中可能产生的网络请求**。

  同时为了减少不必要的资源开销，我们会在名为`aiops24`的docker子网中运行Ollama和Qwen2-7b(Int4量化)版本，如果您的代码没有对LLM做微调，可以直接将LLM的endpoint更改为 `http://ollama:11434`。

  部分选手使用了公网服务，对于这部分公网服务，请单独创建一个名为`domian.conf`的文件，将所有使用到的域名列出，并附上其使用目的，我们会根据用途设置代理白名单。**智谱开放平台和魔搭的相关域名已经加入到白名单中，选手无须额外设置**。

  `domain.conf`中的内容示意，每行一个domain，`#`后添加对该域名的说明：

  ```
  api.jina.ai #jina api embedding service
  generativelanguage.googleapis.com # gemini api service
  ```

- 硬件环境

  复现环境的硬件配置如下

  ```
  CPU: 8*Intel Ice Lake@2.4GHz
  GPU: 1*NVIDIA A100 80G
  RAM: 80GB DDR4 ECC
  ```

## 复现流程

我们会根据选手提交的压缩包以及启动指令在本地进行镜像的构建，然后运行答案生成过程。具体来说复现时评委会运行选手给出的`run.sh`文件，在经过镜像构建和回答生成后，最终会得到一个名为`answer.json`的答案文件。

## Demo说明

Demo中的`run.sh`内容如下

```shell
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
```

该脚本完成了：

1. 嵌入模型的下载
2. 数据集的下载和解压
3. python环境的构建
4. 运行容器并生成答案，当生成完成时将答案拷贝到宿主机上
5. 停止并删除容器

Demo中的`Dockerfile`内容如下

```dockerfile
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
```

该构建完成了：

1. 传入必须的参数（如`OLLAMA_URL`等）
2. 安装依赖

