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

#### 1.1. TCP Handshake

![[그림 1] TCP 3 Way, 4 Way Handshake]({{site.baseurl}}/images/theory_analysis/TCP_Handshake/TCP_3way_4way_Handshake.PNG){: width="550px"}

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
<figcaption class="caption">[Console 1] TCP 3 way, 4 way Handshake</figcaption>
</figure>

#### 1.2. TCP Reset

![[그림 2] TCP Reset at Connection Start]({{site.baseurl}}/images/theory_analysis/TCP_Handshake/TCP_Reset_Connection_Start.PNG){: width="550px"}

{% highlight console %}
13:32:50.672429 IP 192.168.0.60.33214 > 192.168.0.61.81: Flags [S], seq 292716723, win 64240, options [mss 1460,sackOK,TS val 2672676949 ecr 0,nop,wscale 7], length 0
13:32:50.672648 IP 192.168.0.61.81 > 192.168.0.60.33214: Flags [R.], seq 0, ack 292716724, win 0, length 0
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 2] TCP Reset at Connection Start</figcaption>
</figure>

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

### 2. 참조

* [http://intronetworks.cs.luc.edu/1/html/tcp.html](http://intronetworks.cs.luc.edu/1/html/tcp.html)
* [https://unix.stackexchange.com/questions/386536/when-how-does-linux-decides-to-close-a-socket-on-application-kill](https://unix.stackexchange.com/questions/386536/when-how-does-linux-decides-to-close-a-socket-on-application-kill)
* [https://unix.stackexchange.com/questions/282613/can-you-send-a-tcp-packet-with-rst-flag-set-using-iptables-as-a-way-to-trick-nma](https://unix.stackexchange.com/questions/282613/can-you-send-a-tcp-packet-with-rst-flag-set-using-iptables-as-a-way-to-trick-nma)