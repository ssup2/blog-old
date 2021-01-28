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

Raft는 다수의 Server 사이의 **Consensus(합의)**를 맞추는 역활을 수행하는 Algorithm이다. 여기서 Consensus는 State(Date)의 정합성과 동일한 의미를 나타낸다. [그림 1]은 Raft의 Architecture 및 State 변경 요청의 흐름을 나타낸다. Raft는 State를 저장하고 있는 Server Cluster와 필요에 따라서 State 관련 요청을 Server에게 전달하는 Client로 구성되어 있다. Server는 **Leader Server**와 **Follower Server**로 구성되어 있다. 각 Server에는 State Consensus를 맞추는 역활을 수행하는 **Consensus Module**, Client의 State 변경 요청을 기록하는 **Log**, 현재의 State를 저장하는 **State Machine**으로 구성되어 있다. Log는 **Entry**의 집합으로 구성되며 하나의 Entry는 하나의 Client의 State 변경 요청을 의미한다.

Raft는 모든 동작이 Leader Server를 중심으로 동작한다. 따라서 Client의 모든 요청은 Leader Server로 전달 된다. Leader Server의 Consensus Module은 Client의 State 변경 요청이 온다면, 해당 요청을 Leader Server의 Log에 Entry로 저장한다. 이후 Leader Server의 Consensus Module은 Follower Server들에게 Log에 추가된 Entry(Client의 State 변경 요청)를 전달한다. Follower Server의 Consensus Module은 Leader Server로부터 전달된 Entry를 자신의 Log에 저장하고 Leader Server에게 Entry 저장이 완료된 사실을 알린다. 이처럼 Leader Server의 Log가 Follower Server의 Log로 복제되는 과정을 Raft에서는 **Log Replication**이라고 명칭한다.

Follower Server로부터 Entry가 추가 되었다는 응답을 받은 Consensus Module은 추가된 Entry 정보를 State Machine에 반영하여, Client의 State 변경 요청 내역을 실제로 반영한다. 이러한 과정을 Raft에서는 **Commit**이라고 명칭한다. Leader Server의 Consensus Module은 Commit 동작 이후에 Follower Server에게 Commit이 수행되었다는 사실을 알려준다. 이후 Follower Server의 Consensus Module은 추가된 Entry를 State Machine에 반영한다.

Leader, Follower 역활에 관계없이 Server에서 Client의 State 변경 요청은 Consensus Module, Log, State Machine으로 전달된다는 사실을 알 수 있다. 또한 일시적으로 각 Server의 State는 일시적으로 다를 수 있지만, Server의 Log를 통해서 최종적으로는 모든 Server는 동일한 State를 갖게도록 Raft가 설계되어 있다는 사실을 알 수 있다. Raft와 같이 특정 Server의 State를 다른 서버의 State에게 복제하는 방식의 기법을 **Replicated State Machine** 기법이라고 명칭한다.

#### 1.1. Quorum

![[그림 2] Quorum]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Quorum.PNG){: width="400px"}

Raft에서 의사 결정을 위해서 Quorum은 중요한 역활을 수행한다. Quorum은 Consensus를 유지하기 위한 최소한의 **동의표**를 의미한다. **Majority**라는 단어로도 쓰인다. [그림 2]는 Server Cluster에서 Server의 개수에 따른 Quorum을 나타내고 있다. Quorum은 Server의 개수를 절반으로 나눈 다음 하나를 더한 값이란걸 알 수 있다. 즉 찬성하는 Server의 개수가 반대하는 Server의 개수보다 크다는걸 보장하는 최소값이 Quorum이라고 할 수 있다.

Qourum은 Leader가 Entry에 저장되어 있는 State 변경 내역을 State Machine에 반영하기 전, Follower의 Log에 해당 State 변경 내역의 Entry가 저장되었다는 응답을 받아야 하는 개수의 기준이 된다. 즉 [그림 1]에서 Server Cluster는 Server 3대로 구성되어 있기 때문에 Leader는 하나의 Follower에게만 Entry 저장 응답을 받게되면, Leader는 자신을 포함하여 Quorum의 개수인 총 2개의 동의표를 얻었기 때문에 해당 Entry를 State Machine에 반영하게 된다.

