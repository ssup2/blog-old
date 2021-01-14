---
title: In Search of Understandable Consensus Algorithm
category: Paper, Patent
date: 2021-01-14T13:00:00Z
lastmod: 2021-01-14T13:00:00Z
comment: true
adsense: true
---

### 1. 요약

분산 컴퓨팅 환경에서 Data의 Consensus를 맞추기 위해서 이용되는 Raft Algorithm을 설명하고 있는 논문이다.

### 2. Replicated State Machine Architecture

Consensus Algorithm은 일반적으로 Replicated State Machine Architecture를 기반으로 동작한다. Replicated State Machine Architecture는 의미 그대로 동일한 상태를 갖는 State Machine들을 포함한 다수의 Server들로 구성된 Architecture를 의미한다. Replicated State Machine Architecture의 각 Server들은 다음과 같은 구성요소로 이루어져 있다.

* Consensus Module : 다른 Server들의 Consensus Module들과 통신하면서 다른 Server들의 상태를 파악하고 Consensus를 맞추는 역활을 수행한다. 또한 Client의 Command(요청)를 받아 Command를 Log에 기록, State Machine에 반영, 다른 Server들의 Consensus Module에 전파하는 역활도 수행한다.
* State Machine : Server의 현재의 상태를 저장하는 저장소 역활을 수행한다.
* Log : Consensus Module이 State Machine에 적용한 Client의 Command를 적용 순서대로 기록하는 공간이다. 즉 Log를 통해서 State Machine의 History를 파악할 수 있다. Consensus Module은 Log에 저장된 Command 정보를 바탕으로 Consensus를 맞춘다. 하나의 Command 정보는 Log의 하나의 Entry에 저장된다.

### 3. Consensus Algorithm 특징

Consensus Algorithm은 다음과 같은 특징을 만족해야 한다.

* non-Byzantine 환경(Network Delay & Partition, Packet Loss & Duplication & Reordering)에서도 안전성이 보장되어야 한다. 여기서 안전성은 잘못된 결과를 반환하지 않는것을 의미한다.
* 다수의 Server가 정상적으로 동작하고 있다면, Algorithm 수행에 문제가 없어야 한다. 여기서 다수는 Quorum을 의미한다. 예를들어 5대의 Server중에서 3대 이상이 정상 동작하고 있다면, Algorithm 수행에 문제가 없어야 한다.
* Faulty Clock, Message Delay로 인한 Timing 문제가 발생하여도 Log의 Consistency는 유지되어야 한다.

### 4. Raft Algorithm

Raft Algorithm은 기존의 Consensus Algorithm으로 많이 알려진 Pasox Algorithm의 문제점을 해결하기 위해서 태어났다. Raft Algorithm은 Paxos Algorithm을 보다 간단하고 직관적이며, 실제로 구현하기 쉬운 특징을 갖고 있다. Raft Algorithm도 Replicated State Machine Architecture를 기반으로 동작하며, Consensus Algorithm의 특징을 만족시킨다. Raft Algorithm은 아래의 5가지의 특징을 만족시키는것을 보장한다.

* Election Safety : 하나의 Term동안 안전하게 하나의 Leader를 선출할 수 있다.
* Leader Append-Only : Leader는 절대로 Log안에 있는 Entry(Command)를 Overwrite하거나 삭제하지 않는다. Leader는 오직 Log안에 다음 Index에 Entry를 추가만 한다.
* Log Matching : 두 Log의 마지막 Entry의 Index와 Term이 동일하다면, 두 Log는 동일한 Log이다.
* Leader Completeness : Commit된 Entry는 추후 Leader가 변경되더라도 변경된 Leader에도 존재한다.
* State Machine Safety : 하나의 Server에서 특정 Index의 Entry를 State Machine에 반영하였다면, 다른 Server에서 동일한 Index의 동일한 Entry를 갖을 경우에만 해당 State Machine에 반영한다. 만약 동일한 Index에 다른 내용의 Entry가 존재할 경우 해당 Entry는 반영되지 않는다.

#### 4.1. Leader 선출

Raft Algorithm에서 각 Server는 Leader, Follower, Candidate 3가지의 상태를 갖는다. Raft Algorithm은 Leader가 중심이 되어 Consensus를 맞춘다. 이러한 Leader 기반의 방식 때문에, Raft Algorithm은 다른 Consensus Algorithm에 비해서 이해하고, 구현하기 쉬운 장점을 갖게되었다. 3가자의 상태에 대한 설명은 아래와 같다.

