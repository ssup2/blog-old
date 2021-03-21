---
title: TCP Connection State
category: Theory, Analysis
date: 2021-03-17T12:00:00Z
lastmod: 2021-03-17T12:00:00Z
comment: true
adsense: true
---

TCP Connection State를 분석한다.

### 1. TCP Connection State

![[그림 1] TCP Connection State Diagram]({{site.baseurl}}/images/theory_analysis/TCP_Connection_State/TCP_Connection_State_Diagram.PNG)

![[그림 2] TCP Handshake Connection State]({{site.baseurl}}/images/theory_analysis/TCP_Connection_State/TCP_Handshake_Connection_State.PNG){: width="550px"}

#### 1.X. SYN_SENT

Linux의 경우에는 최대 RTO (Retransmission Timeout) 간격으로 * "/proc/sys/net/ipv4/tcp_syn_retries" 값의 횟수만큼 SYN Flag를 전송하며 대기한다. "/proc/sys/net/ipv4/tcp_syn_retries"의 기본값은 "6"이다.

#### 1.X. SYN_RECEIVED

Linux의 경우에는 최대 RTO (Retransmission Timeout) 간격으로 * "/proc/sys/net/ipv4/tcp_synack_retries" 값의 횟수만큼 SYN Flag를 전송하며 대기한다. "/proc/sys/net/ipv4/tcp_synack_retries"의 기본값은 "5"이다.

#### 1.X. FIN_WAIT_1

cat /proc/sys/net/ipv4/tcp_max_orphans
cat /proc/sys/net/ipv4/tcp_orphan_retries

#### 1.X. CLOSE_WAIT

### 2. 참조

* [https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.1.0/com.ibm.zos.v2r1.halu101/constatus.htm](https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.1.0/com.ibm.zos.v2r1.halu101/constatus.htm)
* [https://m.blog.naver.com/PostView.nhn?blogId=jgenius&logNo=221124990186&categoryNo=0&proxyReferer=&proxyReferer=https:%2F%2Fwww.google.com%2F](https://m.blog.naver.com/PostView.nhn?blogId=jgenius&logNo=221124990186&categoryNo=0&proxyReferer=&proxyReferer=https:%2F%2Fwww.google.com%2F)
* [http://intronetworks.cs.luc.edu/1/html/tcp.html](http://intronetworks.cs.luc.edu/1/html/tcp.html)
* [https://m.blog.naver.com/PostView.nhn?blogId=cmw1728&logNo=220448146710&proxyReferer=https:%2F%2Fwww.google.com%2F](https://m.blog.naver.com/PostView.nhn?blogId=cmw1728&logNo=220448146710&proxyReferer=https:%2F%2Fwww.google.com%2F)
* [https://stackoverflow.com/questions/25338862/why-time-wait-state-need-to-be-2msl-long](https://stackoverflow.com/questions/25338862/why-time-wait-state-need-to-be-2msl-long)