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

<img src="{{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/Overlay.PNG" width="500px">

Overlay Network는 실제 물리 Network위에서 가상 Network를 구축하는 기법을 의미한다. 각 가상 Network는 서로 완전히 격리되어 관리 된다. 위의 그림은 물리 Network 위에 구축되어 있는 가상 Network를 나타내고 있다. 일반적으로 Cloud 환경에서는 Overlay Network를 이용하여 각 Tenant의 Network를 구축한다.

### 2. VXLAN (Virtual Extensible LAN)

<img src="{{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/VXLAN_Overview.PNG" width="650px">

VXLAN (Virtual Extensible LAN)은 Overlay Netowrk 구축을 위한 Network Protocol 중 하나이다. 위의 그림은 VXLAN의 개요를 간략하게 나타내고 있다.

VXLAN은 **Tunneling**을 기반으로 하는 기법이다. 가상 Network안에서 발생한 Packet은 Encapsulation되어 물리 Network를 통과하고 다시 Decapsulation되어 가상 Network로 전달된다. 이러한 Packet의 Encapsulation/Decapsulation이 발생하는 지점을 VXLAN에서는 **VTEP(VXLAN Tunnel End Point)**이라고 한다. VTEP은 가상 Software 장치가 될 수도 있고, VXLAN을 지원하는 물리 장치가 될 수도 있다. 위의 그림에서 VM (Virtual Machine)은 Hypervisor가 제공하는 Software 장치를 이용하고 있고, PM (Pysical Machine)은 물리 VTEP을 나타내고 있다.

Encapsulation된 Packet은 VXLAN Header에 있는 **VNI(VXLAN ID)**를 통해서 어느 가상 Network의 Packet인지 구분되고 격리된다. 따라서 VXI 하나당 하나의 가상 Network를 의미한다. VNI는 VLAN의 VLAN ID와 동일한 역활을 수행한다고 할 수 있다. 위의 그림에서는 VNI 1000과 VNI 2000을 이용한 2개의 가상 Network를 나타내고 있다.

#### vs VLAN

VLAN을 통해서도 가상 Network를 만들 수 있다. 하지만 VLAN은 Cloud 환경에서 이용하기에는 몇몇가지 제한 사항이 있다. 먼져 VLAN의 VLAN ID는 12bit로 이루어져 있기 때문에 약 4000개의 VLAN ID밖에 이용하지 못한다. VLAN만을 이용하여 가상 Network를 구성하면 최대 4000 Tenant들만 수용 할 수 있다는 의미이다.

VLAN은 L2 Layer 기술이다. VLAN을 이용하여 가상 Network를 구축하여도, 물리 스위치는 Host의 Mac Address 뿐만 아니라 VM의 MAC Address를 Learning하고 MAC Address Table을 유지해야 한다. 문제는 하나의 Host에서 다수의 VM이 동작하는 Cloud 환경에서 VM의 개수는 Host의 개수보다 훨씬 많다는 점이다. 따라서 물리 스위치가 VM의 MAC Address도 관리해야 한다는 점은 큰 부담이 될 수 있다.

VXLAN의 VNI는 24bit로 이루어져 있기 때문에 약 16,000,000개의 VNI를 이용할 수 있다. 또한 VXLAN은 Tunneling을 기반으로 하는 기법이기 때문에 중간의 물리 스위치들은 가상 Network안에 있는 VM의 MAC Address를 관리할 필요가 없다. VM의 MAC Address는 VTEP에서만 관리한다. Cloud 환경에서 VTEP은 Hypervisor가 제공하는 가상의 VTEP를 이용할 수 있기 때문에 기존의 Legacy 환경에서도 쉽게 VXLAN을 적용 할 수 있다.

#### 2.1. VXLAN Packet

![]({{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/VXLAN_Packet.PNG)

위 그림은 VXLAN의 Packet 구조를 나타내고 있다. VXLAN은 IP/UDP를 이용하여 Tunneling을 수행한다. Packet 의 밖에는 Host가 이용하는 물리 Network에서의 Packet 전달을 위한 Outer Ethernet Header, Outer IP Header, Outer UDP Header가 있다. 안쪽에는 VXLAN Header와 가상 Network안에서 발생한 VM의 L2 Packet이 위치하고 있다.

#### 2.2. VXLAN Broadcast, VTEP MAC Address Learning

VXLAN은 가상 Network안에서 발생한 Broadcast Packet을 물리 Network안에서의 **IP Multicast**로 처리하여 효율적으로 Network를 이용한다. IP/UDP를 이용하여 Tunneling하는 이유도 물리 Network에서의 IP Multicast를 이용하기 때문이다.

![]({{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/VXLAN_Address_Learning.PNG)

위의 그림은 가상 Network안에서 발생한 ARP Packet에 따른 VTEP의 MAC Address Learing 과정을 나타내고 있다. ARP Packet의 처리 과정을 통해서 VXLAN Broadcast의 처리 과정을 이해 할 수 있다. 위의 그림의 모든 VTEP은 VNI 10과 239.1.1.1 Multicast Group을 Mapping한 상태라고 가정한다.

1. Machine A에서 ARP Request Packet을

VNI와 Multicast Group Mapping은 VTEP에서 설정 할 수 있다. VNI는 약 16,000,000개 이지만 Multicast Group의 개수는 약 1000개 이기 때문에 VNI와 Multicast Group은 N:1의 관계를 갖게된다.

VXLAN이 UDP를 이용하는 이유는

#### 2.3. VXLAN Unicast

![]({{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/VXLAN_Unicast.PNG)

### 3. 참조

* [http://youngmind.tistory.com/entry/Network-Overlay-VXLAN-%EB%B6%84%EC%84%9D-1](http://youngmind.tistory.com/entry/Network-Overlay-VXLAN-%EB%B6%84%EC%84%9D-1)

* [https://www.slideshare.net/KwonSunBae/vxlan-deep-dive-session-rev05-final](https://www.slideshare.net/KwonSunBae/vxlan-deep-dive-session-rev05-final)
