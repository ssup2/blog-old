---
title: Kubernetes Architecture
category: Theory, Analysis
date: 2019-05-06T12:00:00Z
lastmod: 2019-05-06T12:00:00Z
comment: true
adsense: true
---

Kubernetes Architecture를 분석한다.

### 1. Kubernetes Architecture

![[그림 1] Kubernetes Architecture]({{site.baseurl}}/images/theory_analysis/Kubernetes_Architecture/Kubernetes_Architecture.PNG){: width="700px"}

[그림 1]은 Kubernetes Architecture를 나타내고 있다. Kubernetes는 Kubernetes를 관리하는 Master Node와 배포된 Application이 동작하는 Worker Node로 구성되어 있다. Kubernetes의 설정에 따라서 Master Node는 Worker Node의 역활도 수행할 수 있다.

#### 1.1. Master Node

Master Node는 Kubernetes Cluster를 관리하는 Node이다. HA (High Availability)를 위해서 일반적으로 다수의 홀수개의 Master Node를 이용한다. Master Node에는 etcd, kube-apiserver, kube-scheduler, kube-controller-manager가 동작한다.

* etcd - etcd는 분산 key-value storage로 **Kuberetes Cluster 관련 Data를 저장**하고 있다. 다수의 Master Node가 동작하는경우 etcd들은 etcd Cluster를 구성하여 동작하며, etcd Cluster의 etcd 사이의 Data Consistency는 Raft 알고리즘을 통해서 유지된다. etcd는 Data가 변경될 경우 해당 Data를 감시하고 있는 Client에게 Data 변경 Event를 전달하는 Watcher 기능을 제공한다. 이러한 Watcher 기능을 이용하여 Kubernetes Cluster는 etcd Cluster를 **Event Bus**처럼 이용하기도 한다.

* kube-apiserver - Kubernetes를 제어하는 REST API를 제공하는 Server이다. 또한 etcd와 통신하는 유일한 구성요소이다. 따라서 etcd에 Kubernetes Cluster 관련 Data를 저장하거나, etcd의 Data 변경 Event를 수신하기 위해서는 반드시 kube-apiserver를 이용해야 한다. [그림 1]에서 Kubernetes 대부분의 구성요소가 kube-apiserver와 통신하는것을 확인할 수 있다.

* kube-controller-manager - Kubernetes에서는 Kubernetes가 정의하는 yaml 문법을 통해 생성하는 객체를 **Object**라고 정의한다. Pod, Deployments, Statefulset, Configmap 등이 Object의 예가 된다. 그리고 이러한 Object를 제어하는 구성요소를 **Controller**라고 정의한다. kube-controller-manager는 이러한 Controller들을 관리한다. Controller는 kube-apiserver를 통해서 제어하려는 Object의 상태정보를 얻어오고, 얻은 상태정보를 바탕으로 다시 kube-apiserver를 통해서 Object를 제어한다.

* kube-scheduler - Pod의 Scheduling을 담당한다. kube-scheduler는 kube-apiserver를 통해서 각 Worker Node의 Pod의 상태 및 Resource 상태 정보를 얻어오고, 얻은 상태정보를 바탕으로 다시 kube-apiserver를 통해서 Pod Scheduling을 수행한다.

#### 1.2. Worker Node

Worker Node는 Kubernetes 사용자가 배포한 Application이 동작하는 Node이다. Worker Node에는 kubelet, kube-proxy, coredns, Network Daemon이 동작한다.

* kubelet - 

* kube-proxy

* coredns -

* Network Daemon -

* CNI Plugin -

### 2. 참조

* [https://www.aquasec.com/wiki/display/containers/Kubernetes+Architecture+101]
(https://www.aquasec.com/wiki/display/containers/Kubernetes+Architecture+101)