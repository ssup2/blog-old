---
title: Redis Master-slave, Cluster
category: Theory, Analysis
date: 2019-02-10T12:00:00Z
lastmod: 2019-02-10T12:00:00Z
comment: true
adsense: true
---

Redis Master-slave 및 Redis Cluster를 분석한다.

### 1. Redis Master-slave

![[그림 1] Redis Master-slave]({{site.baseurl}}/images/theory_analysis/Redis_Master_Slave_Cluster/Redis_Master-slave.PNG){: width="600px"}

Redis Master-slave는 Redis에서 제공하는 가장 기본적인 Replication 기법이다. [그림 1]은 Redis Master-slave 구성시 Architecture를 나타내고 있다. Redis의 Master-slave 기법은 MySQL의 Master-slave Replication 기법과 유사한점이 많다. 하나의 Master에 다수의 Slave가 붙을 수 있다. Master는 Read-Write Mode로 동작하고 Slave는 Read-Only Mode로 동작한다. Client는 필요에 따라서 Master에 붙어 Write 동작을 수행하거나, 적절한 Master 또는 Slave에 붙어 Read 동작을 수행 할 수 있다.

**Master-slave 사이의 Replication은 Async 방식**을 이용한다. Master는 Data 변경시 변경 내용을 backlog에 기록한다. Slave는 Master에 접속하여 backlog의 내용을 바탕으로 Replication을 수행한다. Async 방식이기 때문에 Master에 저장된 Data가 Slave에는 잠깐동안 저장되지 않을 수 있다. 따라서 Client (App)는 Slave에서 Data를 Read 할때 Async 특징을 반드시 고려해야한다.

Master가 죽을경우 Slave는 Master에게 주기적으로 Connection을 요청하며 Master가 되살아 날때까지 대기한다. Master가 살아나면 Slave는 Replication을 수행하여 Master와 동기화를 맞춘다. Master의 복구가 힘든경우 Redis 관리자는 Slave 중에서 하나를 수동으로 Master로 승격시키고, 나머지 Slave들을 새로운 Master로부터 Replication 하도록 설정 해야한다. Master가 바뀐뒤에는 죽었던 Master는 새로운 Master의 Slave로 설정하여 이용해야 한다.

#### 1.1. Sentinel

Master의 동작이 멈출경우 Client는 Slave를 통해서 Read 동작을 수행 할 수 있지만, Write 동작을 수행 할 수 없다. 따라서 Master의 Downtime은 Redis Cluster의 가용성을 떨어트린다. 이러한 가용성 문제를 해결을 도와주는 App이 Sentinel이다. **Sentinel은 Master가 죽는지 감지하고 Master가 죽었을경우 Slave 중 하나를 Master로 승격시키고, 기존의 Master는 Slave로 강등시킨다.** Redis 관리자의 간섭없이 자동으로 이루어지기 때문에 Master의 Downtime을 최소화하여 HA (High Availabilty)를 가능하게 만든다.

Sentinel은 일반적으로 홀수개로 구성하여 Split-brain을 방지한다. [그림 1]에서는 Sentinal을 Redis와 별도의 Node에 구성하여 이용하는 모습을 나타내고 있지만, Sentinel을 Redis와 동일한 Node에 구성하여 이용하여도 문제없다. Sentinel 설정에는 Quorum이란 설정값이 존재한다. Quorum은 특정 Redis에 장애 발생시 몇개의 Sentinel이 특정 Redis의 장애 발생을 감지해야 장애라고 판별하는지를 결정하는 기준값이다. 예를들어 Quorum 값을 2로 설정하였을 경우, 2개 이상의 Sentienl이 특정 Redis에 장애가 발생하였다고 판별해야 Sentinel은 해당 Redis에 대한 장애 대응을 수행한다.

#### 1.2. HAProxy

Redis Master-slave 구성시 Master는 RW Mode로 동작하고 Slave는 RO Mode로 동작하기 때문에 Client는 Master의 IP/Port, Slave의 IP/Port를 각각 알고, 필요에 따라 적절한 Master 또는 Slave에 붙어 동작을 수행해야 한다. 따라서 Master의 장애 발생시 Master가 교체되면 그에 따라 Client의 Redis 설정도 바뀌어야 한다. 하지만 Master가 교체될때 마다 Redis를 이용하는 모든 Client의 설정을 바꾸는 일은 쉬운일이 아니다. 이러한 문제를 해결하기 위해서 일반적으로 HAProxy를 이용한다.

