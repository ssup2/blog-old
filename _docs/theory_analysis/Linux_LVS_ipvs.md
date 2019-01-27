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

![]({{site.baseurl}}/images/theory_analysis/Linux_LVS_IPVS/LVS.PNG){: width="500px"}

LVS는 Linux에서 제공하는 L4 Load Balancer 솔루션이다. 위의 그림은 LVS 구성을 나타낸다. LVS는 크게 Packet Load Balacing을 수행하는 Load Balancer와 Packet의 실제 목적지인 Real Server로 구성되어 있다. Load Balancer는 SPOF (Single Pointer Of Failure) 방지를 위해 일반적으로 2대 이상의 Load Balancer를 VRRP로 묶어서 구성한다. VRRP로 묶는데는 Linux Kernel의 Network Stack에서 제공하는 Keepalived 기능을 이용한다. 각 Load Balancer에서는 아래에서 설명할 Linux Kenrel의 IPVS를 이용하여 Packet Load Balancing을 수행한다.

### 2. IPVS (IP Virtual Server)

![]({{site.baseurl}}/images/theory_analysis/Linux_LVS_IPVS/IPVS.PNG)

IPVS는 Linux의 Netfilter 위에서 동작하는 L4 Load Balancer이다. Linux Kernel Level에서 동작하기 때문에 Haproxy같은 User Level Load Balancer보다 빠른 성능으로 동작한다. IPVS는 ipvsadm 명령어를 통해 제어가 가능하다. 위의 그림은 Netfilter에서 동작하는 IPVS의 Hook Function들을 나타내고 있다. IPVS는 6개의 Hook Function을 이용한다.

* ip_vs_reply() - LOCAL_IN Hook 및 FORWARD Hook에서 호출되는 Hook Function이다. IPVS로 Load Balancing 및 Real Server IP로 DNAT를 같이 수행하여 Real Server에 Packet을 전달할 경우, IPVS는 Real Server로부터 받은 Packet을 Load Balancer IP (VIP)로 SNAT하여 IP로 외부로 내보내야한다. ip_vs_reply() Function은 이러한 SNAT를 수행하는 Hook Funciton이다. ip_vs_reply() Function은 Packet이 LOCAL_IN 및 FORWARD Hook 기반의 iptables filter Table을 지난뒤 호출되기 때문에, iptables filter Table에서 Filtering된 Packet은 처리하지 못한다. 실제 구현은 ip_vs_in() Function을 단순히 실행하는 Wrapper Function으로 되어있다.

* ip_vs_local_reply() - LOCAL_OUT Hook에서 호출되는 Hook Function이다. ip_vs_reply() Function처럼 IPVS를 이용해 DNAT를 수행할 경우 SNAT를 수행한다. ip_vs_reply() Function과 다른점은 Network에서 수신한 Packet이 아니라 Local Process에서 전송한 Packet을 SNAT한다는 점이다. 즉 Load Balancer와 Read Server가 같은 Server에서 동작할 경우 이용된다. 실제 구현도 ip_vs_reply() Function처럼 ip_vs_in() Function을 단순히 실행하는 Wrapper Function으로 되어있다.

* ip_vs_remote_request() - LOCAL_IN Hook에서 호출되는 Hook Function이다. Network로부터 수신한 Packet의 Source IP가 Load Balancer IP (VIP)라면 Load Balancing 알고리즘에 Packet을 어느 Real Server에 전송할지 결정하고, 필요에 따라서 DNAT도 수행한다. Load Balancing이 수행된 Packet은 Local Process로 전달되지 않고 LOCAL_OUT Hook으로 전달된다. 실제 구현은 ip_vs_out() Function을 단순히 실행하는 Wrapper Function으로 되어있다.

* ip_vs_local_request() - LOCAL_OUT Hook에서 호출되는 Hook Function이다. ip_vs_remote_request() Function처럼 Load Balancing 및 필요에 따라서 DNAT를 수행한다. ip_vs_remote_request() Function과 다른점은 Network에서 수신한 Packet이 아니라 Local Process에서 전송한 Packet을 Load Balancing 및 DNAT한다는 점이다. 즉 Load Balancer와 Read Server가 같은 Server에서 동작할 경우 이용된다. 실제 구현도 ip_vs_remote_request() Function처럼 ip_vs_out() Function을 단순히 실행하는 Wrapper Function으로 되어있다.

* ip_vs_forward_icmp() - FORWARD Hook에서 호출되는 Hook Function이다. 모든 ICMP Packet을 받아서 적절한 Real Server에게 전달하는 역활을 수행한다. 실제 구현은 in_vs_in_icmp() Function을 실행하는 Wrapper Function으로 되어있다.

IPVS 없이 Netfilter만으로도 충분히 L4 Load Balacner을 구현 할 수 있지만, Packet을 Rule을 따라가면서 처리하는 Chain 방식으로 동작하는 netfilter의 성능에는 한계점이 존재한다. 또한 IPVS에서는 rr (Round Robin), dh (Destition Hash) 등 많이 이용되는 Load Balancing 알고리즘을 쉽게 이용 할 수 있도록 제공하고 있다. 따라서 Linux Kernel Level에서 L4 Load Balancing을 수행하는 경우 IPVS를 이용하는것이 유리하다.

### 3. 참조

* LVS - [https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/5/html/cluster_suite_overview/s1-lvs-overview-cso](https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/5/html/cluster_suite_overview/s1-lvs-overview-cso)
* ipvs - [http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.filter_rules.html](http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.filter_rules.html)
* ipvs - [https://www.valinux.co.jp/technologylibrary/document/load_balancing/lvs0001/](https://www.valinux.co.jp/technologylibrary/document/load_balancing/lvs0001/)