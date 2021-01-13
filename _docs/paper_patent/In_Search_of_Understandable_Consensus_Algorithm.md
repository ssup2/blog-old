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
* Log : Consensus Module이 State Machine에 적용한 Client의 Command를 적용 순서대로 기록하는 공간이다. 즉 Log를 통해서 State Machine의 History를 파악할 수 있다. Consensus Module은 Log에 저장된 Command 정보를 바탕으로 Consensus를 맞춘다.

### 3. Consensus Algorithm 특징

Consensus Algorithm은 다음과 같은 특징을 만족해야 한다.

* non-Byzantine 환경(Network Delay & Partition, Packet Loss & Duplication & Reordering)에서도 안전성이 보장되어야 한다. 여기서 안전성은 잘못된 결과를 반환하지 않는것을 의미한다.
* 다수의 Server가 정상적으로 동작하고 있다면, Algorithm 수행에 문제가 없어야 한다. 여기서 다수는 Quorum을 의미한다. 예를들어 5대의 Server중에서 3대 이상이 정상 동작하고 있다면, Algorithm 수행에 문제가 없어야 한다.
* Faulty Clock, Message Delay로 인한 Timing 문제가 발생하여도 Log의 Consistency는 유지되어야 한다.

### 4. Raft Algorithm

Raft Algorithm은 기존의 Consensus Algorithm으로 많이 알려진 Pasox Algorithm의 문제점을 해결하기 위해서 태어났다. Raft Algorithm은 Paxos Algorithm을 보다 간단하고 직관적이며, 실제로 구현하기 쉬운 특징을 갖고 있다. Raft Algorithm도 Replicated State Machine Architecture를 기반으로 동작하며, Consensus Algorithm의 특징을 만족시킨다. Raft Algorithm에서 각 Server는 Leader 또는 Follwer로 동작한다.

Raft Algorithm은 아래의 5가지의 특징을 만족시키는것을 보장한다.

* Election Safety : 대부분 하나의 Term안에 안전하게 Leader를 선출할 수 있다.
* Leader Append-Only : Leader는 절대로 Log안에 있는 Entry(Command)를 Overwrite하거나 삭제하지 않는다. Leader는 오직 Log안에 다음 Index에 Entry를 추가만 한다.
* Log Matching : 두 Log의 마지막 Entry의 Index와 Term이 동일하다면, 두 Log는 동일한 Log이다.
* Leader Completeness : Commit된 Entry는 추후 Leader가 변경되더라도 변경된 Leader에도 존재한다.
* State Machine Safety : 하나의 Server에서 특정 Index의 Entry를 State Machine에 반영하였다면, 다른 Server에서 동일한 Index의 동일한 Entry를 갖을 경우에만 해당 Stat Machine에 반영한다. 만약 동일한 Index에 다른 내용의 Entry가 존재할 경우 해당 Entry는 반영되지 않는다.

#### 4.1. Term

#### 4.2. Leader 선출

#### 4.3. Log Replication

#### 4.4. Member 교체

#### 4.5. Log 압축

### 5. 참조

* [https://raft.github.io/](https://raft.github.io/)