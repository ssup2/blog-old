---
title: Linux conntrack
category: Theory, Analysis
date: 2019-12-10T12:00:00Z
lastmod: 2020-03-01T12:00:00Z
comment: true
adsense: true
---

Linux에서 Network Connection을 관리하는 역할을 수행하는 Netfilter Framework의 Module인 conntrack을 분석한다.

### 1. Linux conntrack Module

conntrack Module은 Linux Kernel에서 **Network Connection을 관리, 추적**하는 Netfilter Framework의 Stateful Module이다. iptables와 같이 Netfilter Filter Framework 기반 Application이 제공하는 Network Connection 관련 기능들은 모두 conntrack Module을 기반으로 하고 있다.

#### 1.1. Connection Status, conntrack Command

{% highlight text %}
# conntrack -L conntrack
tcp      6 431899 ESTABLISHED src=127.0.0.1 dst=127.0.0.1 sport=49236 dport=53191 src=127.0.0.1 dst=127.0.0.1 sport=53191 dport=49236 [ASSURED] mark=0 use=1
tcp      6 49 TIME_WAIT src=10.0.0.19 dst=10.0.0.11 sport=55120 dport=9283 src=10.0.0.11 dst=10.0.0.19 sport=9283 dport=55120 [ASSURED] mark=0 use=1
tcp      6 7 CLOSE src=10.0.0.11 dst=10.0.0.19 sport=36892 dport=9093 src=10.0.0.19 dst=10.0.0.11 sport=9093 dport=36892 mark=0 use=1
tcp      6 28 TIME_WAIT src=10.0.0.19 dst=10.0.0.19 sport=34306 dport=18080 src=10.0.0.19 dst=10.0.0.19 sport=18080 dport=34306 [ASSURED] mark=0 use=1
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] conntrack Table</figcaption>
</figure>

conntrack Module이 관리하고 있는 Connection 정보는 conntrack 명령어롤 통해서 확인할 수 있다. conntrack은 conntrack, expect, dying, unconfirmed 4개의 Table을 관리한다. Connection 정보가 저장되는 Table은 Connection Status에 따라 결정된다.

* conntrack : 대부분의 Connection 정보들을 저장하고 있다. [Shell 1]은 conntrack Table을 나타내고있다.
* expect : Connection Tracking Helper에 의해서 Related Connection으로 분류된 Connection 정보들을 저정하고 있다.
* dying : Connection이 만기가 되거나, conntrack 명령어를 통해서 삭제되고 있는 Connection 정보들을 저장하고 있다.
* unconfirmed : Kernel의 Socket Buffer에 저장된 Packet이 갖고 있는 Connection 정보이지만, 아직 확인하지 못하여 conntrack Table에는 저장되지 못한 Connection 정보들을 의미한다. Packet이 갖고 있는 Connection 정보는 Packet이 Postrouting Hook에 도달하였을 때 Confirm된다.

#### 1.2. Connection Tracking Helper

Connection Tracking Helper는 Stateful Application Layer Protocol을 파악하여 별도의 독립된 Connection을 **Related Connection**으로 분류하는 역할을 수행한다. 지원하는 Stateful Application Layer Protocol은 FTP, TFPT, SNMP, SIP 등이 있다. 예를 들어 FTP의 경우 Control Connection과 Data Connection 2가지의 Connection을 이용하는데 Control Connection은 존재하지만 Data Connection이 없는 상태에서 Data Connection이 생성될 경우, 생성된 Data Connection은 New Connection 상태가 아닌 Related Connection 상태로 분류된다.

{% highlight text %}
# lsmod | grep nf_conntrack
nf_conntrack_tftp      16384  0
nf_conntrack_sip       28672  0
nf_conntrack_snmp      16384  0
nf_conntrack_broadcast    16384  1 nf_conntrack_snmp
nf_conntrack_ftp       20480  0
nf_conntrack_netlink    40960  0
nf_conntrack_ipv6      20480  1
nf_conntrack_ipv4      16384  5
nf_conntrack          131072  16 xt_conntrack,nf_nat_masquerade_ipv4,nf_conntrack_ipv6,nf_conntrack_ipv4,nf_nat,nf_conntrack_tftp,nf_nat_ipv6,ipt_MASQUERADE,nf_nat_ipv4,xt_nat,nf_conntrack_sip,openvswitch,nf_conntrack_broadcast,nf_conntrack_netlink,nf_conntrack_ftp,nf_conntrack_snmp
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] conntrack Modules</figcaption>
</figure>

