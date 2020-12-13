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

Kubernetes의 NodeLocal DNSCache는 모든 Kubernetes Cluster의 Node에 DNS Cache Server를 구성하는 기법이다. NodeLocal DNSCache를 통해서 Pod안의 App에서 전송하는 Domain Resolve 요청을 더 빠르게 처리할 수 있으며, Linux conntrack Race Condition에 의해서 발생하는 Domain Resolve 요청 Packet이 Drop되는 현상도 회피할 수 있다. Kubernetes Cluster가 이용하는 kube-proxy의 Mode에 따라서 NodeLocal DNSCache 기법의 구현 방법이 달라지게 된다.

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
<figcaption class="caption">[Shell 1] nodelocaldns Dummy Interface with iptables kube-proxy Mode</figcaption>
</figure>

NodeLocal DNSCache Pod안에서는 Cache Mode로 동작하는 CoreDNS가 존재한다. Cache Mode로 동작하는 CoreDNS는 Host Network Namespace에서 동작하며 CoreDNS Service의 ClusterIP인 10.96.0.10과 Local Address IP인중 하나인 169.254.25.10을 IP 주소로 갖는 nodelocaldns Dummy Interface를 생성한다. 그리고 생성한 nodelocaldns Dummy Interface를 통해서 10.96.0.10와 169.254.25.10 IP 주소로 Listen 상태로 대기하며 Domain Resolve 요청을 대기한다. [Shell 1]은 iptables kube-proxy Mode를 이용하는 Kubernetes Cluster에서 nodelocaldns Dummy Interface의 정보를 확인하는 과정을 나타내고 있다.

Pod안의 App은 10.96.0.10 또는 169.254.25.10 IP 주소를 통해서 자신이 동작하고 있는 Node의 NodeLocal DNSCache에게만 Domain Resolve 요청을 전송한다. 따라서 Cluster CoreDNS로 전송 되어야하는 Domain Resolve 요청이 각 NodeLocal DNSCache에게 자연스럽게 분산되는 효과를 얻을 수 있다. 또한 Pod안의 App에서 전송한 Domain Resolve 요청이 NodeLocal DNSCache에게 까지만 전달되면, 대부분의 경우 NodeLocal DNSCache 내부에서 처리되기 때문에 NodeLocal DNSCache 요청의 Network Hop도 감소된다. 이러한 이유들 때문에 NodeLocal DNSCache를 통해서 Domain Resolve 처리 성능을 높일수 있다.

하지만 NodeLocal DNSCache가 정지하면 NodeLocal DNSCache가 정지한 Node에서 동작하는 모든 Pod의 App에서 Domain Resolve를 수행할 수 없다는 큰 단점을 갖고 있다. NodeLocal DNSCache의 구조상 하나의 Node에 여러개를 동시에 구동시킬수 없기 때문에, 각 Node에 동작중인 NodeLocal DNSCache가 정지하지 않도록 신경써야한다. NodeLocal DNSCache Pod는 kubelet에 의해서 강제로 제거되지 않도록 하기 위해서 system-node-critical priorityClassName을 갖고 동작한다.

NodeLocal DNSCache Update를 위해서 단순히 NodeLocal DNSCache DaemonSet의 Image를 교체한다면, NodeLocal DNSCache의 동작이 일시적으로 정지되는 것을 막을수는 없기 때문에 App의 일시적 장애로 이어질 수 있다. 이러한 장애를 막기위한 우회 방법으로 먼져 NodeLocal DNSCache DaemonSet을 처음으로 구동할때 updateStrategy를 OnDelete으로 설정하여 Kubernetes Cluster 사용자가 하나씩 NodeLocal DNSCache Pod를 삭제하면서 Update를 하도록 설정한다. 이후에 Update를 진행할 Node를 Cordon하여 모든 Pod를 다른 Node로 옮겨놓고 NodeLocal DNSCache Pod를 삭제하여 Update를 진행한다. Update가 완료된 이후에는 Uncordon하여 Pod이 Scheduling 될수 있도록 복구한다. 모든 Node에 대해서 Cordon, Update, Uncordon을 반복해야 한다.

