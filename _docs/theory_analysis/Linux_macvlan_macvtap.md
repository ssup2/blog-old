---
title: Linux macvlan, macvtap
category: Theory, Analysis
date: 2017-10-29T12:00:00Z
lastmod: 2017-10-29T12:00:00Z
comment: true
adsense: true
---

Linux의 Virtual Network Device인 macvlan과 macvtap을 분석한다.

### 1. macvlan

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Component.PNG){: width="400px"}

macvlan은 하나의 Network Interface를 **여러개의 가상 Network Interface**로 분리하여 이용 할 수 있게 만드는 Network Device Driver이다. 위의 그림은 macvlan의 구성요소를 간략하게 나타내고 있다. macvlan은 Parent Inteface를 이용하여 여러개의 Child Interface를 생성한다. Child Interface는 각각 별도의 **MAC Address**와 **macvlan Mode**를 가질 수 있다. Mode는 Child Inteface 생성 시 설정 할 수 있으며, Mode에 따라 macvlan의 Packet 전송 정책이 달라진다.

Mode에 따라서 Child Inteface간의 통신은 가능하지만, Mode에 관계없이 Parent Interface와 Child Interface는 서로 절대로 통신이 불가능한게 macvlan의 특징 중 하나이다.

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Example.PNG){: width="600px"}

위의 그림은 vlan Interface들을 macvlan의 Parent Interface로 두고 여러 Child Interface를 생성한 구성도를 나타내고 있다. macvlan은 물리 Ethernet Inteface 뿐만 아니라 vlan Interface, bridge Inteface 같은 가상의 Interface도 Parent Inteface로 둘 수 있다.

#### 1.1 Mac Address 관리

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Address_Manage.PNG){: width="700px"}

#### 1.2. macvlan Mode

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Private_Mode.PNG){: width="400px"}

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Vepa_Mode.PNG){: width="400px"}

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Bridge_Mode.PNG){: width="400px"}

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Passthru_Mode.PNG){: width="200px"}

#### 1.3. vs Linux Bridge

### 2. macvtap

* macvlan code - [https://github.com/torvalds/linux/blob/80cee03bf1d626db0278271b505d7f5febb37bba/drivers/net/macvlan.c](https://github.com/torvalds/linux/blob/80cee03bf1d626db0278271b505d7f5febb37bba/drivers/net/macvlan.c)
* macvtap code - [https://github.com/torvalds/linux/blob/80cee03bf1d626db0278271b505d7f5febb37bba/drivers/net/macvtap.c](https://github.com/torvalds/linux/blob/80cee03bf1d626db0278271b505d7f5febb37bba/drivers/net/macvtap.c)
* macvlan - [https://hicu.be/bridge-vs-macvlan](https://hicu.be/bridge-vs-macvlan)
