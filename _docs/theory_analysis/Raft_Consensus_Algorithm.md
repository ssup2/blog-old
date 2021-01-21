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

#### 1.1. Quorum

![[그림 2] Quorum]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Quorum.PNG){: width="400px"}

#### 1.2. Leader Election

![[그림 3] Raft Term]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Term.PNG){: width="600px"}

![[그림 4] Raft Server State]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Server_State.PNG){: width="700px"}

#### 1.3. Log Replication, Commit

![[그림 5] Raft Log]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Loh.PNG){: width="600px"}

#### 1.4. Log Compaction

#### 1.5. Cluster Member 변경

![[그림 6] Raft Cluster Member 추가/삭제]({{site.baseurl}}/images/theory_analysis/Raft_Consensus_Algorithm/Cluster_Member_Add_Remove.PNG){: width="500px"}

### 2. 참조

* [https://web.stanford.edu/~ouster/cgi-bin/papers/OngaroPhD.pdf](https://web.stanford.edu/~ouster/cgi-bin/papers/OngaroPhD.pdf)
* [https://raft.github.io/](https://raft.github.io/)