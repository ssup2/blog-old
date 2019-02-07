---
title: Redis Master-slave, Cluster
category: Theory, Analysis
date: 2019-02-06T12:00:00Z
lastmod: 2019-02-06T12:00:00Z
comment: true
adsense: true
---

Redis Master-slave 및 Redis Cluster를 분석한다.

### 1. Redis Master-slave

![]({{site.baseurl}}/images/theory_analysis/Redis_Master_Slave_Cluster/Redis_Master-slave.PNG){: width="600px"}

Redis Master-slave는 Redis에서 제공하는 가장 기본적인 Replication 및 HA (High Availabilty) 기법이다. 위의 그림은 Redis Master-slave로 구성시 Architecture를 나타내고 있다. Redis의 Master-slave 기법은 MySQL의 Master-slave Replication 기법과 유사한점이 많다. 하나의 Master에 다수의 Slave가 붙을 수 있다. Master는 Read-Write Mode로 동작하고 Slave는 Read-Only Mode로 동작한다. Redis Client는 필요에 따라서 Master에 붙어 Write 동작을 수행하거나, 적절한 Master 또는 Slave에 붙어 Read 동작을 수행 할 수 있다.

**Master-slave 사이의 Replication은 Async 방식**을 이용한다. Master는 Data 변경시 변경 내용을 backlog에 기록한다. Slave는 Master에 접속하여 backlog의 내용을 바탕으로 Replication을 수행한다. Async 방식이기 때문에 Master에 저장된 Data가 Slave에는 잠깐동안 저장되지 않을 수 있다. 따라서 Redis Client (App)는 Slave에서 Data를 Read 할때 Async 특징을 반드시 고려해야한다.

Master가 죽을경우 Slave는 Master에게 주기적으로 Connection을 요청하며 Master가 되살아 날때까지 대기한다. Master가 살아나면 Slave는 Replication을 수행하여 Master와 동기화를 맞춘다. Master의 복구가 힘든경우 Redis 관리자는 Slave 중에서 하나를 수동으로 Master로 승격시키고, 나머지 Slave들을 새로운 Master로부터 Replication 하도록 설정 해야한다. Master가 바뀐뒤에는 죽었던 Master는 새로운 Master의 Slave로 설정하여 이용해야 한다.

#### 1.1. Sentinel

Master의 동작이 멈출경우 Redis Client는 Slave를 통해서 Read 동작을 수행 할 수 있지만, Write 동작을 수행 할 수 없다. 따라서 Master의 Downtime은 Redis Cluster의 가용성을 떨어트린다. 이러한 가용성 문제를 해결을 도와주는 App이 Sentinel이다. **Sentinel은 Master가 죽는지 감지하고 Master가 죽었을경우 Slave 중 하나를 Master로 승격시키고, 기존의 Master는 Slave로 강등시킨다.** Redis 관리자의 간섭없이 자동으로 이루어지기 때문에 Master의 Downtime을 최소화하여 HA를 가능하게 만든다.

Sentinel은 일반적으로 홀수개로 구성하여 Split-brain을 방지한다. 위의 그림에서는 Sentinal을 Redis와 별도의 Node에 구성하여 이용하는 모습을 나타내고 있지만, Sentinel을 Redis와 동일한 Node에 구성하여 이용하여도 문제없다. Sentinel 설정에는 Quorum이란 설정값이 존재한다. Quorum은 특정 Redis에 장애 발생시 몇개의 Sentinel이 특정 Redis의 장애 발생을 감지해야 장애라고 판별하는지를 결정하는 기준값이다. 예를들어 Quorum 값을 2로 설정하였을 경우, 2개 이상의 Sentienl이 특정 Redis에 장애가 발생하였다고 판별해야 Sentinel은 해당 Redis에 대한 장애 대응을 수행한다.

#### 1.2. HAProxy

Redis Master-slave 구성시 Master는 RW Mode로 동작하고 Slave는 RO Mode로 동작하기 때문에 Client는 Master의 IP/Port, Slave의 IP/Port를 각각 알고, 필요에 따라 적절한 Master 또는 Slave에 붙어 동작을 수행해야 한다. 따라서 Master의 장애 발생시 Master가 교체되면 그에 따라 Client의 Redis 설정도 바뀌어야 한다. 하지만 Master가 교체될때 마다 Redis를 이용하는 모든 Client의 설정을 바꾸는 일은 쉬운일이 아니다. 이러한 문제를 해결하기 위해서 일반적으로 HAProxy를 이용한다.

**Haproxy는 Client에게 Redis의 Master, Slave에 일정하게 접근 할 수 있는 End-point를 제공한다.** 위의 그림에서 Port X는 Master에게 접근 할 수 있는 Port를 나타내고 Port Y는 Slave에게 접근 할 수 있는 Port를 나타낸다. HAProxy는 tcp-check를 이용하여 주기적으로 각 Redis가 Master로 동작하는지 또는 Slave 동작하는지 파악하고 그에따라 동적으로 Routing Rule을 설정한다. 따라서 Master가 교체되어도 Haproxy는 일정한 End-point를 Client에게 제공 할 수 있다.

### 2. Redis Cluster

![]({{site.baseurl}}/images/theory_analysis/Redis_Master_Slave_Cluster/Redis_Cluster.PNG){: width="600px"}

### 3. 참조

* [https://www.letmecompile.com/redis-cluster-sentinel-overview/](https://www.letmecompile.com/redis-cluster-sentinel-overview/)
* Master-slave - [https://redis.io/topics/replication](https://redis.io/topics/replication)
* Sentinel - [https://redis.io/topics/sentinel](https://redis.io/topics/sentinel)
* Cluster - [https://redis.io/topics/cluster-spec](https://redis.io/topics/cluster-spec)
* Cluster - [http://redisgate.kr/redis/cluster/redis-cli-cluster.php](http://redisgate.kr/redis/cluster/redis-cli-cluster.php)

