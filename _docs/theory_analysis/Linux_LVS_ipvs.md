---
title: Linux LVS, IPVS
category: Theory, Analysis
date: 2019-01-27T12:00:00Z
lastmod: 2019-01-27T12:00:00Z
comment: true
adsense: true
---

Linux Kernel Level에서 Load Balancing을 수행하는 기법인 LVS (Linux Virtual Server)와 LVS의 핵심 요소인 IPVS (IP Virtual Server)를 분석한다.

### 1. LVS (Linux Virtual Server)

![]({{site.baseurl}}/images/theory_analysis/Linux_LVS_IPVS/Linux_LVS_IPVS.PNG){: width="500px"}

LVS는 Linux에서 제공하는 L4 Load Balancer 솔루션이다. 위의 그림은 LVS 구성을 나타낸다. LVS는 크게 Packet Load Balacing을 수행하는 Load Balancer와 Packet을 처리하는 Server로 구성되어 있다. Load Balancer는 SPOF (Single Pointer Of Failure) 방지를 위해 일반적으로 2대 이상의 Load Balancer를 VRRP로 묶어서 구성한다. VRRP로 묶는데는 Linux Kernel의 Network Stack에서 제공하는 Keepalived 기능을 이용한다. 각 Load Balancer에서는 아래에서 설명할 Linux Kenrel의 IPVS를 이용하여 Packet Load Balancing을 수행한다.

### 2. IPVS (IP Virtual Server)

### 3. 참조

* LVS - [https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/5/html/cluster_suite_overview/s1-lvs-overview-cso](https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/5/html/cluster_suite_overview/s1-lvs-overview-cso)
* ipvs - [http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.filter_rules.html](http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.filter_rules.html)