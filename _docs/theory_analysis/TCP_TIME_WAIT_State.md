---
title: TCP TIME_WAIT State
category: Theory, Analysis
date: 2021-04-05T12:00:00Z
lastmod: 2021-04-05T12:00:00Z
comment: true
adsense: true
---

TCP TIME_WAIT 관련 동작을 분석한다.

### 1. TCP TIME_WAIT

TIME_WAIT 상태는 Connection을 먼저 종료하는 Active Closer가 Connection 종료 후 도달하는 상태이다. Connection이 종료되었지만 Network에 남아 있을 수 있는 종료된 Connection의 Packet이 완전히 제거 될때까지 대기하여, 이후에 생성되는 새로운 Connection에 영향을 미치지 않기 위하는 용도로 이용되는 상태이다. 이러한 이유로 TCP 표준에서는 2MSL(2 * Maximum Segment Lifetime)만큼 유지되야 한다고 정의하고 있으며, TIME_WAIT 상태가 끝나기 전까지 TIME_WAIT가 선점하고 있는 Local IP/Port를 이용하여 새로운 Conneciton을 맺을수 없다.

{% highlight console %}
(client)$ echo 30000 30000 > /proc/sys/net/ipv4/ip_local_port_range
(client)$ curl 192.168.0.60:80
DATA
...

(client)$ netstat -na | grep 192.168.0.60
tcp        0      0 192.168.0.61:30000      192.168.0.60:80         TIME_WAIT
...

(client)$ curl 192.168.0.60:80
curl: (7) Couldn't connect to server
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] TIME_WAIT State through curl(Client)</figcaption>
</figure>

[Shell 1]은 curl 명령어를 이용하여 Client가 동작하는 Linux에서 TIME_WAIT 상태를 재현하는 과정을 나타내고 있다. curl 명령어는 Server에게 요청을 전송하고 응답을 받은면 먼저 Connection을 종료하는 Active Closer 역할을 수행한다. 따라서 curl 명령어를 수행한 후에 TIME_WAIT 상태를 확인할 수 있다. 이후에 두번째 curl 명령어를 통해서 동일하게 Server에게 요청하였지만 Error와 함께 동작하지 않는것을 확인할 수 있다.

[Shell 1]에서 curl 명령어는 Local IP/Port로 192.168.0.61:30000를 이용하여 192.168.0.60:80 Server와 Connection을 맺었기 때문에, 192.168.0.61:30000/192.168.0.60:80 Connection은 TIME_WAIT 상태로 존재하는 것을 확인할 수 있다. 이 TIME_WAIT 상태가 종료되기 전까지 192.168.0.61:30000 IP/Port를 이용하여 192.168.0.60:80과 새로운 Connection을 맺을 수 없다. (다른 Local IP를 이용하여 192.168.0.60:80에 연결할 수 있다면, 다른 Local IP/30000를 통해서 192.168.0.60:80와 새로운 Connection을 맺을수는 있다.)

{% highlight console %}
(server)$ -na | grep 192.168.0.61
tcp        0      0 192.168.0.60:80         192.168.0.61:30000      TIME_WAIT

(client)$ echo 30000 30000 > /proc/sys/net/ipv4/ip_local_port_range
(client)$ curl 192.168.0.60:80
OK
...

(server)$ -na | grep 192.168.0.61
Empty
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] TIME_WAIT State with curl(Client)</figcaption>
</figure>

일반적으로 Connection이 맺어진 Server와 Client 사이에서는 Client가 먼저 Connection을 종료하는 경우가 많다. 하지만 상황에 따라서는 Server가 먼저 Connection을 종료하는 경우도 발생하기 때문에 Server에도 TIME_WAIT 상태가 발생할 수 있다. 다만 Server에 존재하는 TIME_WAIT 상태의 Connection으로 동일한 새로운 Connection 요청이 들어오면 기존의 TIME_WAIT 상태의 Connection을 제거하고 새로운 Connection을 맺는다. 따라서 Server에 존재하는 TIME_WAIT 상태의 Connection은 Server의 Connection을 방해하지 않는다.

