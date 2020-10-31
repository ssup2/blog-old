---
title: Linux Container Connection Reset with TCP Out of Order
category: Issue
date: 2020-10-31T12:00:00Z
lastmod: 2020-10-31T12:00:00Z
comment: true
adsense: true
---

### 1. Issue

Container에서 Host 외부로 Packet을 전송하면서 전송한 Packet이 **SNAT** 되는 경우 TCP Out of Order으로 인해서 TCP Connection이 Reset되는 Issue가 존재한다. Container안에서 Client가 동작하고 Host 외부에 Server가 동작하는 경우 Client가 전송한 Packet은 SNAT되어 Host 외부로 전달된다. Container의 Client와 Host 외부에 Server가 HTTP Protocol 처럼 짧은 시간동안 적은 양의 Packet을 전송하는 경우에는 문제 없지만, **오랜 시간동안 TCP Connection을 맺으면서 많은양의 Packet을 전송하는 경우**에는 본 이슈가 발생할 확률이 높다.

Docker Container의 경우 Host 외부로 Packet을 전송하는 경우에 Packet을 SNAT하여 전송하기 때문에 본 이슈가 발생할 수 있다. 또한 대부분의 Kubernetes Pod의 Container 내부에서 Kubernetes Cluster 외부의 Server와 TCP Connection을 맺는 경우, Kubernetes Pod의 Container가 전송한 TCP SYN Packet은 SNAT 되어 외부로 전송되기 때문에 본 Issue가 발생할 수 있다.

### 2. 원인

Client와 Server가 TCP Connection을 맺고 TCP Connection을 맺고 통신을 하는 과정에서 다양한 외부의 요인에 의해서 전송한 Packet의 순서가 변경되는 Out of Order 현상이 발생 할 수 있다. Out of Order 현상에 의해서 Client가 전송한 Sequence Number 100번 Packet의 ACK보다 Client가 이전에 전송한 Sequence Number 90번 Packet의 ACK가 Client에게 먼저 도착할 수 있다. 

Client가 Server로부터 Sequence Number 100번 Packet의 ACK를 받았다는 의미는 TCP Protocol에 의해서 Server가 Sequence Number 90번 Packet도 잘 수신했다는 의미도 포함하고 있다. 따라서 Client가 늦게 수신한 Sequence Number 90번 Packet의 ACK는 TCP의 Spurious Retranmission 기법으로 인해서 재전송된 Packet으로 간주하고 Kernel에 의해서 무시된다.

Container안의 Client가 전송한 Packet이 SNAT를 통해서 Host 외부의 Server와 TCP Connection을 맺는 경우, Server가 Client에게 전송하는 Packet은 DNAT되어 Client에게 전송되야 한다. 문제는 이 경우 Server가 전송한 ACK에게 Out of Order 현상이 발생하면, 해당 ACK는 Linux의 conntrack Module의 Bug로 인해서 Invalid Packet으로 분류된다. conntrack Module에 의해서 Invalid 상태가된 ACK는 DNAT되지 않기 때문에 Container가 아닌 Host로 전달된다. ACK를 받은 Host는 Host가 모르는 Connection으로부터 Packet을 수신하기 때문에 TCP Reset Flag를 통해서 Server와의 Connection을 강제로 종료한다.

