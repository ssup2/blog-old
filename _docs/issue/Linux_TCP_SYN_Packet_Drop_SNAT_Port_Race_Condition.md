---
title: Linux TCP SYN Packet Drop with SNAT Port Race Condition
category: Issue
date: 2020-10-25T12:00:00Z
lastmod: 2020-10-25T12:00:00Z
comment: true
adsense: true
---

[Issue](https://tech.xing.com/a-reason-for-unexplained-connection-timeouts-on-kubernetes-docker-abd041cf7e02)글의 내용을 정리하였습니다.

### 1. Issue

TCP Connection을 맺기 위해서 TCP SYN Packet을 SNAT하여 전송시, SNAT를 진행하면서 TCP SYN Packet에 설정되는 Src Port 번호를 선택하는 과정에서 발생하는 Race Condition에 의해서 TCP SYN Packet이 Drop 되는 Issue가 존재한다. TCP SYN Packet이 Drop되면 TCP Connection이 최소 1초 이상 지연되어 맺어지게 되어, Client는 Timeout을 경험할 수 있다.

대부분의 Docker Container 내부에서 Docker Host 외부의 Server와 TCP Connection을 맺는 경우, Docker Container가 전송한 TCP SYN Packet은 Docker Host에서 SNAT 되어 외부로 전송되기 때문에 본 Issue가 발생할 수 있다. 이와 유사하게 대부분의 Kubernetes Pod의 Container 내부에서 Kubernetes Cluster 외부의 Server와 TCP Connection을 맺는 경우, Kubernetes Pod의 Container가 전송한 TCP SYN Packet은 SNAT 되어 외부로 전송되기 때문에 본 Issue가 발생할 수 있다.

### 2. 원인, 해결 방안

Linux에서는 iptables 명령어를 통해서 Packet을 외부로 전송시, Packet의 Src IP를 Packet이 전송되는 Interface의 IP로 변경해주는 SNAT 기법인 Masquerade 기법을 제공한다. 이때 Src Port 번호도 Host에서 이용되고 있지 않는 임의의 Port 번호로 변경된다.

하나의 Process 내부에서 다수의 Thread가 동시에 Masquerade 기법을 통해서 동일한 외부 Server(동일한 IP, Port)로 TCP Connection을 맺으려는 경우에, 다수의 TCP SYN Packet은 Masquerade 기법을 통해서 SNAT 된다. 이때 **각 TCP SYN Packet의 Src Port 번호는 서로 다른 Port 번호로 변경**되어야 한다. 그래야 외부 Server로부터 응답이 왔을경우 어느 TCP Connection에 대한 응답인지 파악할 수 있기 때문이다.

하지만 **Kernel Bug로 인해서 동시에 TCP SYN Packet을 전송할 경우, 각 TCP SYN Packet의 Src Port 번호는 동일한 Port 번호로 변경** 될 수 있다. 동일한 Port 번호로 Src Port가 변경된 TCP SYN Packet들 중에서 가장 먼저 처리되는 TCP SYN Packet을 제외한 나머지 TCP SYN Packet은 Linux conntrack의 중복 Connection 방지 Logic에 의해서 Drop된다.

현재까지 본 이슈 관련 Kernel Bug는 해결하지 못한 상태이다. 따라서 현재는 Masquerade 기법으로 인해서 할당되는 Src Port 번호가 최대한 중복되지 않도록 설정하는 방법밖에 없다. Masquerade 기법으로 Src Port 번호를 할당하는 Default Algorithm은 마지막으로 할당한 Port 번호를 시작으로 하나씩 증가시키면서 Port 번호가 이용중인지 확인하고, 이용중이 아니라면 할당하는 방식이다. 따라서 Default 방법은 동시에 Src Port 번호 할당 요청이 들어오면, 중복된 Src Port 번호를 할당할 확률이 높다.

Kernel에서는 이러한 문제 해결을 위해서 Random으로 Src Port 번호를 할당하는 NF_NAT_RANGE_PROTO_RANDOM Algorithm과 NF_NAT_RANGE_PROTO_RANDOM_FULLY Algorithm이 존재한다. NF_NAT_RANGE_PROTO_RANDOM_FULLY Algorithm은 NF_NAT_RANGE_PROTO_RANDOM Algorithm을 보안하는 용도로 탄생한 Algorithm이다. 따라서 **NF_NAT_RANGE_PROTO_RANDOM_FULLY Algorithm을 통해서 Src Port를 Random으로 할당하여 Src Port 중복을 방지**하여 TCP SYN Packet의 Drop 확률을 낮출수 있다. 하지만 100% 본 이슈를 해결할 수 있는 방법은 아니다.

NF_NAT_RANGE_PROTO_RANDOM_FULLY Algorithm을 Masquerade 기법에 적용하기 위해서는 iptables 명령어로 Masquerade Rule을 추가하면서 "--random-fully" Option을 넣으면 된다. "--random-fully" Option은 iptables v1.6.2 Version부터 지원한다.

### 3. with Kubernetes

{% highlight console %}
# iptables -t nat -nvL
...
Chain KUBE-POSTROUTING (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MASQUERADE  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service traffic requiring SNAT */ mark match 0x4000/0x4000
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] --random-fully Option이 적용 되어있지 않는 KUBE-POSTROUTING Chain</figcaption>
</figure>

{% highlight console %}
# iptables -t nat -nvL
...
Chain KUBE-POSTROUTING (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 MASQUERADE  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes service traffic requiring SNAT */ mark match 0x4000/0x4000 random-fully
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] --random-fully Option이 적용 되어있는 않는 KUBE-POSTROUTING Chain</figcaption>
</figure>

Kubernetes v1.16.0 Version부터는 본 Issue를 해결하기 위해서, iptables 명령어가 "--random-fully" Option을 지원하면 KUBE-POSTROUTING Chain의 Masquerade Rule에 "--random-fully" Option을 적용한다. [Shell 1]은 "--random-fully" Option이 적용되어 있지 않는 KUBE-POSTROUTING Chain을 나타내고, [Shell 2]는 "--random-fully" Option이 적용되어 있는 Chain을 나타낸다. 또한 일부 CNI Plugin은 "--random-fully" Option이 설정되어있는 Masquerade Rule을 추가하여 본 Issue를 해결하고 있다. Flannel, Cilium CNI는 "--random-fully" Option을 지원하고 있다.

### 4. 참조

* [https://tech.xing.com/a-reason-for-unexplained-connection-timeouts-on-kubernetes-docker-abd041cf7e02](https://tech.xing.com/a-reason-for-unexplained-connection-timeouts-on-kubernetes-docker-abd041cf7e02)
* [https://github.com/kubernetes/kubernetes/pull/78547](https://github.com/kubernetes/kubernetes/pull/78547)
* [https://manpages.debian.org/unstable/iptables/iptables-extensions.8.en.html](https://manpages.debian.org/unstable/iptables/iptables-extensions.8.en.html)
* [https://patchwork.ozlabs.org/project/netfilter-devel/patch/1388963586-5049-7-git-send-email-pablo@netfilter.org/](https://patchwork.ozlabs.org/project/netfilter-devel/patch/1388963586-5049-7-git-send-email-pablo@netfilter.org/)
* [https://lwn.net/Articles/746343/](https://lwn.net/Articles/746343/)
* [https://github.com/coreos/flannel/commit/0d7b99460b81f98df43da183258edf56c4abf854](https://github.com/coreos/flannel/commit/0d7b99460b81f98df43da183258edf56c4abf854)
* [https://github.com/cilium/cilium/commit/4e39def13bca568a21087238877fbc60f8751567](https://github.com/cilium/cilium/commit/4e39def13bca568a21087238877fbc60f8751567)
