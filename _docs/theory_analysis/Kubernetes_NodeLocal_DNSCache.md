---
title: Kubernetes NodeLocal DNSCache
category: Theory, Analysis
date: 2020-12-14T12:00:00Z
lastmod: 2020-12-14T12:00:00Z
comment: true
adsense: true
---

Kubernetes의 NodeLocal DNSCache룰 분석한다.

### 1. Kubernetes NodeLocal DNSCache

Kubernetes의 NodeLocal DNSCache는 모든 Kubernetes Cluster의 Node에 DNS Cache Server를 구성하는 기법이다. NodeLocal DNSCache를 통해서 Pod안의 App에서 전송하는 Domain Resolve 요청을 더 빠르게 처리할 수 있으며, Linux Conntrack Race Condition에 의해서 발생하는 Domain Resolve 요청 Packet이 Drop되는 현상도 회피할 수 있다. Kubernetes Cluster가 이용하는 kube-proxy의 Mode에 따라서 NodeLocal DNSCache 기법의 구현 방법이 달라지게 된다.

#### 1.1. with iptables kube-proxy Mode

![[그림 1] Kubernetes NodeLocal DNSCache Architecture with iptables kube-proxy Mode]({{site.baseurl}}/images/theory_analysis/Kubernetes_NodeLocal_DNSCache/Kubernetes_NodeLocal_DNSCache_iptables.PNG){: width="700px"}

[그림 1]은 Kubernetes Cluster가 iptables kube-proxy Mode를 이용할 때, NodeLocal DNSCache의 Architecture를 나타내고 있다. 일반 Kubernetes Cluster처럼 각 Cluster를 위해 존재하는 CoreDNS Pod과 이 CoreDNS Pod을 묶는 CoreDNS Service가 존재한다. CoreDNS Service의 ClusterIP는 10.96.0.10을 갖고 있다. NodeLocal DNSCache Pod은 DaemonSet을 통해서 모든 Master Node, Worker Node에 위치한다.

{% highlight console %}
# ip a
...
16: nodelocaldns: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default
    link/ether be:29:ca:e7:39:4b brd ff:ff:ff:ff:ff:ff
    inet 169.254.25.10/32 brd 169.254.25.10 scope global nodelocaldns
       valid_lft forever preferred_lft forever
    inet 10.96.0.10/32 brd 10.96.0.10 scope global nodelocaldns
       valid_lft forever preferred_lft forever
...

# ip -details link show
...
16: nodelocaldns: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default
    link/ether be:29:ca:e7:39:4b brd ff:ff:ff:ff:ff:ff promiscuity 0
    dummy addrgenmode eui64 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 6553
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] nodelocaldns Dummy Interface</figcaption>
</figure>

NodeLocal DNSCache Pod안에서는 Cache Mode로 동작하는 CoreDNS가 존재한다. Cache Mode로 동작하는 CoreDNS는 Host Network Namespace에서 동작하며 CoreDNS Service의 ClusterIP인 10.96.0.10과 Local Address IP인중 하나인 169.254.25.10을 IP 주소로 갖는 nodelocaldns Dummy Interface를 생성한다. 그리고 생성한 nodelocaldns Dummy Interface를 통해서 10.96.0.10와 169.254.25.10 IP 주소로 Listen 상태로 대기하며 Domain Resolve 요청을 대기한다. 따라서 Pod은 10.96.0.10 또는 169.254.25.10 IP 주소를 통해서 Domain Resolve 요청을 전송할 수 있다.

#### 1.1. with IPVS kube-proxy Mode

![[그림 2] Kubernetes NodeLocal DNSCache Architecture with iptables kube-proxy Mode]({{site.baseurl}}/images/theory_analysis/Kubernetes_NodeLocal_DNSCache/Kubernetes_NodeLocal_DNSCache_IPVS.PNG){: width="700px"}

{% highlight console %}
# ip a
...
16: nodelocaldns: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default
    link/ether be:29:ca:e7:39:4b brd ff:ff:ff:ff:ff:ff
    inet 169.254.25.10/32 brd 169.254.25.10 scope global nodelocaldns
       valid_lft forever preferred_lft forever

...

# ip -details link show
...
16: nodelocaldns: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default
    link/ether be:29:ca:e7:39:4b brd ff:ff:ff:ff:ff:ff promiscuity 0
    dummy addrgenmode eui64 numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 6553
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] nodelocaldns Dummy Interface</figcaption>
</figure>

### 2. 참조

* [https://povilasv.me/kubernetes-node-local-dns-cache/](https://povilasv.me/kubernetes-node-local-dns-cache/)
* [https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/](https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/)
* [https://github.com/kubernetes/enhancements/blob/master/keps/sig-network/20190424-NodeLocalDNS-beta-proposal.md](https://github.com/kubernetes/enhancements/blob/master/keps/sig-network/20190424-NodeLocalDNS-beta-proposal.md)
* [https://github.com/kubernetes/enhancements/blob/master/keps/sig-network/0030-nodelocal-dns-cache.md](https://github.com/kubernetes/enhancements/blob/master/keps/sig-network/0030-nodelocal-dns-cache.md)
* [https://github.com/kubernetes/kubernetes/issues/45363#issuecomment-443019910](https://github.com/kubernetes/kubernetes/issues/45363#issuecomment-443019910)
* [https://cloud.google.com/kubernetes-engine/docs/how-to/nodelocal-dns-cache](https://cloud.google.com/kubernetes-engine/docs/how-to/nodelocal-dns-cache)
* [https://github.com/kubernetes-sigs/kubespray/blob/master/docs/dns-stack.md](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/dns-stack.md)
* [https://github.com/colopl/k8s-local-dns](https://github.com/colopl/k8s-local-dns)
