---
title: Kubernetes Calico Plugin
category: Theory, Analysis
date: 2018-07-25T12:00:00Z
lastmod: 2018-07-25T12:00:00Z
comment: true
adsense: true
---

Kubernetes Network Plugin인 Calico를 분석한다.

### 1. Calico

Calico는 Container, VM 환경에서 **L3기반** Virtual Network를 구축하게 도와주는 Tool이다. Calico는 **CNI (Container Network Inteface)**를 지원하기 때문에 Kubernetes나 Meos에서 Network Plugin으로 동작 할 수 있다.

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_Calico_Plugin/Calico_Components.PNG){: width="700px"}

위의 그림은 Calico의 구성요소를 나타낸다. 크게 **etcd, felix, bird, confd** 4가지의 구성요소로 이루어져 있다. etcd는 Kubernete Master Node에서 Container로 동작한다. felix, confd, bird는 모든 Kubernetes Node에서 동작하는 calico-node container에서 동작한다. calico-node container는 Node(Host)의 Network Namespace를 이용하기 때문에 calico-node container안에서 동작하는 App은 Node의 Network 설정을 조회하거나 제어 할 수 있다.

* etcd - etcd는 분산 Key-Value store이다. Calico 구동에 필요한 Network 구성/설정 정보, Calico 설정 정보 등 다양한 정보를 저장한다. 또한 저장한 key-value값이 변경될 경우 felix나 bird에게 변경 정보를 전달하는 Communication Bus 역활도 수행한다.

* felix - felix는 Node의 Network를 설정하는 Daemon이다. etcd에 저장되어 있는 Network 설정 정보를 바탕으로 Node의 Network Inteface, Route Table, iptables을 설정하여 Packet이 올바른 Container로 Routing 되게 하거나, 잘못된 Packet이 전달되지 못하도록 차단하는 역활을 수행한다. 또한 felix는 Network의 상태를 정보를 수집 하는 역활도 수행한다. felix가 설정한 Network 설정 정보 및 수집한 Network 상태 정보는 etcd에 저장하여, 다른 Node의 felix나 confd에게 설정 내용이 전달 되도록 한다.

* bird - bird는 **BGP (Border Gateway Protocol)** Client 역활을 수행한다. BGP는 Router간의 Routing Protocol로 Packet을 어느 Router로 Routing할지 결정하는 Protocol이다. 따라서 각 Router는 자신이 전달할 수 있는 IP List를 알고 있어야 한다. bird는 Node에서 동작하는 모든 container의 IP들을 Route Reflector로 전달한다. 그 후 Router는 Route Reflector에게 container들의 IP를 받게되고 Routing Table을 변경하여 Container로 Packet이 Routing 되도록 한다. bird는 BGP Client 뿐만아니라 BGP Route Reflector의 역활을 수행 할 수도 있다.

* confd - confd는 etcd의 Key-Value 변경 내용을 감지하여 동적으로 bird Conf 파일을 생성하는 역활을 수행한다.
 
#### 1.1 Network with IP-in-IP

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_Calico_Plugin/Calico_Network_IPIP.PNG)

위의 그림은 IP-in-IP Tunneling 기법을 이용하여 Calico가 설정한 Network를 나타내고 있다.

### 2. 참조

* [https://docs.projectcalico.org/master/reference/architecture/](https://docs.projectcalico.org/master/reference/architecture/)
* [https://platform9.com/blog/kubernetes-networking-achieving-high-performance-with-calico/](https://platform9.com/blog/kubernetes-networking-achieving-high-performance-with-calico/)
* [http://leebriggs.co.uk/blog/2017/02/18/kubernetes-networking-calico.html](http://leebriggs.co.uk/blog/2017/02/18/kubernetes-networking-calico.html)
* [https://kubernetes.feisky.xyz/zh/network/calico/](https://kubernetes.feisky.xyz/zh/network/calico/)
* [https://jvns.ca/blog/2016/07/16/calico/](https://jvns.ca/blog/2016/07/16/calico/)