#### 1.1. TCP Connection Issue with Short TIME_WAIT State

![[그림 1] TCP Connection Issue with Packet Delay]({{site.baseurl}}/images/theory_analysis/TCP_TIME_WAIT_State/Packet_Delay.PNG){: width="500px"}

TIME_WAIT 상태가 짧을 경우에는 Packet Delay가 발생하거나, 4Way Handshake 과정에서 마지막 ACK Flag가 유실될 경우, 새로운 TCP Connection에 영향을 줄 수 있다. [그림 1]은 TIME_WAIT 상태가 짧을 경우 Packet Delay에 의해서 새로운 TCP Connection이 영향을 받는 상황을 나타내고 있다. [그림 1]에서 Client가 전송한 SEQ=3인 Packet이 Server에게 바로 전달되지 않고 Network에 의해서 지연되는 상황에서, Client와 Server가 기존의 Connection을 종료하고 새로운 Connection을 맺었다. 이후에 이전 Connection의 지연된 SEQ=3 Packet이 Server에게 전달되는 상황이다.

대부분의 경우에는 Server가 받아야 하는 SEQ와 지연된 Packet의 SEQ가 다르기 때문에, 지연된 Packet이 Server에게 전달되어도 Server에서는 Drop하기 때문에 문제가 발생하지 않는다. 하지만 [그림 1]의 상황처럼 Server가 수신해야 하는 SEQ와 지연된 Packet의 SEQ가 우연히 동일한 경우에는 Server는 지연된 Packet을 Drop하지 않고 수신할 수 있다. 이 경우 Data 무결성은 깨진다.

![[그림 2] TCP Connection Issue with Lost Last ACK in 4Way Handshake]({{site.baseurl}}/images/theory_analysis/TCP_TIME_WAIT_State/Lost_Last_ACK.PNG){: width="550px"}

[그림 2]는 TIME_WAIT 상태가 짧을 경우 TCP 4Way Handshake의 마지막 ACK Flag가 Server(Passive Closer)에게 전달되지 않아 Server가 LAST_ACK 상태를 유지하는 상황을 나타내고 있다. TIME_WAIT 상태가 짧을 경우 Server의 LAST_ACK 상태가 Timeout에 의해서 CLOSED 상태로 변경 되기전, Client는 새로운 Connection을 위해서 동일한 Local IP/Port를 이용하여 Server에게 SYN Flag를 전송할 수 있다. 문제는 LAST_ACK 상태의 Server는 SYN Flag를 받을 경우 RST FLAG를 전송하여 Connection 생성을 막기 때문에 새로운 Connection 생성은 실패한다. 이와 같은 이유 때문에 Client 입장에서는 예상하지 못한 Connection Error를 경험하게 된다.

### 2. Short TIME_WAIT in Linux

Linux에서는 기본적으로 TIME_WAIT 상태인 Connection은 60초 동안 지속되도록 Linux Kernel Code에 고정값으로 설정되어 있다. 비교적 긴 시간이기 때문에 TIME_WAIT 상태의 Connection이 많아지면 TIME_WAIT 상태의 Connection이 선점하고 있는 Local IP/Port로 인해서 이용할 수 있는 Local IP/Port가 존재하지 않아, Client가 새로운 Connection을 맺지 못하는 문제가 발생할 수 있다. 또한 TIME_WAIT 상태의 Connection이 많아질수록 Kernel 영역의 Memory를 점유하는 문제도 발생한다. 이러한 문제를 해결하기 위해서 Linux에서는 TIME_WAIT 짧게 만들수 있는 몇가지 기법을 제공하고 있다.

#### 2.1. tcp_timestamps (/proc/sys/net/ipv4/tcp_timestamps)

Linux에서 다수의 TIME_WAIT 상태의 Connection으로 인한 문제를 해결하기 위한 기법을 이해하기 위해서는 tcp_timestamps 설정을 이해해야 한다. tcp_timestamps 설정은 TCP Packet Header에 Timestamp를 설정하는 Option이다. 기본적으로 "1"로 설정되어 있어 Timestamp를 이용하도록 설정되어 있다. Timestamp Field는 Packet 송신자의 Timestamp를 저장하는 "TS Value Field"와 수신한 Packet의 TS Value Field를 복사하여 송신자에게 다시 전달하기 위한 목적으로 존재하는 "TS Echo Reply Field"가 존재한다.

