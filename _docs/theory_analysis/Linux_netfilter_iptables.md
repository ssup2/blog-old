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

![]({{site.baseurl}}/images/theory_analysis/Linux_netfilter_iptables/Netfilter_Packet_Traversal.PNG)

* iptables는 Netfilter Framework를 이용하는 대표 Tool이다. iptables를 이용하여 Packet을 제어하거나 조작 할 수 있다. 위의 그림은 Netfilter를 이용한 iptables의 Packet 처리 과정을 나타내고 있다. 그림에서 PREROUTING, FOWRARD, INPUT, OUTPUT, POSTROUTING은 각각 Netfilter의 NF_IP_PRE_ROUTING, NF_IP_LOCAL_IN, NF_IP_FORWARD, NF_IP_LOCAL_OUT, NF_IP_POST_ROUTING Hook을 의미한다.

#### 2.1. tables

* iptables는 Filter Table, NAT Table, Mangle Table, Raw Table, Security Table 총 5가지의 Table을 제공한다.

1. Filter Table - Packet Filtering을 위한 Table이다. Packet을 Packet의 목적지까지 전달할지 아니면 Packet을 Drop할지 결정한다. Firewall 기능은 Filter Table을 통해 구축 가능하다.

1. NAT Table - Packet NAT(Network Address Translation)를 위한 Table이다. Packet의 Source Address나 Destination Address를 변경한다.

1. Mangle Table - Packet의 IP Header를 바꾼다. Packet의 TTL(Time to Live)를 변경하거나 Packet을 Marking하여 다른 iptables의 Table이나 Network Tool에서 Packet을 구분 할 수 있도록 한다.

1. Raw Table - Netfilter Framework는 Hook 뿐만 아니라 Connection Tracking 기능을 제공한다. 이전에 도착한 Packet들을 바탕으로 방금 도착한 Packet의 Connection을 추적한다. Raw Table은 특정 Packet이 Connection Tracking에서 제외되도록 설정한다.

1. Security Table - SELinux에서 Packet을 어떻게 처리할지 결정하기 위한 Table이다.

#### 2.2. packet flow

### 3. 참조

* iptables, Netfilter - [https://www.digitalocean.com/community/tutorials/a-deep-dive-into-iptables-and-netfilter-architecture](https://www.digitalocean.com/community/tutorials/a-deep-dive-into-iptables-and-netfilter-architecture)

* iptable process - [http://stuffphilwrites.com/2014/09/iptables-processing-flowchart/](http://stuffphilwrites.com/2014/09/iptables-processing-flowchart/)

* Netfilter Packet Traversal - [http://linux-ip.net/](http://linux-ip.net/)