{% highlight console linenos %}
...
117893 291.390819085 192.168.0.100 → 10.205.13.221 TCP 66 80 → 56284 [ACK] Seq=26 Ack=10069055 Win=173056 Len=0 TSval=3479336939 TSecr=499458820
117894 291.390838911 10.205.13.221 → 192.168.0.100 TCP 19790 56284 → 80 [ACK] Seq=10194987 Ack=26 Win=43008 Len=19724 TSval=499458821 TSecr=3479336939 [TCP segment of a reassembled PDU]
117895 291.390917661 192.168.0.100 → 10.205.13.221 TCP 66 80 → 56284 [ACK] Seq=26 Ack=10149475 Win=173056 Len=0 TSval=3479336939 TSecr=499458820
117896 291.390972667 10.205.13.221 → 192.168.0.100 TCP 64326 56284 → 80 [ACK] Seq=10214711 Ack=26 Win=43008 Len=64260 TSval=499458821 TSecr=3479336939 [TCP segment of a reassembled PDU]
117897 291.391007869 10.205.13.221 → 192.168.0.100 TCP 43626 [TCP Window Full] 56284 → 80 [ACK] Seq=10278971 Ack=26 Win=43008 Len=43560 TSval=499458821 TSecr=3479336939 [TCP segment of a reassembled PDU]
117898 291.391020119 192.168.0.100 → 10.205.13.221 TCP 66 80 → 56284 [ACK] Seq=26 Ack=10110467 Win=173056 Len=0 TSval=3479336939 TSecr=499458820
117899 291.391054153 10.205.13.221 → 192.168.0.100 TCP 54 56284 → 80 [RST] Seq=10110467 Win=0 Len=0
117900 291.391596495 192.168.0.100 → 10.205.13.221 TCP 66 80 → 56284 [ACK] Seq=26 Ack=10160447 Win=173056 Len=0 TSval=3479336939 TSecr=499458821
117901 291.391646840 192.168.0.100 → 10.205.13.221 TCP 66 80 → 56284 [ACK] Seq=26 Ack=10194987 Win=173056 Len=0 TSval=3479336940 TSecr=499458821
117902 291.391676345 10.205.13.221 → 192.168.0.100 TCP 20766 56284 → 80 [ACK] Seq=10322531 Ack=26 Win=43008 Len=20700 TSval=499458822 TSecr=3479336940 [TCP segment of a reassembled PDU]
117903 291.391692731 192.168.0.100 → 10.205.13.221 TCP 66 80 → 56284 [ACK] Seq=26 Ack=10204983 Win=173056 Len=0 TSval=3479336940 TSecr=499458821
117904 291.391798515 192.168.0.100 → 10.205.13.221 TCP 66 80 → 56284 [ACK] Seq=26 Ack=10214711 Win=173056 Len=0 TSval=3479336940 TSecr=499458821
117905 291.391852326 192.168.0.100 → 10.205.13.221 TCP 66 80 → 56284 [ACK] Seq=26 Ack=10227563 Win=173056 Len=0 TSval=3479336940 TSecr=499458821
117906 291.392008540 192.168.0.100 → 10.205.13.221 TCP 66 80 → 56284 [ACK] Seq=26 Ack=10256123 Win=173056 Len=0 TSval=3479336940 TSecr=499458821
117907 291.392020293 192.168.0.100 → 10.205.13.221 TCP 66 80 → 56284 [ACK] Seq=26 Ack=10320383 Win=173056 Len=0 TSval=3479336940 TSecr=499458821
117908 291.392092929 10.205.13.221 → 192.168.0.100 TCP 64326 56284 → 80 [ACK] Seq=10343231 Ack=26 Win=43008 Len=64260 TSval=499458822 TSecr=3479336940 [TCP segment of a reassembled PDU]
117909 291.392120048 10.205.13.221 → 192.168.0.100 TCP 64326 56284 → 80 [ACK] Seq=10407491 Ack=26 Win=43008 Len=64260 TSval=499458822 TSecr=3479336940 [TCP segment of a reassembled PDU]
117910 291.392134522 192.168.0.100 → 10.205.13.221 TCP 66 80 → 56284 [ACK] Seq=26 Ack=10322531 Win=173056 Len=0 TSval=3479336940 TSecr=499458821
117911 291.392168474 10.205.13.221 → 192.168.0.100 HTTP 14302 PUT /v1/test/yanoo.kim/METAKAGEAPI-56/b019 HTTP/1.1
117912 291.392855855 192.168.0.100 → 10.205.13.221 TCP 54 80 → 56284 [RST] Seq=26 Win=8397824 Len=0
117913 291.392875260 192.168.0.100 → 10.205.13.221 TCP 54 80 → 56284 [RST] Seq=26 Win=8397824 Len=0
117914 291.392879867 192.168.0.100 → 10.205.13.221 TCP 54 80 → 56284 [RST] Seq=26 Win=8397824 Len=0
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Host Network Interface Packet Dump with tshark</figcaption>
</figure>

