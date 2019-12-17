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

![[그림 1] CUDA Container OCI Runtime Spec]({{site.baseurl}}/images/theory_analysis/Container_NVIDA_CUDA_GPU/CUDA_Container_Runtime_Spec.PNG){: width="600px"}

![[그림 2] CUDA Container Init]({{site.baseurl}}/images/theory_analysis/Container_NVIDA_CUDA_GPU/CUDA_Container_Init.PNG){: width="600px"}

![[그림 3] CUDA Container Stack]({{site.baseurl}}/images/theory_analysis/Container_NVIDA_CUDA_GPU/CUDA_Container_Stack.PNG){: width="700px"}

### 2. 참조

* [https://devblogs.nvidia.com/gpu-containers-runtime/](https://devblogs.nvidia.com/gpu-containers-runtime/)
* [https://gitlab.com/nvidia/container-toolkit/toolkit](https://gitlab.com/nvidia/container-toolkit/toolkit)
* [https://gitlab.com/nvidia/container-toolkit/libnvidia-container/](https://gitlab.com/nvidia/container-toolkit/libnvidia-container/)
* [https://github.com/opencontainers/runtime-spec/blob/master/config.md#posix-platform-hooks](https://github.com/opencontainers/runtime-spec/blob/master/config.md#posix-platform-hooks)