---
title: tcpdump
category: Command, Tool
date: 2019-09-14T12:00:00Z
lastmod: 2019-09-14T12:00:00Z
comment: true
adsense: true
---

Packet을 Dump하는 tcpdump의 사용법을 정리한다.

***

* TOC
{:toc}

***

### 1. tcmpdump

#### 1.1. # tcpdump -i [Interface] tcp port [Port]

[Interface]로 송수신하는 Packet중에서, TCP Protocol을 이용하고 Src/Dst Port 번호가 [Port]인 Packet을 Dump한다.

#### 1.2. # tcpdump -i [Interface] src port [Port]

[Interface]로 송수신하는 Packet중에서 Src Port가 [Port]인 Packet을 Dump한다.

#### 1.3. # tcpdump -i [Interface] dst port [Port]

[Interface]로 송수신하는 Packet중에서 Dst Port가 [Port]인 Packet을 Dump한다.

#### 1.4. # tcpdump -i [Interface] -Q in

[Interface]로 수신하는 Packet을 Dump한다.

#### 1.5. # tcpdump -i [Interface] -Q out

[Interface]로 송신하는 Packet을 Dump한다.
