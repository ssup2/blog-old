---
title: TCP Handshake
category: Theory, Analysis
date: 2021-03-20T12:00:00Z
lastmod: 2021-03-20T12:00:00Z
comment: true
adsense: true
---

TCP Handshake를 분석한다.

### 1. TCP Handshake

#### 1.1. TCP 3Way, 4Way Handshake

![[그림 1] TCP 3Way, 4Way Handshake]({{site.baseurl}}/images/theory_analysis/TCP_Handshake/TCP_3way_4way_Handshake.PNG){: width="750px"}

{% highlight console %}
12:49:33.192719 IP 192.168.0.60.39002 > 192.168.0.61.80: Flags [S], seq 284972257, win 64240, options [mss 1460,sackOK,TS val 2670079469 ecr 0,nop,wscale 7], length 0
12:49:33.192983 IP 192.168.0.61.80 > 192.168.0.60.39002: Flags [S.], seq 1986854381, ack 284972258, win 65160, options [mss 1460,sackOK,TS val 1699876837 ecr 2670079469,nop,wscale 7], length 0
12:49:33.193013 IP 192.168.0.60.39002 > 192.168.0.61.80: Flags [.], ack 1, win 502, options [nop,nop,TS val 2670079470 ecr 1699876837], length 0
12:49:33.193037 IP 192.168.0.60.39002 > 192.168.0.61.80: Flags [P.], seq 1:77, ack 1, win 502, options [nop,nop,TS val 2670079470 ecr 1699876837], length 76: HTTP: GET / HTTP/1.1
12:49:33.193256 IP 192.168.0.61.80 > 192.168.0.60.39002: Flags [.], ack 77, win 509, options [nop,nop,TS val 1699876837 ecr 2670079470], length 0
...
12:49:33.193389 IP 192.168.0.61.80 > 192.168.0.60.39002: Flags [P.], seq 239:851, ack 77, win 509, options [nop,nop,TS val 1699876838 ecr 2670079470], length 612: HTTP
12:49:33.193393 IP 192.168.0.60.39002 > 192.168.0.61.80: Flags [.], ack 851, win 501, options [nop,nop,TS val 2670079470 ecr 1699876838], length 0
12:49:33.193563 IP 192.168.0.60.39002 > 192.168.0.61.80: Flags [F.], seq 77, ack 851, win 501, options [nop,nop,TS val 2670079470 ecr 1699876838], length 0
12:49:33.193818 IP 192.168.0.61.80 > 192.168.0.60.39002: Flags [F.], seq 851, ack 78, win 509, options [nop,nop,TS val 1699876838 ecr 2670079470], length 0
12:49:33.193842 IP 192.168.0.60.39002 > 192.168.0.61.80: Flags [.], ack 852, win 501, options [nop,nop,TS val 2670079471 ecr 1699876838], length 0
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 1] TCP 3Way, 4Way Handshake</figcaption>
</figure>

[그림 1]은 TCP 3Way Handshake와 4Way Handshake를 나타내고 있고, [Console 1]은 tcpdump 명령어를 이용하여 TCP 3Way Handshake, 4Way Handshake 수행시 Packet을 Dump한 모습을 나타내고 있다. [Console 1]에서 Flags의 S는 Sync Flag, F는 Fin Flag, Dot(.)은 ACK를 나타낸다. 3Way Handshake는 TCP Connection을 생성하기 위한 Handshake이며, 4Way Handshake는 생성되어 있는 TCP Connection을 우아하게 종료하는 Handshake이다.

##### 1.1.1. 3Way Handshake

[그림 1]의 윗부분은 3Way Handshake를 나타낸다. Client를 시작으로 SYN, SYN+ACK, ACK Flag를 주고받으며 3Way Handshake를 수행한다. Client는 connect() System Call을 호출하여 Server에게 SYN Flag를 전송하고 SYN_SENT 상태가 된다. Client의 SYN_SENT 상태는 Server로부터 SYN+ACK Flag를 받거나 Timeout이 발생할 때까지 유지된다.

