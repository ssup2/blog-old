---
title: Memcached
category: Theory, Analysis
date: 2019-02-25T12:00:00Z
lastmod: 2019-02-25T12:00:00Z
comment: true
adsense: true
---

다양한 System에서 분산 Cache로 많이 이용되고 있는 Memcached를 분석한다.

### 1. Memcached

Memcached는 의미 그대로 다양한 Data의 **Caching을 위해 설계된 분산 Key-Value Storage**이다. Caching 
System의 핵심은 Data의 빠른 Read/Write 성능이다. 따라서 Memcached도 Data의 빠른 Read/Write 성능에 중점을 두고있다. Memcached는 Data 저장시 Disk를 이용하지 않고 오직 **Memory**만 이용하여 Data의 Read/Write 성능을 극대화 하고 있다. Memory에만 Data가 저장되어 있기 때문에 Data는 언제든지 유실 될 수 있지만, Caching System에서 Data 유실은 치명적이지 않기 때문에 크게 문제되지 않는다. Memcached는 Client와 통신시 Text Protocol과 Binary Protocol 둘다 지원하지만 성능을 위해서는 Binary Procotol을 이용하는 것이 좋다.

#### 1.1. Cluster

![[그림 1] Memcached Cluster]({{site.baseurl}}/images/theory_analysis/Memcached/Memcached_Cluster.PNG){: width="500px"}

Memcached는 일반적으로 Cluster를 구성하여 이용된다. [그림 1]은 Memcached의 Cluster를 나타내고 있다. Memcached Cluster는 엄밀히 말하면 Cluster라고 보기는 힘들다. Memcached는 서로 어떠한 Data도 주고 받지 않고, 오직 Client의 요청에 따라 Data를 Read/Write하는 단순한 동작만 수행하기 때문에다. Memcached 사이의 Data 분배, Cluster를 구성하는 각 Memcached 상태 파악의 등 Cluster 관련 기능은 대부분 Client Lib (Library)에서 수행된다. 따라서 Memcached Cluster 기능은 Client Lib에 따라 결정된다.

일반적으로 Client Lib은 단순한 Hashing을 이용하여 Data를 분배한다. 또한 Client Lib은 모든 Memcached와 Session을 맺고 있는데, Client Lib은 Session의 상태를 통해서 각 Memcached의 상태를 파악한다. 만약 특정 Memcached가 죽어 Session이 끊긴 경우, Client Lib은 Session이 끊긴 Memcached를 제외하고 Data 분배를 수행한다. 이러한 Data 분배, Memcached의 상태 확인 동작은 각 Client Lib마다 독립적으로 수행된다. 따라서 Client Lib은 다른 Client Lib과 상호작용 하지 않는다. 

### 2. 참조

* [https://www.slideshare.net/AmazonWebServices/dat207](https://www.slideshare.net/AmazonWebServices/dat207)