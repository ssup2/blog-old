---
title: Linux LVS, IPVS
category: Theory, Analysis
date: 2019-01-27T12:00:00Z
lastmod: 2019-05-15T12:00:00Z
comment: true
adsense: true
---

Linux Kernel Level에서 Load Balancing을 수행하는 기법인 LVS (Linux Virtual Server)와 LVS의 핵심 요소인 IPVS (IP Virtual Server)를 분석한다.

### 1. LVS (Linux Virtual Server)

![[그림 1] Linux LVS]({{site.baseurl}}/images/theory_analysis/Linux_LVS_IPVS/LVS.PNG){: width="500px"}

LVS는 Linux에서 제공하는 L4 Load Balancer 솔루션이다. [그림 1]은 LVS 구성을 나타낸다. LVS는 크게 Packet Load Balacing을 수행하는 Load Balancer와 Packet의 실제 목적지인 Real Server로 구성되어 있다. Load Balancer는 SPOF (Single Pointer Of Failure) 방지를 위해 일반적으로 2대 이상의 Load Balancer를 VRRP로 묶어서 구성한다. VRRP로 묶는데는 Linux Kernel의 Network Stack에서 제공하는 Keepalived 기능을 이용한다. 각 Load Balancer에서는 아래에서 설명할 Linux Kenrel의 IPVS를 이용하여 Packet Load Balancing을 수행한다.

### 2. IPVS (IP Virtual Server)

IPVS는 Linux의 Netfilter 위에서 동작하는 L4 Load Balancer이다. Linux Kernel Level에서 동작하기 때문에 HAProxy같은 User Level Load Balancer보다 빠른 성능으로 동작한다. IPVS는 수신한 Packet에 대하여 DR (Direct Routing), NAT, IPIP Tunneling을 수행할 수 있다. IPVS는 ipvsadm 명령어를 통해 제어가 가능하다.

IPVS 없이 iptables만으로도 충분히 L4 Load Balacner을 구현할 수 있지만, Packet을 Rule을 따라가면서 처리하는 Chain 방식으로 동작하는 netfilter의 성능에는 한계점이 존재한다. 또한 IPVS에서는 rr (Round Robin), dh (Destination Hash) 등 많이 이용되는 Load Balancing 알고리즘을 쉽게 이용 할 수 있도록 제공하고 있다. 따라서 Linux Kernel Level에서 L4 Load Balancing을 수행하는 경우 IPVS를 이용하는것이 유리하다.

#### 2.1. Netfilter Hook Function

![[그림 2] IPVS Netfilter Hook Function]({{site.baseurl}}/images/theory_analysis/Linux_LVS_IPVS/IPVS.PNG)

[그림 2]는 IPVS의 Netfilter Hook Function들을 나타내고 있다. IPVS의 Netfilter Hook Function들은 IPVS를 이용하는 Server/Client가 외부의 Node에서 구동되는 경우뿐만 아니라, IPVS가 적용된 동일 Node에서 구동되어도 문제가 없도록 구성되어 있다. IPVS는 다음과 같은 6개의 Netfilter Hook Function을 이용한다.

##### 2.1.1. ip_vs_remote_request()

ip_vs_remote_request()는 LOCAL_IN Hook에서 호출되는 Netfilter Hook Function이다. 외부의 Client로부터 수신한 요청 Packet의 Dest IP가 Load Balancer IP (VIP)라면 ip_vs_remote_request()는 LOCAL_IN Hook을 통해서 호출된다. Load Balancing 및 필요에 따라서 해당 요청 Packet을 **DR, DNAT, IPIP Tunning**하여 Server에 전달한다. ip_vs_remote_request()를 통해서 처리가 완료된 Packet은 Local Process로 전달되지 않고 LOCAL_OUT Hook으로 전달된다. ip_vs_remote_request()는 iptables의 Input Filter Table 다음으로 실행되기 때문에 Input Filter Table에서 Filtering된 Packet은 ip_vs_remote_request()에서 처리하지 못한다. ip_vs_remote_request()의 실제 구현은 ip_vs_in()을 단순히 실행하는 형태로 되어있다.

