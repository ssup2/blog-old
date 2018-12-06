---
title: VRRP (Virtual Router Redundancy Protocol)
category: Theory, Analysis
date: 2018-12-07T12:00:00Z
lastmod: 2018-12-07T12:00:00Z
comment: true
adsense: true
---

### 1. VRRP (Virtual Router Redundancy Protocol)

![]({{site.baseurl}}/images/theory_analysis/VRRP/One_Router.PNG){: width="500px"}

VRRP(Virtual Router Redundancy Protocol)는 Gateway Router의 Single Point of Failure를 방지하기 위한 기법이다. 위의 왼쪽 그림은 Gateway Router가 하나일때를 나타내고 있다. Router의 동작이 멈춘다면 Host A, Host B는 External Network와 단절된다. 직관적으로 떠오르는 해결 방법은 여분의 Router를 추가하는 것이다. 하지만 Router 추가만으로는 Single Point of Failure 문제를 해결 할 수 없다.

위의 오른쪽 그림은 IP가 10.0.0.2인 Router B를 단순히 추가 하였을때를 나타내고 있다. Router를 추가하였어도 Host A, Host B의 Default Gateway는 10.0.0.1로 설정되어 있기 때문에 External Network로 나가는 Host A, Host B의 Packet은 Router B로 전달되지 않는다. 이러한 문제를 해결하기 위해서는 VRRP를 도입해야한다.

![]({{site.baseurl}}/images/theory_analysis/VRRP/VRRP.PNG){: width="700px"

위의 그림은 2대의 Router가 있을 경우 VRRP의 동작을 나타내고 있다. VRRP를 통해서 여러대의 Router를 Host에게 하나의 **Virtual Router**처럼 보이게 만들 수 있다. Network 관리자는 각 Router에 **VRID**와 **Priority**를 설정한다. 위의 그림에서는 두 Router에 VRID를 모두 1로 설정하여 2개의 Router가 하나의 Virtual Router로 동작하도록 설정하였다. Priority는 각 Router마다 다른 값을 설정해야 한다. Priority가 높은 Router가 Master Router가 되고 Priority가 낮은 Router가 Backup Router가 된다.

또한 Network 관리자는 VRRP 설정시 Virtual Router가 이용할 **Virtual IP**를 설정한다. 위의 그림에서는 10.0.0.1로 설정되어 있다. Virtual Router의 Virtual MAC은 **0000.5e00.01{VRID}**의 규칙에 따라서 0000.5e00.0101를 이용한다. Master Router는 Host로 부터 ARP Request가 오면 ARP Response를 Host에게 전달하여, Internal Network를 구성하는 Switch가 Dest MAC이 Virtual MAC인 Packet을 Master Router로 전달되도록 한다. 또한 Master Router는 Backup Router에게 주기적으로 **VRRP Advertisement Packet**을 전송하여 Master Router가 정상 동작한다는 것을 Backup Router에게 알려준다. VRRP Advertisement Packet 전송 주기는 Router에서 설정가능하다.

만약 Master Router가 장애로 동작을 중단하면 VRRP Advertisement Packet이 Backup Router로 전달되지 않기 때문에, Backup Router는 Master Router의 장애를 파악하고 자신이 Master Router가 된다. Backup Router는 Master Router가 되고난뒤 Internal Network에게 **GARP (Gratuitous ARP)**를 전송하여, Internal Network를 구성하는 Switch가 Dest MAC이 Virtual MAC인 Packet을 새로운 Master Router로 전달되도록 한다.

### 2. 참조

* [https://www.slideshare.net/netmanias-ko/netmanias20080324-vrrp-protocoloverview](https://www.slideshare.net/netmanias-ko/netmanias20080324-vrrp-protocoloverview)
* [http://www.rfwireless-world.com/Terminology/Virtual-MAC-Address-vs-Physical-MAC-Address.html](http://www.rfwireless-world.com/Terminology/Virtual-MAC-Address-vs-Physical-MAC-Address.html)
* [http://www.h3c.com.hk/Technical_Support___Documents/Technical_Documents/Routers/H3C_SR8800_Series_Routers/Configuration/Operation_Manual/H3C_SR8800_CG-Release3347-6W103/11/201211/761953_1285_0.htm](http://www.h3c.com.hk/Technical_Support___Documents/Technical_Documents/Routers/H3C_SR8800_Series_Routers/Configuration/Operation_Manual/H3C_SR8800_CG-Release3347-6W103/11/201211/761953_1285_0.htm)