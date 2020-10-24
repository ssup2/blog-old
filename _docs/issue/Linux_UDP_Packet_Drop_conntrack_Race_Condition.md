---
title: Linux UDP Packet Drop with conntrack Race Condition
category: Issue
date: 2020-03-03T12:00:00Z
lastmod: 2020-03-03T12:00:00Z
comment: true
adsense: true
---

### 1. Issue

Linux conntrack의 Race Condition에 의해서 UDP Packet이 Drop되는 Issue가 존재한다. Kubernetes Cluster 내부에서는 본 Issue로 인해서 Service Discovery가 일시적으로 실패하는 문제가 발생할 수 있다.

### 2. Background

* Src 10.0.0.10:10, Dst 20.0.0.20:20
  * Original Table : Src 10.0.0.10:10, Dst 20.0.0.20:20
  * Reply Table : Src 20.0.0.20:20, Dst 10.0.0.10:10

Linux conntrack은 하나의 Connection 정보를 저장할때 Original Table, Reply Table 2가지 Table을 이용한다. 위의 예제는 Packet의 Src, Dst IP/Port에 따른 conntrack의 Original Table, Reply Table의 내용을 나타내고 있다. Original Table은 Packet의 Src, Dst IP/Port와 동일한 내용으로 채워진다. Reply Table의 내용은 Original Table에서 Src, Dst의 위치만 바뀐걸 알 수 있다.

* Src 10.0.0.10:10, Dst 20.0.0.20:20, DNAT 20.0.0.20->30.0.0.30:30
  * Original Table : Src 10.0.0.10:10, Dst 20.0.0.20:20
  * Reply Table : Src 30.0.0.30:30, Dst 10.0.0.10:10

위의 예제는 첫번째 예제와 동일하지만 Dst IP/Port로 DNAT Rule이 설정 되어있을때의 상태를 나타낸다. Original Table은 Packet의 Src, Dst IP/Port와 동일한 내용으로 채워진다. Reply Table의 Src IP/Port는 DNAT Rule의 영향으로 Original Table의 Dst IP/Port과 동일하지 않을걸 확인 할 수 있다. 이처럼 conntrack은 빠른 Reverse NAT를 수행하기 위해서 NAT Rule을 반영한 Connection 정보를 저장한다.

TCP의 Connection 정보는 Connection이 생성되는 시점에 conntrack에 저장된다. UDP의 경우 Connection-less Protocol이기 때문에 Connection이 존재하지 않지만, UDP Packet의 Reverse NAT등의 동작을 수행하기 위해서 conntrack은 UDP Packet의 Src,Dst IP/Port 정보를 바탕으로 Connection 정보를 생성하고 관리한다. conntrack에 UDP의 Connection 정보가 저장되는 시점은 실제 UDP Packet이 전송되는 시점이다.

conntrack은 Connection 정보를 추가 할 때 마다 Original Table과 Replay Table을 검사하여 추가할 Connection이 유효한지 확인한다. 추가할 Connection 정보가 Original Table과 중복되거나 Reply Table과 중복될 경우 conntrack은 해당 Connection 정보는 유효하지 않다고 간주하고 Table에 추가하지 않는다. 또한 conntrack은 추가할 Connection 정보를 갖고 있던 Packet을 Drop한다.

### 3. 원인, 해결 방안

UDP의 Connection 정보가 conntrack에 저장되는 시점은 실제 UDP Packet이 전송되는 시점이기 때문에 동일 Process안에 존재하는 다수의 Thread가 하나의 Socket을 통해서 (동일한 Port를 이용하여) 동시에 동일한 상대에게 UDP Packet을 전송하는 경우 conntrack에서는 Race Condition이 발생한다. 이 경우 전송된 모든 UDP Packet들은 상대방에게 전송되야 하지만, conntrack은 UDP Packet들의 동일한 Connection 정보를 발견하고 일부 UDP Packet을 Drop한다.

