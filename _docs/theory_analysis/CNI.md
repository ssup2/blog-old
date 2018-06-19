---
title: CNI (Container Network Interface)
category: Theory, Analysis
date: 2017-06-20T12:00:00Z
lastmod: 2017-06-20T12:00:00Z
comment: true
adsense: true
---

Container Network 설정시 이용되는 CNI (Container Network Interface)를 분석한다.

### 1. CNI (Container Network Interface)

CNI는 Linux Container의 **Network 설정 Specification**을 의미한다. Kubernetes, rkt, Openshift같은 많은 **Container Runtime**들이 CNI를 이용하고 있다. Container Runtime은 CNI에 맞추어 Container에 설정할 Network 정보를 설정한다. 그 후 CNI Plugin은 CNI에 맞추어 Container의 Network를 설정한다. 현재 다양한 CNI Plugin들이 존재하고 있다. Container Runtime은 CNI Plugin의 교체만으로 다양한 형태의 Container Network를 설정할 수 있다.

#### 1.1. CNI Spec

#### 1.2. Example

### 2. 참조

* [https://github.com/containernetworking/cni](https://github.com/containernetworking/cni)
* [https://github.com/containernetworking/cni/blob/master/SPEC.md](https://github.com/containernetworking/cni/blob/master/SPEC.md)
* [https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)
