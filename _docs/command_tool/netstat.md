---
title: netstat
category: Command, Tool
date: 2019-09-16T12:00:00Z
lastmod: 2019-09-16T12:00:00Z
comment: true
adsense: true
---

Network 통계 정보를 보여주는 netstat 사용법을 정리한다.

***

* TOC
{:toc}

***

### 1. netstat

#### 1.1. # netstat

{% highlight console %}
# netstat 
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 node09:9100             node09:50588            TIME_WAIT
tcp        0      0 node09:9198             node09:56430            TIME_WAIT
tcp        0      0 node09:54584            10.0.0.20:mysql         ESTABLISHED
tcp        0      0 node09:41364            192.168.0.40:8776       TIME_WAIT
tcp        0      0 node09:ssh              10.0.0.10:6791          ESTABLISHED
tcp        0      0 node09:54360            10.0.0.20:mysql         ESTABLISHED
tcp        0      0 node09:9091             node09:60262            TIME_WAIT
tcp        0    164 node09:ssh              10.0.0.10:9385          ESTABLISHED
tcp6       0      0 node09:18080            node09:49642            TIME_WAIT
Active UNIX domain sockets (w/o servers)
Proto RefCnt Flags       Type       State         I-Node   Path
unix  2      [ ]         DGRAM                    32031    /run/chrony/chronyd.sock
unix  3      [ ]         DGRAM                    14031    /run/systemd/notify
unix  2      [ ]         DGRAM                    14048    /run/systemd/journal/syslog
unix  9      [ ]         DGRAM                    14054    /run/systemd/journal/socket
unix  8      [ ]         DGRAM                    14464    /run/systemd/journal/dev-log
unix  3      [ ]         STREAM     CONNECTED     20158
unix  3      [ ]         STREAM     CONNECTED     21786    /var/run/dbus/system_bus_socket
unix  3      [ ]         STREAM     CONNECTED     20999
unix  2      [ ]         DGRAM                    683751
unix  3      [ ]         STREAM     CONNECTED     27046
unix  3      [ ]         STREAM     CONNECTED     31101    /run/systemd/journal/stdout
unix  2      [ ]         DGRAM                    21526
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] netstat</figcaption>
</figure>

현재 Open되어 있는 모든 Socket의 정보를 출력한다. [Shell 1]은 "netstat"을 이용하여 Open되어 있는 모든 Socket 정보를 출력하고 있는 Shell의 모습을 나타내고 있다. IPv4 Socket 정보와 Unix Domain Socket 정보를 확인할 수 있다.

#### 1.2. # netstat -i

{% highlight console %}
# netstat -i
Kernel Interface table
Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
docker0   1500        0      0      0 0            52      0      0      0 BMRU
eth0      1500   312536      0      0 0        127530      0      0      0 BMRU
lo       65536   126777      0      0 0        126777      0      0      0 LRU
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] netstat -i</figcaption>
</figure>

각 Network Interface가 주고받은 Packet 정보를 출력한다. [Shell 2]는 "netstat -i"를 이용하여 각 Network Interface가 주고받은 Packet 정보를 출력하는 Shell의 모습을 나타내고 있다. 각 열의 의미는 다음과 같다.
* RX-OK : 올바르게 수신된 Packet의 개수 
* RX-ERR : 수신에는 성공하였지만 Error가 발생하여 처리하지 않은 수신 Packet의 개수
* RX-DRP : 수신 Buffer가 가득차 Drop된 수신 Packet의 개수
* RX-OVR : Kernel이 너무 바빠서 수신에 실패한 Packet의 개수
* TX-OK : 올바르게 송신한 Packet의 개수
* TX-ERR : 송신전에 Error가 발생하여 송신하지 않은 Packet의 개수
* TX-DRP : 송신 Buffer가 가득차 Drop된 송신 Packet의 개수
* TX-OVR : Kernel이 너무 바빠서 송신에 실패한 Packet의 개수

#### 1.3. # netstat -nr

{% highlight console %}
# netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         192.168.0.1     0.0.0.0         UG        0 0          0 eth0
10.0.0.0        0.0.0.0         255.255.255.0   U         0 0          0 eth1
172.17.0.0      0.0.0.0         255.255.0.0     U         0 0          0 docker0
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] netstat -nr</figcaption>
</figure>

Routing Table 정보를 출력한다. [Shell 3]은 "netstat -nr"을 이용하여 Routing Table을 출력하는 Shell의 모습을 나타내고 있다.

#### 1.4. # netstat -plnt

{% highlight console %}
# netstat -plnt
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 10.0.0.19:9100          0.0.0.0:*               LISTEN      3080/node_exporter
tcp        0      0 10.0.0.19:9198          0.0.0.0:*               LISTEN      2253/openstack-expo
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      23825/systemd-resol
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1618/sshd
tcp        0      0 10.0.0.19:3000          0.0.0.0:*               LISTEN      27860/grafana-serve
tcp        0      0 10.0.0.19:9091          0.0.0.0:*               LISTEN      2912/prometheus
tcp        0      0 10.0.0.19:9093          0.0.0.0:*               LISTEN      3361/alertmanager
tcp6       0      0 :::22                   :::*                    LISTEN      1618/sshd
tcp6       0      0 :::18080                :::*                    LISTEN      3335/cadvisor
tcp6       0      0 :::9094                 :::*                    LISTEN      3361/alertmanager
tcp6       0      0 :::5000                 :::*                    LISTEN      3057/docker-proxy
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] netstat -plnt</figcaption>
</figure>

Listen 상태의 Port 및 Process 정보를 출력한다. [Shell 4]는 "netstat -plnt"을 이용하여 Listen 상태의 Port 및 Process 정보를 출력하는 Shell의 모습을 나타내고 있다.

### 2. 참조
* [https://linuxacademy.com/blog/linux/netstat-network-analysis-and-troubleshooting-explained/](https://linuxacademy.com/blog/linux/netstat-network-analysis-and-troubleshooting-explained/)