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

#### 1.2. ethtool [Interface]

[Interface] NIC 정보를 출력한다.

~~~console
# ethtool eth0
Settings for eth0:
        Supported ports: [ ]
        Supported link modes:   Not reported
        Supported pause frame use: No
        Supports auto-negotiation: No
        Supported FEC modes: Not reported
        Advertised link modes:  Not reported
        Advertised pause frame use: No
        Advertised auto-negotiation: No
        Advertised FEC modes: Not reported
        Speed: 1000Mb/s
        Duplex: Full
        Port: Other
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: off
        Link detected: yes
~~~

#### 1.2. `ethtool [Interface] [speed 10|100|1000] [duplex half|full]` 

[Interface] NIC의 Bandwidth와 Duplex Mode를 설정한다.