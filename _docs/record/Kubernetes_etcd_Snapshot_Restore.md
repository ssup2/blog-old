---
title: Kubernetes etcd Snapshot, Restore
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

### 2. etcd Snapshot

~~~console
(Node)# kubectl -n kube-system exec -it etcd-vm01 sh
(Container)# ETCDCTL_API=3 etcdctl --endpoints 127.0.0.1:2379 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernete
s/pki/etcd/server.key snapshot save snap
Snapshot saved at snap
~~~

kubectl을 이용하여 etcd Container에 진입한 이후, etcdctl을 이용하여 Snapshot을 수행한다. Snapshot File의 이름은 snap으로 설정하였다. ETCDCTL_API 환경변수를 이용하여 API Version을 반드시 명시해야하고, 인증서 관련 파일도 Option을 통해서 반드시 지정해주어야 한다.

~~~console
(Container)# ETCDCTL_API=3 etcdctl --endpoints 127.0.0.1:2379 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernete
s/pki/etcd/server.key snapshot status snap
57da4498, 1915062, 2013, 9.3 MB
~~~

etcdctl을 이용하여 Snapshot File의 상태를 파악한다.

### 3. etcd Restore

~~~console
(Node)# kubectl -n kube-system exec -it etcd-vm01 sh
(Container)# ETCDCTL_API=3 etcdctl --endpoints 127.0.0.1:2379 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernete
s/pki/etcd/server.key snapshot restore snap --data-dir="/var/lib/etcd"
~~~

Snapshot File을 통해서 etcd를 복구한다.

### 4. 참조

* [https://stackoverflow.com/questions/47807892/how-to-access-kubernetes-keys-in-etcd](https://stackoverflow.com/questions/47807892/how-to-access-kubernetes-keys-in-etcd)