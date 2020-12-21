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

![[그림 2] IPVS Netfilter Hook Function]({{site.baseurl}}/images/theory_analysis/Linux_LVS_IPVS/IPVS_Netfilter_Hook_Function.PNG)

[그림 2]는 IPVS의 Netfilter Hook Function들을 나타내고 있다. IPVS의 Netfilter Hook Function들은 IPVS를 이용하는 Real Server/Client가 외부 Node에서 구동되는 경우뿐만 아니라, IPVS가 적용된 Node에서 구동되어도 문제가 없도록 구성되어 있다. IPVS는 다음과 같은 6개의 Netfilter Hook Function을 이용한다.

##### 2.1.1. ip_vs_remote_request()

ip_vs_remote_request()는 LOCAL_IN Hook에서 호출되는 Netfilter Hook Function이다. **Client가 외부 Node에 있을경우** ip_vs_remote_request()는 LOCAL_IN Hook을 통해서 호출된다. Load Balancing 및 필요에 따라서 해당 요청 Packet을 **DR, DNAT, IPIP Tunning**하여 Real Server에 전달한다. ip_vs_remote_request()는 iptables의 Input nat Table과 Input security Table 사이에서 ip_vs_reply() 다음으로 호출된다. ip_vs_remote_request()의 실제 구현은 ip_vs_in()을 단순히 호출하는 형태로 되어있다. ip_vs_in()를 통해서 처리가 완료된 Packet은 Local Process로 전달되지 않고 **POSTROUTING Table**로 바로 전달된다.

##### 2.1.2. ip_vs_local_request()

ip_vs_local_request()는 LOCAL_OUT Hook에서 호출되는 Netfilter Hook Function이다. **Client가 IPVS가 적용되어 있는 Node에 있을경우**, 해당 Client로부터 수신한 요청 Packet의 Dest IP가 IPVS의 IP라면 ip_vs_local_request()는 LOCAL_OUT Hook을 통해서 호출된다. ip_vs_remote_request()처럼 Load Balancing 및 필요에 따라서 해당 요청 Packet을 **DR, DNAT, IPIP Tunning**하여 Real Server에 전달한다. ip_vs_local_request는() iptables의 Output nat Table과 Output filter Table 사이에서 ip_vs_local_reply() 다음으로 호출된다. ip_vs_local_request()의 실제 구현은 ip_vs_remote_request()처럼 ip_vs_in()을 단순히 호출하는 형태로 되어있다. ip_vs_in()를 통해서 처리가 완료된 Packet은 **POSTROUTING Table**로 바로 전달된다.

##### 2.1.3. ip_vs_reply()

ip_vs_reply()는 LOCAL_IN Hook 및 FORWARD Hook에서 호출되는 Netfilter Hook Function이다. IPVS를 통해서 Client로부터 받은 요청 Packet을 Load Balancing 및 Real Server IP로 DNAT를 수행하여 Real Server에 Packet을 전달할 경우, IPVS는 Real Server로부터 받은 응답 Packet을 IPVS의 IP로 SNAT하여 IP로 Client로 전송해야 한다. ip_vs_reply()는 Real Server로부터 받은 응답 Packet을 IPVS의 IP로 **SNAT**를 수행하는 Netfilter Hook Funciton이다.

**Real Server가 외부 Node에 있고 Client가 IPVS가 적용된 Node에 있는경우** LOCAL_IN Hook의 ip_vs_reply()를 통해서 SNAT가 수행된다. LOCAL_IN Hook의 ip_vs_reply()은 iptables의 Input nat Table과 Input security Table 사이에서 ip_vs_remote_request() 이전에 호출된다. **Real Server와 Client가 외부 Node에 있을 경우** FORWARD Hook의 ip_vs_reply()를 통해서 SNAT가 수행된다. FORWARD Hook의 ip_vs_reply()는 iptables의 Forward security Table 및 ip_vs_forwoard_icmp() 다음에 호출된다. ip_vs_reply()의 실제 구현은 ip_vs_out()을 단순히 호출하는 형태로 되어있다.

##### 2.1.4. ip_vs_local_reply()

