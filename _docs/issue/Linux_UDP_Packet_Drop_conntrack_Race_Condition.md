---
title: Linux UDP Packet Drop with conntrack Race Condition
category: Issue
date: 2020-03-03T12:00:00Z
lastmod: 2020-03-03T12:00:00Z
comment: true
adsense: true
---

### 1. Issue

Linux conntrack의 Race Condition에 의해서 UDP Packet이 Drop되는 Issue가 존재한다. Kubernetes에서는 Service Discovery를 Domain을 통해서 수행하는데, Domain Resolve 과정에서 발생하는 UDP Packet이 해당 Issue로 인해서 Drop되어 Domain Resolve가 일시적으로 실패할 수 있다.

### 2. Background

* Src 10.0.0.10:10, Dst 20.0.0.20:20
  * Original Table : Src 10.0.0.10:10, Dst 20.0.0.20:20
  * Reply Table : Src 20.0.0.20:20, Dst 10.0.0.10:10

Linux conntrack은 하나의 Connection 정보를 저장할때 Original Table, Reply Table 2가지 Table을 이용한다. 위의 예제는 Packet의 Src IP/Port에 따른 conntrack의 Original Table, Reply Table의 내용을 나타내고 있다. Original Table은 Packet의 Src, Dst IP/Port와 동일한 내용으로 채워진다. Reply Table의 내용은 Original Table에서 Src, Dst의 위치만 바뀐걸 알 수 있다.

* Src 10.0.0.10:10, Dst 20.0.0.20:20, DNAT 20.0.0.20>30.0.0.30:30
  * Original Table : Src 10.0.0.10:10, Dst 20.0.0.20:20
  * Reply Table : Src 30.0.0.30:30, Dst 10.0.0.10:10

위의 예제는 첫번째 예제와 동일하지만 Dst IP/Port로 DNAT Rule이 걸려있을때의 상태를 나타낸다. Original Table은 Packet의 Src, Dst IP/Port와 동일한 내용으로 채워진다. Reply Table의 Src IP/Port는 DNAT Rule에 따라서 Original Table의 Dst IP/Port가 아닌걸 확인 할 수 있다. 이처럼 conntrack은 빠른 Reverse NAT를 수행하기 위해서 NAT Rule을 반영한 Connection 정보를 저장한다.

TCP의 Connection 정보는 Connection이 생성되는 시점에 conntrack에 저장된다. UDP의 경우 Connection-less Protocol이기 때문에 Connection이 존재하지 않지만, UDP Packet의 Reverse NAT등의 동작을 수행하기 위해서 conntrack은 UDP도 Connection이 있는것 처럼 관리한다. Conntrack에 UDP의 Connection 정보가 저장되는 시점은 실제 UDP Packet이 전송되는 시점이다.

conntrack은 Connection 정보를 추가 할 때 마다 Original Table과 Replay Table을 검사하여 추가할 Connection이 유효한지 확인한다. 추가할 Connection 정보가 Original Table과 중복되거나 Reply Table과 중복될 경우 해당 Connection은 유효하지 않다고 간주하고 Table에 추가하지 않는다. 또한 추가할 Connection 정보를 갖고 있던 Packet은 Drop된다.

### 3. 원인, 해결 방안

#### 3.1. Kubernetes

### 4. 참조

* [https://www.weave.works/blog/racy-conntrack-and-dns-lookup-timeouts](https://www.weave.works/blog/racy-conntrack-and-dns-lookup-timeouts)
* [https://github.com/kubernetes/kubernetes/issues/56903](https://github.com/kubernetes/kubernetes/issues/56903)
* [https://github.com/weaveworks/weave/issues/3287](https://github.com/weaveworks/weave/issues/3287)
* [http://patchwork.ozlabs.org/patch/937963](http://patchwork.ozlabs.org/patch/937963)
* [http://patchwork.ozlabs.org/patch/1032812](http://patchwork.ozlabs.org/patch/1032812)
* [https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns](https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns)