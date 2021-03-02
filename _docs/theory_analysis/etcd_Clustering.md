---
title: etcd Clustering
category: Theory, Analysis
date: 2021-02-01T12:00:00Z
lastmod: 2021-02-01T12:00:00Z
comment: true
adsense: true
---

etcd의 Clustering 기법을 분석한다.

### 1. etcd Clustering

![[그림 1] etcd Cluster]({{site.baseurl}}/images/theory_analysis/etcd_Clustering/etcd_Cluster_Architecture.PNG){: width="600px"}

etcd는 Clustering을 통해서 HA(High Availability)를 제공할 수 있다. [그림 1]은 etcd Cluster를 나타내고 있다.

#### 1.1. Server Clustering

Server는 Raft Algorithm에 따라서 Leader와 Follower로 동작한다. Raft Algorithm에 따라서 Client의 Request는 반드시 Leader Server에게로 전달되어야 한다. Follower 역할을 수행하는 Server는 Client의 요청을 받을 경우 Leader Server에게 전달하는 역할을 수행한다.

Server들이 Clustering을 수행하기 위해서는 각 Server는 Cluster에 참여하는 모든 Server의 IP/Port를 알고 있어야한다. Cluster에 참여하는 모든 Server의 IP/Port 정보는 etcd Server의 Parameter를 통해서 Static하게 설정될 수도 있고, Discovery 기능을 활용하여 각 etcd Server가 Cluster에 참여하는 모든 Server의 IP/Port 정보를 스스로 얻어올 수 있도록 할 수 있다. Discovery 기능은 etcd 자체적으로 제공하는 기법과 DNS를 활용한 기법 2가지를 제공하고 있다.

Server들 사이의 통신은 TLS를 이용하여 암호화 할 수 있다.

#### 1.2. Client Load Balancer

#### 1.3. Server 추가/제거

#### 1.4. Learner

### 2. 참조

* [https://etcd.io/docs/v3.4.0/faq/](https://etcd.io/docs/v3.4.0/faq/)
* [https://etcd.io/docs/v3.4.0/op-guide/clustering/](https://etcd.io/docs/v3.4.0/op-guide/clustering/)
* [https://etcd.io/docs/v3.4.0/learning/design-client/](https://etcd.io/docs/v3.4.0/learning/8 design-client/)
* [https://etcd.io/docs/v3.4.0/learning/design-learner/](https://etcd.io/docs/v3.4.0/learning/design-learner/)
* [https://etcd.io/docs/v3.4.0/op-guide/runtime-configuration/](https://etcd.io/docs/v3.4.0/op-guide/runtime-configuration/)
* [https://github.com/etcd-io/etcd/blob/master/Documentation/faq.md](https://github.com/etcd-io/etcd/blob/master/Documentation/faq.md)