[Shell 1]은 Container의 Connection Reset이 발생하였을때의 tshark를 이용하여 Host Interface의 Packet을 Dump한 결과이다. 10.205.13.221은 Docker Container의 Client IP이고, 192.168.0.100은 Host 외부의 Server이다. Docker Container의 Client가 Host 외부의 Server에게 TCP Connection을 맺고 Data를 전송하다가 Connection Reset 현상이 발생한 모습이다.

[Shell 1]의 5번째 줄에 Server가 Client에게 전송한 Sequence Number 10214711번 Packet의 Ack를 수신한걸 확인할 수 있다. [Shell 1]의 7번째 줄에서는 Sequence Number 10110467번 Packet의 ACK를 수신한 것을 확인할 수 있다. 10110467번이 10214711번 보다 작기 때문에 Sequence Number 10110467번의 Packet의 Ack는 원래라면 TCP Spurious로 간주되고 무시되어야 하지만, conntrack Module의 Bug로 인해서 Invalid Packet으로 간주되고 DNAT되지 않는다.

따라서 Sequence Number 10110467번의 Packet의 Ack는 Host로 전달되고, Host의 입장에서는 Sequence Number 10110467번의 Packet의 Ack는 자신이 전송한 Packet이 아니기 때문에 TCP Reset Flag를 통해서 Server와의 Connection을 강제로 종료한다. [Shell 1]의 8번째 줄에서 Server에게 전송하는 TCP Reset Packet을 확인할 수 있다.

