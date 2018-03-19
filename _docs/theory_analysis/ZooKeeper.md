---
title: ZooKeeper
category: Theory, Analysis
date: 2017-03-18T12:00:00Z
lastmod: 2017-03-18T12:00:00Z
comment: true
adsense: true
---

Apache ZooKeeper를 분석한다.

### 1. ZooKeeper

ZooKeeper는 분산 시스템 환경에서 Leader 선출, Node 상태, 분산 Lock 관리등 다양한 역활을 수행하는 **분산 Coordinator**이다. 안전성과 성능을 인정 받아 Hadoop, HBase, Storm, Kafka 등 다양한 Open Source Project에 이용되고 있다.

#### 1.1. Architecture

![]({{site.baseurl}}/images/theory_analysis/ZooKeeper/ZooKeeper_Architecture.PNG)

분산 Coordinator는 분산 시스템의 일부분이 되어 동작하기 때문에 분산 Coordinator의 작동이 멈춘다면 분산 시스템도 정지하게 된다. ZooKeeper는 안전성을 확보하기 위해 다수의 Server를 이용하는 **Server Cluster - Client** 구조를 이용한다. Server Cluster는 하나의 **Leader**와 여러개의 **Follower**로 구성되어 있다. Server Cluster는 홀수 개수로 구성하는 것이 유리하다. Server간의 Consistency가 깨졌을 경우 과반수 이상의 Data를 기준으로 Consistency를 맞추기 때문이다.

각 Server는 Request Processor, Atomic Broadcast, In-memory DB로 구성되어 있다. Request Processor는 Leader Server만 이용한다. Client로 부터 온 모든 ZNode Write 요청은 Leader Server에게 전달된다. Leader Server는 받은 ZNode Write 요청을 Request Processor에서 처리한다. 그 후 Atomic Broadcast를 통해 **Transaction**을 생성하여 ZNode Write 과정이 모든 Server에 올바르게 적용되도록 한다. ZNode 정보는 In-meomry DB에 저장된다. Local Filesystem에 In-memory DB의  Replication을 구성할 수 있다.

Client는 Server에게 주기적으로 PING을 전송하여 Client의 동작을 알려준다. Server는 일정시간 Client로 부터 PING을 받지 못하면 Client/Network Issue가 발생했다고 간주하고 해당 Session을 종료한다. Client는 Server로부터 PING 응답을 받지 못하면 Server/Network Issue가 발생했다고 간주하고 다른 Server에게 연결을 시도한다.

#### 1.2. ZNode

![]({{site.baseurl}}/images/theory_analysis/ZooKeeper/ZooKeeper_ZNode.PNG){: width="700px"}

ZooKeeper는 **ZNode** 단위로 Data 저장 및 계층을 생성한다. 위의 그림은 ZNode로 구성된 Data Model을 나타내고 있다. File System처럼 Root를 기준으로 Tree 형태로 ZNode가 구성된다. 각 ZNode는 Data(byte[])와 Child Node를 가질 수 있다.

ZNode는 **Persistent** Node와 **Ephemeral** Node로 구분된다. Persistent Node는 ZooKeeper Client가 

#### 1.3. Watcher

![]({{site.baseurl}}/images/theory_analysis/ZooKeeper/ZooKeeper_Watcher.PNG)

#### 1.4. Usage Example

### 2. 참조

* [https://www.slideshare.net/madvirus/zookeeper-34888385](https://www.slideshare.net/madvirus/zookeeper-34888385)
* [http://www.allprogrammingtutorials.com/tutorials/introduction-to-apache-zookeeper.php](http://www.allprogrammingtutorials.com/tutorials/introduction-to-apache-zookeeper.php)
* [https://www.slideshare.net/javawork/zookeeper-24265680](https://www.slideshare.net/javawork/zookeeper-24265680)
