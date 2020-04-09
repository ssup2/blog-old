---
title: etcd
category: Theory, Analysis
date: 2019-04-09T12:00:00Z
lastmod: 2019-04-09T12:00:00Z
comment: true
adsense: true
---

etcd를 분석한다.

### 1. etcd

![[그림 1] etcd Architecture]({{site.baseurl}}/images/theory_analysis/etcd/etcd_Architecture.PNG){: width="600px"}

etcd는 High Availability를 제공하는 분산 Key-value 저장소이다. etcd는 **Raft Algorithm**을 이용하여 Consensus(동의)를 유지한다. [그림 1]은 etcd의 Architure를 나타내고 있다. Server는 Raft Algorithm에 따라서 **Leader**와 **Follower**로 역활이 나누어 진다. Leader는 Client의 요청에 따라서 Server Cluster에 저장되는 Data를 관리하는 역활을 수행하며, Data의 변경 내역은 AppendEntries를 통해서 Follower에게 전달된다. Follower는 Leader로 부터 전달받은 AppendEntries를 통해서 자신이 저장하고 있는 Data를 Leader가 저장하고 있는 Data와 일치시킨다.

모든 Client의 요청은 Leader로 전달되며 Leader에서 처리된다. Client의 요청이 Follower에게 전달되면 Follower는 전달 받은 Client의 요청을 다시 Leader로 전달하고, Leader로 부터 요청에 대한 응답을 받아 Client에게 전달하는 Leader의 Proxy 역활을 수행한다. 일반적으로 Client는 각 Server들의 Endpoint(IP,Port) 정보를 갖고 있으며, Client 내부의 Load Balancer는 Server들의 Endpoint 정보를 바탕으로 Client가 접속하고 있는 Server의 장애 발생시 다른 Server로 연결하는 역활을 수행한다. 하지만 Client는 Client 내부의 Load Balancer를 이용할 필요 없으며, Server들을 묶어주는 외부의 Load Balancer를 이용해도 관계없다.

#### 1.1. Quorum

![[표 1] etcd Quorum]({{site.baseurl}}/images/theory_analysis/etcd/etcd_Quorum.PNG){: width="450px"}

Quorum은 Consensus를 유지하기 위한 최소한의 **동의표**를 의미한다. [표 1]은 Server의 개수에 따른 Quorum을 나타내고 있다. Quorum은 Server의 개수를 절반으로 나눈 다음 하나를 더한 값이란걸 알 수 있다. 즉 찬성하는 Server의 개수가 반대하는 Server의 개수보다 크다는걸 보장하는 최소값이 Quorum이라고 할 수 있다. Quorum은 Server Cluster에서 동작해야 하는 최소한의 Server의 개수의 기준이 된다. 만약 Server 5개로 Cluster가 구성되어 있을 경우 동작하는 Server는 최소 3대 이상이 필요하다. 동작하는 Server의 개수가 Quorum보다 미만인 경우 Server Cluster는 Data Read/Write를 수행할 수 없게 된다.

Quorum은 Leader가 Data를 변경할때 Follower들에게 얻어야 하는 동의표 개수의 기준이 되기도 한다. Leader는 Client의 요청으로 인해서 Data를 변경할 경우 변경 내역을 AppendEntries를 통해서 모든 Follower에게 전달한 다음 Follower로부터 동의표를 기다린다. 이때 Leader는 모든 Follower로부터 동의표를 얻어야 Data 변경 내역을 실제로 반영하는게 아니라, 자신의 동의표 포함 Quorum의 개수만큼 동의표를 얻는 순간 Data 변경 내역을 실제로 반영한다. 예를 들어 Server 5개로 Cluster가 구성되어 있을 경우, Leader는 Follower로 부터 2개의 동의표를 얻는 순간 자신의 동의표를 포함하여 Quorum인 3개의 동의표가 되기 때문에 Data 변경 내역을 실제로 반영하게 된다.

#### 1.2. Leader Election

etcd는 Leader에 장애 발생시 Leader Election 과정을 통해서 Follower들 중에서 하나의 Follower를 Leader로 승격하여 Server Cluster를 유지한다. Leader가 Follower에게 전송하는 AppendEntries는 Leader의 Heartbeat 역활도 수행한다. Follower는 Leader로 부터 AppendEntries를 일정시간 동안 받지 못하면 Leader에 장애가 발생한 것으로 판단하고 Leader Election을 준비한다.

Follower는 바로 Leader Election을 진행하지 않고 **Candidate**가 된 다음 Leader Election을 진행한다. Follower가 Candiditate가 되기 위해서는 Random한 시간만큼 대기해야 한다. 따라서 각 Follower들이 Leader의 장애를 거의 같은 시간대에 발견 하였더라도 Random한 시간만큼 대기한 후에 Leader Election을 진행하기 때문에 각 Follower에서 동시에 Leader Election이 수행되지는 않는다.

Candidate의 동의표를 포함하여 다른 Follower들에게 동의표를 요청한다. 만약 특정 시간안에 Quorum만큼 Follower로 부터 동의표를 얻는게 되면 Candidate는 Leader가 된다. 반대로 Quorum만큼 Follower부터 동의표를 얻지 못한다면 Candidate는 Leader가 되지 못하고 다시 Leader Election을 수행한다. 다수의 Candidate로부터 다수의 동의표 요청을 받은 Follower는 가장 먼져 동의표를 요청한 Candidate에게만 동의표를 전송한다. 따라서 다수의 Candidate가 동시에 Leader가 되기 위해서 Leader Election을 수행 하여도 복수의 Leader가 선출되지는 않는다.

### 2. 참조

* [https://github.com/etcd-io/etcd/blob/master/Documentation/faq.md](https://github.com/etcd-io/etcd/blob/master/Documentation/faq.md)
* [https://etcd.io/docs/v3.4.0/learning/design-client/](https://etcd.io/docs/v3.4.0/learning/8 design-client/)
* [https://etcd.io/docs/v3.4.0/learning/design-learner/](https://etcd.io/docs/v3.4.0/learning/design-learner/)
* Raft Algorithm : [https://web.stanford.edu/~ouster/cgi-bin/cs190-winter20/lecture.php?topic=raft](https://web.stanford.edu/~ouster/cgi-bin/cs190-winter20/lecture.php?topic=raft)
* Raft Algorithm : [http://i5on9i.blogspot.com/2016/09/raft.html](http://i5on9i.blogspot.com/2016/09/raft.html)
* Raft Algorithm : [https://swalloow.github.io/raft-consensus](https://swalloow.github.io/raft-consensus)
* Raft Algorithm : [https://suckzoo.github.io/tech/2018/01/03/raft-1.html](https://suckzoo.github.io/tech/2018/01/03/raft-1.html)