Connection Tracking Helper는 별도의 Module로 구성되어 있다. [Shell 2]은 conntrack 관련 Module들을 나타내고 있다. [Shell 2]에서 nf_conntrack_[Protocol] 형태의 Module들이 Connection Tracking Helper의 Module이다. HTTP와 같은 Stateless Application Layer Protocol은 지원하지 않는다.

#### 1.3. Connection Option in iptables

{% highlight text %}
# iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] Connection State in iptables</figcaption>
</figure>

iptables에서는 conntrack Module을 기반으로 하여 Connection State 조건 기능을 제공한다. iptables에서 지원하는 Connection State 조건은 다음과 같다.

* NEW : 새로운 Connection을 생성하려는 상태를 의미한다.
* ESTABLISHED : 현재 존재하는 Connection을 의미한다.
* RELATED : Connection Tracking Helper에 의해서 예상된 새로운 Connection을 생성하려는 상태를 의미한다.
* INVALID : 어떠한 Connection에도 소속되지 않은 상태를 의미한다.
* UNTRACKED : Connection을 추적하지 않는 상태를 의미한다.

[Shell 3]은 22번 Port로 들어온는 Packet이 새로운 Connection을 생성하려고 하거나, 기존의 Connection을 통해서 통신하려는 경우 허용하는 Rule을 iptable 명령어를 통해서 설정하는 과정을 나타내고 있다. iptables에서는 NAT를 수행 할 때도 conntrack Module을 이용한다. iptables에서 NAT Rule을 설정하면 이와 반대대는 Reverse NAT는 iptables에 Reverse NAT Rule이 없어도 자동으로 수행되는데, iptables는 conntrack Module의 Connection 정보를 바탕으로 암묵적으로 Reverse NAT를 수행하기 때문이다.

#### 1.4. Max Connection Count

conntrack Module은 Connection 정보를 Kernel Memory에 저장하기 때문에, 저장할 수 있는 Connection의 개수는 한정되어 있다. '/proc/sys/net/nf_conntrack_max' 또는 '/proc/sys/net/ipv4/netfilter/ip_conntrack_max' 값을 설정하여 conntrack Module이 저장할 수 있는 최대 Connection의 개수를 설정할 수 있다. 일반적으로 기본값은 '262144'이다. Connection 정보를 저장할 수 있는 공간이 가득차 더 이상 Connection 정보를 저장히지 못하는 상태에서 새로운 Connection 정보를 갖고 있는 Packet을 수신할 경우 해당 Packet은 Drop된다.

### 2. 참조

* [https://manpages.debian.org/testing/conntrack/conntrack.8.en.html](https://manpages.debian.org/testing/conntrack/conntrack.8.en.html)
* [https://en.wikipedia.org/wiki/Netfilter](https://en.wikipedia.org/wiki/Netfilter)
* [http://people.netfilter.org/pablo/docs/login.pdf](http://people.netfilter.org/pablo/docs/login.pdf)
* [https://tech.kakao.com/2016/04/21/closewait-timewait/](https://tech.kakao.com/2016/04/21/closewait-timewait/)
* [https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security_guide/sect-security_guide-firewalls-iptables_and_connection_tracking](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security_guide/sect-security_guide-firewalls-iptables_and_connection_tracking)
* [https://unix.stackexchange.com/questions/57423/how-to-understand-why-the-packet-was-considered-invalid-by-the-iptables](https://unix.stackexchange.com/questions/57423/how-to-understand-why-the-packet-was-considered-invalid-by-the-iptables)
* [https://www.frozentux.net/iptables-tutorial/chunkyhtml/x1555.html](https://www.frozentux.net/iptables-tutorial/chunkyhtml/x1555.html)