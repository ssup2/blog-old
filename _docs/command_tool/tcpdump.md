---
title: tcpdump
category: Command, Tool
date: 2019-09-14T12:00:00Z
lastmod: 2019-09-14T12:00:00Z
comment: true
adsense: true
---

packet을 Dump하는 tcpdump의 사용법을 정리한다.

### 1. tcmpdump

* tcpdump -i [Interface] tcp port [Port] : [Interface]로 TCP [Port]로 통신하는 In/Out Packet을 Dump한다.
* tcmpdump -i [Interface] src port [Port] : Src Port가 [Port]인 Packet을 Dump한다.
* tcmpdump -i [Interface] dst port [Port] : Dst Port가 [Port]인 Packet을 Dump한다.