동일한 이유로 Server Cluster에서 동작하는 Server의 개수가 Quorum 개수보다 작다면 해당 Server Cluster에서 동작하는 Server들은 절대로 Quorum 개수 이상의 동의표를 얻을수 없기 때문에, 해당 Server Cluster에서는 절대로 State 변경이 발생할 수 없게된다. Quorum은 다음에 설명하는 Leader Election 과정에서 Server가 Leader가 되기 위해서 다음 Server로부터 얻어야하는 표의 개수의 기준이되기도 한다.

Server Cluster의 Server의 개수가 홀수인 상태에서 Server를 한대더 추가하면 Quorum의 개수도 한개더 추가되는 것을 알 수 있다. 예를 들어 Server의 개수가 3인 경우에 Quorum은 2이지만, Server를 한대더 추가하여 개수가 4개가 되면 Quorum도 1이 증가하여 3이되는 [그림 2]를 통해 확인할 수 있다. 이말은 즉 Server Cluster의 Server의 개수를 짝수개로 증설할 경우 가용성의 관점에서는 효율이 떨어진다는 의미가 된다. 따라서 Server Cluster의 Server의 개수는 홀수개로 구성하는 것이 권장된다.

#### 1.2. Term

![[그림 3] Raft Term]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Term.PNG){: width="500px"}

Term은 Raft에서 이용하는 임의의 시간을 나타내는 단위이다. 하나의 Term이 시작되면 반드시 Server Cluster에서 하나의 Leader Server를 뽑는 Leader Election 과정이 진행된다. 만약 Leader Server가 뽑힌다면 뽑힌 Leader Server가 정상적으로 동작하는 동안에는 해당 Term은 유지된다. 만약 Leader Server가 뽑히지 않는다면 현재 Term을 종료하고 새로운 Term을 시작하여 다시 Leader Election을 수행한다. 즉 하나의 Term은 하나의 Leader Server와 동일한 Life Time을 갖는 특징을 갖는다. [그림 3]에서 Term 1,2,4는 Leader Server를 뽑는데 성공한 Term을 나타내고 있고, Term 3은 Leader Server를 뽑느데 실패한 Term을 나타내고 있다.

각 Term은 번호를 갖고 있으며, 새로운 Term이 시작될 때마다 이전 Term 번호보다 하나큰 Term 번호가 할당된다. [그림 3]에서 새로운 Term이 시작될때마다 Term 번호도 하나씩 증가하는것을 확인할 수 있다. Leader Server와 모든 Follwer Server들이 모두 문제 없이 동작중이라면 Leader Server와 모든 Follwer Server들은 동일한 Term안에서 동작한다. 하지만 일부 또는 전체 Server에서 장애가 발생시 일시적으로 각 Server는 다른 Term안에서 동작할 수 있다.

예를 들어 Leader Server는 계속 동작중이었지만 Leader Server와 Follower Server 사이에 Network 장애로 인해서 Follwer Server는 Leader Server가 비정상 상태라고 간주하고, 새로운 Term을 시작할 수 있다. 이러한 일시적인 Term 불일치는 Leader Election 과정을 통해서 맞춰지게 된다.

#### 1.3. Leader Election

![[그림 4] Raft Server State]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Server_State.PNG){: width="700px"}

Raft는 새로운 Term이 시작되면 Leader Election을 통해서 새로운 Leader Server를 뽑는다. Leader Election 관점에서 Server는 Leader, Follower 그리고 Candidate 3가지의 상태를 갖는다. 앞에서 Leader Server 및 Follower Server라고 표현한 것은 정확히 말하면 Leader 상태의 Server와 Follower 상태의 Server를 의미한다. Candidate 상태는 Server가 Leader Server가 되기 위해서 다른 Server로부터 표를 받기 위해서 대기하는 상태를 의미한다. [그림 4]는 Server의 상태가 어떻게 변하는지를 나타내고 있다.

