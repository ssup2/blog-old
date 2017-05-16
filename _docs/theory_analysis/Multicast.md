---
title: Multicast
category: Theory, Analysis
date: 2017-05-15T12:00:00Z
lastmod: 2017-05-15T12:00:00Z
comment: true
adsense: true
---

Network Multicast를 분석한다.

### Multicast

* Network Packet 전송 방법은 크게 Unicast, Broadcast, Multicast 3가지 방식을 취한다. Unicast는 Packet을 하나의 Node에게 전달하는 방식이다. 일반적인 통신에서 가장 많이 이용하는 방식이다. Broadcast는 같은 네트워크 안에 있는 모든 Node에게 Packet을 전달하는 방식이다. ARP(Address Resolution Protocol)가 대표적인 예이다. 마지막으로 모든 Node가 아닌 특정 Group에 속해있는 Node들에게만 Packet을 전달하는 Multicast가 있다. 대용량의 Packet을 특정 Node들에게만 전송해야하는 Multimedia Streaming에서 이용되고 있다. Multicast는 L3는 IP,L4는 UDP를 이용한다.

### Multicast Address

<img src="{{site.baseurl}}/images/theory_analysis/Multicast/Multicast_Address.PNG" width="600px">

* Packet의 Address 영역을 보면 이 Packet이 Multicast되는 Packet인지 알 수 있다. 위의 그림은 Multicast Packet의 IP Address와 Ethernet Address를 나타내고 있다. Multicast는 IP Address로 **Class D**를 이용한다. Class D는 앞의 4비트가 **1110**으로 시작한다.

* Ethernet Address는 IP Address를 기반으로 생성한다. Ethernet Address는 **0000 0001 0000 0000 0101 1110 0**으로 시작하며 나머지 23bit는 IP Address의 뒷부분 23bit으로 채워 생성한다. 위 그림의 빨간 부분 처럼 5bit가 Ethernet Address를 만드는데 이용되지 않기 때문에 하나의 Ethernet Address가 여러개의 IP Address를 나타낼 수 있다.

### IGMP

![]({{site.baseurl}}/images/theory_analysis/Multicast/IGMP_Report.PNG)

![]({{site.baseurl}}/images/theory_analysis/Multicast/IGMP_Query_Leave.PNG)

![]({{site.baseurl}}/images/theory_analysis/Multicast/IGMP_Snooping.PNG)

* [https://osrg.github.io/ryu-book/ko/html/igmp_snooping.html](https://osrg.github.io/ryu-book/ko/html/igmp_snooping.html)
*  [http://www.cisco.com/c/en/us/td/docs/ios/solutions_docs/ip_multicast/White_papers/mcst_ovr.html](http://www.cisco.com/c/en/us/td/docs/ios/solutions_docs/ip_multicast/White_papers/mcst_ovr.html)
