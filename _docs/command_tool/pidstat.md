---
title: pidstat
category: Command, Tool
date: 2019-09-14T12:00:00Z
lastmod: 2019-09-14T12:00:00Z
comment: true
adsense: true
---

process별 Resource 사용량을 출력하는 pidstat의 사용법을 정리한다.

### 1. pidstat

* `pidstat [Interval]` : Interval 간격으로 CPU 사용량을 출력한다.
* `pidstat [Interval] [Count]` : Interval 간격으로 Count 횟수 만큼 CPU 사용량을 출력한다.
* `pidstat -p [PID] [Interval]` : Interval 간격으로 [PID] Process의 CPU 사용량을 출력한다.
* `pidstat -p [PID] -t [Interval]` : Interval 간격으로 [PID] Process Thread의 CPU 사용량을 출력한다.

* `pidstat -d [Interval]` : Interval 간격으로 Disk I/O 사용량을 출력한다.
* `pidstat -r [Interval]` : Interval 간격으로 Memory 사용량을 출력한다.
* `pidstat -s [Interval]` : Interval 간격으로 Stack 사용량을 출력한다.
* `pidstat -v [Interval]` : Interval 간격으로 Kernel Table (User, Thread Count, FD Count) 정보를 출력한다.
* `pidstat -w [Interval]` : Interval 간격으로 Context Switch 정보를 출력한다.
