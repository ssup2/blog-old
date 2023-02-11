---
title: Container NVIDIA GPU
category: Theory, Analysis
date: 2019-12-16T12:00:00Z
lastmod: 2019-12-16T12:00:00Z
comment: true
adsense: true
---

Container에게 NVIDIA GPU를 제공하는 기법을 분석한다.

### 1. Container NVIDIA GPU

NVIDIA GPU을 Container에게 제공하여 Container가 NVIDIA GPU를 이용할 수 있는 환경을 구성할 수 있다. Docker 19.03 Version에서는 추가된 GPU Opiton을 이용하여 Container에게 NVIDIA GPU를 제공할 수 있다. Container에게 NVIDIA GPU를 제공하는 방법으로 **OCI Runtime Spec**을 이용한다.

![[그림 1] NVIDIA GPU Container OCI Runtime Spec]({{site.baseurl}}/images/theory_analysis/Container_NVIDA_GPU/Container_Runtime_Spec.PNG){: width="600px"}

[그림 1]은 Docker GPU Option을 이용하여 Container를 생성시 생성되는 OCI Runtime Spec을 나타내고 있다. Docker는 GPU Option을 발견하면 OCI Runtime Spec의 Prestart Hook에 nvidia-container-runtime-hook CLI를 실행하기 위한 설정 내용이 추가된다. Prestart Hook의 Argument는 prestart로 고정되며, Container의 Env에는 NVIDIA GPU, CUDA 관련 설정 정보를 저장한다. 예를 들어 "NVIDIA_VISIBLE_DEVICES" 환경 변수의 경우 Container에게 노출될 NVIDIA GPU의 지정하는 환경 변수이다. [그림 1]의 경우에서는 Docker에서 모든 NVIDIA GPU를 이용하도록 "--gpu all" 설정을 수행하였기 때문에 "NVIDIA_VISIBLE_DEVICES" 환경 변수에도 "all"이 설정된다.

![[그림 2] NVIDIA GPU Container Init]({{site.baseurl}}/images/theory_analysis/Container_NVIDA_GPU/Container_Init.PNG){: width="700px"}

[그림 2]는 [그림 1]에 생성된 OCI Runtime Spec을 바탕으로 runc가 Container를 생성하는 과정을 나타내고 있다. runc는 Container를 위한 Namespace 생성 및 rootfs을 설정하기 위해 clone()을 통해서 Container Init Process를 생성하고, 생성된 Container Init Process의 PID를 가져온다. 그 후 runc는 OCI Runtime Spec의 Prestart Hook의 내용처럼 nvidia-container-runtime-hook을 실행한다.

nvidia-container-runtime-hook은 OCI Runtime Spec 파일의 내용을 바탕으로 Container, NVIDIA GPU 정보를 다시 nvidia-container-cli의 **Parameter**로 넘겨 nvidia-container-cli을 실행한다. nvidia-container-cli가 Container의 NVIDIA GPU를 실제로 설정하는 주체이고, nvidia-container-runtime-hook은 OCI Runtime Spec과 nvidia-container-cli 사이를 연결해주는 **Interface 역할**만을 수행한다. nvidia-container-cli는 전달받은 정보를 바탕으로 Device Node를 생성하고 NVIDIA GPU 구동을 위한 Kernel Module도 Loading을 수행한다.

{% highlight console %}
# ls -l /dev
...
crw-rw-rw- 1 root root 510,   0 Feb 11 15:41 nvidia-uvm
crw-rw-rw- 1 root root 510,   1 Feb 11 15:41 nvidia-uvm-tools
crw-rw-rw- 1 root root 195,   0 Feb 11 15:41 nvidia0
crw-rw-rw- 1 root root 195,   1 Feb 11 15:41 nvidia1
crw-rw-rw- 1 root root 195,   2 Feb 11 15:41 nvidia2
crw-rw-rw- 1 root root 195,   3 Feb 11 15:41 nvidia3
crw-rw-rw- 1 root root 195, 255 Feb 11 15:41 nvidiactl
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 1] Device Node List in NVIDIA GPU Container</figcaption>
</figure>

[Console 1]은 4개의 NVIDIA GPU가 이용 가능한 Container 내부에서의 Device Node List를 나타내고 있다.

![[그림 3] NVIDIA GPU Container Stack]({{site.baseurl}}/images/theory_analysis/Container_NVIDA_GPU/Container_Stack.PNG){: width="700px"}

[그림 3]은 NVIDIA GPU 설정이 완료된 Container들을 나타내고 있다. Host는 4개의 NVIDIA GPU를 갖고 있어 4개의 Device Node File을 갖고 있다. Container A는 0,1번째 NVIDIA GPU, Container B는 0,2,3번째 NVIDIA GPU, Container C는 3번째 NVIDIA GPU를 이용하고 있다. 하나의 NVIDIA GPU가 여러 Process들에 의해서 공유가 가능한 것 처럼, 여러 Container가 하나의 NVIDIA GPU를 공유하여 이용할 수 있다. 이 경우 다수의 Process가 하나의 NVIDIA GPU를 공유해서 이용하는 것과 동일하게 CUDA의 MPS (Multi Process Service) 기능을 활용해야 한다.

### 2. 참조

* [https://devblogs.nvidia.com/gpu-containers-runtime/](https://devblogs.nvidia.com/gpu-containers-runtime/)
* [https://gitlab.com/nvidia/container-toolkit/toolkit](https://gitlab.com/nvidia/container-toolkit/toolkit)
* [https://gitlab.com/nvidia/container-toolkit/libnvidia-container/](https://gitlab.com/nvidia/container-toolkit/libnvidia-container/)
* [https://github.com/opencontainers/runtime-spec/blob/master/config.md#posix-platform-hooks](https://github.com/opencontainers/runtime-spec/blob/master/config.md#posix-platform-hooks)
* [https://docs.nvidia.com/deploy/pdf/CUDA_Multi_Process_Service_Overview.pdf](https://docs.nvidia.com/deploy/pdf/CUDA_Multi_Process_Service_Overview.pdf)