{% highlight console %}
# iptables -t raw -nvL
Chain PREROUTING (policy ACCEPT 5262 packets, 1194K bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 CT         udp  --  *      *       0.0.0.0/0            10.96.0.10           udp dpt:53 NOTRACK
    0     0 CT         tcp  --  *      *       0.0.0.0/0            10.96.0.10           tcp dpt:53 NOTRACK
    0     0 CT         udp  --  *      *       0.0.0.0/0            169.254.25.10        udp dpt:53 NOTRACK
    0     0 CT         tcp  --  *      *       0.0.0.0/0            169.254.25.10        tcp dpt:53 NOTRACK
...
Chain OUTPUT (policy ACCEPT 5918 packets, 537K bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 CT         tcp  --  *      *       10.96.0.10           0.0.0.0/0            tcp spt:8080 NOTRACK
    0     0 CT         tcp  --  *      *       0.0.0.0/0            10.96.0.10           tcp dpt:8080 NOTRACK
    0     0 CT         udp  --  *      *       0.0.0.0/0            10.96.0.10           udp dpt:53 NOTRACK
    0     0 CT         tcp  --  *      *       0.0.0.0/0            10.96.0.10           tcp dpt:53 NOTRACK
    0     0 CT         udp  --  *      *       10.96.0.10           0.0.0.0/0            udp spt:53 NOTRACK
    0     0 CT         tcp  --  *      *       10.96.0.10           0.0.0.0/0            tcp spt:53 NOTRACK
    0     0 CT         tcp  --  *      *       169.254.25.10        0.0.0.0/0            tcp spt:8080 NOTRACK
    0     0 CT         tcp  --  *      *       0.0.0.0/0            169.254.25.10        tcp dpt:8080 NOTRACK
    0     0 CT         udp  --  *      *       0.0.0.0/0            169.254.25.10        udp dpt:53 NOTRACK
    0     0 CT         tcp  --  *      *       0.0.0.0/0            169.254.25.10        tcp dpt:53 NOTRACK
    0     0 CT         udp  --  *      *       169.254.25.10        0.0.0.0/0            udp spt:53 NOTRACK
    0     0 CT         tcp  --  *      *       169.254.25.10        0.0.0.0/0            tcp spt:53 NOTRACK
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] iptables raw table with iptables kube-proxy Mode</figcaption>
</figure>

Pod에서 CoreDNS Service의 ClusterIP인 10.96.0.10 IP 주소로 Domain Resolve 요청을 전송하여도 요청이 Cluster CoreDNS Pod이 아닌, NodeLocal DNSCache에게 전송되는 이유는 iptables raw Table을 확인하면 알 수 있다. [Shell 2]는 iptables kube-proxy Mode를 이용하는 Kubernetes Cluster에서 iptables의 raw Table을 확인하는 과정을 나타내고 있다. Packet의 Src IP 또는 Dst IP에 10.96.0.10 IP 주소가 있는 Packet의 경우에는 NOTRACK Rule이 적용되어 있는걸 확인할 수 있다.

NOTRACK Rule은 해당 Packet이 Linux conntrack에 의해서 Connection이 관리되지 않도록 만드는 Rule이다. Connection이 관리되지 않는 Packet은 iptables의 nat Table에 의해서 NAT가 수행되지 않는다. 따라서 Pod에서 10.96.0.10 IP 주소로 Domain Resolve 요청을 전송하여도 Cluster CoreDNS Pod이 아닌 NodeLocal DNSCache에게 전송된다. NOTRACK Rule을 통해서 또한가지 얻을수 있는 이점은 Linux conntrack의 Connection 관리 대상에서 Domain Resolve 요청 Packet이 제외되기 때문에, Linux conntrack Race Condition에 의해서 발생하는 Domain Resolve 요청 Packet이 Drop되는 현상도 회피할 수 있다. 이러한 이유 때문에 169.254.25.10 IP 주소에 대해서도 NOTRACK Rule이 적용되어 있다.

iptables kube-proxy Mode일때는 Pod안의 App은 NodeLocal DNSCache 적용 유무에 관계없이 동일하게 10.96.0.10 IP 주소로 Domain Resolve 요청을 전송하면 된다. 또한 NodeLocal DNSCache는 시작하면서 nodelocaldns dummy Interface 생성 및 NOTRACK Rule을 설정하고, 종료하면서 odelocaldns dummy Interface 삭제 및 NOTRACK Rule을 제거한다. 따라서 App Pod의 재시작이 필요없이 NodeLocal DNSCache 이용유무를 자유롭게 변경할 수 있다.

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
<figcaption class="caption">[Shell 3] nodelocaldns Dummy Interface with IPVS kube-proxy Mode</figcaption>
</figure>

{% highlight console %}
# iptables -t raw -nvL
Chain PREROUTING (policy ACCEPT 18166 packets, 75M bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 CT         udp  --  *      *       0.0.0.0/0            169.254.25.10        udp dpt:53 NOTRACK
    0     0 CT         tcp  --  *      *       0.0.0.0/0            169.254.25.10        tcp dpt:53 NOTRACK
...
Chain OUTPUT (policy ACCEPT 9161 packets, 1478K bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 CT         tcp  --  *      *       169.254.25.10        0.0.0.0/0            tcp spt:8080 NOTRACK
    0     0 CT         tcp  --  *      *       0.0.0.0/0            169.254.25.10        tcp dpt:8080 NOTRACK
    0     0 CT         udp  --  *      *       0.0.0.0/0            169.254.25.10        udp dpt:53 NOTRACK
    0     0 CT         tcp  --  *      *       0.0.0.0/0            169.254.25.10        tcp dpt:53 NOTRACK
    0     0 CT         udp  --  *      *       169.254.25.10        0.0.0.0/0            udp spt:53 NOTRACK
    0     0 CT         tcp  --  *      *       169.254.25.10        0.0.0.0/0            tcp spt:53 NOTRACK
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] iptables raw table with IPVS kube-proxy Mode</figcaption>
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