아래에서 설명할 Linux에서 제공하는 tcp_tw_reuse, tcp_tw_recycle 설정은 TCP Header에 Timestamp값이 설정되어 있어야 제대로 동작한다. 따라서 tcp_tw_reuse, tcp_tw_recycle 설정을 제대로 동작시키기 위해서는 tcp_timestamps가 설정되어 있어서 TCP Header에 Timestamp 값이 설정되어 있어야 한다.

#### 2.2. tcp_tw_reuse (/proc/sys/net/ipv4/tcp_tw_reuse)

{% highlight console %}
(client)$ echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
(client)$ echo 30000 30000 > /proc/sys/net/ipv4/ip_local_port_range
(client)$ curl 192.168.0.60:80
OK
...

(client)$ netstat -na | grep 192.168.0.60
tcp        0      0 192.168.0.61:30000      192.168.0.60:80         TIME_WAIT
...

(client)$ curl 192.168.0.60:80
OK
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] TIME_WAIT State through curl(Client) with tcp_tw_reuse</figcaption>
</figure>

tcp_tw_reuse 설정은 TIME_WAIT 상태의 Connection을 재사용 할 수 있도록 만든다. 주로 Client에 설정되어 Client에 존재하는 TIME_WAIT 상태의 Connection을 재사용하기 위해서 이용된다. [Shell 3]에서는 tcp_tw_reuse을 설정한 다음 [Shell 1]과 같이 동일하게 curl 명령어를 통해서 2번 Server에게 요청을 전송한 과정을 나타내고 있다. [Shell 1]에서는 두번재 curl 요청은 실패했지만, [Shell 3]에서는 tcp_tw_reuse 설정으로 인해서 TIME_WAIT 상태의 192.168.0.61:30000/192.168.0.60:80 Connection을 재사용 할 수 있기 때문에, 두번째 curl 명령어도 성공한 것을 확인할 수 있다.

TIME_WAIT 상태가 짧아져 발생할 수 있는 [그림 1]과 [그림 2]의 문제는 TCP Packet Header에 포함되어 있는 Timestamp를 통해서 해결할 수 있다. TCP Packet에 Timestamp가 존재하면 Linux는 TCP Packet 수신시 SEQ뿐만 아니라 Timestamp 값도 비교한다. 만약 Timestamp가 오래된 Timestamp라면 해당 Packet은 Drop된다. 따라서 [그림 1]의 상황에서 Server는 지연된 Packet의 오래된 Timestamp를 보고 지연된 Packet을 Drop하게 된다.

[그림 1]의 상황에서 만약 지연된 Packet이 원래의 SEQ=3인 Packet 이후에 Server에게 전달되어도 Server는 Timestamp를 보고 지연된 Packet을 Drop하게 된다. 즉 동일한 SEQ를 갖는 Packet을 수신하는 상황이 발생하여도 TCP Packet의 Timestamp를 통해서 어느 Packet이 유효한지 알 수 있기 때문에 문제가 되지 않는다.

![[그림 3] Lost Last ACK Recovery with Timestamp in 4Way Handshake]({{site.baseurl}}/images/theory_analysis/TCP_TIME_WAIT_State/Lost_Last_ACK_Recovery.PNG){: width="550px"}

[그림 3]의 경우 [그림 2]과 동일한 상황에서 Packet의 Timestamp를 이용하여 Server의 LAST_ACK 상태를 종료하고, Client와 Server가 새로운 Connection을 맺는 과정을 나타내고 있다. [그림 3]이 [그림 2]와 다른점은 Server가 Packet의 Timestamp 확인을 통해서 Client에게 RST Flag를 전송하는 것이 아니라 SYN Flag를 무시하여 Client에게 아무런 응답 Packet을 전달하지 않는다는 점이다. 따라서 Client의 Connection 시도는 중단되지 않는다.

