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

[그림 1]은 TCP Connection State Diagram을 나타내고 있고, [그림 2]는 TCP 3Way Handshake 및 4Way Handshake에 따른 TCP Connection State를 나타내고 있다. TCP 표준에서는 TCP 3Way Handshake 수행시 SYN Flag를 먼저 전송하는 Client를 Active Opener라고 명칭하고, 반대쪽인 Server를 Passive Opener라고 명칭한다. 또한 TCP 표준에서 TCP 4Way Handshake 수행시 FIN Flag를 먼저 전송하는 Client 또는 Server를 Active Closer라고 명칭하며, 반대쪽 Server를 Passive Closer라고 명칭한다. [그림 1]에서는 Client가 Active Closer라고 가정한 상태이다.

따라서 [그림 1]에서 Client가 SYN Flag를 전송하여 SYN_SENT 상태가 되는 과정을 "active open" 동작으로 나타내고 있고, Server가 LISTEN 상태가 되는 과정을 "passive open" 동작으로 나타내고 있다. 이와 유사하게 Client의 4Way Handshake 연관 상태들을 "active close" 과정으로 분류하고 있으며, Server의 4Way Handshake 연관 상태들을 "passive close" 과정으로 분류하고 있다.

#### 1.1. LISTEN

#### 1.2. SYN_SENT

Linux의 경우에는 최대 RTO (Retransmission Timeout) 간격으로 * "/proc/sys/net/ipv4/tcp_syn_retries" 값의 횟수만큼 SYN Flag를 전송하며 대기한다. "/proc/sys/net/ipv4/tcp_syn_retries"의 기본값은 "6"이다.

#### 1.3. SYN_RECEIVED

Linux의 경우에는 최대 RTO (Retransmission Timeout) 간격으로 * "/proc/sys/net/ipv4/tcp_synack_retries" 값의 횟수만큼 SYN Flag를 전송하며 대기한다. "/proc/sys/net/ipv4/tcp_synack_retries"의 기본값은 "5"이다.

#### 1.4. ESTABLISHED

#### 1.5. FIN_WAIT_1

#### 1.6. FIN_WAIT_2

#### 1.7. TIME_WAIT

#### 1.8. CLOSING

#### 1.9. CLOSE_WAIT

cat /proc/sys/net/ipv4/tcp_max_orphans
cat /proc/sys/net/ipv4/tcp_orphan_retries

#### 1.10. LASK_ACK

### 2. 참조

* [https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.1.0/com.ibm.zos.v2r1.halu101/constatus.htm](https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.1.0/com.ibm.zos.v2r1.halu101/constatus.htm)
* [https://m.blog.naver.com/PostView.nhn?blogId=jgenius&logNo=221124990186&categoryNo=0&proxyReferer=&proxyReferer=https:%2F%2Fwww.google.com%2F](https://m.blog.naver.com/PostView.nhn?blogId=jgenius&logNo=221124990186&categoryNo=0&proxyReferer=&proxyReferer=https:%2F%2Fwww.google.com%2F)
* [http://intronetworks.cs.luc.edu/1/html/tcp.html](http://intronetworks.cs.luc.edu/1/html/tcp.html)
* [https://m.blog.naver.com/PostView.nhn?blogId=cmw1728&logNo=220448146710&proxyReferer=https:%2F%2Fwww.google.com%2F](https://m.blog.naver.com/PostView.nhn?blogId=cmw1728&logNo=220448146710&proxyReferer=https:%2F%2Fwww.google.com%2F)
* [https://stackoverflow.com/questions/25338862/why-time-wait-state-need-to-be-2msl-long](https://stackoverflow.com/questions/25338862/why-time-wait-state-need-to-be-2msl-long)