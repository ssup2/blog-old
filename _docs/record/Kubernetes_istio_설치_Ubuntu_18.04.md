---
title: Kubernetes istio 설치 / Ubuntu 18.04 환경
category: Record
date: 2019-05-19T12:00:00Z
lastmod: 2019-05-19T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

설치 환경은 다음과 같다.
* Kubernetes 1.12
  * Network Addon : cilium 이용
* Helm
  * Client : v2.13.1
  * Server : v2.13.1
* istio 1.1.7

### 2. istio 설치

~~~console
# curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.1.7 sh -
# cd istio-1.1.7
~~~

istio를 Download한다.

~~~console
# helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system
# helm install install/kubernetes/helm/istio --name istio --namespace istio-system
~~~

Helm을 이용하여 istio를 설치한다.

~~~console
# kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l
53
# kubectl get svc -n istio-system
NAME                     TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                                                                                                                                     AGE
istio-citadel            ClusterIP      10.107.41.179    <none>         8060/TCP,15014/TCP                                                                                                                          95s
istio-galley             ClusterIP      10.108.41.12     <none>         443/TCP,15014/TCP,9901/TCP                                                                                                                  97s
istio-ingressgateway     LoadBalancer   10.105.163.25    172.35.0.201   15020:30578/TCP,80:31380/TCP,443:31390/TCP,31400:31400/TCP,15029:30727/TCP,15030:30464/TCP,15031:30556/TCP,15032:30918/TCP,15443:31746/TCP   96s
istio-pilot              ClusterIP      10.110.136.28    <none>         15010/TCP,15011/TCP,8080/TCP,15014/TCP                                                                                                      95s
istio-policy             ClusterIP      10.96.178.186    <none>         9091/TCP,15004/TCP,15014/TCP                                                                                                                96s
istio-sidecar-injector   ClusterIP      10.110.41.235    <none>         443/TCP                                                                                                                                     95s
istio-telemetry          ClusterIP      10.106.86.30     <none>         9091/TCP,15004/TCP,15014/TCP,42422/TCP                                                                                                      96s
prometheus               ClusterIP      10.107.155.154   <none>         9090/TCP     
# kubectl get pods -n istio-system
NAME                                      READY   STATUS      RESTARTS   AGE
istio-citadel-7f447d4d4b-2nw9v            1/1     Running     0          115s
istio-galley-84749d54b7-9bvxm             1/1     Running     0          115s
istio-ingressgateway-6b79f895d6-xrxk6     0/1     Running     0          115s
istio-init-crd-10-jhzgc                   0/1     Completed   0          4m24s
istio-init-crd-11-h6w6p                   0/1     Completed   0          4m24s
istio-pilot-76899788b6-rjqt8              2/2     Running     0          115s
istio-policy-578bcb878f-k2lxg             2/2     Running     3          115s
istio-sidecar-injector-6895997989-hnd5k   1/1     Running     0          115s
istio-telemetry-5448cbd995-g6wdt          2/2     Running     3          115s
prometheus-5977597c75-xgkvz               1/1     Running     0          115s
~~~

istio 설치를 확인한다.

### 3. 참조

* [https://istio.io/docs/setup/kubernetes/install/helm/](https://istio.io/docs/setup/kubernetes/install/helm/)