이후에 Server는 LAST_ACK 상태를 벗어나기 위해서 FIN Flag를 재전송 한다. Client 입장에서는 FIN Flag가 원하는 응답이 아니기 때문에 Server에게 SYN SYN Flag에 대한 응답으로 RST Flag를 전송한다. RST Flag를 전송받은 Server는 LAST_ACK 상태를 종료한다. Client의 Connection 시도는 중단되지 않았기 때문에 Client는 TCP Retranmission 정책에 의해서 1초 이후에 다시 SYN Flag를 Server에게 전송하여 Server와 Connection을 맺는다. 이러한 과정은 Client App에게는 노출되지 않고 처리된다.

#### 2.3. tcp_tw_recycle (/proc/sys/net/ipv4/tcp_tw_recycle)

tcp_tw_recycle 설정은 TIME_WAIT 상태를 60초가 아닌 TCP Connection의 RTO(Retransmission Timeout)만큼 줄여 TIME_WAIT 상태를 매우 짧게 만드는 설정이다. 주로 Server에 설정되어 Server에 존재하는 TIME_WAIT 상태의 Connection을 제거하기 위해서 이용된다. Linux에서 최소 RTO는 200ms이기 때문에 tcp_tw_recycle을 설정하면 TIME_WAIT 상태도 최소 200ms만 존재할 수 있다.

tcp_tw_recycle가 설정되면 Server는 Connection이 TIME_WAIT 상태가 되었을때 해당 Connection의 마지막 Timestamp를 저장한다. 이후에 Server가 동일한 IP/Port를 갖는 Client로부터 Packet을 수신하면 Server는 Packet의 Timestamp를 확인하고, Timestamp가 Server가 저장하고 있는 이전 Connection의 마지막 Timestamp와 비교한다. Server가 수신한 Packet의 Timestamp가 Server가 저장하고 있는 마지막 Timestamp보다 작다면 Server는 해당 Packet을 Drop한다. 

이러한 동작을 수행하는 이유는 TIME_WAIT 상태가 짧아지면서 [그림 1]과 같이 지연된 Packet이 발생 하였을때 지연된 Packet을 Drop할 수 있는 간단한 방법이기 때문이다. 하지만 이와 같이 Packet의 Timestamp만을 비교하여 Packet을 Drop하는 방식은 Client가 SNAT되어 Server와 통신하는 Network 환경에서는 문제가 발생할 수 있다.

![[그림 4] DROP Packet Issue with Client SNAT]({{site.baseurl}}/images/theory_analysis/TCP_TIME_WAIT_State/SNAT_SYN_Packet_Drop.PNG){: width="700px"}

[그림 4]는 tcp_tw_recycle 설정으로 인해서 Client가 SNAT 되어 Server와 통신하는 경우 발생할 수 있는 문제를 나타내고 있다. Client A와 Client B는 서로 다른 Timestamp를 가지고 있으며 Client A가 Client B보다 높은 Timestamp를 갖고 있는 상황이다. Client A가 먼저 SNAT를 통해서 Server와 Connection을 맺었다. 이후에 Client B도 SNAT를 통해서 Server와 Connection을 맺으려는 상황이다. 이때 Client B도 Client A와 동일한 SRC IP/Port로 SNAT 되었다. 따라서 Server는 Client A와 Client B를 구분하지 못하고 동일한 Client라고 간주한다.

Server는 Client A가 전송한 마지막 Timestamp 값인 200을 Server에 저장하고 있는다. 이후에 Client B가 Timestamp 값이 100인 Packet을 전송한다면, Server는 이전과 동일한 Client가 전송한 지연된 Packet이라고 간주하고 Client B의 Packet을 Drop한다. 대부분의 경우 Connection을 맺을때 가장 먼저 전송하는 **SYN Flag**가 이러한 문제로 인해서 Server에서 DROP된다. 따라서 Client는 SYN Flag를 전송하였지만 이에 대한 어떠한 응답도 받지 못하는 상황이 발생한다. 

