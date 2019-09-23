---
title: Linux Status Analysis Tool
category: Command, Tool
date: 2019-09-23T12:00:00Z
lastmod: 2019-09-23T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

Linux 상태 분석 Tool들을 정리한다.

### 1. Linux Status Analysis Tool

#### 1.1. netstat

{% highlight console %}
# netstat -plnt
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 10.0.0.19:9100          0.0.0.0:*               LISTEN      3080/node_exporter
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      23825/systemd-resol
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1618/sshd
tcp        0      0 10.0.0.19:9091          0.0.0.0:*               LISTEN      2912/prometheus
tcp        0      0 10.0.0.19:9093          0.0.0.0:*               LISTEN      3361/alertmanager   
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] uptime Shell</figcaption>
</figure>

netstat은 Linux Kernel이 갖고있는 대부분의 Network 정보를 출력하는 Tool이다. [Shell 1]은 netstat을 이용하여 현재 Listen 상태의 Server Process와 Port를 출력하는 Shell의 모습을 나타내고 있다.

#### 1.2. tcpdump

{% highlight console %}
#  tcpdump -i eth0 tcp port 80                                                                    [13:30:16]
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
13:30:19.335743 IP node09.55226 > a184-28-153-161.deploy.static.akamaitechnologies.com.http: Flags [S], seq 3863811539, win 29200, options [mss 1460,sackOK,TS val 2368590441 ecr 0,nop,wscale 7], length 0
13:30:19.339342 IP a184-28-153-161.deploy.static.akamaitechnologies.com.http > node09.55226: Flags [S.], seq 1883939558, ack 3863811540, win 28960, options [mss 1460,sackOK,TS val 2709703628 ecr 2368590441,nop,wscale 7], length 0
13:30:19.339369 IP node09.55226 > a184-28-153-161.deploy.static.akamaitechnologies.com.http: Flags [.], ack 1, win 229, options [nop,nop,TS val 2368590444 ecr 2709703628], length 0
13:30:19.339409 IP node09.55226 > a184-28-153-161.deploy.static.akamaitechnologies.com.http: Flags [P.], seq 1:78, ack 1, win 229, options [nop,nop,TS val 2368590444 ecr 2709703628], length 77: HTTP: GET / HTTP/1.1
13:30:19.342916 IP a184-28-153-161.deploy.static.akamaitechnologies.com.http > node09.55226: Flags [.], ack 78, win227, options [nop,nop,TS val 2709703632 ecr 2368590444], length 0
13:30:19.355650 IP a184-28-153-161.deploy.static.akamaitechnologies.com.http > node09.55226: Flags [P.], seq 1:301,ack 78, win 227, options [nop,nop,TS val 2709703644 ecr 2368590444], length 300: HTTP: HTTP/1.1 302 Moved Temporarily
13:30:19.355673 IP node09.55226 > a184-28-153-161.deploy.static.akamaitechnologies.com.http: Flags [.], ack 301, win 237, options [nop,nop,TS val 2368590461 ecr 2709703644], length 0
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] tcpdump Shell</figcaption>
</figure>

tcpdump은 특정 Network Interface의 Inbound/Outbound Packet 정보를 출력하는 Tool이다. [Shell 2]는 tcpdump를 이용하여 eth0 Interface의 Src/Dest Port가 80인 Inbound/Outbound Packet 정보를 출력하는 Shell의 모습을 나타내고 있다.

#### 1.3. lsof

{% highlight console %}
# lsof -u root
COMMAND     PID USER   FD      TYPE             DEVICE SIZE/OFF       NODE NAME
systemd       1 root  cwd       DIR                8,2     4096          2 /
systemd       1 root  rtd       DIR                8,2     4096          2 /
systemd       1 root  txt       REG                8,2  1595792   11535295 /lib/systemd/systemd
systemd       1 root  mem       REG                8,2  1700792   11535141 /lib/x86_64-linux-gnu/libm-2.27.so
systemd       1 root  mem       REG                8,2   121016   11534693 /lib/x86_64-linux-gnu/libudev.so.1.6.9
systemd       1 root  mem       REG                8,2    84032   11535128 /lib/x86_64-linux-gnu/libgpg-error.so.0.22.0
systemd       1 root  mem       REG                8,2    43304   11535134 /lib/x86_64-linux-gnu/libjson-c.so.3.0.1
systemd       1 root  mem       REG                8,2    34872    2103003 /usr/lib/x86_64-linux-gnu/libargon2.so.0
systemd       1 root  mem       REG                8,2   432640   11534609 /lib/x86_64-linux-gnu/libdevmapper.so.1.02.1
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] uptime Shell</figcaption>
</figure>

lsof는 Open 상태의 File List를 출력하는 Tool이다. [Shell 1]은 lsof를 이용하여 root User가 Open한 File List를 출력하는 Shell을 나타내고 있다. User 단위의 Filter뿐만 아니라 Directory, Binary 단위의 Filter도 가능하다. 또한 lsof를 이용하여 TCP, UDP의 특정 Port를 이용하는 Process를 찾는것도 가능하다.

### 2. 참조

* [https://github.com/nicolaka/netshoot](https://github.com/nicolaka/netshoot)

