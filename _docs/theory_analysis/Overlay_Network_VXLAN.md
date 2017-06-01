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

VXLAN은 **Tunneling**을 기반으로 하는 기법이다. 가상 네트워크안에서 발생한 Packet은 Encapsulation되어 물리 Network를 통과하고 다시 Decapsulation되어 가상 네트워크로 전달된다. 이러한 Packet의 Encapsulation/Decapsulation이 발생하는 지점을 VXLAN에서는 **VTEP(VXLAN Tunnel End Point)**이라고 한다. VTEP은 가상 Software 장치가 될 수도 있고, VXLAN을 지원하는 물리 장치가 될 수도 있다. 위의 그림에서 VM (Virtual Machine)은 Hypervisor가 제공하는 Software 장치를 이용하고 있고, PM (Pysical Machine)은 물리 VTEP을 나타내고 있다.

Encapsulation된 Packet은 VXLAN Header에 있는 **VNI(VXLAN ID)**를 통해서 어느 가상 Network의 Packet인지 구분되고 격리된다. 따라서 VXI 하나당 하나의 가상 Network를 의미한다. VNI는 VLAN의 VLAN ID와 동일한 역활을 수행한다고 할 수 있다. 위의 그림에서는 VNI 1000과 VNI 2000을 이용한 2개의 가상 네트워크를 나타내고 있다.

#### 2.1. VLAN

VXALN은 VLAN의

#### 2.1. VXLAN Packet

![]({{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/VXLAN_Packet.PNG)

#### 2.2. VXLAN Address Learning

![]({{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/VXLAN_Address_Learning.PNG)

#### 2.3. VXLAN Unicast

![]({{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/VXLAN_Unicast.PNG)

### 3. 참조

* [http://youngmind.tistory.com/entry/Network-Overlay-VXLAN-%EB%B6%84%EC%84%9D-1](http://youngmind.tistory.com/entry/Network-Overlay-VXLAN-%EB%B6%84%EC%84%9D-1)

* [https://www.slideshare.net/KwonSunBae/vxlan-deep-dive-session-rev05-final](https://www.slideshare.net/KwonSunBae/vxlan-deep-dive-session-rev05-final)
