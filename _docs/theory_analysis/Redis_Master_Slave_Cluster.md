---
title: Redis Master-Slave, Cluster
category: Theory, Analysis
date: 2019-02-06T12:00:00Z
lastmod: 2019-02-06T12:00:00Z
comment: true
adsense: true
---

Redis Master-Slave 및 Redis Cluster를 분석한다.

### 1. Redis Master-Slave

![]({{site.baseurl}}/images/theory_analysis/Redis_Master_Slave_Cluster/Redis_Master-Slave.PNG){: width="600px"}

Redis Master-Slave는 Redis에서 제공하는 가장 기본적인 Replication 및 HA (High Availabilty) 기법이다. 위의 그림은 Redis Master-Slave로 구성시 Architecture를 나타내고 있다. Redis의 Master-Slave 기법은 MySQL의 Master-Slave Replication 기법과 유사한점이 많다. 하나의 Master에 다수의 Slave가 붙을 수 있다. Master는 Read-Write Mode로 동작하고 Slave는 Read-Only Mode로 동작한다. Redis Client는 필요에 따라서 Master에 붙어 Write 동작을 수행하거나, 적절한 Master 또는 Slave에 붙어 Read 동작을 수행 할 수 있다.

**Master-Slave 사이의 Replication은 Async 방식**을 이용한다. Master는 Data 변경시 변경 내용을 backlog에 기록한다. Slave는 Master에 접속하여 backlog의 내용을 바탕으로 Replication을 수행한다. Async 방식이기 때문에 Master에 저장된 Data가 Slave에는 잠깐동안 저장되지 않을 수 있다. 따라서 Redis Client (App)는 Slave에서 Data를 Read 할때 Async 특징을 반드시 고려해야한다.

Master의 동작이 멈출경우 Slave는 Master에게 주기적으로 Connection을 요청하며 Master가 되살아 날때까지 대기한다. Master가 살아나면 Slave는 Replication을 수행하여 Master와 동기화를 맞춘다. 아니면 Redis 관리자는 Slave 중에서 하나를 수동으로 Master로 승격시키고, 나머지 Slave들을 새로운 Master로부터 Replication 하도록 설정 해야한다. Master의 동작이 멈출경우 Redis Client는 Slave를 통해서 Read 동작을 수행 할 수 있지만, Write 동작을 수행 할 수 없다. 따라서 Master의 Downtime은 Redis Cluster의 가용성을 떨어트린다. 이러한 가용성 문제를 해결을 도와주는 Daemon이 Sentinel이다.

### 2. Redis Cluster

![]({{site.baseurl}}/images/theory_analysis/Redis_Master_Slave_Cluster/Redis_Cluster.PNG){: width="600px"}

### 3. 참조

* [https://www.letmecompile.com/redis-cluster-sentinel-overview/](https://www.letmecompile.com/redis-cluster-sentinel-overview/)
* Master-Slave - [https://redis.io/topics/replication](https://redis.io/topics/replication)
* Sentinel - [https://redis.io/topics/sentinel](https://redis.io/topics/sentinel)
* Cluster - [https://redis.io/topics/cluster-spec](https://redis.io/topics/cluster-spec)
* Cluster - [http://redisgate.kr/redis/cluster/redis-cli-cluster.php](http://redisgate.kr/redis/cluster/redis-cli-cluster.php)

