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

![[그림 2] TCP Handshake Connection State]({{site.baseurl}}/images/theory_analysis/TCP_Connection_State/TCP_Handshake_Connection_State.PNG){: width="750px"}

[그림 1]은 TCP Connection State Diagram을 나타내고 있고, [그림 2]는 TCP 3Way Handshake 및 4Way Handshake에 따른 TCP Connection State를 나타내고 있다. TCP 표준에서는 TCP 3Way Handshake 수행시 SYN Flag를 먼저 전송하는 Client를 Active Opener라고 명칭하고, 반대쪽인 Server를 Passive Opener라고 명칭한다. 또한 TCP 표준에서 TCP 4Way Handshake 수행시 FIN Flag를 먼저 전송하는 Client 또는 Server를 Active Closer라고 명칭하며, 반대쪽 Server를 Passive Closer라고 명칭한다. [그림 1]에서는 Client가 Active Closer라고 가정한 상태이다.

따라서 [그림 1]에서 Client가 SYN Flag를 전송하여 SYN_SENT 상태가 되는 과정을 "active open" 동작으로 나타내고 있고, Server가 LISTEN 상태가 되는 과정을 "passive open" 동작으로 나타내고 있다. 이와 유사하게 Client의 4Way Handshake 연관 상태들을 "active close" 과정으로 분류하고 있으며, Server의 4Way Handshake 연관 상태들을 "passive close" 과정으로 분류하고 있다.

2개의 App이 존재하고 있고 각 App은 Server와 Client의 역할을 동시에 수행할 수 있다. 그리고 2개의 App은 LISTEN 상태 이후에 서로에게 SYN Flag를 전송하여 서로 동시에 Connection을 맺으려고 할 수 있다. LISTEN 상태에서 SYN_SENT 상태를 지나 SYN_RECEIVED 상태가 되는 과정은 이와 같은 상황일때 발생한다. 이러한 상황을 "simultaneous open"이라고 명칭한다. 이와 유사하게 2개의 App이 동시에 Connection을 종료할 수도 있다. 이러한 상황을 "simultaneous close"라고 명칭하며, FIN_WAIT_1 상태에서 CLOSING 상태를 지나 TIME_WAIT 상태로 변경되는 과정에 해당한다.

#### 1.1. LISTEN

LISTEN 상태는 Server가 Clinet로부터 SYN Flag를 받아서 새로운 Connection을 생성할 수 있는 상태를 의미한다. Linux 환경에서 Server는 Server는 bind(), listen() System Call 호츨을 통해서 LISTEN 상태가 될 수 있다.

#### 1.2. SYN_SENT

SYN_SENT 상태는 Closed 상태의 Client가 SYN Flag를 전송하고 전환되는 상태이다. Linux 환경에서 Client는 connect() System Call 호출을 통해서 SYN 상태가 될 수 있다. 또한 Linux 환경에서는 최대 RTO (Retransmission Timeout) 간격으로 * "/proc/sys/net/ipv4/tcp_syn_retries" 값의 횟수만큼 SYN Flag를 전송하며 대기한다. "/proc/sys/net/ipv4/tcp_syn_retries"의 기본값은 "6"이다.

#### 1.3. SYN_RECEIVED

SYN_RECEIVED 상태는 LISTEN 상태의 Server가 Client로부터 SYN Flag를 수신할 경우 Client에게 SYN+ACK Flag를 전송한 후 전환되는 상태이다. Linux 환경에서는 Server는 accept() System Call을 호출을 통해서 SYN_RECEIVED 상태가 될 수 있다. 또한 Linux 환경에서는 최대 RTO (Retransmission Timeout) 간격으로 * "/proc/sys/net/ipv4/tcp_synack_retries" 값의 횟수만큼 SYN Flag를 전송하며 대기한다. "/proc/sys/net/ipv4/tcp_synack_retries"의 기본값은 "5"이다.

#### 1.4. ESTABLISHED

ESTABLISHED 상태는 3Way Handshake 이후에 Connection이 맺어져 Server와 Cilent가 되는 상태이다. ESTABLISHED 상태에서 Server와 Client는 Data를 주고 받을 수 있다. Linux 환경에서는 send(), recv() System Call 호출을 통해서 Data를 주고 받을수 있다.

Linux 환경에서는 Socket에 SO_KEEPALIVE Option을 설정할 수 있다. Server 또는 Client는 SO_KEEPALIVE Option이 설정된 Socket으로 오랜 시간동안 Data를 주고 받지 않을 경우, ACK와 함께 Data가 비어있는 Packet인 Probe Packet을 주기적으로 상대방에게 전송하여 TCP Connection이 유효한지 확인한다. Probe Packet을 수신한 Server 또는 Client는 Connection이 아직 유효할 경우 ACK를 전송하고, Connection이 유효하지 않을경우 RST Flag를 전송하여 상대방이 Connection 정보를 제거하도록 만든다. 이러한 기법을 TCP Keepalived라고 명칭한다.

Linux 환경에서는 SO_KEEPALIVE Option이 설정된 Socket에서 "/proc/sys/net/ipv4/tcp_keepalive_time" 값의 시간 만큼 Data를 주고 받지 않는경우에는 Probe Packet을 전송한다. 만약 Probe Packet에 대한 응답을 받지 못하는 경우 최대 "/proc/sys/net/ipv4/tcp_keepalive_probes" 값의 횟수만큼 "/proc/sys/net/ipv4/tcp_keepalive_intvl" 간격으로 Probe Packet을 반복해서 전송한다. "/proc/sys/net/ipv4/tcp_keepalive_time"의 기본값은 "7200(초)", "/proc/sys/net/ipv4/tcp_keepalive_probes"의 기본값은 "9", "/proc/sys/net/ipv4/tcp_keepalive_intvl"의 기본값은 "72(초)"이다.

