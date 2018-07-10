---
title: Multicast
category: Theory, Analysis
date: 2017-05-15T12:00:00Z
lastmod: 2017-05-15T12:00:00Z
comment: true
adsense: true
---

Network Multicast를 분석한다.

### 1. Multicast

Network Packet 전송 방법은 크게 Unicast, Broadcast, Multicast 3가지 방식을 취한다. Unicast는 Packet을 하나의 Node에게 전달하는 방식이다. 일반적인 통신에서 가장 많이 이용하는 방식이다. Broadcast는 같은 네트워크 안에 있는 모든 Node에게 Packet을 전달하는 방식이다. ARP(Address Resolution Protocol)가 대표적인 예이다. 마지막으로 모든 Node가 아닌 특정 Group에 속해있는 Node들에게만 Packet을 전달하는 Multicast가 있다. 대용량의 Packet을 특정 Node들에게만 전송해야하는 Multimedia Streaming에서 이용되고 있다.

### 2. Multicast Address

![]({{site.baseurl}}/images/theory_analysis/Multicast/Multicast_Address.PNG){: width="600px"}

Multicast는 일반적으로 L3는 IP를 이용하고 L4는 UDP를 이용한다. 위의 그림은 Multicast Packet의 IP Address와 Ethernet Address를 나타내고 있다. Multicast는 IP Address로 **Class D**를 이용한다. Class D는 앞의 4비트가 **1110**으로 시작하는 주소를 의미한다. Multicast IP는 하나의 **Multicast Group**을 나타낸다. Packet의 Dest IP가 Multicast IP인 224.0.0.1이라면 224.0.0.1 Group에 소속되어 있는 Node들만 해당 Packet을 받게 된다.

Ethernet Address는 IP Address를 기반으로 생성한다. Ethernet Address는 **0000 0001 0000 0000 0101 1110 0**으로 시작하며 나머지 23bit는 IP Address의 뒷부분 23bit으로 채워 생성한다. 위 그림의 빨간 부분 처럼 5bit가 Ethernet Address를 만드는데 이용되지 않기 때문에 하나의 Ethernet Address가 여러개의 IP Address를 나타낼 수 있다.

### 3. IGMP (Internet Group Management Protocol)

IGMP는 Router와 Subnet사이에서 Multicast Group 정보를 주고 받기 위한 Protocol이다. Router는 IGMP Protocol을 통해 Multicast Packet을 어느 Subnet에 보내야할지 판단하게 된다.

#### 3.1. IGMP Report

![]({{site.baseurl}}/images/theory_analysis/Multicast/IGMP_Report.PNG)

위의 그림은 IGMP Protocol의 Report를 나타내고 있다. Subnet에 속해 있는 특정 Node가 224.0.0.1 Multicast Group에 소속되고 싶으면 Node는 Router에게 IGMP Report Packet을 전송한다. Router는 Dest IP가 224.0.0.1인 Multicast Packet을 받으면 IGMP Report Packet을 전송한 Node가 있는 Subnet으로 Multicast Packet을 전송한다.

#### 3.2. IGMP Query, Leave

![]({{site.baseurl}}/images/theory_analysis/Multicast/IGMP_Query_Leave.PNG)

위 그림은 IGMP Query Packet과 IGMP Leave Packet을 나타내고 있다. Router는 주기적으로 각 Multicast Group에 소속되어 있는 Node들에게 IGMP Query Packet을 전송한다. IGMP Query Packet을 받은 Node는 자신이 계속해서 Multicast Packet을 받고 싶으면 IGMP Report Packet을 Router에게 전송한다. 반대로 더이상 해당 Multicast Group의 Packet을 받고 싶지 않으면 IGMP Leave Packet을 Router에게 전송한다.

#### 3.3. IGMP Snooping

![]({{site.baseurl}}/images/theory_analysis/Multicast/IGMP_Snooping.PNG)

Multicast가 효율적으로 동작하기 위해서는 Router의 Multicast Routing 뿐만 아니라 Subnet을 구성하는 Switch의 Multicast Routing도 중요하다. IGMP Snooping은 Switch에서 Multicast Routing을 위해 동작하는 기법이다. 위의 그림은 IGMP Snooping을 나타내고 있다.

Switch는 Packet의 Ethernet Address를 보고 해당 Packet이 Multicast Packet인지 알 수 있다. Switch가 Multicast Ethernet Address를 가진 Packet을 받으면 해당 Packet이 Switch의 어느 Port에서 왔는지 기록한다. 기록을 바탕으로 Multicast Packet을 적절한 Port로 Routing한다. 만약 Switch에서 IGMP Snooping 기능을 지원하지 않으면, Switch는 Multicast Packet을 Broadcast하여 모든 Port에게 전달해야 한다.

### 4. 참고

* [https://osrg.github.io/ryu-book/ko/html/igmp_snooping.html](https://osrg.github.io/ryu-book/ko/html/igmp_snooping.html)
*  [http://www.cisco.com/c/en/us/td/docs/ios/solutions_docs/ip_multicast/White_papers/mcst_ovr.html](http://www.cisco.com/c/en/us/td/docs/ios/solutions_docs/ip_multicast/White_papers/mcst_ovr.html)
