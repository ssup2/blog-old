---
title: nmap
category: Command, Tool
date: 2020-05-13T12:00:00Z
lastmod: 2020-05-13T12:00:00Z
comment: true
adsense: true
---

외부 Host의 Network 상태 정보를 출력하는 nmap의 사용법을 정리한다.

***

* TOC
{:toc}

***

### 1. nmap

#### 1.1. # nmap [host]

{% highlight console %}
# nmap localhost

Starting Nmap 7.60 ( https://nmap.org ) at 2020-05-12 23:33 KST
Nmap scan report for localhost (127.0.0.1)
Host is up (0.0000040s latency).
Other addresses for localhost (not scanned): ::1
Not shown: 998 closed ports
PORT     STATE SERVICE
22/tcp   open  ssh
5000/tcp open  upnp

Nmap done: 1 IP address (1 host up) scanned in 1.63 seconds
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] nmap localhost</figcaption>
</figure>

host에서 1000번까지의 TCP Port들을 Scanning하여 Listen 상태의 TCP Port 정보를 출력한다. [Shell 1]은 "nmap localhost"를 이용하여 localhost에서 Listen하고 있는 1000번 이하의 TCP Port 목록을 출력하는 Shell의 모습을 나타내고 있다.

### 2. 참조

* [https://phoenixnap.com/kb/nmap-scan-open-ports](https://phoenixnap.com/kb/nmap-scan-open-ports)
* [https://exchangeinfo.tistory.com/11](https://exchangeinfo.tistory.com/11)