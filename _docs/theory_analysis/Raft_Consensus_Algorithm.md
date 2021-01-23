---
title: Raft Consensus Algorithm
category: Theory, Analysis
date: 2021-01-20T12:00:00Z
lastmod: 2021-01-20T12:00:00Z
comment: true
adsense: true
---

Raft Consensus Algorithm을 분석한다.

### 1. Raft Consensus Algorithm

![[그림 1] Raft Architecture]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Raft_Architecture.PNG){: width="750px"}

Raft는 다수의 Server 사이의 **Consensus(합의)**를 맞추는 역활을 수행하는 Algorithm이다. 여기서 Consensus는 State(Date)의 정합성과 동일한 의미를 나타낸다. [그림 1]은 Raft의 Architecture 및 State 변경 요청의 흐름을 나타낸다. Raft는 State를 저장하고 있는 Server Cluster와 필요에 따라서 State 관련 요청을 Server에게 전달하는 Client로 구성되어 있다. Server는 **Leader**와 **Follower**로 구성되어 있다. 각 Server에는 Data Consensus를 맞추는 역활을 수행하는 **Consensus Module**, Client의 State 변경 요청을 기록하는 **Log**, 현재의 State를 저장하는 **State Machine**으로 구성되어 있다. Log는 **Entry**의 집합으로 구성되며 하나의 Entry는 하나의 Client의 State 변경 요청을 의미한다.

Raft는 모든 동작이 Leader를 중심으로 동작한다. 따라서 Client의 모든 요청은 Leader Server로 전달 된다. Leader Server의 Consensus Module은 Client의 State 변경 요청이 온다면, 해당 요청을 Leader Server의 Log에 Entry로 저장한다. 이후 Leader Server의 Consensus Module은 Follower Server들에게 Log에 추가된 Entry(Client의 State 변경 요청)를 전달한다. Follower Server의 Consensus Module은 Leader Server로부터 전달된 Entry를 자신의 Log에 Entry로 저장하고 Leader Server에게 Entry 저장이 완료된 사실을 알린다. 이처럼 Leader Server의 Entry가 Follower Server의 Entry로 복제되는 과정을 Raft에서는 **Log Replication**이라고 명칭한다. 

Follower Server로부터 Entry가 추가 되었다는 응답을 받은 Consensus Module은 추가된 Entry 정보를 State Machine에 반영하여, Client의 Data 변경 요청 내역을 실제로 반영한다. 이러한 과정을 Raft에서는 **Commit**이라고 명칭한다. Leader Server의 Consensus Module은 Commit 동작 이후에 Follower Server에게 Commit이 수행되었다는 사실을 알려준다. 이후 Follower Server의 Consensus Module은 추가된 Entry를 State Machine에 반영한다.

Leader, Follower 역활에 관계없이 Server에서 Client의 State 변경 요청은 Consensus Module, Log, State Machine으로 전달된다는 사실을 알 수 있다. 또한 일시적으로 각 Server의 State는 일시적으로 다를 수 있지만, Server의 Log를 통해서 최종적으로는 모든 Server는 동일한 State를 갖게도록 Raft가 설계되어 있다는 사실을 알 수 있다. Raft와 같이 특정 Server의 State를 다른 서버의 State에게 복제하는 방식의 기법을 **Replicated State Machine** 기법이라고 명칭한다.

#### 1.1. Quorum

![[그림 2] Quorum]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Quorum.PNG){: width="400px"}

#### 1.2. Leader Election

![[그림 3] Raft Term]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Term.PNG){: width="600px"}

![[그림 4] Raft Server State]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Server_State.PNG){: width="700px"}

#### 1.3. Log Replication, Commit

![[그림 5] Raft Log]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Loh.PNG){: width="600px"}

Leader Server의 Consensus Module은 Client의 Data 변경 요청이 온다면, 해당 요청을 Leader Server의 Log에 Entry로 저장한다. 이후 Leader Server의 Consensus Module은 Follower Server들에게 Log에 추가된 Entry(Client의 Data 변경 요청)를 전달한다. Follower Server의 Consensus Module은 Leader Server로부터 전달된 Entry를 자신의 Log에 Entry로 저장하고 Leader Server에게 Entry 저장이 완료된 사실을 알린다.

#### 1.4. Log Compaction

#### 1.5. Cluster Member 변경

![[그림 6] Raft Cluster Member 추가/삭제]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Cluster_Member_Add_Remove.PNG){: width="500px"}

### 2. 참조

* [https://web.stanford.edu/~ouster/cgi-bin/papers/OngaroPhD.pdf](https://web.stanford.edu/~ouster/cgi-bin/papers/OngaroPhD.pdf)
* [https://raft.github.io/](https://raft.github.io/)