Server는 처음 시작되면 Follower Server가 된다. Follower Server가 Leader Server가 되는 과정은 다음과 같다.

1. Follower Server가 특정 시간(Election Timeout)동안 Leader Server로부터 Heartbeat를 받지 못한다.
1. Follower Server는 Leader Server가 죽었다고 판단하고 Candidate Server가 된다.
1. Candidate Server는 새로운 Term을 시작하고 다른 Server들로부터 투표를 요청한다.
1. 만약 투표를 요청하고 특정시간 동안 자기 자신을 포함하여 다른 Server들로부터 표를 Quorum 개수이상 받는다면 해당 Candidate Server는 Leader Server가 된다.
1. 새로운 Leader Server는 Heatbeat를 다른 Server들에게 전달하여 자신이 새로운 Leader가 된것을 알린다.

Raft에서 투표 요청은 **RequestVote** RPC 호출을 통해서 이루어진다. 투표 요청에는 Candidate의 현재 Term 및 Log 정보도 같이 전송한다. 만약 Candidate Server가 투표를 요청하고 특정시간 동안 자기 자신을 포함하여 다른 Server들로부터 표를 Quorum 개수를 받지 못한다면, 해당 Candidate는 Candidate 상태를 유지한 상태로 새로운 Term을 시작하고 다시 투표 요청을 다른 Server들에게 전송한다. 또는 만약 Candidate Server가 새로운 Leader Server로부터 Heartbeat를 받거나 더 높은 Term을 갖는 다른 Candidate Server로부터 투표 요청을 받을 경우에, 해당 Candidate Server는 Follower 상태가 된다.

Follower Server가 투표를 진행하고 다시 Follower Server가 되는 과정은 다음과 같다.

1. Follower Server는 Candidate Server로부터 투표 요청을 받는다.
1. Follower Server는 투표 요청에 포함된 Log 정보를 확인한다. 만약 투표 요청에 포함된 Log 정보가 자신의 Log 정보보다 오래 되었다면, 해당 투표 요청을 거절한다. 만약 투표 요청에 포함된 Log 정보가 자신의 Log 정보와 동일하거나 더 최신의 Log 정보이고, 현재의 Term 동안 다른 Candidate Server에게 표를 보낸적이 없다면 투표 요청에 응하여 표를 전송한다.
1. Follower Server는 투표 또는 투표 거절이후 Heartbeat를 전송한 Server를 새로운 Leader로 간주한다.

Follower Server가 투표 요청에 포함된 Log 정보를 확인하는 이유는, Follwer Server의 Log에 저장되어 있는 Entry를 저장하고 있지 않는 Candidate Server가 Leader Server가 되는것을 방지하기 위해서이다. Raft는 Leader Server의 Log를 기준으로 Consensus를 맞추기 때문에, Leader Server의 Log에 저장되어 있지 않는 Entry를 Follower Server에만 저장하고 있다면, 해당 Entry는 Leader Server에 의해서 제거되기 때문이다.

Follower Server는 Log 조건을 충족하는 Candidate Server의 투표 요청중에서 가장 먼저 투표를 요청한 Candidate Server에게만 표를 전송한다. 따라서 동시에 다수의 Server가 Candidate Server가 된다면 투표로 Leader Server가 선출되지 않을 확률이 높아진다. 이러한 문제를 방지하기 위해서 각 Server는 Random한 Election Timeout을 갖는다. 즉 Follower Server가 Candidate Server가 되기 위한 대기 시간이 각 Follower Server마다 다르기 때문에, 동시에 다수의 Follower Server가 Candidate Server가 되는것을 방지한다.

#### 1.4. Log Replication, Commit

![[그림 5] Raft Log]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Log.PNG){: width="500px"}

