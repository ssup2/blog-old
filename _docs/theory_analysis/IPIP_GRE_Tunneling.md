---
title: IP-in-IP, GRE Tunneling
category: Theory, Analysis
date: 2017-01-14T12:00:00Z
lastmod: 2017-01-15T12:00:00Z
comment: true
adsense: true
---

Network Tunneling 기법인 IP-in-Ip 기법과 GRE 기법을 분석한다.

### 1. IP-in-IP

![[그림 1] IP-in-IP Header]({{site.baseurl}}/images/theory_analysis/IPIP_GRE_Tunneling/IPIP_Header.PNG){: width="450px"}

IP-in-IP는 IP기반 Tunneling 기법이다. [그림 1]은 IP-in-IP의 Header를 나타내고 있다. 원본 IP Header위에 **Outer IP Header**를 붙여 네트워크 통과하는 방식이다.

![[그림 2] IP-in-IP 처리과정]({{site.baseurl}}/images/theory_analysis/IPIP_GRE_Tunneling/IPIP_Process.PNG)

[그림 2]는 IP-in-IP가 처리되는 과정을 나타내고 있다. PC에서 전송된 Packet은 Routing 규칙에 따라서 출발지 Tunnel에 전송된다. Tunnel은 Packet의 Dst IP와 Tunnel에 설정된 Mapping Table을 참조하여 목적지 Tunnel의 IP를 알아낸다. 그뒤 원본 IP Header 위에 Dst IP는 목적지 Tunnel의 IP를 갖고 Src IP는 출발지 Tunnel의 IP를 갖는 Outer IP Header를 붙여 캡슐화한다. 목적지 Tunnel은 캡슐화된 Packet을 받으면 Outer IP Header를 제거한뒤 Packet을 목적지에 전달한다.

### 2. GRE (Generic Routing Encapsulation)

![[그림 3] GRE Header]({{site.baseurl}}/images/theory_analysis/IPIP_GRE_Tunneling/GRE_Header.PNG){: width="600px"}

GRE(Generic Routing Encapsulation)는 IP-in-IP와 유사한 방식의 Tunneling Protocol이다. IP-in-IP와 동일하게 원본 Packet에 Outer IP Header를 붙여 Tunneling을 수행한다. IP-in-IP와의 차이점은 원본 IP Header와 Outer IP Header 사이에 **GRE Header**가 추가된다는 점이다. [그림 3]은 GRE Header를 나타내고 있다.

* C : Checksum Bit이며 1일경우 Checksum을 이용한다.
* K : Key Bit이며 1일경우 Key를 이용한다.
* S : Sequence Number Bit이며 1일경우 Sequence Number를 이용한다.
* Version : GRE Version을 나타낸다.
* Protocol Type : 캡슐화된 Packet의 Ethertype을 나타낸다.
* Key : 필요에 따라 정보를 저장한다.

GRE Header를 바탕으로 IP-in-IP 보다 좀더 많은 기능을 지원한다. 원본 Packet이 UDP를 이용하더라도 Sequence Number와 Checksum을 이용하여 Packet의 무결성을 검사할 수 있다. 또한 Key값을 이용하여 Packet의 보안을 향상시킬수 있다. IP-in-IP가 지원하지 않는 Multicast도 지원한다.

### 3. 참조

* IPIP : [http://cizz.net/lartc/lartc.tunnel.ip-ip.html](http://cizz.net/lartc/lartc.tunnel.ip-ip.html)
* GRE : [http://cizz.net/lartc/lartc.tunnel.gre.html](http://cizz.net/lartc/lartc.tunnel.gre.html)
* GRE : [https://en.wikipedia.org/wiki/Generic_Routing_Encapsulation](https://en.wikipedia.org/wiki/Generic_Routing_Encapsulation)
