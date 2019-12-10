---
title: Linux conntrack
category: Theory, Analysis
date: 2019-12-10T12:00:00Z
lastmod: 2019-12-10T12:00:00Z
comment: true
adsense: true
---

Linux에서 Connection을 Tracking하는 모듈인 conntrack을 분석한다.

### 1. Linux conntrack Module

conntrack은 Linux Netfilter Framework에서 Connection을 관리하는 **Stateful Module**이다. 수신한 Packet의 Header 정보만을 이용하여 Packet을 Filtering하는 기법은 DDos 같은 Traffic 기반 공격을 방어할 수 없다. conntrack Module은 Connection 정보를 저장하여 다양한 Filtering 기법을 가능하도록 만든다. iptables에서 NAT Rule을 설정하면 이와 반대대는 Reverse NAT는 iptables에 Reverse NAT Rule이 없어도 자동으로 수행되는데, iptables는 conntrack Module의 Connection 정보를 바탕으로 암묵적으로 Reverse NAT를 수행하기 때문이다. 

#### 1.1. Connection State

Linux conntrack Module은 Connection State를 다음과 같이 정의한다. 

* NEW : 새로운 Connection을 생성하려는 상태를 의미한다.
* ESTABLISHED : 현재 존재하는 Connection을 의미한다.
* RELATED : Connection Tracking Helper에 의해서 **예상된** 새로운 Connection을 생성하려는 상태를 의미한다.
* INVALID : 예상된 Connection 동작을 수행하지 않는 상태를 의미한다.

#### 1.2. Connection Tracking Helper

Connection Tracking Helper는 **Stateful Application Layer Protocol**을 파악하여 새로운 Connection을 예상하고, 예상된 Connection이 생성될 경우 해당 Connection을 RELATED Connection으로 분류하는 역활을 수행한다. 지원하는 Protocol은 FTP, TFPT, SNMP, SIP 등이 있다. HTTP와 같은 Stateless Application Layer Protocol은 지원하지 않는다.

### 2. conntrack Tool

Linux conntrack Module이 관리하는 Connection 정보는 **conntack 명령어**로 확인 및 제어할 수 있다.

#### 2.1. Tables

conntrack에서는 conntrack, expect, dying, unconfirmed 4개의 Table을 지원한다.

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

* conntrack : 추적하고 있는 Connection의 상태 정보를 갖고 있다. [Shell 1]은 conntrack Table을 나타내고있다. Protocol, (TCP) Connection 상태, Src IP/Port, Dest IP/Port 정보를 확인할 수 있다.
* expect : Connection Tracking Helper에 의해서 RELATED 상태의 Connection 정보를 갖고 있다.
* dying : Connection이 만기가 되거나, conntrack 명령어를 통해서 삭제되고 있는 Connection 정보를 갖고 있다.
* unconfirmed : 확인되지 않은 Connection 정보를 갖고 있다.

### 3. 참조

* [https://manpages.debian.org/testing/conntrack/conntrack.8.en.html](https://manpages.debian.org/testing/conntrack/conntrack.8.en.html)
* [https://en.wikipedia.org/wiki/Netfilter](https://en.wikipedia.org/wiki/Netfilter)
* [http://people.netfilter.org/pablo/docs/login.pdf](http://people.netfilter.org/pablo/docs/login.pdf)
* [https://www.projectcalico.org/when-linux-conntrack-is-no-longer-your-friend/](https://www.projectcalico.org/when-linux-conntrack-is-no-longer-your-friend/)
* [https://tech.kakao.com/2016/04/21/closewait-timewait/]
