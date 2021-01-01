---
title: Istio Sidecar
category: Theory, Analysis
date: 2021-01-03T12:00:00Z
lastmod: 2021-01-03T12:00:00Z
comment: true
adsense: true
---

Istio의 Sidecar 기법을 분석한다.

### 1. Istio Sidecar

![[그림 1] Istio Sidecar]({{site.baseurl}}/images/theory_analysis/Istio_Sidecar/Istio_Sidecar.PNG){: width="500px"}

Istio의 Sidecar 기법은 각 Pod 마다 전용 Proxy Server를 띄우는 기법을 의미한다. [그림 1]은 Istio Sidecar 기법의 Architecture를 나타내고 있다. Sidecar는 Pod으로 전달되는 모든 Inbound Packet을 대신 수신한 다음, 처리후 Pod의 Container에게 전송하는 역활을 수행한다. 또한 Sidecar는 Pod에서 밖으로 전송되는 모든 Packet을 대신 수신한 다음, 처리후 Pod의 외부로 전송하는 역활을 수행한다.

이러한 Sidecar의 특징 때문에 Sidecar는 Packet 전송에 필요한 모든 정보를 알고 있어야 한다. Sidecar는 이러한 Packet 전송에 필요한 정보를 Istiod라고 불리는 중앙 Controller로 부터 받는다. Istiod가 Sidecar에게 전송하는 정보에는 Pod에서 동작하는 App이 제공하는 Service 정보, Packet 전송에 필요한 Routing 정보, Packet 송수신 허용 여부를 결정하는 Policy 정보, Packet 암호화를 위한 인증서 정보등이 포함되어 있다. Sidecar는 Istiod로 부터 받은 정보들을 바탕으로 Service Discovery, Packet Load Balancing, Packet Encap/Decap, Circuit Breaker 역활 등을 수행한다.

Istio의 Sidecar는 Envoy라고 불리는 Proxy 서버를 이용하며 HTTP, gRPC, TCP등 다양한 Protocol을 지원한다. 따라서 App에서도 다양한 Protocol을 기반으로 Packet을 주고받을 수 있다.

#### 1.1. Sidecar Injection

Sidecar는 Pod안에서 Container로 동작 해야한다. 따라서 Sidecar가 Pod안에서 Container로 동작할 수 있도록 설정해주어야 한다. Sidecar 설정은 각 Pod마다 수동으로 설정할 수도 있고, Namespace 단위로 설정하여 Namespace안에서 생성되는 모든 Pod에서 Sidecar가 동작하도록 설정할 수 있다.

##### 1.1.1. Manual 설정

##### 1.1.2. Namespace 설정

#### 1.2. Packet Capture

{% highlight console %}
# iptables -t nat -nvL
Chain PREROUTING (policy ACCEPT 11729 packets, 704K bytes)
 pkts bytes target     prot opt in     out     source               destination
11729  704K ISTIO_INBOUND  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain INPUT (policy ACCEPT 11729 packets, 704K bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 1074 packets, 95511 bytes)
 pkts bytes target     prot opt in     out     source               destination
   54  3240 ISTIO_OUTPUT  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain POSTROUTING (policy ACCEPT 1077 packets, 95691 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain ISTIO_INBOUND (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 RETURN     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:15008
    0     0 RETURN     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
    0     0 RETURN     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:15090
11727  704K RETURN     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:15021
    2   120 RETURN     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:15020
    0     0 ISTIO_IN_REDIRECT  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain ISTIO_IN_REDIRECT (3 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 REDIRECT   tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            redir ports 15006

Chain ISTIO_OUTPUT (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 RETURN     all  --  *      lo      127.0.0.6            0.0.0.0/0
    0     0 ISTIO_IN_REDIRECT  all  --  *      lo      0.0.0.0/0           !127.0.0.1            owner UID match 1337
    0     0 RETURN     all  --  *      lo      0.0.0.0/0            0.0.0.0/0            ! owner UID match 1337
   51  3060 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            owner UID match 1337
    0     0 ISTIO_IN_REDIRECT  all  --  *      lo      0.0.0.0/0           !127.0.0.1            owner GID match 1337
    0     0 RETURN     all  --  *      lo      0.0.0.0/0            0.0.0.0/0            ! owner GID match 1337
    0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            owner GID match 1337
    0     0 RETURN     all  --  *      *       0.0.0.0/0            127.0.0.1
    3   180 ISTIO_REDIRECT  all  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain ISTIO_REDIRECT (1 references)
 pkts bytes target     prot opt in     out     source               destination
    3   180 REDIRECT   tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            redir ports 15001
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 1] Pod iptables NAT Table with Istio Sidecar</figcaption>
</figure>

### 2. 참조

* [https://istio.io/latest/docs/reference/config/networking/virtual-service/](https://istio.io/latest/docs/reference/config/networking/virtual-service/)
* [https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/)
