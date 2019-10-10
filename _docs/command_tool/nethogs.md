---
title: nethogs
category: Command, Tool
date: 2019-10-10T12:00:00Z
lastmod: 2019-10-10T12:00:00Z
comment: true
adsense: true
---

Process들을 Network Bandwidth 사용량이 높은 순서대로 출력하는 nethogs의 사용법을 정리한다.

***

* TOC
{:toc}

***

### 1. nethogs

#### 1.1. # nethogs

{% highlight console %}
NetHogs version 0.8.5-2

    PID USER     PROGRAM DEV SENT      RECEIVED
      ? root     10.0.0.19:9093-10.0.0.11:37344                             0.058       0.109 KB/sec
      ? root     10.0.0.19:3000-10.0.0.11:53954                             0.058       0.109 KB/sec
      ? root     10.0.0.19:9091-10.0.0.11:53762                             0.029       0.055 KB/sec
  28303 root     sshd: root@pts/0                               eth1        0.180       0.042 KB/sec
  27860 42417    /usr/sbin/grafana-server                       eth1        0.013       0.013 KB/sec
   2912 42472    /opt/prometheus/prometheus                     eth1        0.000       0.000 KB/sec
  29277 root     curl                                           eth0        0.000       0.000 KB/sec
  29270 root     curl                                           eth0        0.000       0.000 KB/sec
      ? root     unknown TCP                                                0.000       0.000 KB/sec

  TOTAL 0.000 0.000 KB/sec                                                  0.337       0.329
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] nethogs</figcaption>
</figure>

Process들을 Network Bandwidth 사용량이 높은 순서대로 출력한다. [Shell 1]은 nethogs를 이용하여 Process별 Network Bandwidth 사용량을 출력하는 Shell의 모습을 나타내고 있다. PID가 "?"이고 DEV에 Interface가 공백인 경우는 User Level에서 알 수 없는 Kernel Thread에서 Packet을 처리하기 때문이다.

#### 1.2. # nethogs [Interface]

[Interface]를 이용하는 Process들만 출력한다.

### 2. 참조
* [https://unix.stackexchange.com/questions/91055/how-to-tell-if-mysterious-programs-in-nethogs-listing-are-malware](https://unix.stackexchange.com/questions/91055/how-to-tell-if-mysterious-programs-in-nethogs-listing-are-malware)


