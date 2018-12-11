---
title: Kubernetes, Helm 설치, 실행 - Ubuntu_18.04
category: Record
date: 2018-12-11T12:00:00Z
lastmod: 2018-12-11T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

* VirtualBox 5.0.14r
  * Master Node - Ubuntu Desktop 18.04.1 64bit - 1대
  * Worker Node - Ubuntu Server 18.04.1 64bit - 2대
* Kubernetes 1.12
  * Network Addon - cilium 이용

### 2. Helm 설치

* Helm 설치

~~~
# kubectl create serviceaccount --namespace kube-system tiller
# kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
# helm init --service-account tiller
~~~

### 3. 참조

* Helm Issue - [https://github.com/helm/helm/issues/3055](https://github.com/helm/helm/issues/3055)