---
title: Container Storage Interface (CSI)
category: Theory, Analysis
date: 2019-10-17T12:00:00Z
lastmod: 2019-10-17T12:00:00Z
comment: true
adsense: true
---

Container Storage 설정시 이용되는 Container Storage Interface (CSI)를 분석한다.

### 1. Container Storage Interface (CSI)

![[그림 1] CSI]({{site.baseurl}}/images/theory_analysis/Container_Storage_Interface/CSI.PNG){: width="350px"}

Container Storage Interface (CSI)는 Kubernetes, Mesos같은 Container Orchestration System (CO)와 Storage를 제어하는 Plugin (Storage Controller) 사이의 Interface를 의미한다. [그림 1]은 CSI를 나타내고 있다. CSI는 다음과 같이 3가지를 정의한다.

* Storage를 제어하는 Plugin
* Storage(Volume)의 Life Cycle
* CO와 Plugin 사이의 Interface

#### 1.1. Plugin

Plugin은 CO의 명령에 따라서 Storage를 제어하는 Storage Controller를 의미한다. Plugin은 **Controller Plugin**과 **Node Plugin**으로 구분된다. Controller Plugin은 어느 Node에서 동작해도 관계없는 Plugin을 의미한다. Storage 중앙 관리 기능은 Controller Plugin이 수행한다. Node Plugin은 Container가 동작하는 모든 Node에서 동작하는 Plugin을 의미한다. 특정 Node를 제어하는 역활은 Node Plugin이 수행한다.

CSI에서 Controller Plugin과 Node Plugin의 구성 및 배치는 비교적 자유롭게 열어두었다. CSI는 Controller Plugin과 Node Plugin을 구분하였지만, 하나의 Program으로 구성될수도 있다고 정의하고 있다. 심지어 Controller Plugin이 존재하지 않고 Node Plugin으로만 구성할 수 있다고 정의하고 있다. CSI는 Plugin의 Life Cycle은 정의하지 않는다.

#### 1.2. Volume(Storage) Lifecycle

![[그림 2] CSI Volume Lifecycle]({{site.baseurl}}/images/theory_analysis/Container_Storage_Interface/CSI_Volume_Lifecycle.PNG){: width="400px"}

CSI는 Storage의 Lifecycle을 정의하고 있다. CSI에서는 Storage Lifecycle이란 단어 대신 Volume Lifecycle이란 단어를 이용하고 있다. CSI는 하나의 Volume Lifecycle만을 정의하지 않고 다수의 Life Cycle을 정의하고 있는데, 다양한 Storage의 특성 및 구성 환경을 충족시키기 위해서이다. [그림 2]는 CSI에서 정의하는 Volume Lifecycle중 가장 긴 Lifecycle을 나타내고 있다.

#### 1.3. Interface

CSI는 정의한 Plugin과 Volume Lifecycle을 바탕으로 CO와 Plugin 사이의 Interface를 정의한다. Inteface는 gRPC를 기반으로 구성되어 있다. Interface는 **Identity Service**, **Controller Service**, **Node Service**로 구분되어 있다. Identity Service는 Controller Plugin과 Node Plugin이 공통으로 이용하는 Interface이다. Controller Service는 Controller Plugin이 이용하는 Interface이고, Node Service는 Node Plugin이 이용하는 Interface이다. Interface 목차는 아래와 같다.

* Identity Service
  * GetPluginInfo
  * GetPluginCapabilities
  * Probe

* Controller Service
  * CreateVolume
  * DeleteVolume
  * ControllerPublishVolume
  * ControllerUnpublishVolume
  * ValidateVolumeCapabilities
  * ListVolumes 
  * GetCapacity 
  * ControllerGetCapabilities 
  * CreateSnapshot 
  * DeleteSnapshot 
  * ListSnapshots 
  * ControllerExpandVolume 

* Node Service
  * NodeStageVolume
  * NodeUnstageVolume
  * NodePublishVolume 
  * NodeUnpublishVolume 
  * NodeGetVolumeStats 
  * NodeExpandVolume
  * NodeGetCapabilities 
  * NodeGetInfo 

Interface 목차를 통해서 Identiy Service는 Plug 관련 Interface, Controller Service는 Volume 관리 및 Snapshot 관리 Interface, Node Service는 Node 관리 Interface인걸 알 수 있다. 각 Interface는 Request/Response를 정의하는 형태로 구성되어 있다. 또한 CSI는 Error Code 및 Sercet 규칙도 정의하고 있다.

### 2. 참조

* [https://github.com/container-storage-interface/spec/blob/master/spec.md](https://github.com/container-storage-interface/spec/blob/master/spec.md)
* [https://kubernetes-csi.github.io/docs/](https://kubernetes-csi.github.io/docs/)
* [https://medium.com/google-cloud/understanding-the-container-storage-interface-csi-ddbeb966a3b](https://medium.com/google-cloud/understanding-the-container-storage-interface-csi-ddbeb966a3b)
