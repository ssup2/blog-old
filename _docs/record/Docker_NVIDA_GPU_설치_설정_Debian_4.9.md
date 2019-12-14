---
title: Docker NVIDIA GPU 설치, 실행 / Debian 9 환경
category: Record
date: 2019-12-15T12:00:00Z
lastmod: 2019-12-15T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

* GPU : GTX 1060 (Pascal Architecture)
* OS : Debian 9, 4.9.0 Kernel, root User
* Software
  * Docker 19.03

### 2. Docker 설치

Docker를 설치한다. 19.03 Version 이상의 Docker를 설치해야 한다.

~~~
# sudo apt-get update
# sudo apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common
# curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
# apt-key fingerprint 0EBFCD88
# add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
# apt-get update
# apt-get install docker-ce docker-ce-cli containerd.io
# docker version
Client: Docker Engine - Community
 Version:           19.03.5
...
Server: Docker Engine - Community
 Engine:
  Version:          19.03.5
...
~~~

### 3. NVIDIA Driver 설치

NVIDIA Driver를 설치한다.

~~~
# apt-get install nvidia-driver
~~~

### 4. NVIDIA Container Toolkit 설치

NVIDIA Container Toolkit Package를 설치하여 nvidia-container-runtime-hook, nvidia-container-toolkit, nvidia-container-cli를 설치한다.

~~~
# distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
# curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
# curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
# sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
~~~

Docker를 재시작하여 Docker에서 Nvida Container Toolkit을 이용하도록 설정한다.

~~~
# sudo systemctl restart docker
~~~

### 5. 동작 확인

Container 안에서 nvidia-smi 명령어를 통해서 container에서 이용가능한 GPU 정보를 얻는다.

~~~
# docker run --gpus all nvidia/cuda:9.0-base nvidia-smi
~~~

### 6. 참조

* [https://collabnix.com/introducing-new-docker-cli-api-support-for-nvidia-gpus-under-docker-engine-19-03-0-beta-release/](https://collabnix.com/introducing-new-docker-cli-api-support-for-nvidia-gpus-under-docker-engine-19-03-0-beta-release/)
* [https://en.wikipedia.org/wiki/Direct_Rendering_Manager](https://en.wikipedia.org/wiki/Direct_Rendering_Manager)