한가지 더 고려해야할 부분은 App에서 동일한 상대를 대상으로 다수의 UDP Packet을 동시에 전송하였더라도, App이 구동되는 Node에서 Kernel의 DNAT Rule에 의해서 실제로는 서로 다른 곳으로 Packet이 전송될 경우이다. DNAT Rule은 conntrack의 Reply Table에 저장될 Connection 정보에 영향을 주지만, conntrack의 Original Table에 저장될 Connection 정보에는 영향을 주지 않는다. 따라서 conntrack은 Original Table에서 충돌을 감시하고 일부 UDP Packet을 Drop한다.

DNAT를 수행하지 않을 경우에 발생하는 Issue는 다음의 2가지의 Kernel Patch로 인해서 해결되었다.

* [https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ed07d9a021df6da53456663a76999189badc432a](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ed07d9a021df6da53456663a76999189badc432a)
* [https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=4e35c1cb9460240e983a01745b5f29fe3a4d8e39](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=4e35c1cb9460240e983a01745b5f29fe3a4d8e39)

위의 Kernel Patch가 적용된 Version은 다음과 같다.

* Linux Stable 
  * 5.0+
* Linux Longterm
  * 4.9.163+, 4.14.106+, 4.19.29+, 5.4+
* Distro Linux Kernel
  * Ubuntu : 4.15.0-56+

UDP Packet이 DNAT 되어 서로 다른 상대에게 전송되는 경우에 발생하는 Issue는 아직 Kernel에서 해결하지 못한 상태이다. 따라서 App 내부에서 하나의 Socket을 통해서 동시에 UDP Packet을 전송하지 못하도록 제한하여 conntrack Race Condition을 방지하거나, 위의 Kernel Patch가 적용된 상태에서 UDP Packet이 DNAT 되어 전송되어도 서로 다른 상대가 아닌 동일한 상대한테 전송되도록 Kernel의 DNAT Rule을 설정하여 본 Issue를 우회해야 한다. 또는 iptables의 mangle Table을 활용하여 특정 IP, Port 대상으로 전송되는 Packet은 conntrack을 통해서 Connection 정보가 관리되지 않도록 설정하여 conntrack Race Condition을 방지할 수도 있다.

### 4. DNS Timeout Issue with Kubernetes
 
Kubernetes에서는 Domain을 이용하여 Service Discovery를 수행하는데, Kubernetes 환경에서는 본 Issue로 인해서 Domain Resolve 수행시 발생하는 UDP Packet이 Drop되어 Service Discovery가 일시적으로 실패하는 현상이 발생할 수 있다. Kubernetes에서는 일반적으로 Master Node에 DNS Server 역활을 수행하는 CoreDNS를 다수 띄우고 Service로 묶어서 Kubernetes Cluster 내부의 App들에게 제공한다. 따라서 App에서 Domain Resolve를 위해서 CoreDNS로 전송되는 UDP Packet은 App Pod이 있는 Node에서 **DNAT** 되어 Master의 CoreDNS로 분배된다.

또한 Domain Resolve를 수행시 App에서 가장 많이 이용하는 C Library인 glibc과 musl은, Kernel이 IPv4와 IPv6를 둘다 이용하도록 설정되어 있으면, A Record와 AAAA Record를 동일 Socket(동일 Port)을 이용하여 동시에 수행한다. 즉 Kubernetes에서 동작하는 glic 또는 musl 기반의 App이 전송하는 A Record Resolve Packet과 AAAA Record Resolve Packet은 동시에 동일한 Src IP/Port를 갖고 DNAT를 통해서 CoreDNS로 전송 되지만, 본 이슈로 인해서 두 Resolve Packet 중에서 하나의 Packet은 conntrack에 의해서 Drop이 발생한다.

