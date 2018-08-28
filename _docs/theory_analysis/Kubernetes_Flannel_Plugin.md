---
title: Kubernetes flannel Plugin
category: Theory, Analysis
date: 2018-08-08T12:00:00Z
lastmod: 2018-08-08T12:00:00Z
comment: true
adsense: true
---

Kubernetes Network Plugin인 flannel를 분석한다.

### 1. flannel

flannel은 Kubernetes를 위해서 L3 Network를 구축해주는 Plugin이다.

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_Flannel_Plugin/Flannel_Components.PNG){: width="500px"}

위의 그림은 flannel의 구성요소를 나타낸다. 크게 **etcd, flanneld** 2가지로 구성되어 있다. etcd는 Kubernete Master Node에서 Container로 동작한다. flanneld는 모든 Kubernetes Node 위에서 동작하는 flanneld Container d안에서 동작한다. calico-node container는 Node(Host)의 Network Namespace를 이용하기 때문에 calico-node container안에서 동작하는 App은 Node의 Network 설정을 조회하거나 제어 할 수 있다.

* etcd - etcd는 분산 Key-Value store이다. Calico 구동에 필요한 Network 구성/설정 정보, Calico 설정 정보 등 다양한 정보를 저장한다. 또한 저장한 key-value값이 변경될 경우 flanneld에게 변경 정보를 전달하는 Communication Bus 역활도 수행한다.

* flanneld - flanneld는 Node의 Network를 설정하는 Daemon이다. etcd에 저장되어 있는 Network 설정 정보를 바탕으로 Node의 Network Inteface, Route Table, iptables을 설정하여 Packet이 올바른 Container로 Routing 되게 한다.

#### 1.1. host-gw

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_flannel_Plugin/Flannel_Network_Host_GW.PNG)

flannel은 Container은 구축하는 하나의 기법으로 host-gw 기법을 제공한다. host-gw 기법은 의미 그대로 host를 gateway로 이용하는 기법이다. 위의 그림은 flannel이 host-gw 기법을 이용하여 설정한 Network를 나타내고 있다. Node의 Network는 10.0.0.0/24이고, Container Network는 10.244.0.0/16이다.

flanneld는 etcd에 저장된 정보를 바탕으로 각 Node에 Container Network를 할당한다. 그림에서 Node1에는 10.244.1.0/24 Network가 할당되었다. 따라서 Node 1에 생긴 Container A의 IP는 10.244.1.0/24 Network에 속한 IP인 10.244.1.2를 이용한다. Node 2에는 10.244.2.0/24 Network가 할당 되었기 때문에 Node 2에 생긴 Container B의 IP는 10.244.2.0/24 Network에 속한 10.244.2.2를 이용한다. Node 1에는 Node 2의 Container Network에 대해서 Node 2의 IP로 Default GW가 설정되어 있다. Node 2에서는 Node 1의 Container Network에 대해서 Node1의 Node IP로 Default GW가 설정되어 있다.

Container A에서 Dest IP가 10.244.2.2인 Packet을 전송하면 Packet은 vethxxx와 cni Bridge를 지난뒤 Host의 Routing Table에 따라서 다시 Routing된다. Packet의 Dest IP는 10.244.2.0/24 Network에 속하기 때문에 Packet은 Node 2의 IP인 10.0.0.30으로 Forwarding되어 Node 2에게 전달된다. 그 후 Packet은 Node 2의 Routing Table에 따라서 cni0에게 전달되고 다시 Container B에게 전달된다.

#### 1.2. VXLAN

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_flannel_Plugin/Flannel_Network_VXLAN.PNG)

flannel은 Container은 구축하는 하나의 기법으로 VXLAN 기법을 제공한다. VXLAN 기법은 의미 그대로 VXLAN을 이용하는 기법이다. 위의 그림은 flannel이 VXLAN 기법을 이용하여 설정한 Network를 나타내고 있다. Node의 Network는 10.0.0.0/24이고, Container Network는 10.244.0.0/16이다.

### 2. 참조

* [https://github.com/coreos/flannel](https://github.com/coreos/flannel)
* [https://blog.laputa.io/kubernetes-flannel-networking-6a1cb1f8ec7c](https://blog.laputa.io/kubernetes-flannel-networking-6a1cb1f8ec7c)
* [https://github.com/coreos/flannel/blob/master/Documentation/backends.md](https://github.com/coreos/flannel/blob/master/Documentation/backends.md)
* [https://docs.openshift.com/container-platform/3.4/architecture/additional_concepts/flannel.html](https://docs.openshift.com/container-platform/3.4/architecture/additional_concepts/flannel.html)
