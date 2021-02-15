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

* Consensus Module : 다른 Server들의 Consensus Module들과 통신하면서 다른 Server들의 상태를 파악하고 Consensus를 맞추는 역할을 수행한다. 또한 Client의 Command(요청)를 받아 Command를 Log에 기록, State Machine에 반영, 다른 Server들의 Consensus Module에 전파하는 역할도 수행한다.
* State Machine : Server의 현재의 상태를 저장하는 저장소 역할을 수행한다.
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

* Leader : Server 사이의 Consensus를 맞추는 중추적인 역할을 수행한다.
* Follower : Leader의 명령에 따라서 Log에 Entry 및 State Machine에 상태를 저장한다.
* Candidate : Leader가 되기 위해서 다른 Server들로부터 표를 받을 상태를 의미한다.

모든 Server는 상황에 따라서 Leader, Follower, Candidate가 될 수 있다. 따라서 Leader를 선출하는 방법을 Raft Algorithm에서 제공하고 있다. Follower가 Leader가 되는 과정은 다음과 같다.

1. Follower가 특정 시간(Election Timeout)동안 Leader로부터 Heartbeat를 받지 못한다.
1. Follower는 Leader가 죽었다고 판단하고 Candidate가 된다.
1. Candidate는 새로운 Term을 생성하고 다른 Server들로부터 투표를 요청한다. 이후에 새로 생성한 Term이 끝날때 까지 다른 Server들의 표를 대기한다. 투표 요청(Request Vote)에는 Candidate 현재 자신의 Log 정보도 포함시킨다.
1. 만약 Term동안에 자기 자신포함 다른 Server들로부터 표를 Quorum 개수이상 받는다면 해당 Candidate는 Leader가 된다. 만약 Term 동안에 자기 자신 포함 표를 Quorum 개수 이상 받지 못한다면 해당 Candidate는 Leader가 되지 못하고 다음 Term에 다시 투표를 진행한다.
1. Leader가된 Server는 Heatbeat를 다른 Server들에게 전달하여 자신이 새로운 Leader가 된것을 알린다.

Term은 Raft Algorithm에서 이용하는 논리적 시간이다. Leader가 바뀌게 되면 새로운 Term이 시작된다. 즉 하나의 Term 동안에는 하나의 Leader가 해당 Term을 점유한다. 투표 요청에는 Candidate의 Log 정보도 같이 전송한다. Follower가 투표를 진행하고 다시 Follower가 되는 과정은 다음과 같다.

1. Follower는 다른 Candidate 상태의 Server로부터 투표 요청을 받는다.
1. Follower는 투표 요청에 Log 정보를 확인한다. 만약 투표 요청에 포함된 Log 정보가 자신의 Log 정보보다 오래 되었다면, 해당 투표 요청을 거절한다. 만약 투표 요청에 포함된 Log 정보가 자신의 Log 정보와 동일하거나 더 최신의 Log 정보이고, 현재의 Term 동안 다른 Candidate에게 표를 보낸적이 없다면 투표 요청에 응하여 표를 전송한다.
1. Follower는 투표 또는 투표 거절이후 Heartbeat를 전송한 Server를 새로운 Leader로 간주한다.

Follower가 투표 요청에 포함된 Log 정보를 확인하는 이유는, 자신이 Log에 저장하고 있는 Entry를 저장하고 있지 않는 Candidate가 Leader가 되는것을 방지하기 위해서이다. Raft Algorithm은 Leader의 Log를 기준으로 Consensus를 맞추기 때문에, Leader의 Log에 저장되어 있지 않는 Entry를 Follower만 저장하고 있다면 해당 Entry는 Leader에 의해서 제거되기 때문이다.

Follower는 Log 조건을 충족하는 Candidate의 투표 요청중에서 가장 먼저 투표를 요청하는 Candidate에게만 표를 전송한다. 따라서 동시에 다수의 Server가 Candidate가 된다면 투표로 Leader가 선출되지 않을 확률이 높아진다. 이러한 문제를 방지하기 위해서 각 Server는 Random한 Election Timeout을 갖는다. 즉 Follower가 Candidate가 되기 위한 대기 시간이 각 Follower마다 다르기 때문에, 동시에 다수의 Follower가 Candidate가 되는것을 방지한다.

#### 4.2. Log Replication

Leader가 선출되면 Leader는 Log Replication을 수행하여 Follower에게 자신의 Log를 복제한다. 여기서 Log를 복제한다는 의미는 Log에 저장되어 있는 Entry들을 복제한다는 의미와 동일하다. Entry들을 복제하는 과정에서 Leader는 Follower에게 AppendEntries 요청을 전송한다. AppendEntries 요청에는 복제 되어야하는 Entry들의 정보가 포함되어 있다. AppendEntries 요청을 받은 Follower는 요청에 포함된 Entry들의 정보를 확인한다. Entry들의 정보가 유효하면 해당 Entry들을 자신의 Log에 추가하고 Leader에게 Entry들이 반영되었다는 것을 알린다. 만약 Entry들의 정보가 유효하지 않다면 해당 Entry들을 반영되지 않았다는 것을 Leader에게 알린다.

