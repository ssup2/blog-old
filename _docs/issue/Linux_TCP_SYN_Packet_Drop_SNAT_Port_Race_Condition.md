---
title: Linux TCP SYN Packet Drop with SNAT Port Race Condition
category: Issue
date: 2020-10-25T12:00:00Z
lastmod: 2020-10-25T12:00:00Z
comment: true
adsense: true
---

### 1. Issue

TCP Connection을 맺기 위해서 TCP SYN Packet을 SNAT하여 전송시, SNAT를 진행하면서 TCP SYN Packet에 설정되는 Src Port를 선택하는 과정에서 발생하는 Race Condition에 의해서 TCP SYN Packet이 Drop 되는 Issue가 존재한다. 본 이슈로 인해서 Client가 전송한 TCP SYN Packet이 Drop되면 Client는 Timeout을 경험하게 된다. 

대부분의 Docker Container 내부에서 Docker Host 외부의 Server와 TCP Connection을 맺는 경우, Docker Container가 전송한 TCP SYN Packet은 Docker Host에서 SNAT 되어 외부로 전송되기 때문에 본 Issue로 인해서 TCP SYN Packet이 Drop 될 수 있다. 이와 유사하게 대부분의 Kubernetes Pod의 Container 내부에서 Kubernetes Cluster 외부의 Server와 TCP Connection을 맺는 경우, Kubernetes Pod의 Container가 전송한 TCP SYN Packet은 SNAT 되어 외부로 전송되기 때문에 본 Issue로 인해서 TCP SYN Packet이 Drop 될 수 있다.

### 2. 원인

### 3. 해결 방안

### 4. with Kubernetes

### 5. 참조

* [https://tech.xing.com/a-reason-for-unexplained-connection-timeouts-on-kubernetes-docker-abd041cf7e02](https://tech.xing.com/a-reason-for-unexplained-connection-timeouts-on-kubernetes-docker-abd041cf7e02)
* [https://github.com/kubernetes/kubernetes/pull/78547](https://github.com/kubernetes/kubernetes/pull/78547)
