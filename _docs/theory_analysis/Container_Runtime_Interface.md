---
title: Container Runtime Interface (CRI)
category: Theory, Analysis
date: 2020-08-03T12:00:00Z
lastmod: 2020-08-03T12:00:00Z
comment: true
adsense: true
---

Container Runtime Interface (CRI)를 분석한다.

### 1. Container Runtime Interface (CRI)

![[그림 1] CRI]({{site.baseurl}}/images/theory_analysis/Container_Runtime_Interface/CRI.PNG){: width="350px"}

Container Runtime Interface (CRI)는 Kubernetes의 Component 중에서 kubelet과 Container Runtime 사이의 정의된 Interface를 의미한다. kubelet은 Kubernetes Cluster의 모든 Node에서 동작하며, Container Runtime을 이용하여 Node의 Container를 관리하는 역활을 수행한다. [그림 1]은 CRI를 나타내고 있다. CRI는 gRPC를 이용하여 통신한다. CRI를 지원하는 Container Runtime의 경우에는 kubelet으로부터 바로 명령을 받아서 Container를 제어한다. CRI를 지원하지 않는 Container Runtime의 경우에는 CRI Shim이라는 Layer를 통해서 kubelet에 연결할 수 있다.

Docker Container Runtime의 경우에는 CRI를 지원하지 않는다. 따라서 kubelet은 Kubernetes에서 개발한 **dockershim**이라고 불리는 CRI shim 통해서 Docker Container를 제어한다. containerd Container Runtime의 경우에는 내부적으로 **CRI Plugin**을 통해서 CRI를 지원한다. **crictl** 명령어는 CRI를 통해서 containerd를 제어할때 이용하는 명령어이다.

#### 1. Interface

{% highlight console %}
service RuntimeService {
    rpc RunPodSandbox(RunPodSandboxRequest) returns (RunPodSandboxResponse) {}
    rpc StopPodSandbox(StopPodSandboxRequest) returns (StopPodSandboxResponse) {}
    rpc RemovePodSandbox(RemovePodSandboxRequest) returns (RemovePodSandboxResponse) {}
    rpc PodSandboxStatus(PodSandboxStatusRequest) returns (PodSandboxStatusResponse) {}
    rpc ListPodSandbox(ListPodSandboxRequest) returns (ListPodSandboxResponse) {}

    rpc CreateContainer(CreateContainerRequest) returns (CreateContainerResponse) {}
    rpc StartContainer(StartContainerRequest) returns (StartContainerResponse) {}
    rpc StopContainer(StopContainerRequest) returns (StopContainerResponse) {}
    rpc RemoveContainer(RemoveContainerRequest) returns (RemoveContainerResponse) {}
    rpc ListContainers(ListContainersRequest) returns (ListContainersResponse) {}
    rpc ContainerStatus(ContainerStatusRequest) returns (ContainerStatusResponse) {}
    rpc UpdateContainerResources(UpdateContainerResourcesRequest) returns (UpdateContainerResourcesResponse) {}
    rpc ReopenContainerLog(ReopenContainerLogRequest) returns (ReopenContainerLogResponse) {}

    rpc ExecSync(ExecSyncRequest) returns (ExecSyncResponse) {}
    rpc Exec(ExecRequest) returns (ExecResponse) {}
    rpc Attach(AttachRequest) returns (AttachResponse) {}
    rpc PortForward(PortForwardRequest) returns (PortForwardResponse) {}
}

service ImageService {
    rpc ListImages(ListImagesRequest) returns (ListImagesResponse) {}
    rpc ImageStatus(ImageStatusRequest) returns (ImageStatusResponse) {}
    rpc PullImage(PullImageRequest) returns (PullImageResponse) {}
    rpc RemoveImage(RemoveImageRequest) returns (RemoveImageResponse) {}
    rpc ImageFsInfo(ImageFsInfoRequest) returns (ImageFsInfoResponse) {}
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] CRI protobuf</figcaption>
</figure>

[파일 1]은 CRI의 protobuf 파일의 일부를 나타내고 있다. protobuf 파일을 통해서 CRI가 어떠한 Interface를 정의하고 있는지 파악할 수 있다. Runtime Service에는 Container 그리고 Container의 집합인 Pod을 관리하는 함수들을 확인할 수 있다. Image Service에서는 Container Image를 관리하는 함수들을 확인할 수 있다.

### 2. 참고

* [https://kubernetes.io/blog/2016/12/container-runtime-interface-cri-in-kubernetes/](https://kubernetes.io/blog/2016/12/container-runtime-interface-cri-in-kubernetes/)
* [https://github.com/kubernetes/cri-api/blob/master/pkg/apis/runtime/v1alpha2/api.proto](https://github.com/kubernetes/cri-api/blob/master/pkg/apis/runtime/v1alpha2/api.proto)