#### 1.5. FIN_WAIT_1

FIN_WAIT_1 상태는 ESTABLISHED 상태의 Active Closer가 종료되면 전환되는 상태이다. Active Closer가 FIN_WAIT_1 상태가 된 이후에 Passive Closer에게 FIN Flag를 전송한다. Linux 환경에서 Active Closer가 close() System Call을 호출하거나 Active Closer의 Process가 종료되면 Active Closer의 Socket은 Close되기 때문에 Active Closer는 FIN Flag를 전송하고 FIN_WAIT_1 상태가 된다.

또한 Linux 환경에서 FIN_WAIT_1의 Timeout은 존재하지 않으며 Passive Closer로 ACK FLAG를 전달받아 FIN_WAIT_2 상태가 되거나, Linux Kernel이 저장하고 있는 전체 FIN_WAIT_1 상태의 개수가 특정 개수 이상이 되어 Linux Kernel로 부터 제거되기 전까지는 계속 남아 있게된다. Linux Kenrel이 저장할 수 있는 상태의 개수는 "/proc/sys/net/ipv4/tcp_max_orphans"의 값에 설정되어 있다. "/proc/sys/net/ipv4/tcp_max_orphans"의 기본값은 16384이다.

#### 1.6. FIN_WAIT_2

FIN_WAIT_2 상태는 FIN_WAIT_1 상태의 Active Closer가 Passive Closer에게 ACK FLAG를 수신하고 전환되는 상태이다. Linux 환경에서 FIN_WAIT_2 상태는 Passive Closer로부터 FIN Flag를 전달받아 TIME_WAIT 상태가 되거나, Linux Kernel이 설정하고 있는 FIN_WAIT_2의 Timeout 시간이 지날때까지 유지된다. Linux Kernel의 FIN_WAIT_2의 Timeout은 "/proc/sys/net/ipv4/tcp_fin_timeout"에 설정되며 기본값은 "60(초)"이다.

#### 1.7. TIME_WAIT

TIME_WAIT 상태는 FIN_WAIT_2 상태의 Active Closer가 Passive Closer에게 FIN FLAG를 수신하고 전환되는 상태이다. TIME_WAIT 상태는 TCP 표준에는 2MSL(2 * Maximum Segment Lifetime)만큼 유지되야 한다고 정의하고 있다. 즉 Network 상에서 제거된 Connection 관련 Packet(Segment)이 완전히 제거 될때까지 대기하여, 안전하게 Connection 종료 및 이후에 생성되는 새로운 Connection에도 영향을 미치지 않기 위한 상태이다. 

Linux 환경에서는 TIME_WAIT 상태는 60초 동안 지속되며, Code에 설정되어 있기 때문에 변경할 수 없다. 또한 Linux 환경에서 Socket(Port)이 부족한 경우 TIME_WAIT 상태의 Socket을 재사용 할수 있는 Option을 제공하고 있다. 관련 Option은 "/proc/sys/net/ipv4/tcp_tw_reuse" 값을 "1"로 설정하면 된다.

#### 1.8. CLOSING

CLOSING 상태는 simultaneous close가 발생하여 FIN_WAIT_1 상태의 ACTIVE Closer가 FIN Flag를 수신하였을때 전환되는 상태이다.

#### 1.9. CLOSE_WAIT

CLOSE_WAIT 상태는 Passive Closer가 Active Closer로부터 FIN Flag를 수신하고 전환되는 상태이다. Linux 환경에서 Passive Closer가 close() System Call을 호출하거나 Passive Closer의 Process가 종료되면 Passive Closer의 Socket은 Close되기 때문에 Passive Closer는 FIN Flag를 전송하고 LASK_ACK 상태가 된다. Linux 환경에서 CLOSE_WAIT 상태는 Timeout이 존재하지 않으며, 반드시 Passive Closer의 Socket이 Close 되어야 LASK_ACK가 되면서 종료된다.

#### 1.10. LAST_ACK

LAST_ACK 상태는 CLOSE_WAIT 상태의 Passive Closer가 FIN Flag를 Active Closer에게 전송한후 이에 대한 ACK를 받기 전까지 유지되는 상태이다.

### 2. 참조

* [https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.1.0/com.ibm.zos.v2r1.halu101/constatus.htm](https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.1.0/com.ibm.zos.v2r1.halu101/constatus.htm)
* [https://m.blog.naver.com/PostView.nhn?blogId=jgenius&logNo=221124990186&categoryNo=0&proxyReferer=&proxyReferer=https:%2F%2Fwww.google.com%2F](https://m.blog.naver.com/PostView.nhn?blogId=jgenius&logNo=221124990186&categoryNo=0&proxyReferer=&proxyReferer=https:%2F%2Fwww.google.com%2F)
* [http://intronetworks.cs.luc.edu/1/html/tcp.html](http://intronetworks.cs.luc.edu/1/html/tcp.html)
* [https://m.blog.naver.com/PostView.nhn?blogId=cmw1728&logNo=220448146710&proxyReferer=https:%2F%2Fwww.google.com%2F](https://m.blog.naver.com/PostView.nhn?blogId=cmw1728&logNo=220448146710&proxyReferer=https:%2F%2Fwww.google.com%2F)
* [https://stackoverflow.com/questions/25338862/why-time-wait-state-need-to-be-2msl-long](https://stackoverflow.com/questions/25338862/why-time-wait-state-need-to-be-2msl-long)
* [https://stackoverflow.com/questions/2231283/tcp-two-sides-trying-to-connect-simultaneously](https://stackoverflow.com/questions/2231283/tcp-two-sides-trying-to-connect-simultaneously)
* [https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt](https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt)