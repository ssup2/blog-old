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

Raft는 다수의 Server 사이의 **Consensus(합의)**를 맞추는 역활을 수행하는 Algorithm이다. 여기서 Consensus는 State(Date)의 정합성과 동일한 의미를 나타낸다. [그림 1]은 Raft의 Architecture 및 State 변경 요청의 흐름을 나타낸다. Raft는 State를 저장하고 있는 Server Cluster와 필요에 따라서 State 관련 요청을 Server에게 전달하는 Client로 구성되어 있다. Server는 **Leader**와 **Follower**로 구성되어 있다. 각 Server에는 State Consensus를 맞추는 역활을 수행하는 **Consensus Module**, Client의 State 변경 요청을 기록하는 **Log**, 현재의 State를 저장하는 **State Machine**으로 구성되어 있다. Log는 **Entry**의 집합으로 구성되며 하나의 Entry는 하나의 Client의 State 변경 요청을 의미한다.

Raft는 모든 동작이 Leader를 중심으로 동작한다. 따라서 Client의 모든 요청은 Leader Server로 전달 된다. Leader Server의 Consensus Module은 Client의 State 변경 요청이 온다면, 해당 요청을 Leader Server의 Log에 Entry로 저장한다. 이후 Leader Server의 Consensus Module은 Follower Server들에게 Log에 추가된 Entry(Client의 State 변경 요청)를 전달한다. Follower Server의 Consensus Module은 Leader Server로부터 전달된 Entry를 자신의 Log에 저장하고 Leader Server에게 Entry 저장이 완료된 사실을 알린다. 이처럼 Leader Server의 Log가 Follower Server의 Log로 복제되는 과정을 Raft에서는 **Log Replication**이라고 명칭한다.

Follower Server로부터 Entry가 추가 되었다는 응답을 받은 Consensus Module은 추가된 Entry 정보를 State Machine에 반영하여, Client의 State 변경 요청 내역을 실제로 반영한다. 이러한 과정을 Raft에서는 **Commit**이라고 명칭한다. Leader Server의 Consensus Module은 Commit 동작 이후에 Follower Server에게 Commit이 수행되었다는 사실을 알려준다. 이후 Follower Server의 Consensus Module은 추가된 Entry를 State Machine에 반영한다.

Leader, Follower 역활에 관계없이 Server에서 Client의 State 변경 요청은 Consensus Module, Log, State Machine으로 전달된다는 사실을 알 수 있다. 또한 일시적으로 각 Server의 State는 일시적으로 다를 수 있지만, Server의 Log를 통해서 최종적으로는 모든 Server는 동일한 State를 갖게도록 Raft가 설계되어 있다는 사실을 알 수 있다. Raft와 같이 특정 Server의 State를 다른 서버의 State에게 복제하는 방식의 기법을 **Replicated State Machine** 기법이라고 명칭한다.

#### 1.1. Quorum

![[그림 2] Quorum]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Quorum.PNG){: width="400px"}

Raft에서 의사 결정을 위해서 Quorum은 중요한 역활을 수행한다. Quorum은 Consensus를 유지하기 위한 최소한의 **동의표**를 의미한다. **Majority**라는 단어로도 쓰인다. [그림 2]는 Server Cluster에서 Server의 개수에 따른 Quorum을 나타내고 있다. Quorum은 Server의 개수를 절반으로 나눈 다음 하나를 더한 값이란걸 알 수 있다. 즉 찬성하는 Server의 개수가 반대하는 Server의 개수보다 크다는걸 보장하는 최소값이 Quorum이라고 할 수 있다.

Qourum은 Leader가 Entry에 저장되어 있는 State 변경 내역을 State Machine에 반영하기 전, Follower의 Log에 해당 State 변경 내역의 Entry가 저장되었다는 응답을 받아야 하는 개수의 기준이 된다. 즉 [그림 1]에서 Server Cluster는 Server 3대로 구성되어 있기 때문에 Leader는 하나의 Follower에게만 Entry 저장 응답을 받게되면, Leader는 자신을 포함하여 Quorum의 개수인 총 2개의 동의표를 얻었기 때문에 해당 Entry를 State Machine에 반영하게 된다.

동일한 이유로 Server Cluster에서 동작하는 Server의 개수가 Quorum 개수보다 작다면 해당 Server Cluster에서 동작하는 Server들은 절대로 Quorum 개수 이상의 동의표를 얻을수 없기 때문에, 해당 Server Cluster에서는 절대로 State 변경이 발생할 수 없게된다. Quorum은 다음에 설명하는 Leader Election 과정에서 Server가 Leader가 되기 위해서 다음 Server로부터 얻어야하는 표의 개수의 기준이되기도 한다.

Server Cluster의 Server의 개수가 홀수인 상태에서 Server를 한대더 추가하면 Quorum의 개수도 한개더 추가되는 것을 알 수 있다. 예를 들어 Server의 개수가 3인 경우에 Quorum은 2이지만, Server를 한대더 추가하여 개수가 4개가 되면 Quorum도 1이 증가하여 3이되는 [그림 2]를 통해 확인할 수 있다. 이말은 즉 Server Cluster의 Server의 개수를 짝수개로 증설할 경우 가용성의 관점에서는 효율이 떨어진다는 의미가 된다. 따라서 Server Cluster의 Server의 개수는 홀수개로 구성하는 것이 권장된다.

#### 1.2. Term

![[그림 3] Raft Term]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Term.PNG){: width="600px"}

Term은 Raft에서 이용하는 임의의 시간을 나타내는 단위이다. [그림 3]은 Raft의 Term을 나타내고 있다. 하나의 Term이 시작되면 반드시 Server Cluster에서 하나의 Leader Server를 뽑는 Leader Election 과정이 진행된다. 만약 Leader Server가 뽑힌다면 뽑힌 Leader Server가 정상적으로 동작하는 동안에는 해당 Term은 유지된다. 만약 Leader Server가 뽑히지 않는다면 현재 Term을 종료하고 새로운 Term을 시작하여 다시 Leader Election을 수행한다. 즉 하나의 Term은 하나의 Leader Server와 동일한 Life Time을 갖는 특징을 갖는다.

각 Term은 번호를 갖고 있으며, 새로운 Term이 시작될 때마다 이전 Term 번호보다 하나큰 Term 번호가 할당된다. [그림 3]에서 새로운 Term이 시작될때마다 Term 번호도 하나씩 증가하는것을 확인할 수 있다. Leader Server와 모든 Follwer Server들이 모두 문제 없이 동작중이라면 Leader Server와 모든 Follwer Server들은 동일한 Term안에서 동작한다. 하지만 일부 또는 전체 Server에서 장애가 발생시 일시적으로 각 Server는 다른 Term안에서 동작할 수 있다. 

예를 들어 Leader Server는 계속 동작중이었지만 Leader Server와 Follower Server 사이에 Network 장애로 인해서 Follwer Server는 Leader Server가 비정상 상태라고 간주하고, 새로운 Term을 시작할 수 있다. 이러한 일시적인 Term 불일치는 Leader Election 과정을 통해서 맞춰지게 된다.

#### 1.3. Leader Election

![[그림 4] Raft Server State]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Server_State.PNG){: width="700px"}

#### 1.4. Log Replication, Commit

![[그림 5] Raft Log]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Log.PNG){: width="600px"}

#### 1.5. Log Compaction

#### 1.6. Cluster Member 변경

![[그림 6] Raft Cluster Member 추가/삭제]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Cluster_Member_Add_Remove.PNG){: width="500px"}


#### 1.7. Client Connection

### 2. 참조

* [https://web.stanford.edu/~ouster/cgi-bin/papers/OngaroPhD.pdf](https://web.stanford.edu/~ouster/cgi-bin/papers/OngaroPhD.pdf)
* [https://raft.github.io/](https://raft.github.io/)