---
title: OpenStack Network, Neutron
category: Theory, Analysis
date: 2018-12-02T12:00:00Z
lastmod: 2020-01-15T12:00:00Z
comment: true
adsense: true
---

OpenStack의 Network Concept을 이해하고 OpenStack에서 Network를 제어하는 Service인 Neutron을 분석한다.

### 1. OpenStack Network

![[그림 1] OpenStack Network 분류]({{site.baseurl}}/images/theory_analysis/OpenStack_Network_Neutron/OpenStack_Network.PNG){: width="700px"}

OpenStack Network은 OpenStack을 이용하여 Cloud를 제공하는 Provider 관점에서의 Network와 Cloud를 이용하는 User 관점의 Network로 접근할 수 있다. [그림 1]은 OpenStack Network를 나타내고 있다. Provider 관점에서의 Network는 Management, Guest, External, API 4가지로 분류 할 수 있다.

* Management Network : OpenStack을 구성하는 Service들이 이용하는 Network이다. 일반적으로 Node 사이의 물리 Network(VLAN)를 이용한다.

* Guest Network : VM 사이의 통신에 이용되는 Network이다. 일반적으로 VXLAN/GRE 기반의 가상 Network를 이용하지만, 물리 Network(VLAN)으로도 구성이 가능하다.

* External Network : VM이 외부와 통신시 이용되는 Network이다. 일반적으로 Node 사이의 물리 Network(VLAN)를 이용한다.

* API Network : OpenStack의 Service API를 User에 노출시키는 통로가 되는 Network이다. 일반적으로 Node 사이의 물리 Network(VLAN)를 이용한다.

User 관점에서의 Network는 Provider Network, Self-service Network 2가지로 분류 할 수 있다.

* Provider Network : Provider가 생성하는 Network이다. Provider는 물리 Network(VLAN) 기반의 Network 또는 VXLAN/GRE 기반의 가상 Network 모두 생성 할 수 있다. Provder 관점에서의 Guest, External Network가 Provider Network라고 할 수 있다. VM이 물리 Network(VLAN) 기반의 Provider Network에 연결되기 위해서는 해당 물리 Network가 Compute Node에도 연결되어 있어야 한다.

* Self-service Network : User가 생성한 가상의 Network이다. User는 VXLAN/GRE 기반의 가상 Network만 생성 할 수 있다. Provider 관점에서 Guest Network가 Self-service Network라고 할 수 있다.

### 2. OpenStack Neutron

![[그림 2] Neutorn Architecture]({{site.baseurl}}/images/theory_analysis/OpenStack_Network_Neutron/Neutron_Architecture.PNG){: width="700px"}

OpenStack의 모든 Network를 담당하는 Service이다. Neutron은 Network, Subnet, Router, LB 등 Infra 구성에 필요한 대부분의 Network 구성요소를 Provider 또는 User가 쉽게 생성하고 설정 할 수 있도록 도와준다. [그림 2]는 Neutron의 Architecture를 나타내고 있다. Neutron은 Master 역할을 수행하는 Neutron Server과 Slave 역할을 수행하는 ML2 Plugin Agent, L3 Agent, DHCP Agent, Meta Agent 등으로 구성되어 있다.

Neutron Server와 Agent들은 사이의 통신은 Message Queue를 이용한다. Neutron Server, Agent들은 Message Queue와 통신할때 RPC (Remote Procedure Call)를 이용한다. 별도의 SDN Service가 Neutron과 협력하여 Network를 제어하는 경우 Neutron과 SDN Service는 REST API 방식으로 통신한다.

* Neutron Server : Neutron Server는 Controller Node에서 동작하며 Provider 또는 User에게 Network API 제공하고 요청에 따라 전반적인 OpenStack Network를 제어하는 Master 역할을 수행한다. Neutron Server는 Plugin으로 구성되어 있는데 Core Plugin, Service Plugin으로 구분된다. Core Plugin은 Network, Subnet과 연관된 기능을 수행한다. Service Plugin은 Router, LB, Firewall 같은 Network L3와 연관된 기능을 수행한다.

* ML2 Plugin Agent : Network Node 또는 Compute Node에서 동작하며 Neutron Server의 명령에 따라 VLAN, Bridge, OVS(Open V Switch)와 같은 Network L2를 제어한다.

