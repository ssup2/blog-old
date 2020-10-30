---
title: Kubernetes Service Delay with iptables "--random-fully" Option
category: Issue
date: 2020-10-25T12:00:00Z
lastmod: 2020-10-25T12:00:00Z
comment: true
adsense: true
---

### 1. Issue

Kubernetes 1.16부터 KUBE-POSTROUTING NAT Chain에 추가된 iptables의 "--random-fully" Option으로 인해서, Kubernetes Cluster가 VXLAN을 이용하는 CNI Plugin을 이용하는 경우 Service의 ClusterIP로 전송하는 Packet이 Delay가 발생하는 Issue가 존재한다.

### 2. 배경 지식

### 3. 원인

### 4. 해결 방안

### 5. 참조

* [https://github.com/kubernetes/kubernetes/pull/92035](https://github.com/kubernetes/kubernetes/pull/92035)
* [https://github.com/kubernetes/kubernetes/issues/90854](https://github.com/kubernetes/kubernetes/issues/90854)
* [https://tech.xing.com/a-reason-for-unexplained-connection-timeouts-on-kubernetes-docker-abd041cf7e02](https://tech.xing.com/a-reason-for-unexplained-connection-timeouts-on-kubernetes-docker-abd041cf7e02)
* [https://github.com/kubernetes/kubernetes/pull/78547](https://github.com/kubernetes/kubernetes/pull/78547)

