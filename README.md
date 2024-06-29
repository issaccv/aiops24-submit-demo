# 提交指南

为了保证复现环境的一致性，我们使用Docker对选手的代码进行复现，要求如下

1. 将包含`Dockerfile`和启动复现环境的shell脚本`run.sh`打包为 zip 格式，并命名为“队伍名称+队长手机号”
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

为了方便参赛选手理解，我们提供了对[baseline demo](https://github.com/issaccv/aiops24-RAG-demo)的提交实例，可以到[github url](https://github.com/issaccv/aiops24-submit-demo)查看。复现时评委只需要运行`run.sh`即可完成环境构建，答案生成等操作，并将最后的答案拷贝到Dockerfile同级的目录下。

## 复现环境

- 网络环境

  原则上生成答案时无法从网络下载模型，所有模型需要在构建Docker镜像时已经加载完成，**请选手注意模型加载过程中可能产生的网络请求**。

  同时为了减少不必要的资源开销，我们会在相同的Docker子网中运行Ollama和Qwen2-7b(Int4量化)版本，如果您的代码没有对LLM做微调，可以直接将LLM的endpoint更改为 `http://ollama:11434`。

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
