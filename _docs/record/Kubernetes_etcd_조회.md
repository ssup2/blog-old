---
title: Kubernetes etcd 조회, Backup
category: Record
date: 2019-10-12T12:00:00Z
lastmod: 2019-10-12T12:00:00Z
comment: true
adsense: true
---

### 1. 실행 환경

실행 환경은 다음과 같다.

* Kubernetes 1.15
* etcd 3.3.10

### 2. etcd Key 조회

~~~console
(Node)# kubectl -n kube-system exec -it etcd-vm01 sh
(Container)# ETCDCTL_API=3 etcdctl --endpoints 127.0.0.1:2379 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key get / --prefix --keys-only
/registry/apiextensions.k8s.io/customresourcedefinitions/adapters.config.istio.io

/registry/apiextensions.k8s.io/customresourcedefinitions/apikeys.config.istio.io

/registry/apiextensions.k8s.io/customresourcedefinitions/attributemanifests.config.istio.io

/registry/apiextensions.k8s.io/customresourcedefinitions/authorizations.config.istio.io

/registry/apiextensions.k8s.io/customresourcedefinitions/bypasses.config.istio.io

/registry/apiextensions.k8s.io/customresourcedefinitions/checknothings.config.istio.io
...
~~~

kubectl을 이용하여 etcd Container에 진입한 이후에 etcdctl을 이용하여 Key 조회 명령어를 수행한다. ETCDCTL_API 환경변수를 이용하여 API Version을 반드시 명시해야하고, 인증서 관련 파일도 Option을 통해서 반드시 지정해주어야 한다.

### 3. 참조

* [https://stackoverflow.com/questions/47807892/how-to-access-kubernetes-keys-in-etcd](https://stackoverflow.com/questions/47807892/how-to-access-kubernetes-keys-in-etcd)