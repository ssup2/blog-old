---
title: ethtool
category: Command, Tool
date: 2019-09-16T12:00:00Z
lastmod: 2019-09-16T12:00:00Z
comment: true
adsense: true
---

NIC을 제어하는 ethtool 사용법을 정리한다.

### 1. ethtool

* `ethtool [Interface]` : [Interface] NIC 정보를 출력한다.
* `ethtool [Interface] [speed 10|100|1000] [duplex half|full]` : [Interface] NIC의 Bandwidth와 Duplex Mode를 설정한다.