bind(), listen() System Call을 호출하여 LISTEN 상태가 된 Server는 Client에게 SYN Flag를 받은 다음 accept() System Call을 호출하여 Client에게 SYN+ACK Flag를 전송하고 SYN_RECEIVED 상태가 된다. Server의 SYN_RECEIVED 상태는 Client로부터 ACK 또는 Data Packet을 수신하거나 Timeout이 발생할 때까지 유지된다. SYN_SENT의 및 SYN_RECEIVED의 Timeout 값은 OS 설정마다 다르다.

Client의 connect() System Call 호출은 Server로부터 SYN+ACK Flag를 수신한 다음에 종료된다. 이후에 Client는 ESTABLISHED 상태가 되어 send()/recv() System Call 호출을 통해서 Server와 Data를 주고 받는다. Server의 accept() System Call 호출은 Client로 부터 ACK 또는 Data Packet을 수신하거나 SYN_RECEIVED의 Timeout에 의해서 종료된다.

Client가 전송한 ACK가 유실되어 Server가 Client의 ACK를 수신하지 못한 상태에서 Client가 전송한 Data Packet만 수신한 경우, Server는 Data Packet의 Sequence Number를 통해서 자신이 전송한 ACK+SYN Flag를 Client가 수신했다는 사실을 간접적으로 알 수 있다. 따라서 Client로부터 Data Packet을 수신하여도 Server의 accept() System Call 호출은 종료되고, Server는 ESTABLISHED 상태가 되어 send()/recv() System Call 호출을 통해서 Client와 Data를 주고 받는다.

##### 1.1.2. 4Way Handshake

[그림 1]의 아랫부분은 4Way Handshake를 나타낸다. Client 또는 Server의 FIN Flag를 시작으로 FIN, ACK Flag를 서로 주고받으며 4Way Handshake를 수행한다. 4Way Handshake를 시작한 Client 또는 Server는 FIN_WAIT_1 상태가 되며 상대로부터 ACK Flag를 받을때 까지 유지된다. FIN Flag를 받은 Client 또는 Server는 ACK Flag를 전송하고 CLOSE_WAIT 상태가 된다. CLOSE_WAIT는 이름에서 유츄할 수 있는것 처럼 Socket이 Close 될때까지 대기를 하는 상태를 의미한다. Socket이 Close가 되려면 App에서 close() System Call을 호출하거나 App Process가 종료되면 Kernel에서 Close한다.

Socket이 Close가 되면 상대에게 FIN Flag를 전송하고 LAST_ACK 상태가 된다. FIN_

이후에 일정 시간이 지난 이후에 상대에게 다시 FIN Flag를 전송하고 LAST_ACK 상태가 된다. 

CLOSE_WAIT는 이름에서 유츄할 수 있는것 처럼 Socket이 Close 될때까지 대기를 하는 상태를 

#### 1.2. TCP Reset

![[그림 2] TCP Reset at Connection Start]({{site.baseurl}}/images/theory_analysis/TCP_Handshake/TCP_Reset_Connection_Start.PNG){: width="550px"}

{% highlight console %}
13:32:50.672429 IP 192.168.0.60.33214 > 192.168.0.61.81: Flags [S], seq 292716723, win 64240, options [mss 1460,sackOK,TS val 2672676949 ecr 0,nop,wscale 7], length 0
13:32:50.672648 IP 192.168.0.61.81 > 192.168.0.60.33214: Flags [R.], seq 0, ack 292716724, win 0, length 0
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 2] TCP Reset at Connection Start</figcaption>
</figure>

TCP RST Flag는 예상치 못한 상황으로 인해서 생성된 TCP Connection을 급하게 종료할때 이용한다. [그림 2]는 Client가 TCP Connection을 생성하기 위해서 잘못된 IP/Port로 Sync Flag를 전송할 경우 발생하는 RST Flag를 나타내고 있고, [Console 2]는 이때의 실제 Packet을 tcpdump 명령어를 통해서 Dump한 모습이다. [Console 2]에서 Flags의 R은 RST Flag를 나타낸다. Client의 SYN Flag를 받은 Server는 RST Flag를 전송하여 바로 Connection을 종료한다.