{% highlight console linenos %}
...
348997 1199.001039577 192.168.0.100 → 10.251.0.1   TCP 66 80 → 56284 [ACK] Seq=26 Ack=10069055 Win=173056 Len=0 TSval=3479336939 TSecr=499458820
348998 1199.001044501   10.251.0.1 → 192.168.0.100 TCP 19790 56284 → 80 [ACK] Seq=10194987 Ack=26 Win=43008 Len=19724 TSval=499458821 TSecr=3479336939 [TCP segment of a reassembled PDU]
348999 1199.001137509 192.168.0.100 → 10.251.0.1   TCP 66 80 → 56284 [ACK] Seq=26 Ack=10149475 Win=173056 Len=0 TSval=3479336939 TSecr=499458820
349000 1199.001142437   10.251.0.1 → 192.168.0.100 TCP 64326 56284 → 80 [ACK] Seq=10214711 Ack=26 Win=43008 Len=64260 TSval=499458821 TSecr=3479336939 [TCP segment of a reassembled PDU]
349001 1199.001173634   10.251.0.1 → 192.168.0.100 TCP 43626 [TCP Window Full] 56284 → 80 [ACK] Seq=10278971 Ack=26 Win=43008 Len=43560 TSval=499458821 TSecr=3479336939 [TCP segment of a reassembled PDU]
349002 1199.001829309 192.168.0.100 → 10.251.0.1   TCP 66 80 → 56284 [ACK] Seq=26 Ack=10160447 Win=173056 Len=0 TSval=3479336939 TSecr=499458821
349003 1199.001867310 192.168.0.100 → 10.251.0.1   TCP 66 80 → 56284 [ACK] Seq=26 Ack=10194987 Win=173056 Len=0 TSval=3479336940 TSecr=499458821
349004 1199.001873632   10.251.0.1 → 192.168.0.100 TCP 20766 56284 → 80 [ACK] Seq=10322531 Ack=26 Win=43008 Len=20700 TSval=499458822 TSecr=3479336940 [TCP segment of a reassembled PDU]
349005 1199.001913499 192.168.0.100 → 10.251.0.1   TCP 66 80 → 56284 [ACK] Seq=26 Ack=10204983 Win=173056 Len=0 TSval=3479336940 TSecr=499458821
349006 1199.002019049 192.168.0.100 → 10.251.0.1   TCP 66 80 → 56284 [ACK] Seq=26 Ack=10214711 Win=173056 Len=0 TSval=3479336940 TSecr=499458821
349007 1199.002072808 192.168.0.100 → 10.251.0.1   TCP 66 80 → 56284 [ACK] Seq=26 Ack=10227563 Win=173056 Len=0 TSval=3479336940 TSecr=499458821
349008 1199.002234891 192.168.0.100 → 10.251.0.1   TCP 66 80 → 56284 [ACK] Seq=26 Ack=10256123 Win=173056 Len=0 TSval=3479336940 TSecr=499458821
349009 1199.002246041   10.251.0.1 → 192.168.0.100 TCP 64326 56284 → 80 [ACK] Seq=10343231 Ack=26 Win=43008 Len=64260 TSval=499458822 TSecr=3479336940 [TCP segment of a reassembled PDU]
349010 1199.002239068 192.168.0.100 → 10.251.0.1   TCP 66 80 → 56284 [ACK] Seq=26 Ack=10320383 Win=173056 Len=0 TSval=3479336940 TSecr=499458821
349011 1199.002275354   10.251.0.1 → 192.168.0.100 TCP 64326 56284 → 80 [ACK] Seq=10407491 Ack=26 Win=43008 Len=64260 TSval=499458822 TSecr=3479336940 [TCP segment of a reassembled PDU]
349012 1199.002354715 192.168.0.100 → 10.251.0.1   TCP 66 80 → 56284 [ACK] Seq=26 Ack=10322531 Win=173056 Len=0 TSval=3479336940 TSecr=499458821
349013 1199.002360711   10.251.0.1 → 192.168.0.100 HTTP 14302 PUT /v1/test/yanoo.kim/METAKAGEAPI-56/b019 HTTP/1.1
349014 1199.003089773 192.168.0.100 → 10.251.0.1   TCP 54 80 → 56284 [RST] Seq=26 Win=8397824 Len=0
349015 1199.003094968 192.168.0.100 → 10.251.0.1   TCP 54 80 → 56284 [RST] Seq=26 Win=8397824 Len=0
349016 1199.003098534 192.168.0.100 → 10.251.0.1   TCP 54 80 → 56284 [RST] Seq=26 Win=8397824 Len=0
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Container Network Interface Packet Dump with tshark</figcaption>
</figure>

[Shell 2]는 [Shell 1]의 Connection Reset 현상이 발생하였을때 tshark를 이용하여 Container 내부에서 Container Interface의 Packet을 Dump한 결과이다. [Shell 1]과 대부분 동일하지만 Sequence Number 10110467번 Packet의 ACK가 존재하지 않는걸 확인할 수 있다. Sequence Number 10110467번 Packet의 ACK는 Host에서 conntrack Module의 Bug로 인해서 Invalid Packet을 간주되어 DNAT 되지 않았기 때문에, Container로 전달되지 않았기 때문이다.

### 3. 해결 방안

### 4. 참조

* [https://github.com/moby/libnetwork/issues/1090](https://github.com/moby/libnetwork/issues/1090)
* [https://github.com/moby/libnetwork/issues/1090#issuecomment-425421288](https://github.com/moby/libnetwork/issues/1090#issuecomment-425421288)
* [https://imbstack.com/2020/05/03/debugging-docker-connection-resets.html](https://imbstack.com/2020/05/03/debugging-docker-connection-resets.html)
* [https://github.com/kubernetes/kubernetes/pull/74840#issuecomment-491674987](https://github.com/kubernetes/kubernetes/pull/74840#issuecomment-491674987)
