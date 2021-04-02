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

TIME_WAIT 상태는 Connection을 먼저 종료하는 Active Closer가 Connection 종료 후 도달하는 상태이다. Network 상에서 종료한 Connection 관련 Packet(Segment)이 완전히 제거 될때까지 대기하여, 이후에 생성되는 새로운 Connection에도 영향을 미치지 않기 위한 상태이다. 이러한 이유로 TCP 표준에서는 2MSL(2 * Maximum Segment Lifetime)만큼 유지되야 한다고 정의하고 있으며, TIME_WAIT 상태가 끝나기 전까지 TIME_WAIT가 선점하고 있는 Local IP/Port를 이용하여 새로운 Conneciton을 맺을수 없다.

{% highlight console %}
$ curl 192.168.0.60:80
...
$ netstat -na | grep 192.168.0.60
tcp        0      0 192.168.0.61:49240      192.168.0.60:80         TIME_WAIT
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] TIME_WAIT</figcaption>
</figure>

[Shell 1]은 Linux에서 TIME_WAIT 상태를 재현하는 과정을 나타내고 있다. curl 명령어는 Server에게 요청을 전송하고 응답을 받은면 먼저 Connection을 종료하는 Active Closer 역할을 수행한다. 따라서 curl 명령어를 수행한 후에 TIME_WAIT 상태를 확인할 수 있다. [Shell 1]에서 curl 명령어는 Local IP/Port로 192.168.0.61:49240를 이용하였기 때문에, TIME_WAIT 상태에서 Local IP/Port로 192.168.0.61:49240를 출력 하는것을 확인할 수 있다. 이 TIME_WAIT 상태가 종료되기 전까지 192.168.0.61:49240 IP/Port를 이용하여 새로운 Connection을 맺을수 없다. IP가 달라질 경우 49240 Port를 이용하여 새로운 Connection을 맺을 수 잇다.

![[그림 1] Packet Delay]({{site.baseurl}}/images/theory_analysis/TCP_TIME_WAIT/Packet_Delay.PNG){: width="500px"}

[그림 1]은 TIME_WAIT 상태가 짧을 경우 Packet Delay에 의해서 새로운 TCP Connection에 영향을 받는 상황을 나타내고 있다. Client가 전송한 SEQ=3인 Packet이 Server에게 바로 전달되지 않고 Network에 의해서 지연되는 상황에서, Client와 Server가 기존의 Connection을 종료하고 새로운 Connection을 맺는 상황이다. 이후에 이전 Connection의 지연된 SEQ=3 Packet이 Server에게 전달될 경우 새로운 Connection에 영향을 줄수 있다.

대부분의 경우에는 Server가 받아야 하는 SEQ와 지연된 Packet의 SEQ가 다르기 때문에, 지연된 Packet은 Server에서 Drop되어 처리 되지만, [그림 1]의 상황처럼 우연히 SEQ 번호가 동일한 경우에는 TCP 무결성에 영향을 줄 수 있게 된다.

![[그림 2] Lost Last ACK in 4Way Handshake]({{site.baseurl}}/images/theory_analysis/TCP_TIME_WAIT/Lost_Last_ACK.PNG){: width="550px"}

[그림 2]는 TIME_WAIT 상태가 짧을 경우 TCP 4Way Handshake의 마지막 ACK Flag가 Server(Passive Closer)에게 전달되지 않아 Server가 LAST_ACK 상태를 유지하는 상황을 나타내고 있다. TIME_WAIT 상태가 짧을 경우 Server의 LAST_ACK 상태가 Timeout에 의해서 CLOSED 상태로 변경 되기전, Client는 새로운 Connection을 위해서 동일한 Port를 이용하여 Server에게 SYN Flag를 전송할 수 있다. LAST_ACK 상태의 Server는 SYN Flag를 받을 경우 RST FLAG를 전송하여 Connection 생성을 막기 때문에 Connection 생성에 실패하게 된다.

### 2. with Linux