**Haproxy는 Client에게 Redis의 Master, Slave에 일정하게 접근 할 수 있는 End-point를 제공한다.** [그림 1]에서 Port X는 Master에게 접근 할 수 있는 Port를 나타내고 Port Y는 Slave에게 접근 할 수 있는 Port를 나타낸다. HAProxy는 tcp-check를 이용하여 주기적으로 각 Redis가 Master로 동작하는지 또는 Slave 동작하는지 파악하고 그에따라 동적으로 Routing Rule을 설정한다. 따라서 Master가 교체되어도 Haproxy는 일정한 End-point를 Client에게 제공 할 수 있다. HAProxy를 하나만 구성하면 HAProxy로 HAProxy가 죽을경우 SPOF(Single Point of Failure)가 발생하여 Redis의 HA를 방해한다. 따라서 L4 Load Balancer 및 VRRP를 이용하여 다수의 HAProxy를 하나의 HAProxy 처럼 보이도록 Client에게 제공해야 한다.

### 2. Redis Cluster

![[그림 2] Redis Cluster]({{site.baseurl}}/images/theory_analysis/Redis_Master_Slave_Cluster/Redis_Cluster.PNG){: width="600px"}

Redis Cluster는 Redis에서 제공하는 Replication 및 Sharding 기법이다. [그림 2]는 Redis Cluster 구성시 Architecture를 나타내고 있다. Cluster를 구성하는 각 Redis는 다른 모든 Redis들과 직접 연결하여 gossip Protocol을 통해 통신한다. gossip Protocol을 통해서 각 Redis는 Redis 상태 정보를 교환한다. gossip Protocl은 Cluster Client가 이용하는 Port번호보다 10000이 높은 번호를 Port로 이용한다. Cluster Client가 이용하는 기본 Port 번호는 6379를 이용하기 때문에 gossip Protocol이 이용하는 기본 Port번호는 16379가 된다. Cluster Client 또한 Cluster를 구성하는 모든 Redis와 직접 연결하여 Data를 주고 받는다.

Redis Cluster는 Multi-master, Multi-slave 구조를 갖으며 각 Redis는 Master 또는 Slave로 동작한다. 각 Master는 **Hash Slot**이라는 Data 저장구역을 다른 Master와 나누어 소유한다. Hash Slot은 0부터 16384까지의 주소를 가지고 있다. [그림 2]는 각 Master가 Hash Slot을 3개로 균등하게 분활해서 구성한 모습을 나타내고 있다. Data가 이용할 Hash Slot은 Data의 Key를 Hashing한 결과값을 이용한다. Hashing은 CRC16 및 Moduler 연산자를 이용하여 Data가 각 Hash Slot에 균등하게 배분되도록 한다. 따라서 Data는 각 Master의 Hash Slot의 크기에 비례하여 Data를 저장하게 된다.

각 Master에 할당한 Hash Slot은 Redis 관리자에 의해서 동적으로 변경이 가능하다. 따라서 동적으로 Master를 추가하거나 제거하는것도 가능하다. 각 Master는 다수의 Slave를 갖을 수 있다. [그림 2]에서는 각 Master가 하나의 Slave를 갖고 있는 모습을 나타내고 있다. **Master와 Slave사이의 Replication은 Redis Master-slave 구성과 동일하게 Async 방식으로 이루어진다.** 따라서 Slave도 동적으로 자유롭게 추가하거나 제거하는것이 가능하다.

Master Redis가 죽을경우 죽은 Master의 Slave Redis는 gossip Protocol을 통해서 Master의 죽음을 파악한뒤 스스로 Master로 승격하여 Master를 대신한다. 그 후 죽은 Master가 살아나서 동작하는 경우 스스로 Slave로 강등하여 동작한다. Master와 Slave사이의 Replication은 Async 방식으로 이루어지기 때문에 Master의 죽음은 Master와 Slave 사이의 Data 정합성을 깰 수 있다. 깨진 Data 정합성으로 인해서 Master와 Slave 사이의 Data 충돌이 발생하는 경우 무조건 **나중에 Master가 된 Data를 기준으로 정합성을 맞춘다.**

#### 2.1. Cluster Client