* L3 Agent : Network Node에서 동작하며 Neutron Server의 명령에 따라 Router, Firewall 같은 Network L3를 제어한다.

* Meta Agent : VM 내부에서 VM 초기화를 진행하는 Cloud-Init 또는 Cloudbase에게 VM 초기화에 필요한 VM Metadata를 Nova에게 얻어와 전달한다. Cloud-Init 또는 Cloudbase로부터 오는 VM Metadata 요청은 Router의 Routing Rule 및 각 Router에 한개씩 존재하는 Meta Proxy를 통해 Meta Agent에게 전달된다. Meta Agent는 VM Metadata 요청이 온 Router의 ID와 VM Metadata 요청 Packet에 있는 VM IP 정보를 Neutron Server에게 전달하여 VM ID를 얻는다. 그 후 Meta Agent는 VM ID를 이용하여 Nova에게 얻은 VM Metadata를 해당 VM의 Cloud-Init 또는 Cloudbase에게 전달한다.

* DHCP Agent : VM에게 IP를 부여하기 위한 DHCP Server를 제어한다. 또한 Router의 Meta Proxy를 대신하는 별도의 Meta Proxy를 관리하는 역할도 수행한다. DHCP Agent의 Meta Proxy는 VM이 Router와 연결되어 있지 않는 고립된 네트워크에 연결되어 있는 경우, 고립된 Network ID와 VM Metadata 요청 Packet에 있는 VM IP 정보를 Meta Agent에게 전달하여 Meta Agent가 VM Metadata를 얻도록 도와준다.

#### 2.1. Management/Provider/Self-service Network, Router, DHCP

OVS (Open vSwitch)의 유뮤에 따라서 Management Network, Provider Network, Self-service Network, Router, DHCP Server가 실제 어떻게 구성되는지 분석한다. Management Network는 VLAN을 이용하지 않으면서 Node의 Network를 직접 이용하는 Flat Network로 구성되어 있다고 가정하였다. 또한 첫번째 Guest Network는 VLAN 10번 Network로 구성되어 있고 두번째 Guest Network는 VXLAN 20번 Network로 구성되어 있다고 가정하였다.

##### 2.1.1. Without OVS

![[그림 3] Compute Node Network without OVS]({{site.baseurl}}/images/theory_analysis/OpenStack_Network_Neutron/Compute_Node_No_OVS.PNG){: width="700px"}

[그림 3]은 OVS 없이 Compute Node의 Network 구성을 나타내고 있다. eth0는 Management Network와 연결되어 있다. 첫번째 Guest Network는 VLAN 10번을 이용하기 때문에 eth0 Interface에 VLAN 10번 Interface와 VLAN 10번에 VM을 붙일때 이용하는 Bridge를 설정한다. 이와 유사하게 두번째 Guest Network는 VXLAN 20번을 이용하기 때문에 eth0 Interface에 VXLAN 20번 Interface와 VXLAN 20번에 VM을 붙일때 이용하는 Bridge를 설정한다. VM의 모든 Inbound/Outbound Packet은 Bridge를 지나며 OpenStack의 Security Group의 Rule에 의해서 설정된 iptables의 Filter Table에 의해서 Filtering 된다.

VM A는 Provider Network에만 연결되어 있기 때문에 VM A의 TAP Interface는 VLAN 10번 Interface와  연결되어 있는 Bridge에만 연결되어 있다. VM C는 Self-serviced Network에만 연결되어 있기 때문에 VM C의 TAP Interface는 VLAN 20번 Interface와 연결되어 있는 Bridge에만 연결되어 있다. VM B는 양쪽 Network 모두와 연결되어 있기 때문에 VM B의 2개의 TAP Interface를 이용하여 모든 Bridge에 연결되어 있다. Bridge, VLAN Interface, VXLAN Interface 모두 ML2 Plugin Agent가 설정한다.

![[그림 4] Network Node Network without OVS]({{site.baseurl}}/images/theory_analysis/OpenStack_Network_Neutron/Network_Node_No_OVS.PNG){: width="700px"}

