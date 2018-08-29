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

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_flannel_Plugin/flannel_Components.PNG){: width="400px"}

위의 그림은 flannel의 구성요소를 나타낸다. 크게 **etcd, flanneld** 2가지로 구성되어 있다. etcd는 Kubernete Master Node에서 Container로 동작한다. flanneld는 모든 Kubernetes Node 위에서 동작하는 flanneld Container d안에서 동작한다. calico-node container는 Node(Host)의 Network Namespace를 이용하기 때문에 calico-node container안에서 동작하는 App은 Node의 Network 설정을 조회하거나 제어 할 수 있다.

* etcd - etcd는 분산 Key-Value store이다. Calico 구동에 필요한 Network 구성/설정 정보, Calico 설정 정보 등 다양한 정보를 저장한다. 또한 저장한 key-value값이 변경될 경우 flanneld에게 변경 정보를 전달하는 Communication Bus 역활도 수행한다.

* flanneld - flanneld는 Node의 Network를 설정하는 Daemon이다. etcd에 저장되어 있는 Network 설정 정보를 바탕으로 Node의 Network Inteface, Route Table, iptables을 설정하여 Packet이 올바른 Container로 Routing 되게 한다.

#### 1.1. host-gw

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_flannel_Plugin/flannel_Network_Host_GW.PNG)

flannel은 Container Network를 구축하는 하나의 기법으로 host-gw 기법을 제공한다. host-gw 기법은 의미 그대로 host를 gateway로 이용하는 기법이다. 위의 그림은 flannel이 host-gw 기법을 이용하여 설정한 Network를 나타내고 있다. Node의 Network는 10.0.0.0/24이고, Container Network는 10.244.0.0/16이다.

flanneld는 etcd에 저장된 정보를 바탕으로 각 Node에 Container Network를 할당한다. 그림에서 Node1에는 10.244.1.0/24 Network가 할당되었다. 따라서 Node 1에 생긴 Container A의 IP는 10.244.1.0/24 Network에 속한 IP인 10.244.1.2를 이용한다. Node 2에는 10.244.2.0/24 Network가 할당 되었기 때문에 Node 2에 생긴 Container B의 IP는 10.244.2.0/24 Network에 속한 10.244.2.2를 이용한다. Node 1에는 Node 2의 Container Network의 Default GW로 Node 2의 IP가 설정되어 있다. 반대로 Node 2에는 Node 1의 Container Network의 Default GW로 Node 1의 IP가 설정되어 있다.

Container A에서 Dest IP가 10.244.2.2인 Packet을 전송하면 Packet은 vethxxx와 cni Bridge를 지난뒤 Host의 Routing Table에 따라서 다시 Routing된다. Packet의 Dest IP는 10.244.2.0/24 Network에 속하기 때문에 Packet은 Node 2로 Forwarding된다. 즉 Packet의 Dest MAC만 Node 2의 Mac Address로 바꾸어 Packet이 Node 2에게 전달한다. 그 후 Packet은 Node 2의 Routing Table에 따라서 cni0에게 전달되고 다시 Container B에게 전달된다.

host-gw 기법은 Packet의 Dest MAC만 교체하는 기법이기 때문에 VXLAN 기법보다 높은 성능을 보여준다. 하지만 host-gw 기법은 모든 Node(Host)들이 같은 Network에 있어야 동작하는 기법이다. Container가 전송한 Packet은 Dest MAC만 Node의 Routing Table에 의해서 변경될 뿐, Packet의 Dest IP는 Container Network IP는 그대로 유지된다. 위의 예제에서 Packet의 Dest IP 10.244.2.2는 변경되지 Container에게 전달 된다. 만약 Node들이 서로 다른 Network에 있어 Node Network들을 연결하는 Router에 Packet이 전달되어도, Router에는 Container Network에 대한 Routing Rule이 없기 때문에 Packet은 Drop된다. host-gw 기법을 서로 다른 Network에 있는 Node들에게 적용하기 위해서는 직접 Router에 Container Network에 대한 Routing Rule을 추가하고 관리해야 한다.

#### 1.2. VXLAN

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_flannel_Plugin/flannel_Network_VXLAN.PNG)

flannel은 Container Network를 구축하는 하나의 기법으로 VXLAN 기법을 제공한다. VXLAN 기법은 의미 그대로 VXLAN을 이용하는 기법이다. 위의 그림은 flannel이 VXLAN 기법을 이용하여 설정한 Network를 나타내고 있다. Node Network와 Container Network, 각 Node에 할당된 Container Network, Node IP, Container IP는 host-gw 기법의 예제와 동일하다.

host-gw 기법과 차이점은 각 Node에 flannel.1이라는 VXLAN Interface가 있다. Node 1에는 Node 2의 Container Network의 Default GW로 Node 2의 flannel.1 Interface가 설정되어 있다. 반대로 Node 2에는 Node 1의 Container Network의 Default GW로 Node 1의 flannel.1 Interface가 설정되어 있다. Packet은 Node를 나갈때 flannel.1 Inteface의 설정에 따라서 VXLAN으로 Encapsulation되고, Node에 들어갈때 Decapsulation이 된다. flannel.1은 VNI로 1번을 이용하도록 설정되어 있고, Kernel의 VXLAN Default UDP Port인 8472를 이용한다.

VXLAN 기법은 Encapsulation 기법이기 때문에 Packet이 Node를 나갈때는 Packet의 Dest IP가 Node Network의 IP로 설정된다. 따라서 각 Node가 서로 다른 Network에 있더라도, Node사이 통신이 된다면 VXLAN 기법을 적용 할 수 있다. 하지만 성능은 Encapsulation/Decapsulation Overhead 때문에 host-gw 기법보다 성능이 떨어진다.

### 2. 참조

* [https://github.com/coreos/flannel](https://github.com/coreos/flannel)
* [https://github.com/coreos/flannel/blob/master/Documentation/backends.md](https://github.com/coreos/flannel/blob/master/Documentation/backends.md)
* [https://blog.laputa.io/kubernetes-flannel-networking-6a1cb1f8ec7c](https://blog.laputa.io/kubernetes-flannel-networking-6a1cb1f8ec7c)
* [https://github.com/coreos/flannel/blob/master/Documentation/backends.md](https://github.com/coreos/flannel/blob/master/Documentation/backends.md)
* [https://docs.openshift.com/container-platform/3.4/architecture/additional_concepts/flannel.html](https://docs.openshift.com/container-platform/3.4/architecture/additional_concepts/flannel.html)
* [https://stackoverflow.com/questions/45293321/why-host-gw-of-flannel-requires-direct-layer2-connectivity-between-hosts](https://stackoverflow.com/questions/45293321/why-host-gw-of-flannel-requires-direct-layer2-connectivity-between-hosts)
* [https://www.slideshare.net/enakai/how-vxlan-works-on-linux](https://www.slideshare.net/enakai/how-vxlan-works-on-linux)
