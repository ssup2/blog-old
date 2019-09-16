---
title: netstat
category: Command, Tool
date: 2019-09-16T12:00:00Z
lastmod: 2019-09-16T12:00:00Z
comment: true
adsense: true
---

Network 통계 정보를 보여주는 netstat 사용법을 정리한다.

### 1. netstat

* `netstat` : 현재 Open되어 있는 모든 Socket의 정보를 출력한다.
* `netstat -i` : 각 Network Interface가 주고받은 Packet 정보를 출력한다.
* `netstat -nr` : Routing Table 정보를 출력한다.
* `netstat -plnt` : Listen 상태의 Port 및 Process 정보를 출력한다.