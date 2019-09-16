---
title: iostat
category: Command, Tool
date: 2019-09-16T12:00:00Z
lastmod: 2019-09-16T12:00:00Z
comment: true
adsense: true
---

I/O 통계 정보를 보여주는 iostat 사용법을 정리한다.

### 1. iostat

* `iostat` : 현재 I/O 통계 정보를 출력한다.
* `iostat [Interval] [Count]` : [Interval] 간격으로 [Count] 횟수만큼 I/O 통계 정보를 출력한다.
* `iostat -c` : CPU 통계 정보만 출력한다.
* `iostat -d` : Disk 장치 정보만 출력한다.
* `iostat -x` : 확장된 통계 정보를 출력한다.
* `iostat -k` : 초당 블록 수 대신 초당 kb로 출력한다.
* `iostat -m` : 초당 블록 수 대신 초당 Mb로 출력한다.