Leader Server가 선출되면 Leader Server는 Log Replication을 수행하여 Follower Server들에게 자신의 Log를 복제한다. 여기서 Log를 복제한다는 의미는 Log를 구성하는 Entry들을 복제한다는 의미와 동일하다. [그림 5]는 Leader Server와 Follower Server의 Log 구성을 나타내고 있다. Entry는 Index 번호를 갖고 있으며 각 Entry에는 Index Entry에는 State 변경 내역 및 State가 변경되었을 때의 Term의 번호가 저장되어 있다.

Leader Server는 Follower Server에게 **AppendEntries** RPC 호출을 통해서 복제될 Entry 정보와 함께 Entry 복제 요청을 전송한다. Entry 복제 요청을 받은 Follower Server는 요청에 포함된 Entry들의 정보가 유효한지 확인한다. Entry들의 정보가 유효하면 해당 Entry들을 자신의 Log에 추가하고 Leader Server에게 Entry들이 복제되었다는 것을 알린다. 만약 Entry들의 정보가 유효하지 않다면 해당 Entry들을 복제되지 않았다는 것을 Leader Server에게 알린다.

Follower Server는 수신한 Entry들이 자신이 가장 마지막에 저장한 Entry의 다음 Entry에 저장되는 Entry이면 유효하다고 판단하고, 그렇지 않으면 유효하지 않다고 판단한다. Entry들의 정보에는 Entry의 Index 번호 및 현재의 Term 정보를 포함하고 있는데, Index 번호가 연속되며 및 현재의 Term 번호가 일치할 경우에만 수신한 Entry들이 유효한 Entry라고 간주한다.

Follower Server에게 Entry 복제 수락 응답을 받은 Leader Server는 다음에 복제해야할 Entry들이 존재하는지 확인한다. 만약 복제할 Entry들이 존재한다면 다시 Entry 복제 요청을 통해서 Follower Server에게 Entry 복제를 시도한다. 만약 복제되어야할 Entry가 존재하지 않는다면 Leader Server는 빈 Entry 정보와 함께 Entry 복제 요청을 계속 전송한다. 복제될 Entry가 없어도 Entry 복제 요청이 Leader Server의 Heartbeat 역활을 수행하기 때문이다. 즉 앞에서 Leader Server가 Follower Server에게 전송하는 Heatbeat의 정채는 Leader Server가 Follower Server들의 AppendEntries RPC를 호출하는 것을 의미한다.

Follower Server에게 Entry 복제 거절 응답을 받은 Leader Server는 복제 거절된 Entry들의 이전 Entry들을 Entry 복제 요청에 포함하여 다시 Follower Server에게 전송한다. 이처럼 Leader Server는 Entry 복제 거절 응답을 받을때 마다 복제 거절된 Entry의 이전 Entry를 다시 보낸다. 이러한 과정을 계속 반복하면 언젠가 Leader Server는 Follower Server에게 유효한 Entry를 보내게 되고, 이후에는 Leader Server와 Follwer Server는 Entry 복제가 시작된다.

Leader Server는 Follower Server들로부터 Quorum 개수 이상의 Entry 복제 수락 응답을 받게되면, 해당 Entry들을 **Commit**하여 State Machine에 반영한다. Follower Server는 Leader Server에게 다음 Entry 복제 요청 또는 빈 Entry 복제 요청을 받을 경우, 이전에 Log에 복제한 Entry들을 State Machine에 반영한다.

#### 1.5. Log Compaction, Snapshot

Raft는 Log를 압축하는 방법으로 **Snapshot**을 이용하고 있다. Snapshot을 찍은 이후에는 Snapshot을 찍기 이전의 Entry들은 제거되기 때문이다. Snapshot 이후에 State 변경 내역은 이전과 동일하게 Log의 Entry로 남게된다.

#### 1.6. Server Cluster의 Server 추가/제거

