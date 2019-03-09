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

Cilium은 **BPF (Berkeley Packet Filter)**를 기반으로 Container Network를 구축하는 Tool이다. Kubernetes의 Network Plugin으로 많이 이용되고 있다. 위의 그림은 Kubernetes의 Plugin으로 동작하는 Cilium의 구성요소를 나타내고 있다. 크게 **etcd, cilium-agent, BPF** 3가지로 구성되어 있다. cilium-agent는 모든 Kubernetes Host 위에서 동작하는 cilium Container안에서 동작한다. cilium container는 Host(Node)의 Network Namespace를 이용하기 때문에 calico-node Container안에서 동작하는 App은 Host의 Network 설정을 조회하거나 제어 할 수 있다.

* etcd - etcd는 분산 Key-Value store이다. Cilium 구동에 필요한 Network 구성/설정 정보, Cilium 설정 정보 등 다양한 정보를 저장한다. 또한 저장한 key-value값이 변경될 경우 cilium-agent에게 변경 정보를 전달하는 Communication Bus 역활도 수행한다.

* cilium-agent - cilium-agent는 Host의 Network를 설정 및 Monitoring을 하는 Daemon이다. 필요에 따라 BPF를 Linux Kernel에 삽입하고 제어한다. 또한 cilium-agent는 cilium-node-monitor 및 cilium-health 실행한다. cilium-node-monitor는 BPF의 Event를 수신하고 전달한다. cilium-health는 cilium-agent의 상태를 외부의 Host에게 전달하거나, 외부 Host의 cilium-agent의 상태 정보를 얻는다. cilium-agent는 API 또는 cilium CLI를 통해서 제어가 가능하다.

* BPF - BPF는 Linux Kernel 안에서 Packet Routing 및 Filtering을 수행한다. BPF는 기존의 Linux Netfilter Framework 기반의 iptables에 비해서 낮은 Overhead 및 높은 성능이 가장 큰 장점이다. Cilium은 BPF 이용을 통해서 Netfilter Framework 사용을 최소화하여 Network 성능을 끌어올린다.

#### 1.1. Network

Cilium은 Container Network를 구축하는 방법으로 VXLAN 기반의 기법과 Host Network를 그대로 이용하는 기법 2가지를 제공한다.

##### 1.1.1. Network with VXLAN

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_Cilium_Plugin/Cilium_Network_VXLAN.PNG)

위의 그림은 Cilium과 VXLAN을 이용하여 구축한 Container Network를 나타낸다. Host의 Network는 10.0.0.0/24이고, Container Network는 10.244.0.0/16이다. Cilium은 etcd에 저장된 정보를 바탕으로 각 Host에 Container Network를 할당한다. 그림에서 Host 1은 192.167.2.0/24 Network가 할당되었다. 따라서 Host 1에 생긴 Container A의 IP는 192.167.2.0/24 Network에 속한 IP인 192.167.2.10을 이용한다. Host 2에는 192.167.3.0/24 Network가 할당되었기 때문에 Host 2에 생긴 Container B의 IP는 192.167.3.0/24 Network에 속한 IP인 192.167.3.10를 이용한다.

Container Network 구축시 이용하는 BPF는 VXLAN Interface에 붙는 tc action ingress BPF, Container의 veth Interface에 붙는 tc action ingress BPF, Cilium을 위해 Host에 생성한 veth Inteface인 cilium_host에 붙는 tc action engress BPF, 3가지 BPF가 이용된다. VXLAN Interface에 붙는 tc action ingress BPF은 cilium-agent가 BPF Map에 저장한 Container의 IP, MAC 주소 정보를 Packet과 함께 L3 Network Stack에 넘겨, L3 Network Stack에서 Packet이 Container로 바로 Routing 되도록 한다. Container의 veth Interface에 붙는 tc action ingress BPF는 Packet이 Container로 전달되도 되는 Packet인지 확인 및 Packet Filtering을 수행한다. Cilium에서는 Container가 특정 Container로부터온 Packet만을 받을 수 있도록 설정하거나, Container가 특정 URL로 오는 요청만 받도록 설정 할 수 있다.

Container에서 전송된 Packet은 Container의 veth Interface에서 나와 Note의 Routing Table로 전달된다. Note Routing Table에서는 모든 Container Network Packet이 cilium_host로 전달되도록 설정되어 있다. 따라서 Container에서 나온 Packet은 모두 cilium_host의 tc action engress BPF에게 Routing 된다. cilium_host의 tc action engress BPF에서는 동일 Host로 다시 전달 되어야하는 Packet은 해당 Contianer의 veth Interface로 Routing하고, 외부 Host로 전달 되어야하는 Packet은 VXLAN Interface로 Redirection되어 Host 밖으로 나간다.

##### 1.1.2. Network with Host L3 Network

![]({{site.baseurl}}/images/theory_analysis/Kubernetes_Cilium_Plugin/Cilium_Network_Host.PNG)

위의 그림은 Host L3 Network를 이용하여 구축한 Container Network를 나타낸다. 각 Host에 할당된 Container Network, Host IP, Container IP는 VXLAN 기법의 예제와 동일하다. VXLAN 기법과의 차이점은 VXLAN Interface 및 VXLAN Interface에 붙는 tc action ingress BPF가 존재하지 않는다. Host의 Routing Table에는 각 Host에게 할당된 Container Network 관련 Rule만 있다. Host 1의 Routing Table에는 Host 1에 할당된 Container Network인 192.167.2.0/24 관련 Rule만 있지 Host 2에 할당된 Container Network인 192.167.3.0/24 관련 Rule은 없다. 마지막으로 Host 사이에는 반드시 L3 Router가 존재한다.

Container에게 전달되어야 하는 Packet은 Host가 수신한 뒤 Host의 Routing Table에 따라서 cilium_host Interface로 전달된다. cilium_host의 tc action engress BPF에서는 Container의 veth로 Packet을 Routing하여 Container에게 Packet을 전달한다. Container로부터 전송된 Packet은 veth를 통해서 Host의 Routing Table에 전달되고, Packet의 목적지가 같은 Host에 있는 Container라면 cilium_host로 Routing되고 아니라면 eth0으로 Routing되어 Host 밖으로 전달된다. Host에서 나온 Packet은 Router에 의해서 적절한 Node로 Routing된다.

Router는 Host Network Routing Rule뿐만 아니라 Container Network 관련 Routing Rule도 알고 있어야 한다. 위의 그림에서 Router는 192.167.2.0/24 Container Network를 Node 1로 Routing 및 192.167.3.0/24 Container Network를 Node 2로 Routing 하도록 설정되어 있어야 한다. 따라서 Host L3 Network 기법은 Host를 연결하는 Router를 자유롭게 제어가능한 환경에서만 적용이 가능하다.

#### 1.2. Service Load Balancing

#### 1.3. Service Filtering

### 2. 참조

* [https://docs.cilium.io/en/v1.3/concepts/](https://docs.cilium.io/en/v1.3/concepts/) 
* [https://github.com/cilium/cilium/tree/master/monitor](https://github.com/cilium/cilium/tree/master/monitor)
* [https://ddiiwoong.github.io/2018/cilium-1/](https://ddiiwoong.github.io/2018/cilium-1/)
