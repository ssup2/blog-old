---
title: ethtool
category: Command, Tool
date: 2019-09-16T12:00:00Z
lastmod: 2019-09-16T12:00:00Z
comment: true
adsense: true
---

NIC의 통계 정보를 출력하는 nicstat의 사용법을 정리한다.

### 1. nicstat

* `nicstat` : 모든 NIC의 정보를 출력한다.
* `nicstat -i [Interface]` : [Interface] NIC의 정보를 출력한다.
* `nicstat -i [Interface] [Interval] [Count] ` : [Interface] NIC의 정보를 [Interval] 간격으로 [Count]만큼 반복한다.