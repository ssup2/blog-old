---
title: Kubernetes PKI (Public Key Infrastructure)
category: Theory, Analysis
date: 2020-03-12T12:00:00Z
lastmod: 2020-03-12T12:00:00Z
comment: true
adsense: true
---

Kubernetes PKI (Public Key Infrastructure)를 분석한다.

### 1. Kubernetes PKI

![[그림 1] Kubernetes Certificate, Key with kubeadm]({{site.baseurl}}/images/theory_analysis/Kubernetes_PKI/Kubernetes_Cert_Key.PNG)

Kubernetes Component들은 서로간 통신시 TLS를 이용하여 암호화 한다. [그림 1]은 kubeadm을 이용하여 Kubernetes Cluster 구성시 Kubernetes에서 TLS를 위해서 이용하는 Certificate와 Key를 나타내고 있다. 모든 Certificate는 Private CA (Certificate Authority)를 이용하여 생성한다. [그림 1]의 Tree 관계에 있는 Certificate, Key는 Chain of Trust를 나타내고 있다. sa.pub,key는 인증서를 의미하지 않고, Private/Public Key 한쌍을 의미하며, CA가 존재하지 않는다.

![[그림 2] Kubernetes PKI with kubeadm]({{site.baseurl}}/images/theory_analysis/Kubernetes_PKI/Kubernetes_PKI.PNG)

[그림 2]는 [그림 1]의 Cetificate와 Key를 바탕으로 kubeadm을 이용하여 구성한 Kubernetes의 PKI를 나타내고 있다. Non-bold로 표시된 Certificate, Key는 Cluster 내에서 모두 동일한 Certificate, Key를 의미한다. 예를 들어 [그림 2]에서 Kuberenetes API Server의 etcd/ca.crt와 etcd Server의 etcd/ca.crt는 동일한 Certificate를 나타낸다. Bold로 표시된 Certifcate, Key는 각 Instance/File 마다 다른 Certifcate, Key를 의미한다. 예를 들어 [그림 2]에서 etcd Server의 etcd/peer.crt,key는 각 etcd Server마다 다르다는 것을 의미한다.

etcd Server에는 etcd/peer.crt,key와 etcd/server.crt,key를 이용한다. etcd/peer.crt,key는 Cluster내의 etcd Server 사이의 통신에 이용한다. etcd/server.crt,key는 etcd Server의 Certificate, Key 역활을 수행하며 etcd의 Client인 etcdctl 또는 Kubernetes API Server와의 통신시에 이용한다. etcdctl은 etcd Server에 연결시 etcd/healthcheck-client.crt,key를 이용한다.

etcd Server를 제외한 나머지 Kubernetes Component들은 ca.crt를 기반으로 생성된 client.crt,key를 이용하여 apiserver.crt,key를 이용하는 Kubernetes API Server와 통신한다. Kubernetes API Server는 kubelet에 연결시 apiserver-kublet-client.crt,key를 이용하고, Kubernetes 사용자가 정의하는 Kubernetes Extention API Server에 연결시 front-proxy-client.crt,key 파일을 이용한다. kubelet은 스스로 생성한 kubelet.crt,key를 이용하여 Server 역활을 수행한다. Kubernetes Scheduler, Controller Manager도 Memory에 스스로 생성한 Certificate, Key를 이용하여 Server 역활을 수행한다.

sa.pub,key는 Kubernetes의 Service Account Token을 암호화/복호화 하는데 이용된다. Service Account Token은 Kubernetes Controller Manager에서 암호화 되며 Kubernetes API Server에서 복호화 된다.

### 2. 참고

* [https://kubernetes.cn/docs/setup/best-practices/certificates/](https://kubernetes.cn/docs/setup/best-practices/certificates/)
* [https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/)
* [https://kubernetes.io/docs/tasks/access-kubernetes-api/configure-aggregation-layer/](https://kubernetes.io/docs/tasks/access-kubernetes-api/configure-aggregation-layer/)
* [https://github.com/kubernetes-sigs/apiserver-builder-alpha](https://github.com/kubernetes-sigs/apiserver-builder-alpha)