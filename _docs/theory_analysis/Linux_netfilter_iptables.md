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

#### 1.1. Hooks

* Netfilter는 5개의 Hook Point를 제공한다.

1. NF_IP_PRE_ROUTING - 외부에서 온 Packet이 Linux Kernel의 Network Stack을 통과하기 전 발생하는 Hook이다. Packet을 Routing하기 전에 발생한다.

1. NF_IP_LOCAL_IN - Packet이 Routing된 후 목적지가 자신일 경우, Packet을 Application에 전달하기 전에 발생하는 Hook이다.

1. NF_IP_FORWARD - Packet이 Routing된 후 목적지가 자신이 아닐 경우, Packet을 다른 곳으로 Forwarding 하는 경우 발생하는 Hook이다.

1. NF_IP_LOCAL_OUT - Packet이 Application에서 나와 Network Stack을 통과하기 전에 발생하는 Hook이다.

1. NF_IP_POST_ROUTING - Packet이 Network Stack을 통과한 후 밖으로 보내기 전 발생하는 Hook이다.

#### 1.2. Packet Process

* 외부에서 온 Packet의 목적지가 자신인 경우 NF_IP_PRE_ROUTING -> NF_IP_LOCAL_IN -> NF_IP_LOCAL_OUT -> NF_IP_POST_ROUTING Hook을 거친다.

* 외부에서 온 Packet의 목적지가 자신이 아닌경우 NF_IP_PRE_ROUTING -> NF_IP_FORWARD -> NF_IP_POST_ROUTING Hook을 거친다.  

### 2. iptables

![]({{site.baseurl}}images\theory_analysis\Linux_netfilter_iptables\Netfilter_Packet_Traversal.PNG)

* iptables는 Netfilter Framework를 이용하여 Packet을 제어하고 변경하는 Tool이다. 위의 그림은 iptables이 Netfilter를 이용한 Packet 처리 과정을 나타내고 있다. 그림에서 PREROUTING, FOWRARD, INPUT, OUTPUT, POSTROUTING은 각각 Netfilter의 NF_IP_PRE_ROUTING, NF_IP_LOCAL_IN, NF_IP_FORWARD, NF_IP_LOCAL_OUT, NF_IP_POST_ROUTING Hook을 의미한다.

#### 2.1. tables

#### 2.2. packet flow

### 3. 참조

* iptables, Netfilter - [https://www.digitalocean.com/community/tutorials/a-deep-dive-into-iptables-and-netfilter-architecture](https://www.digitalocean.com/community/tutorials/a-deep-dive-into-iptables-and-netfilter-architecture)

* Netfilter Packet Traversal - [http://linux-ip.net/](http://linux-ip.net/)
