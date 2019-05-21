---
title: Kubernetes istio 설치 - Ubuntu_18.04
category: Record
date: 2019-05-19T12:00:00Z
lastmod: 2019-05-19T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

* Kubernetes 1.12
  * Network Addon - cilium 이용
* Helm
  * Client - v2.13.1
  * Server - v2.13.1
* istio 1.1.7

### 2. istio 설치

* istio를 Download한다.

~~~
# curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.1.7 sh -
# cd istio-1.1.7
~~~

* Helm을 이용하여 istio를 설치한다.

~~~
# helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system
~~~

* istio CRD (Custom Resource Definition)을 확인하여 istio 설치를 확인한다.

~~~
# kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l
53
~~~

### 3. 참조

* [https://istio.io/docs/setup/kubernetes/install/helm/](https://istio.io/docs/setup/kubernetes/install/helm/)