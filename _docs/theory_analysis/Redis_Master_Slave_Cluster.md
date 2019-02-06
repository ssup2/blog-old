---
title: Redis Master-Slave, Cluster
category: Theory, Analysis
date: 2019-02-06T12:00:00Z
lastmod: 2019-02-06T12:00:00Z
comment: true
adsense: true
---

Redis Master-Slave 및 Redis Cluster를 분석한다.

### 1. Master-Slave

![]({{site.baseurl}}/images/theory_analysis/Redis_Master_Slave_Cluster/Redis_Master-Slave.PNG){: width="600px"}

Redis Master-Slave는 Redis에서 제공하는 가장 기본적인 Replication 및 HA (High Availabilty) 기법이다. 위의 그림은 Redis Master-Slave로 구성시 Architecture를 나타내고 있다.

### 2. Cluster

![]({{site.baseurl}}/images/theory_analysis/Redis_Master_Slave_Cluster/Redis_Cluster.PNG){: width="600px"}

### 3. 참조

* [https://www.letmecompile.com/redis-cluster-sentinel-overview/](https://www.letmecompile.com/redis-cluster-sentinel-overview/)
* Master-Slave - [https://redis.io/topics/replication](https://redis.io/topics/replication)
* Sentinel - [https://redis.io/topics/sentinel](https://redis.io/topics/sentinel)
* Cluster - [https://redis.io/topics/cluster-spec](https://redis.io/topics/cluster-spec)
* Cluster - [http://redisgate.kr/redis/cluster/redis-cli-cluster.php](http://redisgate.kr/redis/cluster/redis-cli-cluster.php)

