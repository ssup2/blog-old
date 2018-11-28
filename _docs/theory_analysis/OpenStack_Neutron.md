---
title: OpenStack Neutron
category: Theory, Analysis
date: 2018-12-02T12:00:00Z
lastmod: 2017-12-02T12:00:00Z
comment: true
adsense: true
---

OpenStack의 Network Concept을 이해하고 OpenStack에서 Network를 제어하는 Service인 Neutron을 분석한다.

### 1. OpenStack Network

![]({{site.baseurl}}/images/theory_analysis/OpenStack_Neutron/OpenStack_Network.PNG){: width="700px"}

OpenStack Network은 OpenStack을 이용하여 Cloud를 제공하는 Provider 관점에서의 Network와 Cloud를 이용하는 User 관점의 Network로 접근할 수 있다. 위의 그림은 OpenStack Network를 나타내고 있다. Provider 관점에서의 Network는 Management, Guest, External, API 4가지로 분류 할 수 있다.

* Management - OpenStack을 구성하는 Service들이 이용하는 Network이다. 일반적으로 Node 사이의 물리 Network(VLAN)를 이용한다.
* Guest - User가 생성한 가상의 Network로써 VM 사이의 통신에 이용된다. 일반적으로 VXLAN/GRE 기반의 가상 Network를 이용하지만, 물리 Network(VLAN)으로도 구성이 가능하다.
* External - VM이 외부와 통신시 이용되는 Network이다. 일반적으로 Node 사이의 물리 Network(VLAN)를 이용한다.
* API - OpenStack의 Service API를 User에 노출시키는 통로가 되는 Network이다. 일반적으로 Node 사이의 물리 Network(VLAN)를 이용한다.

User 관점에서의 Network는 Provider Network, Self-service Network 2가지로 분류 할 수 있다.

* Provider Network - Provider가 생성하는 Network이다. Provider는 물리 Network(VLAN) 기반의 Network 또는 VXLAN/GRE 기반의 가상 Network 모두 생성 할 수 있다. Provder 관점에서의 Guest, External Network가 Provider Network라고 할 수 있다. VM이 물리 Network(VLAN) 기반의 Provider Network에 연결되기 위해서는 해당 물리 Network가 Compute Node에도 연결되어 있어야 한다.
* Self-service Network - User가 생성한 가상의 Network이다. User는 VXLAN/GRE 기반의 가상 Network만 생성 할 수 있다. Provider 관점에서 Guest Network가 Self-service Network라고 할 수 있다.

### 2. Neutron

![]({{site.baseurl}}/images/theory_analysis/OpenStack_Neutron/Neutron_Architecture.PNG){: width="600px"}

OpenStack의 모든 Network를 담당하는 Service이다. Neutron은 Network, Subnet, Router, LB 등 Infra 구성에 필요한 대부분의 Network 구성요소를 Provider 또는 User가 쉽게 생성하고 설정 할 수 있도록 도와준다.

#### 2.1. Management, Self-service, Router, DHCP

![]({{site.baseurl}}/images/theory_analysis/OpenStack_Neutron/Compute_Node_VXLAN_No_SDN.PNG){: width="500px"}

##### 2.1.1. VXLAN without SDN

![]({{site.baseurl}}/images/theory_analysis/OpenStack_Neutron/Network_Node_VXLAN_No_SDN.PNG){: width="600px"}

### 3. 참조

* [https://docs.openstack.org/install-guide/](https://docs.openstack.org/install-guide/)
* [https://docs.openstack.org/security-guide/networking/architecture.html](https://docs.openstack.org/security-guide/networking/architecture.html)
* [https://www.slideshare.net/rootfs32/20150511-jun-leeopenstack-neutron](https://www.slideshare.net/rootfs32/20150511-jun-leeopenstack-neutron)