* Leader : Server 사이의 Consensus를 맞추는 중추적인 역활을 수행한다.
* Follower : Leader의 명령에 따라서 Log에 Entry 및 State Machine에 상태를 저장한다.
* Candidate : Leader가 되기 위해서 다른 Server들로부터 표를 받을 상태를 의미한다.

모든 Server는 상황에 따라서 Leader, Follower, Candidate가 될 수 있다. 따라서 Leader를 선출하는 방법을 Raft Algorithm에서 제공하고 있다. Follower가 Leader가 되는 과정은 다음과 같다.

1. Follower가 특정 시간(Election Timeout)동안 Leader로부터 Heartbeat를 받지 못한다.ㄴ
1. Follower는 Leader가 죽었다고 판단하고 Candidate가 된다.
1. Candidate는 새로운 Term을 생성하고 다른 Server들로부터 투표를 요청한다. 이후에 새로 생성한 Term이 끝날때 까지 다른 Server들의 표를 대기한다. 투표 요청에는 Candidate 현재 자신의 Log 정보도 포함시킨다.
1. 만약 Term동안에 자기 자신포함 다른 Server들로부터 표를 Quorum 개수이상 받는다면 해당 Follower는 Leader가 된다. 만약 Term 동안에 자기 자신 포함 표를 Quorum 개수 이상 받지 못한다면 해당 Follower는 Leader가 되지 못하고 다음 Term에 다시 투표를 진행한다.
1. Leader가된 Server는 Heatbeat를 다른 Server들에게 전달하여 자신이 새로운 Leader가 된것을 알린다.

Term은 Raft Algorithm에서 이용하는 논리적 시간이다. Leader가 바뀌게 되면 새로운 Term이 시작된다. 즉 하나의 Term 동안에는 하나의 Leader가 해당 Term을 점유한다. 투표 요청에는 Candidate의 Log 정보도 같이 전송한다. Follower가 투표를 진행하고 다시 Follower가 되는 과정은 다음과 같다.

1. Follower는 다른 Candidate 상태의 Server로부터 투표 요청을 받는다.
1. Follower는 투표 요청에 Log 정보를 확인한다. 만약 투표 요청에 포함된 Log 정보가 자신의 Log 정보보다 오래 되었다면, 해당 투표 요청을 거절한다. 만약 투표 요청에 포함된 Log 정보가 자신의 Log 정보와 동일하거나 더 최신의 Log 정보이고, 현재의 Term 동안 다른 Candidate에게 표를 보낸적이 없다면 투표 요청에 응하여 표를 전송한다.
1. Follower는 투표 또는 투표 거절이후 Heartbeat를 전송한 Server를 새로운 Leader로 간주한다.

Follower가 투표 요청에 포함된 Log 정보를 확인하는 이유는, 자신이 Log에 저장하고 있는 Entry를 저장하고 있지 않는 Candidate가 Leader가 되는것을 방지하기 위해서이다. Raft Algorithm은 Leader의 Log를 기준으로 Consensus를 맞추기 때문에, Leader의 Log에 저장되어 있는 Entry를 Follower만 저장하고 있다면 해당 Entry는 Leader에 의해서 제거되기 때문이다.

Follower는 Log 조건을 충족하는 Candidate의 투표 요청중에서 가장 먼저 투표를 요청하는 Candidate에게만 표를 전송한다. 따라서 동시에 다수의 Server가 Candidate가 된다면 투표로 Leader가 선출되지 않을 확률이 높아진다. 이러한 문제를 방지하기 위해서 각 Server는 Random한 Election Timeout을 갖는다. 즉 Follower가 Candidate가 되기 위한 대기 시간이 각 Follower마다 다르기 때문에, 동시에 다수의 Follower가 Candidate가 되는것을 방지한다.

#### 4.2. Log Replication

Term은 번호를 갖고 있으며, 모든 Server는 현재의 Term 번호를 알고 있다. Follower가 Candidate가 되면 현재의 Term 번호보다 숫자 1이 높은 새로운 Term을 만들고, 새로운 Term 번호를 투표 요청에 포함시켜 다른 Server들에게 새로운 Term 번호도 같이 전달한다. 만약 새로운 Term 동안 Leader가 선출되지 못한다면, Candidate는 다시 숫자 1이 높은 새로운 Term을 만들고 투표 요청을 진행한다.

#### 4.3. Member 교체

#### 4.4. Log 압축

### 5. 참조

* [https://raft.github.io/](https://raft.github.io/)