Follower는 수신한 Entry들이 자신이 가장 마지막에 저장한 Entry의 다음 Entry에 저장되는 Entry이면 유효하다고 판단하고, 그렇지 않으면 유효하지 않다고 판단한다. Entry들의 정보에는 Entry의 Index 번호, 현재의 Term 정보를 포함하고 있다. AppendEntries 요청 반영 응답을 받은 Leader는 복제되어야할 Entry가 존재한다면 다음 Entry들을 AppendEntries 요청에 포함하여 Follower에게 전송한다. 만약 복제되어야할 Entry가 존재하지 않는다면 Leader는 빈 Entry 정보와 함께 AppendEntries 요청을 보낸다. 복제될 Entry가 없어도 AppendEntries 요청를 전송하는 이유는 AppendEntries 요청이 Leader의 Heartbeat 역할을 수행하기 때문이다.

AppendEntries 요청 거절 응답을 받은 Leader는 이전에 보냈던 Entry의 이전 Entry를 AppendEntries 요청에 포함하여 다시 Follower에게 전송한다. AppendEntries 요청 거절 응답을 받을때 마다 Leader는 이전에 보냈던 Entry의 이전 Entry를 다시 보낸다. 이러한 과정을 계속 반복하면 언젠가 Leader는 Follower에게 유효한 Entry를 보내게 되고, Follower로부터 AppendEntries 요청 반영 응답을 받게 된다. 이후에는 이전에 보냈던 Entry의 다음 Entry를 보내면서 Leader는 Follower에게 Log 복제를 수행한다.

Leader는 Follower으로부터 Quorum 개수 이상의 AppendEntries 요청 응답 Message를 받으면 해당 Entry를 Commit하여 State Machine에 반영한다. Follower는 Leader가 전송한 AppendEntries 요청의 Entry를 Log에 반영하면서, 바로 이전에 Leader가 전송하여 Log에 반영되어 있는 Entry를 State Machine에 반영한다.

#### 4.3. Server 구성 변경

Raft Algorithm을 통해서 Consensus를 맞추는 Server들은 상황에 따라서 교체되거나 추가될 수 있다. 이에 따라서 각 Server들의 Server 구성 설정도 변경되어야 한다. 문제는 한번에 모든 Server들의 Server 구성 설정을 동시에 변경할수 없다. 가장 쉬운 방법은 모든 Server들의 동작을 중지시킨 다음, Server 구성 설정을 변경하고 다시 모든 Server를 구동시키는 방법이다. 하지만 Server 구성 설정을 변경하는 동안 Client는 Server를 이용하지 못한다는 큰 단점을 갖게된다.

이러한 문제를 해결하기 위해서 Raft Algorithm은 Two-phase로 Server 구성 설정을 변경한다. Server 구성 설정도 Client의 Command(요청)에 의해서 저장되는 Data처럼 동일하게 관리된다. Leader가 Server 구성 설정을 변경하면 변경 내역은 Leader의 Log의 Entry에 기록되고 Follower들의 Log의 Entry로 복제되어, Leader 및 Follower들의 State Machine에 저장된다. 이때 Server 구성 설정은 한번에 새로운 Server 구성 설정으로 변경하지 않고, 구 Server 구성 설정과 신규 Server 구성 설정이 둘다 존재하는 Joint Consensus라고 불리는 상태를 이용한다. 따라서 Server 구성 설정은 다음과 같은 단계로 이루어 진다.

* 구 Server 구성 -> 구 Server 구성 + 신규 Server 구성 (Joint Consensus) -> 신규 Server 구성

구 Server 구성 설정과 신규 Server 구성 설정이 잠깐 동안 동시에 존재해야 하는 이유는 동시에 2개의 Server가 Leader가 되는것을 방지하기 위해서이다. 구 Server 구성 설정과 신규 Server 구성 설정이 동시에 적용되어 있는 경우에는 두 Server 구성 설정을 만족하는 하나의 Leader만 선출되기 때문이다. 구 Server 구성 설정에서 신규 Server 구성으로 한번에 변경하게 되면 변경되는 동안 일부 Server들은 구 Server 구성 설정으로 돌아가고, 일부 Server들은 신규 Server 구성으로 동작하게 되는데, 이때 2개의 Server가 동시에 Leader가 되어 동작할 수 있다.

### 5. 참조

* [https://raft.github.io/](https://raft.github.io/)
* [https://web.stanford.edu/~ouster/cgi-bin/papers/OngaroPhD.pdf](https://web.stanford.edu/~ouster/cgi-bin/papers/OngaroPhD.pdf)