ip_vs_local_reply()는 LOCAL_OUT Hook에서 호출되는 Hook Function이다. ip_vs_reply()처럼 Real Server로부터 받은 응답 Packet을 IPVS의 IP로 **SNAT**를 수행하는 Netfilter Hook Funciton이다. Client의 위치에 관계없이 **Real Server가 IPVS가 적용되어 있는 Node에 있을 경우** ip_vs_local_reply()를 통해서 SNAT가 수행된다. ip_vs_local_reply()는 iptables의 Output nat Table과 Output filter Table 사이에서 ip_vs_local_request() 이전에 호출된다. 실제 구현은 ip_vs_reply()처럼 ip_vs_out()을 단순히 호출하는 형태로 되어있다.

##### 2.1.5. ip_vs_forward_icmp()

ip_vs_forward_icmp()는 FORWARD Hook에서 호출되는 Hook Function이다. Dest가 0.0.0.0/0(모든 IP)인 ICMP Packet은 LOCAL_IN Table이 아니라 FORWARD Table로 전달되는데, 이러한 ICMP Packet을 받아서 Real Server에게 전달하는 역할을 수행한다. ip_vs_forward_icmp()은 iptables의 Forward security Table과 ip_vs_reply() 사이에 호출된다. ip_vs_forward_icmp()의 실제 구현은 in_vs_in_icmp()을 호출하는 형태로 되어있다.

#### 2.2 IPVS Dummpy Interface

{% highlight console %}
# ipvsadm -ln
...
TCP  10.100.15.169:80 rr
  -> 192.167.1.93:80              Masq    1      0          0
  -> 192.167.2.88:80              Masq    1      0          0
  -> 192.167.2.215:80             Masq    1      0          0    
TCP  10.103.1.234:80 rr
  -> 192.167.1.93:80              Masq    1      0          0
  -> 192.167.2.88:80              Masq    1      0          0
  -> 192.167.2.215:80             Masq    1      0          0   
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] IPVS List</figcaption>
</figure>

{% highlight console %}
# ip a
...
4: ipvs0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default
    link/ether 72:35:cc:0c:19:b3 brd ff:ff:ff:ff:ff:ff
    inet 10.100.15.169/32 brd 10.100.15.169 scope global kube-ipvs0
       valid_lft forever preferred_lft forever
    inet 10.103.1.234/32 brd 10.103.1.234 scope global kube-ipvs0
       valid_lft forever preferred_lft forever
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] IPVS Dummy Interface</figcaption>
</figure>

LOCAL_IN Hook은 Packet의 Dest IP가 Node 자기 자신의 IP일 경우, 해당 Packet이 Process로 전달되기 전에 호출되는 Hook이다. 따라서 Packet의 Dest IP가 Node의 IP가 아닌 IPVS의 IP이면 해당 Packet은 LOCAL_IN Hook이 아니라 FORWARD Hook에서 처리되어야 한다. 하지만 해당 Packet이 LOCAL_IN Hook에서 처리되는 이유는 IPVS 설정과 같이 설정되어야 하는 Dummy Interface에 IPVS의 IP가 할당되기 때문이다.

[Shell 1]은 ipvsadm 명령어를 이용하여 IPVS List 정보를 보여주고 있다. Dest IP, Dest Port가 10.100.15.169:80 또는 10.103.1.234:80인 Packet이 Round Robin 알고리즘에 의해서 Load Balancing 되도록 설정되어 있다. [Shell 2]는 IPVS의 Dummy Interface를 나타내고 있다. ipvs0 Interface에 IPVS의 IP인 10.100.15.169와 10.103.1.234가 설정되어 있는것을 확인할 수 있다.

### 3. 참조

* LVS : [https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/5/html/cluster_suite_overview/s1-lvs-overview-cso](https://access.redhat.com/documentation/ko-kr/red_hat_enterprise_linux/5/html/cluster_suite_overview/s1-lvs-overview-cso)
* LVS : [http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.fwmark.html](http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.fwmark.html)
* ipvs : [http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.filter_rules.html](http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.filter_rules.html)
* ipvs : [https://www.valinux.co.jp/technologylibrary/document/load_balancing/lvs0001/](https://www.valinux.co.jp/technologylibrary/document/load_balancing/lvs0001/)
* ipvs : [https://github.com/torvalds/linux/blob/master/net/netfilter/ipvs/ip_vs_core.c](https://github.com/torvalds/linux/blob/master/net/netfilter/ipvs/ip_vs_core.c)
* ipvs : [http://helloweishi.github.io/network/stack/2015/06/27/L3-IP-stack/](http://helloweishi.github.io/network/stack/2015/06/27/L3-IP-stack/)
* ipvs : [http://www.linuxvirtualserver.org/VS-NAT.html](http://www.linuxvirtualserver.org/VS-NAT.html)