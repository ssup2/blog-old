---
title: Overlay Network, VXLAN
category: Theory, Analysis
date: 2017-05-23T12:00:00Z
lastmod: 2017-05-23T12:00:00Z
comment: true
adsense: true
---

Cloud 환경에서 Network 가상화를 위해 이용하는 Overlay Network를 분석하고, Overlay Network의 구현을 가능하게 하는 VXLAN 기술을 분석한다.

### 1. Overlay Network

![]({{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/Overlay.PNG){: width="500px"}

Overlay Network는 실제 물리 Network위에서 가상 Network를 구축하는 기법을 의미한다. 각 가상 Network는 서로 완전히 격리되어 관리 된다. 위의 그림은 물리 Network 위에 구축되어 있는 가상 Network를 나타내고 있다. 일반적으로 Cloud 환경에서는 Overlay Network를 이용하여 각 Tenant의 Network를 구축한다.

### 2. VXLAN (Virtual Extensible LAN)

![]({{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/VXLAN_Overview.PNG){: width="650px"}

VXLAN (Virtual Extensible LAN)은 Overlay Netowrk 구축을 위한 Network Protocol 중 하나이다. 위의 그림은 VXLAN의 개요를 간략하게 나타내고 있다.

VXLAN은 **Tunneling**을 기반으로 하는 기법이다. 가상 Network안에서 발생한 Packet은 Encapsulation되어 물리 Network를 통과하고 다시 Decapsulation되어 가상 Network로 전달된다. 이러한 Packet의 Encapsulation/Decapsulation이 발생하는 지점을 VXLAN에서는 **VTEP(VXLAN Tunnel End Point)**이라고 한다. VTEP은 가상 Software 장치가 될 수도 있고, VXLAN을 지원하는 물리 장치가 될 수도 있다. 위의 그림에서 VM (Virtual Machine)은 Hypervisor가 제공하는 Software VTEP를 이용하고 있고, PM (Pysical Machine)은 물리 VTEP을 이용하고 있다.

Encapsulation된 Packet은 VXLAN Header에 있는 **VNI(VXLAN ID)**를 통해서 어느 가상 Network의 Packet인지 구분되고 격리된다. 따라서 VXI 하나당 하나의 가상 Network를 의미한다. VNI는 VLAN의 VLAN ID와 동일한 역활을 수행한다고 할 수 있다. 위의 그림에서는 VNI 1000과 VNI 2000을 이용한 2개의 가상 Network를 나타내고 있다.

#### 2.1. VXLAN Packet

![]({{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/VXLAN_Packet.PNG)

위 그림은 VXLAN의 Packet 구조를 나타내고 있다. VXLAN은 IP/UDP를 이용하여 Tunneling을 수행한다. Packet 의 밖에는 Host가 이용하는 물리 Network에서의 Packet 전달을 위한 Outer Ethernet Header, Outer IP Header, Outer UDP Header가 있다. 안쪽에는 VXLAN Header와 가상 Network안에서 발생한 VM의 L2 Packet이 위치하고 있다. VXLAN Header안에 VNI가 저장되어 있다. VNI는 24bit로 구성되어 있어 약 16,000,000개의 VNI를 이용할 수 있다.

#### 2.2. VXLAN Broadcast, VTEP MAC Address Learning

VXLAN은 가상 Network안에서 발생한 Broadcast Packet을 물리 Network안에서의 **IP Multicast**로 처리하여 효율적으로 Network를 이용한다. IP/UDP를 이용하여 Tunneling하는 이유도 물리 Network에서의 IP Multicast를 이용하기 때문이다.

가상 Network안에서 발생한 Broadcast Packet이 물리 Network안에서 IP Multicast로 처리된다는 의미는 특정 VNI와 Multicast Group이 Mapping되어 있다는 의미와 같다. 이러한 Mapping 정보는 VTEP에 설정해 놓는다. VNI는 약 16,000,000개 이지만 Multicast Group의 개수는 약 1000개 이기 때문에 VNI와 Multicast Group은 실제로 N:1의 관계를 갖게된다.

VTEP은 가상 Network Packet이 Encapsulation되는 지점이기 때문에 Encapsulation을 위한 정보도 알고 있어야 한다. 따라서 VTEP은 자신에게 온 가상 Network Packet을 몇번 VNI로 Encapsulation 할지 정해야 한다. 일반적으로 가상 Network Packet의 VLAN ID와 VLAN의 Mapping 정보를 VTEP에 설정해 놓는다. 또는 가상 Network Packet의 Dst Subnet IP와 VNI를 Mapping하도록 VTEP을 설정 할 수도 있다.

![]({{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/VXLAN_Address_Learning.PNG)

위의 그림은 가상 Network안에서 발생한 ARP Packet에 따른 VTEP의 MAC Address Learning 과정을 나타내고 있다. ARP Packet의 처리 과정을 통해서 VXLAN Broadcast의 처리 과정을 이해 할 수 있다. 위 그림의 모든 VTEP은 VNI 10과 239.1.1.1 Multicast Group을 Mapping하도록 설정되어 있다. 또한 VNI 10과 VLAN 1을 Mapping하도록 설정되어 있다.

1. Machine A에서 IP B의 Mac Address를 알기 위해 ARP Request Packet을 VLAN ID 1과 함께 전송한다.

1. VTEP 1은 가상 Network Packet의 VLAN ID가 1인것을 확인한다. VTEP에 VLAN 1과 VNI 10이 Mapping 되어 있고, VNI 10은 Multicast 239.1.1.1에 Mapping되어 있기 때문에, 가상 Network Packet은 VNI 10으로 Encapsulation 된 후 239.1.1.1 Multicast Group에 전송된다.

1. Encapsulation된 Packet은 239.1.1.1 Multicast Group에 참여한 VTEP 2, VTEP 3에 전송된다. VTEP 2, VTEP 3은 Encapsulation된 Packet의 정보를 바탕으로 **Src MAC/VNI/Outer Src IP** Mapping Table을 생성한다.

1. VTEP 2, VTEP 3은 Encapsulation된 Packet을 Decapsulation하여 원래의 ARP Packet으로 변환한다. 그 후 Machine B, Machine C에 각각 전송한다.

1. IP B가 Machine B의 IP이기 때문에 Machine B만 ARP Response를 Machine A에게 Unicast한다.

1. VTEP 2에 저장된 Src MAC/VNI/Outer Src IP Mapping Table을 바탕으로 ARP Response Packet을 VTEP 1에게 Unicast된다.

1. Encapsulation된 ARP Response Packet을 받은 VTEP 1은 Src MAC/VNI/Outer Src IP Table을 생성한다.

1. VTEP 1은 Decapsulation을 통해 ARP Response Packet을 Machine A에게 전달한다.

ARP Packet 처리 과정을 통해 VXLAN이 얼마나 효율적으로 Broadcast와 Unicast를 처리하는지 파악 할 수 있다.

#### 2.3. VXLAN Unicast

![]({{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/VXLAN_Unicast.PNG)

위의 그림은 VXLAN Unicast 과정을 나타내고 있다. ARP Response Packet이 처리되는 과정과 비슷하다. 각 VTEP이 가지고 있는 Src MAC/VNI/Outer Src IP Table을 바탕으로 효율적으로 Unicast를 처리한다.

### 3. vs VLAN

VLAN을 통해서도 가상 Network를 만들 수 있다. 하지만 VLAN은 Cloud 환경에서 이용하기에는 몇몇가지 제한 사항이 있다. 먼져 VLAN의 VLAN ID는 12bit로 이루어져 있기 때문에 약 4000개의 VLAN ID밖에 이용하지 못한다. VLAN만을 이용하여 가상 Network를 구성하면 최대 4000 Tenant들만 수용 할 수 있다는 의미이다.

VLAN은 L2 Layer 기술이다. VLAN을 이용하여 가상 Network를 구축하여도, 물리 스위치는 Host의 Mac Address 뿐만 아니라 VM의 MAC Address를 Learning하고 MAC Address Table을 유지해야 한다. 문제는 하나의 Host에서 다수의 VM이 동작하는 Cloud 환경에서 VM의 개수는 Host의 개수보다 훨씬 많다는 점이다. 따라서 물리 스위치가 VM의 MAC Address도 관리해야 한다는 점은 큰 부담이 될 수 있다.

VXLAN의 VNI는 약 16,000,000개를 이용 할 수 있기 때문에 많은 수의 Tenant를 수용할 수 있다. 또한 VXLAN은 Tunneling을 기반으로 하는 기법이기 때문에 중간의 물리 스위치들은 가상 Network안에 있는 VM의 MAC Address를 관리할 필요가 없다. VM의 MAC Address는 VTEP에서만 관리한다. Cloud 환경에서 VTEP은 Hypervisor가 제공하는 가상의 VTEP를 이용할 수 있기 때문에 기존의 Legacy 환경에서도 쉽게 VXLAN을 적용 할 수 있다.

### 4. 참조

* [http://youngmind.tistory.com/entry/Network-Overlay-VXLAN-%EB%B6%84%EC%84%9D-1](http://youngmind.tistory.com/entry/Network-Overlay-VXLAN-%EB%B6%84%EC%84%9D-1)

* [https://www.slideshare.net/KwonSunBae/vxlan-deep-dive-session-rev05-final](https://www.slideshare.net/KwonSunBae/vxlan-deep-dive-session-rev05-final)

* [https://www.arista.com/assets/data/pdf/Whitepapers/Arista_Networks_VXLAN_White_Paper.pdf](https://www.arista.com/assets/data/pdf/Whitepapers/Arista_Networks_VXLAN_White_Paper.pdf)
