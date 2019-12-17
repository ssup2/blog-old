---
title: Container NVIDIA CUDA GPU
category: Theory, Analysis
date: 2019-12-16T12:00:00Z
lastmod: 2019-12-16T12:00:00Z
comment: true
adsense: true
---

Container에게 NVIDIA CUDA GPU를 제공하는 기법을 분석한다.

### 1. Container NVIDIA CUDA GPU

NVIDIA CUDA GPU을 Container에게 제공하여 Container가 CUDA를 이용할 수 있는 환경을 구성할 수 있다. Docker 19.03 Version에서는 추가된 GPU Opiton을 이용하여 Container에게 NVIDIA CUDA GPU를 제공할 수 있다. Container에게 NVIDIA CUDA GPU를 제공하는 방법으로 **OCI Runtime Spec**을 이용한다.

![[그림 1] CUDA GPU Container OCI Runtime Spec]({{site.baseurl}}/images/theory_analysis/Container_NVIDA_CUDA_GPU/CUDA_Container_Runtime_Spec.PNG){: width="600px"}

[그림 1]은 Docker GPU Option을 이용하여 Container를 생성시 생성되는 OCI Runtime Spec을 나타내고 있다. Docker는 GPU Option을 발견하면 OCI Runtime Spec의 Prestart Hook에 nvidia-container-runtime-hook CLI을 실행하기 위한 설정 내용을 추가하고, Container의 Env에는 GPU, CUDA 관련 설정 정보를 저장한다. Prestart Hook의 Argument는 prestart로 고정된다. Prestart Hook의 Env는 Container의 Env 정보를 그대로 가져와 설정하기 때문에 Docker가 Container의 Env에 추가한 GPU, CUDA 관련 설정 정보가 그대로 Prestart Hook의 Env에 저장된다. Env에는 Container가 이용할 GPU Device List, GPU Capability, CUDA Version, CUDA Library 경로등의 정보가 포함되어 있다.

![[그림 2] CUDA GPU Container Init]({{site.baseurl}}/images/theory_analysis/Container_NVIDA_CUDA_GPU/CUDA_Container_Init.PNG){: width="700px"}

[그림 2]는 [그림 1]에 생성된 OCI Runtime Spec을 바탕으로 runc가 Container를 생성하는 과정을 나타내고 있다. runc는 Container를 위한 Namespace 생성 및 rootfs을 설정하기 위해 clone()을 통해서 Container Init Process를 생성하고, 생성된 Container Init Process의 PID를 가져온다. 그 후 runc는 Prestart Hook의 내용처럼 GPU, CUDA 관련 Env와 함께 nvidia-container-runtime-hook을 실행하고, OCI Runtime Spec에 따라 nvidia-container-runtime-hook의 STDIN을 통해서 Contianer Init PID, rootfs Path와 같은 Container 상태 정보를 전달한다. nvidia-container-runtime-hook은 전달받은 Container, GPU, CUDA 정보를 nvidia-container-cli의 Parameter로 넘겨 nvidia-container-cli을 실행한다. 

nvidia-container-cli은 Parameter로 전달받은 Container, GPU, CUDA 정보와 libnvidia-container를 이용하여 Container가 NVIDIA CUDA GPU을 이용할 수 있도록 설정한다. nvidia-container-cli가 Container의 NVIDIA CUDA GPU를 실제로 설정하는 주체이고, nvidia-container-runtime-hook은 OCI Runtime Spec과 nvidia-container-cli 사이를 연결해주는 Interface 역활만을 수행한다.

![[그림 3] CUDA GPU Container Stack]({{site.baseurl}}/images/theory_analysis/Container_NVIDA_CUDA_GPU/CUDA_Container_Stack.PNG){: width="700px"}

[그림 3]은 NVIDIA CUDA GPU 설정이 완료된 Container들을 나타내고 있다. Host는 4개의 NVIDIA CUDA GPU를 갖고 있어 4개의 Device Node File을 갖고 있다. Container A는 0,1번째 GPU, Container B는 0,2,3번째 GPU, Container C는 3번째 GPU를 이용하고 있다. nvidia-container-cli는 전달 받은 GPU Device List 정보를 바탕으로 해당 GPU Device의 Device Node File을 Bind Mount하여 Container에게 노출시키고, Container App (Init Process)에게 GPU Device를 이용할 수 있는 권한을 설정한다. Container App은 Container Image에 포함된 NVIDIA CUDA Lib/Toolkit을 이용하여 CUDA를 이용하게 된다.

### 2. 참조

* [https://devblogs.nvidia.com/gpu-containers-runtime/](https://devblogs.nvidia.com/gpu-containers-runtime/)
* [https://gitlab.com/nvidia/container-toolkit/toolkit](https://gitlab.com/nvidia/container-toolkit/toolkit)
* [https://gitlab.com/nvidia/container-toolkit/libnvidia-container/](https://gitlab.com/nvidia/container-toolkit/libnvidia-container/)
* [https://github.com/opencontainers/runtime-spec/blob/master/config.md#posix-platform-hooks](https://github.com/opencontainers/runtime-spec/blob/master/config.md#posix-platform-hooks)