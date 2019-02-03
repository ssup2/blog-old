---
title: Kubernetes Cilium Plugin
category: Theory, Analysis
date: 2019-02-06T12:00:00Z
lastmod: 2019-02-06T12:00:00Z
comment: true
adsense: true
---

Kubernetes Network Plugin인 Cilium을 분석한다.

### 1. Cilium

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_Cilium_Plugin/Cilium_Components.PNG){: width="600px"}

Cilium은 **BPF (Berkeley Packet Filter)**를 기반으로 Container Network를 구축하는 Tool이다. Kubernetes의 Network Plugin으로 많이 이용되고 있다. 위의 그림은 Kubernetes의 Plugin으로 동작하는 Cilium의 구성요소를 나타내고 있다. 크게 **etcd, cilium-agent, BPF** 3가지로 구성되어 있다. cilium-agent는 모든 Kubernetes Node 위에서 동작하는 cilium Container안에서 동작한다. cilium container는 Node(Host)의 Network Namespace를 이용하기 때문에 calico-node Container안에서 동작하는 App은 Node의 Network 설정을 조회하거나 제어 할 수 있다.

* etcd - etcd는 분산 Key-Value store이다. Cilium 구동에 필요한 Network 구성/설정 정보, Cilium 설정 정보 등 다양한 정보를 저장한다. 또한 저장한 key-value값이 변경될 경우 cilium-agent에게 변경 정보를 전달하는 Communication Bus 역활도 수행한다.

* cilium-agent - cilium-agent는 Node의 Network를 설정 및 Monitoring을 하는 Daemon이다. 필요에 따라 BPF를 Linux Kernel에 삽입하고 제어한다. 또한 cilium-agent는 cilium-node-monitor 및 cilium-health 실행한다. cilium-node-monitor는 BPF의 Event를 수신하고 전달한다. cilium-health는 cilium-agent의 상태를 외부의 Node에게 전달하거나, 외부 Node의 cilium-agent의 상태 정보를 얻는다. cilium-agent는 API 또는 cilium CLI를 통해서 제어가 가능하다.

* BPF - BPF는 Linux Kernel 안에서 Packet Routing 및 Filtering을 수행한다. BPF는 기존의 Linux Netfilter Framework 기반의 iptables에 비해서 낮은 Overhead 및 높은 성능이 가장 큰 장점이다. Cilium은 BPF 이용을 통해서 Netfilter Framework 사용을 최소화하여 Network 성능을 끌어올린다.

#### 1.1. Network with VXLAN

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_Cilium_Plugin/Cilium_Network_VXLAN.PNG)

Cilium은 Container Network를 구축하는 하나의 기법으로 VXLAN을 이용하는 기법을 제공한다. 위의 그림은 Cilium과 VXLAN을 이용하여 구축한 Container Network를 나타낸다. Node의 Network는 10.0.0.0/24이고, Container Network는 10.244.0.0/16이다.

Cilium은 etcd에 저장된 정보를 바탕으로 각 Node에 Container Network를 할당한다. 그림에서 Node 1은 192.167.2.0/24 Network가 할당되었다. 따라서 Node 1에 생긴 Container A의 IP는 192.167.2.0/24 Network에 속한 IP인 192.167.2.10을 이용한다. Node 2에는 192.167.3.0/24 Network가 할당되었기 때문에 Node 2에 생긴 Container B의 IP는 192.167.3.0/24 Network에 속한 IP인 192.167.3.10를 이용한다.

Container Network 구축시 이용하는 BPF는 VXLAN Interface에 붙는 tc action ingress BPF, Container의 veth Interface에 붙는 tc action ingress BPF, Cilium을 위해 Host에 생성한 veth Inteface인 cilium_host에 붙는 tc action engress BPF, 3가지 BPF가 이용된다. VXLAN Interface에 붙는 tc action ingress BPF은 cilium-agent가 BPF Map에 저장한 Container의 IP, MAC 주소 정보를 Packet과 함께 L3 Network Stack에 넘겨, L3 Network Stack에서 Packet이 Container로 바로 Routing 되도록 한다.

Container의 veth Interface에 붙는 tc action ingress BPF는 Packet이 Container로 전달되도 되는 Packet인지 확인 및 Packet Filtering을 수행한다. Cilium에서는 Container가 특정 Container로부터온 Packet만을 받을 수 있도록 설정하거나, Container가 특정 URL로 오는 요청만 받도록 설정 할 수 있다. 이러한 Packet Filtering 기능은 veth Interface에 붙는 tc action ingress BPF에서 이루어진다.

Container에서 전송된 Packet은 Container의 veth Interface에서 나와 Host의 Routing Table로 전달된다. Host Routing Table에서는 모든 Container Network Packet이 cilium_host로 전달되도록 설정되어 있다. 따라서 Container에서 나온 Packet은 모두 cilium_host의 tc action engress BPF에게 Routing 된다. cilium_host의 tc action engress BPF에서는 동일 Node로 다시 전달 되어야하는 Packet은 해당 Contianer의 veth Interface로 Routing하고, 외부 Node로 전달 되어야하는 Packet은 VXLAN Interface로 Redirection되어 Node 밖으로 나간다.

### 2. 참조

* [https://docs.cilium.io/en/v1.3/concepts/](https://docs.cilium.io/en/v1.3/concepts/) 
* [https://github.com/cilium/cilium/tree/master/monitor](https://github.com/cilium/cilium/tree/master/monitor)
* [https://ddiiwoong.github.io/2018/cilium-1/](https://ddiiwoong.github.io/2018/cilium-1/)
