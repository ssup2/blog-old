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

TCP의 Connection 정보는 Connection이 생성되는 시점에 conntrack에 저장된다. UDP의 경우 Connection-less Protocol이기 때문에 Connection이 존재하지 않지만, UDP Packet의 Reverse NAT등의 동작을 수행하기 위해서 conntrack은 UDP Packet의 Src,Dst IP/Port 정보를 바탕으로 Connection 정보를 생성하고 관리한다. Conntrack에 UDP의 Connection 정보가 저장되는 시점은 실제 UDP Packet이 전송되는 시점이다.

conntrack은 Connection 정보를 추가 할 때 마다 Original Table과 Replay Table을 검사하여 추가할 Connection이 유효한지 확인한다. 추가할 Connection 정보가 Original Table과 중복되거나 Reply Table과 중복될 경우 conntrack은 해당 Connection 정보는 유효하지 않다고 간주하고 Table에 추가하지 않는다. 또한 conntrack은 추가할 Connection 정보를 갖고 있던 Packet을 Drop한다.

### 3. 원인, 해결 방안

UDP의 Connection 정보가 conntrack에 저장되는 시점은 실제 UDP Packet이 전송되는 시점이기 때문에 동일 Process안에 존재하는 다수의 Thread가 하나의 Socket을 통해서 (동일한 Port를 이용하여) 동시에 동일한 상대에게 UDP Packet을 전송하는 경우 conntrack에서는 Race Condition이 발생한다. 이 경우 전송된 모든 UDP Packet들은 상대방에게 전송되야 하지만, Conntrack은  UDP Packet들의 동일한 Connection 정보를 발견하고 일부 UDP Packet을 Drop한다.

한가지 더 고려해야할 부분은 App에서 동일한 상대를 대상으로 다수의 UDP Packet을 동시에 전송하였더라도 Kernel의 DNAT Rule에 의해서 실제로는 서로 다른 곳으로 Packet이 전송될 경우이다. DNAT Rule은 conntrack의 Reply Table에 저장될 Connection 정보에 영향을 주지만, conntrack의 Original Table에 저장될 Connection 정보에는 영향을 주지 않는다. 따라서 conntrack은 Original Table에서 충돌을 감시하고 일부 UDP Packet을 Drop한다.

DNAT를 수행하지 않을 경우에 발생하는 Issue는 다음의 2가지의 Kernel Patch로 인해서 해결되었다.

* [https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ed07d9a021df6da53456663a76999189badc432a](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ed07d9a021df6da53456663a76999189badc432a)
* [https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=4e35c1cb9460240e983a01745b5f29fe3a4d8e39](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=4e35c1cb9460240e983a01745b5f29fe3a4d8e39)

UDP Packet이 DNAT 되어 서로 다른 상대에게 전송되는 경우에 발생하는 Issue는 아직 Kernel에서 해결하지 못한 상태이다. 따라서 App 내부에서 하나의 Socket을 통해서 (동일한 Port를 이용하여) 동시에 UDP Packet을 전송하지 못하도록 제한하여 conntrack Race Condition을 방지하거나, 위의 Kernel Patch가 적용된 상태에서 UDP Packet이 DNAT 되어 전송되어도 서로 다른 상대가 아닌 동일한 상대한테 전송되도록 Kernel의 DNAT Rule을 설정하여 해당 이슈를 우회해야 한다.

### 4. DNS Timeout Issue with Kubernetes
 
Kubernetes에서는 일반적으로 Master Node에 DNS Server 역활을 수행하는 CoreDNS를 다수 띄우고 Service로 묶어서 Kubernetes Cluster 내부의 App들에게 제공한다.

### 5. 참조

* [https://www.weave.works/blog/racy-conntrack-and-dns-lookup-timeouts](https://www.weave.works/blog/racy-conntrack-and-dns-lookup-timeouts)
* [https://github.com/kubernetes/kubernetes/issues/56903](https://github.com/kubernetes/kubernetes/issues/56903)
* [https://github.com/weaveworks/weave/issues/3287](https://github.com/weaveworks/weave/issues/3287)
* [http://patchwork.ozlabs.org/patch/937963](http://patchwork.ozlabs.org/patch/937963)
* [http://patchwork.ozlabs.org/patch/1032812](http://patchwork.ozlabs.org/patch/1032812)
* [https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns](https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns)
* [https://github.com/kubernetes/kubernetes/issues/56903#issuecomment-466368174](https://github.com/kubernetes/kubernetes/issues/56903#issuecomment-466368174)