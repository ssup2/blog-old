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

ZNode는 **Persistent Node**와 **Ephemeral Node**로 구분된다. Persistent Node는 Client가 종료되더라도 유지되는 Node이다. Ephemeral Node는 Client가 종료되면 사라지는 Node이고, Child를 가질 수 없다. 또한 ZNode는 **Sequence Node**와 일반 Node로 구분 할 수 있다. Sequence Node는 생성시 Node이름 뒤에 숫자가 붙으며, 숫자는 중복되지 않는다. Persistent Node와 Ephemeral Node 모두 Sequence Node가 될 수 있다.

Server의 Atomic Broadcast를 통해서 ZNode 생성/변경/삭제 동작은 Client 입장에서는 Sequence Consistency, Atomicity 특징을 보인다.

#### 1.3. Watcher

![]({{site.baseurl}}/images/theory_analysis/ZooKeeper/ZooKeeper_Watcher.PNG)

Watcher는 ZNode의 변경을 Client에게 먼져 알려주는 역활을 수행한다. Client는 먼져 특정 ZNode에 대해 Watcher를 등록한다. 그 후 해당 ZNode의 Data가 변경되거나, Child Node가 생성/삭제 될 경우 Client에게 변경되었다는 Event를 Client에게 전달한다.

#### 1.4. Usage Example

ZNode와 Watcher를 이용하여 분산 시스템 환경에서 필요한 다양한 기능을 구현 할 수 있다. 첫번째 그림을 통해서 ZooKeeper를 이용한 간단한 사용 예제를 설명한다.

##### 1.4.1. Machine 상태 확인

Ephemeral Node는 Ephemeral Node를 생성한 Client가 Server Cluster와 접속이 끊기면 사라지는 Node이다. 따라서 Ephemeral Node를 이용하여 각 Machine 상태를 쉽게 파악 할 수 있다.

* 각 Machine에 Client를 설치하고 Server Cluster에 연결한다.
* 연결된 Client는 첫번째 그림의 machine Node처럼 특정 Node아래 의 고유 ID를 이름으로하는 Ephemeral Node를 생성한다. 그 후 machine Node를 감지하기 위한 Watcher를 등록한다.
* Client의 연결이 종료되어 Ephemeral Node가 사라지면 machine Node Watcher를 등록한 모든 Client에게 Event를 전달한다.
* Event를 받은 Client는 다른 Client의 종료 정보를 통해 Machine의 종료 상태를 파악 할 수 있다.

##### 1.4.2. 분산 Lock

Sequence Node의 숫자는 중복되어 생성되지 않는 특징을 이용하여 분산 Lock을 구현 할 수 있다.

* 각 Node에 Client를 설치한다.
* Lock을 얻으려는 Client는 Server Cluster에 연결한 뒤 첫번째 그림의 lock Node처럼 특정 Node아래 Ephemeral/Sequence Node를 생성하고 생성된 Sequence 번호를 확인한다. 그 후 lock Node를 감지하기 위한 Watcher를 등록한뒤 대기한다.
* Watcher로 부터 Event가 오면 Client는 lock Node의 Child Node 중 Sequence 번호가 가장 작은 Node가 자신이 생성한 Sequence 번호와 일치 하는지 확인한다.
* 번호가 일치하면 해당 Client는 Lock을 획득한 뒤 연산을 수행한다. 연산 수행이 완료되면 연결을 끊는다.
* 연결이 끊기면 Ephemeral Node는 사라지기 때문에 lock Node Watcher는 다시 Event를 발생시켜 Client에게 전달한다.

### 2. 참조

* [https://www.slideshare.net/madvirus/zookeeper-34888385](https://www.slideshare.net/madvirus/zookeeper-34888385)
* [http://www.allprogrammingtutorials.com/tutorials/introduction-to-apache-zookeeper.php](http://www.allprogrammingtutorials.com/tutorials/introduction-to-apache-zookeeper.php)
* [https://www.slideshare.net/javawork/zookeeper-24265680](https://www.slideshare.net/javawork/zookeeper-24265680)