![[그림 3] TCP Reset in Connection]({{site.baseurl}}/images/theory_analysis/TCP_Handshake/TCP_Reset_Connection.PNG){: width="550px"}

{% highlight console %}
14:22:47.003693 IP 192.168.0.60.59904 > 192.168.0.61.80: Flags [S], seq 2377770701, win 64240, options [mss 1460,sackOK,TS val 2675673280 ecr 0,nop,wscale 7], length 0
14:22:47.003932 IP 192.168.0.61.80 > 192.168.0.60.59904: Flags [S.], seq 3834916885, ack 2377770702, win 65160, options [mss 1460,sackOK,TS val 1705470647 ecr 2675673280,nop,wscale 7], length 0
14:22:47.003962 IP 192.168.0.60.59904 > 192.168.0.61.80: Flags [.], ack 1, win 502, options [nop,nop,TS val 2675673281 ecr 1705470647], length 0
14:22:48.071533 IP 192.168.0.60.43478 > 192.168.0.61.22: Flags [P.], seq 26216:26260, ack 124345, win 501, options [nop,nop,TS val 2675674348 ecr 2444573493], length 44
14:22:48.072274 IP 192.168.0.61.22 > 192.168.0.60.43478: Flags [P.], seq 124345:124669, ack 26260, win 501, options [nop,nop,TS val 2444589375 ecr 2675674348], length 324
14:22:48.072300 IP 192.168.0.60.43478 > 192.168.0.61.22: Flags [.], ack 124669, win 501, options [nop,nop,TS val 2675674349 ecr 2444589375], length 0
...
14:22:50.341815 IP 192.168.0.61.22 > 192.168.0.60.43478: Flags [P.], seq 125029:125097, ack 26376, win 501, options [nop,nop,TS val 2444591644 ecr 2675676617], length 68
14:22:50.341839 IP 192.168.0.60.43478 > 192.168.0.61.22: Flags [.], ack 125097, win 501, options [nop,nop,TS val 2675676619 ecr 2444591644], length 0
14:22:53.840281 IP 192.168.0.60.59904 > 192.168.0.61.80: Flags [P.], seq 1:3, ack 1, win 502, options [nop,nop,TS val 2675680117 ecr 1705470647], length 2: HTTP
14:22:53.840520 IP 192.168.0.61.80 > 192.168.0.60.59904: Flags [R], seq 3834916886, win 0, length 0
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 3] TCP Reset in Connection</figcaption>
</figure>

[그림 3]은 TCP Connection이 생성되어 있는 상태에서 Server가 먼저 RST Flag를 전송한 경우를 나타내고 있고, [Console 2]는 이때의 실제 Packet을 tcpdump 명령어를 통해서 Dump한 모습이다. RST Flag를 받은 Client는 더이상의 Handshake 없이 TCP Connection을 종료한다. 

### 2. 참조

* [http://intronetworks.cs.luc.edu/1/html/tcp.html](http://intronetworks.cs.luc.edu/1/html/tcp.html)
* [https://unix.stackexchange.com/questions/386536/when-how-does-linux-decides-to-close-a-socket-on-application-kill](https://unix.stackexchange.com/questions/386536/when-how-does-linux-decides-to-close-a-socket-on-application-kill)
* [https://unix.stackexchange.com/questions/282613/can-you-send-a-tcp-packet-with-rst-flag-set-using-iptables-as-a-way-to-trick-nma](https://unix.stackexchange.com/questions/282613/can-you-send-a-tcp-packet-with-rst-flag-set-using-iptables-as-a-way-to-trick-nma)
* [https://stackoverflow.com/questions/16259774/what-if-a-tcp-handshake-segment-is-lost](https://stackoverflow.com/questions/16259774/what-if-a-tcp-handshake-segment-is-lost)
* [https://tech.kakao.com/2016/04/21/closewait-timewait/](https://tech.kakao.com/2016/04/21/closewait-timewait/)
* [https://stackoverflow.com/questions/25338862/why-time-wait-state-need-to-be-2msl-long](https://stackoverflow.com/questions/25338862/why-time-wait-state-need-to-be-2msl-long)