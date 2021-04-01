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

TIME_WAIT 상태는 Connection을 먼저 종료하는 Active Closer가 Connection 종료 후 도달하는 상태이다. Network 상에서 종료된 Connection 관련 Packet(Segment)이 완전히 제거 될때까지 대기하여, 이후에 생성되는 새로운 Connection에도 영향을 미치지 않기 위한 상태이다. 이러한 이유로 TCP 표준에서는 2MSL(2 * Maximum Segment Lifetime)만큼 유지되야 한다고 정의하고 있다.

![[그림 1] Packet Delay]({{site.baseurl}}/images/theory_analysis/TCP_TIME_WAIT/Packet_Delay.PNG){: width="500px"}

[그림 1]은 TIME_WAIT 상태가 짧을 경우 Packet Delay에 의해서 새로운 TCP Connection에 영향을 받는 상황을 나타내고 있다. Client가 전송한 SEQ=3인 Packet이 Server에게 바로 전달되지 않고 Network에 의해서 지연되는 상황에서, Client와 Server가 기존의 Connection을 종료하고 새로운 Connection을 맺는 상황이다. 이후에 이전 Connection의 지연된 SEQ=3 Packet이 Server에게 전달될 경우 새로운 Connection에 영향을 줄수 있다.

대부분의 경우에는 Server가 받아야하는 SEQ와 지연된 Packet의 SEQ가 다르기 때문에, 지연된 Packet은 Server에서 Drop되어 처리 되지만, [그림 1]의 상황처럼 SEQ 번호가 동일한 경우에는 TCP 무결성에 영향을 줄 수 있게 된다.

![[그림 2] Lost Last ACK in 4Way Handshake]({{site.baseurl}}/images/theory_analysis/TCP_TIME_WAIT/Lost_Last_ACK.PNG){: width="550px"}

[그림 2]는 TIME_WAIT 상태가 짧을 경우 TCP 4Way Handshake의 마지막 ACK Flag가 Server(Passive Closer)에게 전달되지 않아 Server가 LAST_ACK 상태를 유지하는 상황을 나타내고 있다. TIME_WAIT 상태가 짧을 경우 Server의 LAST_ACK 상태가 Timeout에 의해서 CLOSED 상태로 변경 되기전, Client는 새로운 Connection을 위해서 동일한 Port를 이용하여 Server에게 SYN Flag를 전송할 수 있다. LAST_ACK 상태의 Server는 SYN Flag를 받을 경우 RST FLAG를 전송하여 Connection 생성을 막기 때문에 Connection 생성에 실패하게 된다.

### 2. with Linux

#### 2.1. /proc/net/ipv4/tcp_timestamps

#### 2.2. /proc/net/ipv4/tcp_tw_reuse

Client

#### 2.3. /proc/net/ipv4/tcp_tw_recycle

![[그림 3] DROP SYN Packet with Client SNAT]({{site.baseurl}}/images/theory_analysis/TCP_TIME_WAIT/SNAT_SYN_Packet_Drop.PNG){: width="700px"}

### 3. 참조

* [http://docs.likejazz.com/time-wait/](http://docs.likejazz.com/time-wait/)
* [https://meetup.toast.com/posts/55](https://meetup.toast.com/posts/55)
* [https://brunch.co.kr/@alden/3](https://brunch.co.kr/@alden/3)
* [https://stackoverflow.com/questions/8893888/dropping-of-connections-with-tcp-tw-recycle](https://stackoverflow.com/questions/8893888/dropping-of-connections-with-tcp-tw-recycle)
* [https://man7.org/linux/man-pages/man7/tcp.7.html](https://man7.org/linux/man-pages/man7/tcp.7.html)