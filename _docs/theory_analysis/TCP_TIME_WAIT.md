---
title: TCP TIME_WAIT
category: Theory, Analysis
date: 2021-04-05T12:00:00Z
lastmod: 2021-04-05T12:00:00Z
comment: true
adsense: true
---

TCP TIME_WAIT 관련 동작을 분석한다.

### 1. TCP TIME_WAIT

![[그림 1] Packet Delay]({{site.baseurl}}/images/theory_analysis/TCP_TIME_WAIT/Packet_Delay.PNG){: width="500px"}

![[그림 2] Lost Last ACK]({{site.baseurl}}/images/theory_analysis/TCP_TIME_WAIT/Lost_Last_ACK.PNG){: width="550px"}

![[그림 3] DROP SYN Packet with Client SNAT]({{site.baseurl}}/images/theory_analysis/TCP_TIME_WAIT/Lost_Last_ACK.PNG){: width="700px"}

### 2. with Linux

#### 2.1. /proc/net/ipv4/tcp_timestamps

#### 2.2. /proc/net/ipv4/tcp_tw_reuse

#### 2.3. /proc/net/ipv4/tcp_tw_recycle

### 3. 참조

* [http://docs.likejazz.com/time-wait/](http://docs.likejazz.com/time-wait/)
* [https://meetup.toast.com/posts/55](https://meetup.toast.com/posts/55)