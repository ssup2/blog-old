---
title: Linux Netfilter / iptables
category: Theory, Analysis
date: 2017-04-19T12:00:00Z
lastmod: 2017-04-19T12:00:00Z
comment: true
adsense: true
---

Linux안에 있는 Netfilter Framework를 분석하고 Netfilter를 이용하는 iptables tool을 분석한다.

### 1. Netfilter

* Netfilter는 Linux를 위한 Network Packet Filtering Framework이다. Linux Application은 Netfilter를 통해서 Linux Kenel로 전달되는 Packet을 Hooking하고 조작할 수 있다.

### 1.1. Hooks

* Netfilter는 5가지 Hook Point를 제공한다.

1. NF_IP_PRE_ROUTING -

1. NF_IP_LOCAL_IN -

1. NF_IP_FORWARD -

1. NF_IP_LOCAL_OUT -

1. NF_IP_POST_ROUTING -

### 2. iptables

### 3. 참조

<img src="{{site.baseurl}}/images/theory_analysis/Virtual_Machine_Linux_Container/Linux_Container.PNG" width="500px">

![]({{site.baseurl}}/images/theory_analysis/KVM_QEMU/QEMU_non-iothread.PNG)

* QEMU - [http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html](http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html)
