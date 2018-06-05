---
title: Kubernetes Pod
category: Theory, Analysis
date: 2018-06-05T12:00:00Z
lastmod: 2018-06-05T12:00:00Z
comment: true
adsense: true
---

Kubernetes Pod을 분석한다.

### 1. Pod

Pod은 Kubernetes에서 이용하는 **Container 관리 단위**이다. Kubernetes는 Pod 단위로 Scheduling을 및 Load Balancing을 수행한다. 대부분의 Pod은 하나의 Container로 구성되어 있지만 다수의 Container로도 구성 될 수 있다. 이러한 Pod을 Multi-container Pod이라고 표현한다. Multi-container Pod의 Container들은 같은 Network Namespace와 IPC Namespace를 공유한다. 또한 같은 Volume(Storage)를 공유한다.

#### 1.1. Namespace

#### 1.2. Resource Manage (Cgroup)

##### 1.2.1. CPU

##### 1.2.2. Memory

#### 1.3. Life Cycle

### 2. 참조

* [https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/)
* [https://www.mirantis.com/blog/multi-container-pods-and-container-communication-in-kubernetes/](https://www.mirantis.com/blog/multi-container-pods-and-container-communication-in-kubernetes/)
