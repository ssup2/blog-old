---
title: BGP (Border Gateway Protocol)
category: Theory, Analysis
date: 2019-01-10T12:00:00Z
lastmod: 2019-01-10T12:00:00Z
comment: true
adsense: true
---

BGP (Border Gateway Protocol)를 분석한다.

### 1. BGP (Border Gateway Protocol)

![]({{site.baseurl}}/images/theory_analysis/BGP/BGP.PNG)

BGP는 AS (Autonomous System)의 External Router (Gateway)의 Routing Table 관리를 위해 이용되는 Protocol이다. 위의 그림은 BGP를 나타내고 있다. AS는 특정 Group의 Network 관리자가 관리하는 Network를 의미한다. Internet을 제공하는 ISP (Internet Service Provier)가 AS에 해당된다. DMZ는 의미그대로 중립 Network를 의미하며 다수의 AS를 연결하는 Network를 의미한다.

BGP는 eBGP (external BGP), iBGP (internal BGP) 2가지로 분류 할 수 있다. eBGP는 서로 다른 AS에 속해있는 External Router사이에 Routing 정보를 교환하기 위한 Protocl이다. iBGP는 같은 AS에 속해있는 External Router 사이에 Routing 정보를 교환하기 위한 Protocol이다. BGP는 Path Vector 방식의 Protocol이다. 각 External Router는 다른 AS로 가기 위한 Path 정보를 가지고 있다. 예를 들어 위의 그림에서 AS 100에 속한 Router A2는 AS 300으로 가기위한 Path인 'AS100 - AS200 - AS300' 정보를 갖고 있다.

Internal Router로 전달된 목적지가 외부 AS인 Packet은 IGP (Interior Gateway Protocol)에 의해서 External Router로 전달되고, 다시 BGP에 의해서 외부 AS로 전달된다.

### 2. 참조

* [https://www.slideshare.net/apnic/bgp-techniques-for-network-operators](https://www.slideshare.net/apnic/bgp-techniques-for-network-operators)
* [https://www.nanog.org/meetings/nanog53/presentations/Sunday/bgp-101-NANOG53.pdf](https://www.nanog.org/meetings/nanog53/presentations/Sunday/bgp-101-NANOG53.pdf)
* [http://luk.kis.p.lodz.pl/ZTIP/BGP.pdf](http://luk.kis.p.lodz.pl/ZTIP/BGP.pdf)
* [https://www.netmanias.com/ko/?m=view&id=techdocs&no=5128](https://www.netmanias.com/ko/?m=view&id=techdocs&no=5128)