Cluster Client는 Redis Cluster와 처음 Connection을 맺을시 Redis Cluster를 구성하는 각 Redis의 상태 정보를 얻어온다. 상태 정보에는 IP, Port, Master/Slave Mode, 할당된 Hash Slot 등이 포함되어 있다. **Cluster Client는 Redis Cluster로부터 얻은 상태 정보를 바탕으로 Redis Cluster를 구성하는 모든 Redis와 직접 Connection을 맺는다.** 그 후 Cluster Client는 Data의 Key를 바탕으로 Data가 Read/Write될 Hash Slot을 직접 계산한뒤, Hash Slot이 할당된 Redis에게 직접 Read/Wrtie를 수행한다.

만약 Hashslot의 배치가 바뀌어 Cluster Client가 Read/Write 요청을 잘못된 Redis에게 전달하면, 요청을 받은 Redis는 요청을 처리할 수 있는 Redis의 접속 정보 및 **MOVED 명령어**를 전달하여 요청을 Redirection 한다. Cluster Client는 MOVED 명령어와 함께온 접속 정보를 바탕으로 요청을 처리할 수 있는 Redis에게 다시 요청을 전달한다. 예를들어 Slave Redis에게 Write 요청을 보내면 Slave Redis는 해당 요청을 처리 할 수 있는 Master Redis의 정보를 Cluster Client에게 넘겨준다. 일반적으로 Cluster Client는 MOVED 명령어를 받으면 Cluster로부터 Cluster 상태 정보를 다시 받아 Hashslot 및 Redis 접속 정보를 갱신한다. 이처럼 Cluster Client는 Redis Cluster로부터 얻은 상태 정보 및 MOVED 명령어를 처리 할 수 있어야하기 때문에, 기존의 Redis Master-slave Library를 그대로 이용하면 안되고 Redis Cluster를 위한 Library를 이용해야한다.

일반적으로 Redis Cluster의 Slave Redis는 자신이 처리 할 수 있는 Read 요청을 받아도 자신의 Master에게 해당 Read 요청을 Redirection 한다. 오직 **READONLY** 명령어를 통해서 Read Mode로 진입한 Client으로부터 오는 Read 요청만 Slave Redis에서 처리할 수 있다.

#### 2.2. Cluster Proxy

위에서 언급한것 처럼 Redis Cluster의 Cluster Client는 Cluster를 구성하는 모든 Redis와 Network로 직접 연결되어 있어야 한다는 특징을 갖고 있다. 즉 Redis Cluster의 각 Redis는 Cluster Client를 위한 End-point를 반드시 하나이상 갖고 있어야 한다. 이러한 특징 때문에 Cluster를 구성하는 Redis의 개수 또는 Cluster Client의 개수가 늘어날수록 Network Connection은 기하급수적으로 늘어난다. 또한 Redis Master-slave의 Client에게 Master, Slave 2개의 End-point만을 제공하던 Network 환경에 Redis Cluster 구성을 힘들게하는 요인이 된다. 이러한 문제점들을 해결하기 위해서는 Cluster Proxy를 이용해야 한다.

Cluster Proxy는 Proxy Client에게 일정한 End-point를 제공한다. Cluster Proxy에는 corvus, predixy 같은 Application이 있다. Cluster Proxy는 요청 Redirection 같은 Redis Cluster만을 위한 추가적인 동작이 필요하기 때문에 HAProxy같은 범용 Proxy를 Cluster Proxy로 이용하지 못한다. Redis Master-slave의 HAProxy 처럼 다수의 Cluster Proxy를 L4 Load Balancer 및 VRRP를 이용하여 Cluster Proxy의 HA를 보장하도록 구성하는 것이 좋다.

### 3. 참조

* [https://www.letmecompile.com/redis-cluster-sentinel-overview/](https://www.letmecompile.com/redis-cluster-sentinel-overview/)
* Master-slave : [https://redis.io/topics/replication](https://redis.io/topics/replication)
* Sentinel : [https://redis.io/topics/sentinel](https://redis.io/topics/sentinel)
* Cluster : [https://redis.io/topics/cluster-spec](https://redis.io/topics/cluster-spec)
* Cluster : [http://redisgate.kr/redis/cluster/redis-cli-cluster.php](http://redisgate.kr/redis/cluster/redis-cli-cluster.php)