Raft는 Server Cluster의 설정 정보도 State와 동일하게 Log 및 State Machine에 의해서 관리된다. 즉 Server Cluster의 설정 정보가 변경될 경우, 변경된 설정은 모든 Server에 동시에 적용 되는것이 아니라 각 Server가 변경된 설정을 State Machine에 반영할때 적용된다. 따라서 Leader Server가 제일 먼저 Server Cluster의 설정 정보를 적용하고 이후에 시간 차이를 두고 Follower Server들이 변경된 설정을 적용한다. Server Cluster의 Server를 추가/삭제하는 과정도 Server Cluster의 설정 변경을 의미한다.

![[그림 6] Raft Server Cluster의 Server 추가에 의한 2개의 Leader]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Cluster_Member_Add_2_Leader.PNG){: width="450px"}

Raft는 운영중에 발생할 수 있는 Server Cluster의 Server 추가/제거 과정이 Raft의 동작이 중지되지 않으면서 이루어질 수 있는 방법을 제공하고 있다. Raft에서 이러한 무중단 Server 추가/제거 방법이 중요한 이유는 하나의 Server Cluster에서 일시적으로 2개의 Leader Server가 정상적으로 동작할 수 있기 때문이다. [그림 6]은 3개의 Server로 구성된 Server Cluster에 Server 4,5 2개의 Server를 추가하였을 경우 2개의 Leader Server로 인해서 문제가 발생할 수 있는 상황을 나타내고 있다.

[그림 6]에서 Old Conf는 Server Cluster에 3개의 Server만 존재하는 설정을 나타내고 New Conf는 Server Cluster에 5개의 Server가 존재하는 설정을 나타낸다. 따라서 Old Conf의 Quorum은 2개이고 New Conf의 Quorum은 3개이다. [그림 6]의 빨간점선 시점에 Server 1,2는 Old Conf로 동작하며, Server 3,4,5는 New Conf로 동작하고 있다. 이때 Old Conf의 Quorum은 2개이기 때문에 Server 1,2 둘중 하나는 Leader Server가 되어 동작이 가능하다. 이와 동시에 New Conf의 Quorum은 3개이기 때문에 Server 3,4,5 셋중 하나는 Leader Server가 되어 동작이 가능하다. 즉 2개의 Leader Server가 동시에 동작할 수 있기 때문에 문제가 된다.

이러한 문제를 해결하기 위해서 Raft는 2가지 Server 추가/제거 방법을 제공한다. 첫번째 방법은 동시에 무조건 단일 Server만 추가/제거를 하는 방식이다. 두번째 방법은 Old Conf와 New Conf를 동시에 적용하는 Joint Consensus를 이용하는 방법이다.

##### 1.6.1. 단일 Server 추가/제거

![[그림 7] Raft Server Cluster의 단일 Server 추가/제거]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Cluster_Member_Add_Remove.PNG){: width="500px"}

2개의 Leader Server가 동시에 동작하는 문제를 막기 위한 첫번째 방법은, 동시에 단일 Server만 추가/제거를 하는 방식이다. [그림 7]은 단일 Server 추가/제거를 하였을때의 Cluster Conf를 나타내고 있다. 4가지의 Case 모두 Old Conf와 New Conf가 동시에 필요한 Quorum의 개수를 만족시킬 수 없다는걸 알 수 있다. 즉 Old Conf의 Leader Server와 New Conf의 Leader 서버는 동시에 동작할 수 없게된다.

##### 1.6.2. Joint Consensus

> 구 Server 구성 -> 구 Server 구성 + 신규 Server 구성 (Joint Consensus) -> 신규 Server 구성

2개의 Leader Server가 동시에 동작하는 문제를 막기 위한 두번째 방법은, Old Conf와 New Conf를 동시에 적용하는 Joint Consensus를 이용하는 방법이다. Server Cluster에 Old Conf와 New Conf가 동시에 적용되어 있는 동안에는 두 Conf를 만족시키는 하나의 Leader Server만이 동작하기 때문이다.

#### 1.7. Client Connection

### 2. 참조

* [https://web.stanford.edu/~ouster/cgi-bin/papers/OngaroPhD.pdf](https://web.stanford.edu/~ouster/cgi-bin/papers/OngaroPhD.pdf)
* [https://raft.github.io/](https://raft.github.io/)