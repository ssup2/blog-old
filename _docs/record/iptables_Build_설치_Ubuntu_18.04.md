---
title: iptables Build, 설치 / Ubuntu 18.04 환경
category: Record
date: 2020-10-25T12:00:00Z
lastmod: 2020-10-25T12:00:00Z
comment: true
adsense: true
---

Ubuntu 18.04에서는 iptables 1.6.1 Version 까지만 Ubuntu Package로 제공한다. 이상의 Version을 이용하기 위해서는 직접 iptables를 Build 및 설치하여 이용해야 한다.

### 1. Ubuntu Package 설치

~~~console
# apt install build-essential
~~~

iptables Bulid에 필요한 Ubuntu Package를 설치한다.

### 2. iptables Build & 설치

~~~console
# curl -O http://www.netfilter.org/projects/iptables/files/iptables-1.6.2.tar.bz2
# tar -xvf iptables-1.6.2.tar.bz2
# cd iptables-1.6.2
~~~

iptables v1.6.2 Version Code를 Download한다.

~~~
# ./configure --disable-nftables
# make && make install
~~~

iptables를 Build하고 설치한다.

### 3. 참조

* [http://www.linuxfromscratch.org/blfs/view/8.2/postlfs/iptables.html](http://www.linuxfromscratch.org/blfs/view/8.2/postlfs/iptables.html)