위에서 언급한 Patch가 적용된 Kernel Version을 이용해도 DNAT 수행시 발생하는 Issue는 해결하지 못하기 때문에 우회 방법을 적용하여 문제를 해결해야 한다. 가장 직관적인 접근법은 동시에 수행되는 Domain Resolve를 막아 conntrack Race Condition을 방지하는 방법이다. glibc는 /etc/resolv.conf 파일에 “single-request” 또는 “single-request-reopen” Option을 주어 동시에 A Record와 AAAA Record를 동시에 Resolve하지 못하게 제한할 수 있다. 하지만 musl은 이러한 Opiton을 지원하지 않는다. musl은 많은 곳에서 이용중인 Alpine Image에서 이용되는 C Library이다.

또 하나의 우회 방법은 하나의 App에서 전송되는 Domain Resolve Packet은 무조건 동일한 CoreDNS로 DNAT 되도록 설정하는 방법이 있다. Packet의 Header Hashing을 기반으로 하는 Load Balancing을 수행하는 알고리즘을 이용하면 된다. Kubernetes Cluster에서 Service Loadbalancing을 IPVS를 통해서 수행하고 있다면 IPVS의 Load Balancing 알고리즘을 dh(Destination Hashing Scheduling), sh(Source Hashing Scheduling)을 이용하면 된다. DNAT 수행없이 바로 CoreDNS로 Domain Resolve Packet을 전송하여 본 이슈를 회피하는 방법도 존재한다. 모든 Node마다 CoreDNS를 구동한 다음 각각의 App이 App이 구동되는 Node의 CoreDNS를 이용하도록 설정하면, App의 Domain Resolve Packet은 DNAT 수행없이 CoreDNS에게 전달된다.

마지막 우회 방법은 conntrack을 이용하지 않는 방법이다. Domain Resolve Packet은 53번 Port를 이용한다. iptables의 mangle Table을 활용하여 53번 Port를 갖는 Packet은 conntrack에 의해서 Connection 정보가 관리되지 않도록 설정할 수 있다. Cilium CNI는 Host Network Namespace를 이용하지 않는 Pod과 Service 사이의 Connection 관리를 conntrack을 이용하지 않고 BPF와 BPF Map을 이용한다. Host Network Namespace를 이용하는 Pod 또는 Host Processes와 Service 사이의 Connection 관리는 cgroup eBPF를 지원하는 Cilium CNI Version (1.6.0+)에서는 conntrack을 이용하지 않고 BPF와 BPF Map을 이용한다. 따라서 cgroup eBPF를 지원하는 Cilium CNI Version과 Kernel Version을 이용한다면 본 Issue를 우회할 수 있다.

### 5. 참조

* [https://www.weave.works/blog/racy-conntrack-and-dns-lookup-timeouts](https://www.weave.works/blog/racy-conntrack-and-dns-lookup-timeouts)
* [https://github.com/kubernetes/kubernetes/issues/56903](https://github.com/kubernetes/kubernetes/issues/56903)
* [https://github.com/weaveworks/weave/issues/3287](https://github.com/weaveworks/weave/issues/3287)
* [http://patchwork.ozlabs.org/patch/937963](http://patchwork.ozlabs.org/patch/937963)
* [http://patchwork.ozlabs.org/patch/1032812](http://patchwork.ozlabs.org/patch/1032812)
* [https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns](https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns)
* [https://github.com/kubernetes/kubernetes/issues/56903#issuecomment-466368174](https://github.com/kubernetes/kubernetes/issues/56903#issuecomment-466368174)
* [https://blog.quentin-machu.fr/2018/06/24/5-15s-dns-lookups-on-kubernetes/](https://blog.quentin-machu.fr/2018/06/24/5-15s-dns-lookups-on-kubernetes/)
* [https://wiki.musl-libc.org/functional-differences-from-glibc.html](https://wiki.musl-libc.org/functional-differences-from-glibc.html)
* [https://launchpad.net/ubuntu/+source/linux/4.15.0-58.64](https://launchpad.net/ubuntu/+source/linux/4.15.0-58.64)