[그림 4]는 OVS 없이 Network Node의 Network 구성을 나타내고 있다. eth1는 Management Network와 연결되어있고, eth0은 External/Provider Network에 연결되어 있다. Compute Node와 유사하게 VLAN 10번 Interface, VXLAN 20번 Interface 설정 및 관련 Bridge들을 설정한다. 이와 더불어 External/Provider Network와 연결을 위한 별도의 Bridge가 설정되어 있다. Bridge, VLAN Interface, VXLAN Interface는 ML2 Plugin Agent가 설정한다.

Router와 Network Namespace는 1:1 관계를 갖는다. Router별로 별도의 Network Namespace를 이용하기 때문에 각 Router는 완전히 독립된 Routing Table을 구성할 수 있다. [그림 4]의 Router는 External/Provider Network, Guest/Provider Network, Guest/Self-service Network를 연결하는 Router이다. 각 Network를 연결하는 Bridge에 VETH Interface를 이용하여 Router Network Namespace로 Packet을 전송한다. Router Network Namespace로 전송된 Packet은 iptables을 통해 설정된 Routing Rule에 의해서 Routing된다. Router 설정은 L3 Agent가 수행한다.

DHCP Server는 Network Node에 Guest Network의 Bridge에 dnsmasq를 붙여 구성한다. 각 dnsmasq는 별도의 Network Namespace에서 구동되기 때문에 Network Node에 여러개의 dnsmasq가 동작하여도 충돌이 발생하지 않는다. dnsmasq의 Network Namespace로 Packet을 전송하기 위해서 Router와 동일하게 VETH를 이용한다. dnsmasq 설정은 DHCP Agent가 수행한다.

##### 2.1.2. With OVS

![[그림 5] Compute Node Network with OVS]({{site.baseurl}}/images/theory_analysis/OpenStack_Network_Neutron/Compute_Node_With_OVS.PNG){: width="700px"}

[그림 5]는 OVS를 이용한 Compute Node의 Network 구성을 나타내고 있다. [그림 3]과 동일한 Network 구성이지만 OVS를 이용하여 구성했다는 점이 다르다. VM과 연결된 모든 TAP Interface는 Bridge, VETH를 통해서 통합 OVS 역할을 수행하는 br-int OVS에 연결된다. br-int에서 VXLAN, GRE 기반의 Guest Network는 br-tun OVS를 이용한다. VLAN 기반의 Network는 br-vlan OVS를 이용한다. 첫번째 Guest Network는 VLAN을 이용하기 때문에 br-vlan OVS를 이용하고, 두번째 Guest Network는 VXLAN을 이용하기 때문에 br-tun OVS를 이용한다.

VM의 모든 Inbound/Outbound Packet은 TAP Interface와 연결된 Bridge를 지나며 OpenStack의 Security Group의 Rule에 의해서 설정된 iptables의 Filter Table에 의해서 Filtering 된다. TAP Interface, Bridge, VETH, OVS 모두 ML2 Plugin Agent가 설정한다.

![[그림 6] Network Node Network with OVS]({{site.baseurl}}/images/theory_analysis/OpenStack_Network_Neutron/Network_Node_With_OVS.PNG){: width="700px"}

[그림 6]은 OVS를 이용한 Network Node의 Network 구성을 나타내고 있다. [그림 4]와 동일한 Network 구성이지만 OVS를 이용하여 구성했다는 점이 다르다. 모든 VETH Interface는 통합 OVS 역할을 수행하는 br-int OVS에 연결된다. br-int에서 VXLAN, GRE 기반의 Guest Network는 br-tun OVS를 이용하고 VLAN 기반의 Network는 br-vlan OVS를 이용한다. 또한 External Network는 br-ex OVS를 이용한다. OVS는 ML2 Plugin Agent가 설정한다.

### 3. 참조

* [https://docs.openstack.org/install-guide/](https://docs.openstack.org/install-guide/)
* [https://docs.openstack.org/security-guide/networking/architecture.html](https://docs.openstack.org/security-guide/networking/architecture.html)
* [https://docs.openstack.org/liberty/networking-guide/scenario-classic-ovs.html](https://docs.openstack.org/liberty/networking-guide/scenario-classic-ovs.html)
* [https://docs.openstack.org/liberty/networking-guide/scenario-classic-lb.html](https://docs.openstack.org/liberty/networking-guide/scenario-classic-lb.html)
* [https://www.suse.com/c/vms-get-access-metadata-neutron/](https://www.suse.com/c/vms-get-access-metadata-neutron/)