##### 2.1.2. ip_vs_local_request()

ip_vs_local_request()는 LOCAL_OUT Hook에서 호출되는 Netfilter Hook Function이다. Client가 IPVS가 적용되어 있는 동일 Node에 있을경우, 해당 Client로부터 수신한 요청 Packet의 Dest IP가 Load Balancer IP라면 ip_vs_local_request()는 LOCAL_OUT Hook을 통해서 호출된다. ip_vs_remote_request()처럼 Load Balancing 및 필요에 따라서 해당 요청 Packet을 **DR, DNAT, IPIP Tunning**하여 Server에 전달한다. ip_vs_local_request는() iptables의 Output Mangle Table을 다음으로 수행된다. ip_vs_local_request()의 실제 구현은 ip_vs_remote_request()처럼 ip_vs_in()을 단순히 실행하는 형태로 되어있다.

##### 2.1.3. ip_vs_reply()

ip_vs_reply()는 LOCAL_IN Hook 및 FORWARD Hook에서 호출되는 Netfilter Hook Function이다. IPVS를 통해서 Client로부터 받은 요청 Packet을 Load Balancing 및 Server IP로 DNAT를 수행하여 Server에 Packet을 전달할 경우, IPVS는 Server로부터 받은 응답 Packet을 Load Balancer IP로 SNAT하여 IP로 Client로 전송해야 한다. ip_vs_reply()는 Server로부터 받은 응답 Packet을 Load Balancer IP로 **SNAT**를 수행하는 Netfilter Hook Funciton이다.

LOCAL_IN Hook의 ip_vs_reply()는 Server가 외부에 있고 Client가 IPVS가 적용된 동일 Node에 있는경우 호출된다. LOCAL_IN Hook의 ip_vs_reply()은 iptables의 Input Filter Table 다음으로 실행되기 때문에 Input Filter Table에서 Filtering된 Packet은 LOCAL_IN Hook의 ip_vs_reply()에서 처리하지 못한다. FORWARD Hook의 ip_vs_reply()는 Server와 Client가 외부에 있을 경우 호출된다. FORWARD Hook의 ip_vs_reply()는 iptables의 Forward Filter Table 다음으로 실행되기 때문에 Forward Filter Table에서 Filtering된 Packet은 FORWARD Hook의 ip_vs_reply()에서 처리하지 못한다. ip_vs_reply()의 실제 구현은 ip_vs_out()을 단순히 실행하는 형태로 되어있다.

##### 2.1.4. ip_vs_local_reply()

ip_vs_local_reply()는 LOCAL_OUT Hook에서 호출되는 Hook Function이다. ip_vs_reply()처럼 Server로부터 받은 응답 Packet을 Load Balancer IP로 **SNAT**를 수행하는 Netfilter Hook Funciton이다. ip_vs_local_reply()는 Client의 위치에 관계없이 Server가 IPVS가 적용되어 있는 동일 Node에 있을 경우 호출된다. 실제 구현은 ip_vs_reply()처럼 ip_vs_out() Function을 단순히 실행하는 형태로 되어있다.

##### 2.1.4. ip_vs_forward_icmp()

ip_vs_forward_icmp()는 FORWARD Hook에서 호출되는 Hook Function이다. 모든 ICMP Packet을 받아서 적절한 Real Server에게 전달하는 역활을 수행한다. 실제 구현은 in_vs_in_icmp()을 실행하는 형태로 되어있다.

### 3. 참조

* LVS - [https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/5/html/cluster_suite_overview/s1-lvs-overview-cso](https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/5/html/cluster_suite_overview/s1-lvs-overview-cso)
* ipvs - [http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.filter_rules.html](http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.filter_rules.html)
* ipvs - [https://www.valinux.co.jp/technologylibrary/document/load_balancing/lvs0001/](https://www.valinux.co.jp/technologylibrary/document/load_balancing/lvs0001/)
* ipvs - [https://github.com/torvalds/linux/blob/master/net/netfilter/ipvs/ip_vs_core.c](https://github.com/torvalds/linux/blob/master/net/netfilter/ipvs/ip_vs_core.c)