Linux에서는 기본적으로 TIME_WAIT 상태가 60초 동안 지속되도록 Linux Kernel Code에 설정되어 있다. 비교적 긴 시간이기 때문에 TIME_WAIT 상태가 많아지면 TIME_WAIT 상태가 선점하고 있는 Port로 인해서 이용할 수 있는 Port가 줄어들어 새로운 Connection을 맺지 못하는 문제가 발생할 수 있다. 또한 TIME_WAIT 상태가 많아질수록 Kernel 영역의 Memory를 점유하는 문제도 발생한다. 이러한 문제를 해결하기 위해서 Linux에서는 몇가지 기법을 제공하고 있다.

#### 2.1. /proc/net/ipv4/tcp_timestamps

TIME_WAIT 상태로 인하여 Port가 부족한 문제를 해결하기 위한 기법을 이해하기 위해서는 tcp_timestamps 설정을 이해해야 한다. tcp_timestamps 설정은 TCP Packet Header에 Timestamp를 설정하는 Option이다. 기본적으로 "1"로 설정되어 있어 Timestamp를 이용하도록 설정되어 있다.

TCP Packet의 Timestamp는 Packet Reordering에 쓰인다. 짧은 시간동안 많은 Packet을 한번에 보내는 경우 SEQ의 Overflow로 인해서 Packet의 SEQ가 중복될 수 있다. 이러한 경우 Network의 상황에 따라서 수신부에서는 SEQ가 동일한 Packet을 동시에 수신할 수도 있다. 이 경우 Packet의 SEQ만으로는 Packet Reordering을 수행할 수 없고, Packet의 Timestamp도 참고하여 Reordering을 수행 해야한다. 이처럼 Packet의 SEQ와 Timestamp 둘다 참고하여 Packet Reordering을 하는 기법을 PAWS (TCP Sequence number wrapping) 기법이라고 명칭한다.

#### 2.2. /proc/net/ipv4/tcp_tw_reuse

tcp_tw_reuse는 TIME_WAIT 상태의 Port를 재사용 할 수 있도록 만든다. [Shell 1]에서 tcp_tw_reuse가 "1" 또는 "2"로 설정되어 있어 재사용이 가능하도록 설정되어 있다면, TIME_WAIT 상태가 끝나지 않더라도 49240 Port를 새로운 Connection을 맺는데 이용할 수 있다. Socket의 "SO_REUSEADDR" Option과 유사한 효과를 준다. Client에서 유용한 설정이며 Listen하는 고정된 Port를 이용하는 Server에서는 설정해도 큰 의미는 없다.

TIME_WAIT 상태가 짧아져 [그림 1]과 같이 동일한 SEQ로 인해서 발생할 수 있는 문제는 PAWS를 이용하면 해결 할 수 있다. SEQ가 동일하더라도 이전 Connection의 Packet은 지난 Timestamp이기 때문에 무시하고 Drop하면 된다. 따라서 tcp_tw_reuse는 tcp_timestamps과 함께 이용되어야 한다. tcp_timestamps과 함께 이용되는 tcp_tw_reuse는 이용해도 안전한 것으로 알려져 있다.

#### 2.3. /proc/net/ipv4/tcp_tw_recycle

![[그림 3] DROP SYN Packet with Client SNAT]({{site.baseurl}}/images/theory_analysis/TCP_TIME_WAIT/SNAT_SYN_Packet_Drop.PNG){: width="700px"}

### 3. 참조

* [http://docs.likejazz.com/time-wait/](http://docs.likejazz.com/time-wait/)
* [https://meetup.toast.com/posts/55](https://meetup.toast.com/posts/55)
* [https://brunch.co.kr/@alden/3](https://brunch.co.kr/@alden/3)
* [https://stackoverflow.com/questions/8893888/dropping-of-connections-with-tcp-tw-recycle](https://stackoverflow.com/questions/8893888/dropping-of-connections-with-tcp-tw-recycle)
* [https://man7.org/linux/man-pages/man7/tcp.7.html](https://man7.org/linux/man-pages/man7/tcp.7.html)
* [https://sunyzero.tistory.com/198](https://sunyzero.tistory.com/198)