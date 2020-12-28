---
title: Kubernetes istio 1.8 설치 / Ubuntu 18.04 환경
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

istio를 Download한다.

~~~console
# export PATH=$PWD/bin:$PATH
~~~

istioctl을 설정한다.

~~~console
# istioctl install --set profile=demo -y

# kubectl -n istio-system get pod
NAME                                    READY   STATUS    RESTARTS   AGE
istio-egressgateway-6f9f4ddc9c-2qggk    1/1     Running   0          16m
istio-ingressgateway-78b47bc88b-lvxj2   1/1     Running   0          16m
istiod-67dbfcd4dd-b2dtc                 1/1     Running   0          16m

# kubectl -n istio-system get service
NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                                                                      AGE
istio-egressgateway    ClusterIP      10.110.33.89    <none>         80/TCP,443/TCP,15443/TCP                                                     16m
istio-ingressgateway   LoadBalancer   10.109.246.4    192.168.0.82   15021:31021/TCP,80:31546/TCP,443:30724/TCP,31400:31073/TCP,15443:30737/TCP   16m
istiod                 ClusterIP      10.105.57.203   <none>         15010/TCP,15012/TCP,443/TCP,15014/TCP                                        16m
~~~

istio를 설치하고 동작을 확인한다.

~~~console
# kubectl apply -f samples/addons

# kubectl -n istio-system get pod
NAME                                    READY   STATUS    RESTARTS   AGE
grafana-94f5bf75b-q429h                 1/1     Running   0          9m43s
istio-egressgateway-6f9f4ddc9c-2qggk    1/1     Running   0          16m
istio-ingressgateway-78b47bc88b-lvxj2   1/1     Running   0          16m
istiod-67dbfcd4dd-b2dtc                 1/1     Running   0          16m
jaeger-5c7675974-p8hs2                  1/1     Running   0          9m43s
kiali-667b888c56-pkzs6                  1/1     Running   0          9m43s
prometheus-7d76687994-l4ntm             2/2     Running   0          9m43s

# kubectl -n istio-system get service
NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                                                                      AGE
grafana                ClusterIP      10.102.101.17   <none>         3000/TCP                                                                     22m
istio-egressgateway    ClusterIP      10.110.33.89    <none>         80/TCP,443/TCP,15443/TCP                                                     43m
istio-ingressgateway   LoadBalancer   10.109.246.4    192.168.0.82   15021:31021/TCP,80:31546/TCP,443:30724/TCP,31400:31073/TCP,15443:30737/TCP   43m
istiod                 ClusterIP      10.105.57.203   <none>         15010/TCP,15012/TCP,443/TCP,15014/TCP                                        43m
jaeger-collector       ClusterIP      10.107.85.228   <none>         14268/TCP,14250/TCP                                                          22m
kiali                  ClusterIP      10.104.186.86   <none>         20001/TCP,9090/TCP                                                           22m
prometheus             ClusterIP      10.99.26.84     <none>         9090/TCP                                                                     22m
tracing                ClusterIP      10.101.35.46    <none>         80/TCP                                                                       22m
zipkin                 ClusterIP      10.97.246.60    <none>         9411/TCP 
~~~

istio Dashboard를 설치하고 동작을 확인한다.

### 3. 참조

* [https://istio.io/docs/setup/kubernetes/install/helm/](https://istio.io/docs/setup/kubernetes/install/helm/)