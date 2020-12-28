---
title: Kubernetes istio 1.1 설치 / Ubuntu 18.04 환경
category: Record
date: 2019-05-19T12:00:00Z
lastmod: 2019-05-19T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

설치 환경은 다음과 같다.
* Kubernetes 1.18.3
  * Network Addon : cilium 이용
* istio 1.8.1

### 2. istio 설치

~~~console
# curl -L https://istio.io/downloadIstio | sh -
# cd istio-1.8.1
~~~

istioctl을 설정한다.

~~~console
# export PATH=$PWD/bin:$PATH
~~~

Helm을 이용하여 istio를 설치한다.

~~~console
# istioctl install --set profile=demo -y

# kubectl -n istio-system get pod
NAME                                    READY   STATUS    RESTARTS   AGE
istio-egressgateway-6f9f4ddc9c-2qggk    1/1     Running   0          2m14s
istio-ingressgateway-78b47bc88b-lvxj2   1/1     Running   0          2m14s
istiod-67dbfcd4dd-b2dtc                 1/1     Running   0          2m16s

# kubectl -n istio-system get service
NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                                                                      AGE
istio-egressgateway    ClusterIP      10.110.33.89    <none>         80/TCP,443/TCP,15443/TCP                                                     2m21s
istio-ingressgateway   LoadBalancer   10.109.246.4    192.168.0.82   15021:31021/TCP,80:31546/TCP,443:30724/TCP,31400:31073/TCP,15443:30737/TCP   16m
istiod                 ClusterIP      10.105.57.203   <none>         15010/TCP,15012/TCP,443/TCP,15014/TCP                                        16m
~~~

istio 설치를 확인한다.

### 3. 참조

* [https://istio.io/docs/setup/kubernetes/install/helm/](https://istio.io/docs/setup/kubernetes/install/helm/)