위와 같은 문제를 막기 위해선는 2개의 Client가 완전히 동일한 Timestamp를 갖고 있어야 한다. 하지만 다수의 Client가 완전히 동일한 Timestamp를 갖는것은 불가능하다. 따라서 Linux Manpage에서도 tcp_tw_recycle은 Client가 SNAT 되는 Network 환경에서 이용하지 않는것을 권장하고 있다.

tcp_tw_recycle 설정을 이용하지 않으면 Server에서 발생하는 TIME_WAIT 상태의 Connection을 줄일수 있는 방법이 존재하지 않는다. 하지만 Server의 Memory 용량이 크게 늘어나면서 TIME_WAIT 상태의 Connection이 점유하는 Kernel Memory 영역은 과거와 다르게 현재는 큰 문제가 되지 않는 상황이 되었다. 따라서 대부분의 환경에서 tcp_tw_recycle 설정을 이용할 필요가 없다. 또한 [Linux Kernel 4.10](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=95a22caee396cef0bb2ca8fafdd82966a49367bb)에서는 각 Connection 마다 Random Offset을 갖는 Timestamp를 이용하도록 변경되었는데, 이에 따라 tcp_tw_recycle 설정은 Client의 SNAT 유무에 관계 없이 의미없는 설정이 되어 Linux Kernel 4.10에서 같이 제거되었다.

#### 2.4. Socket Lingering (SO_LINGER Socket Option)

Linux에서는 Socket에 SO_LINGER Option을 통해서 Socket Lingering을 수행할 수 있다. SO_LINGER Option이 설정된 Socket을 App에서 close() System Call을 통해서 종료하면, close() System Call은 Socket Buffer에 있는 모든 Data를 상대에게 전송하고 Socket이 종료될때까지 Blocking 된다. 이때 Blocking은 최대 SO_LINGER Option과 함께 Socket에 넘겨준 시간만큼 대기한다. 만약 최대 시간만큼 대기한 이후에도 Socket Buffer의 모든 Data를 상대에게 전송하지 못한다면, 상대에게 RST Flag를 전송하여 Connection을 강제로 종료한다.

만약 SO_LINGER Option과 함께 넘겨준 시간을 "0"으로 설정하여 Socket을 설정하면, 해당 Socket과 연결된 Connection은 RST Flag를 통하여 강제로 종료되기 때문에 TIME_WAIT 상태가 남지 않게된다. 하지만 SO_LINGER Option은 TIME_WAIT 상태를 줄이기 위한 Option이 아니라 Socket 종료시 Data 전송 보장을 위해서 제공하는 Option이다. 따라서 일반적인 상황에서는 SO_LINGER Option을 이용한 TIME_WAIT 상태 제거 방법은 권장되지 않는다.

### 3. 참조

* [https://vincent.bernat.ch/en/blog/2014-tcp-time-wait-state-linux](https://vincent.bernat.ch/en/blog/2014-tcp-time-wait-state-linux)
* [http://docs.likejazz.com/time-wait/](http://docs.likejazz.com/time-wait/)
* [https://meetup.toast.com/posts/55](https://meetup.toast.com/posts/55)
* [https://brunch.co.kr/@alden/3](https://brunch.co.kr/@alden/3)
* [https://brunch.co.kr/@alden/19](https://brunch.co.kr/@alden/19)
* [https://stackoverflow.com/questions/8893888/dropping-of-connections-with-tcp-tw-recycle](https://stackoverflow.com/questions/8893888/dropping-of-connections-with-tcp-tw-recycle)
* [https://man7.org/linux/man-pages/man7/tcp.7.html](https://man7.org/linux/man-pages/man7/tcp.7.html)
* [https://sunyzero.tistory.com/198](https://sunyzero.tistory.com/198)
* [https://www.alibabacloud.com/blog/why-are-linux-kernel-protocol-stacks-dropping-syn-packets_595251](https://www.alibabacloud.com/blog/why-are-linux-kernel-protocol-stacks-dropping-syn-packets_595251)
* [https://tech.kakao.com/2016/04/21/closewait-timewait/](https://tech.kakao.com/2016/04/21/closewait-timewait/)
* [https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=95a22caee396cef0bb2ca8fafdd82966a49367bb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=95a22caee396cef0bb2ca8fafdd82966a49367bb)