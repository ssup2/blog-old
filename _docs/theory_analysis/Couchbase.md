---
title: Couchbase
category: Theory, Analysis
date: 2019-05-01T12:00:00Z
lastmod: 2019-05-01T12:00:00Z
comment: true
adsense: true
---

Couchbase를 분석한다.

### 1. Couchbase

![[그림 1] Document-Node Mapping]({{site.baseurl}}/images/theory_analysis/Couchbase/Document_Node_Mapping.PNG){: width="700px"}

Couchbase는 JSON처럼 계층을 이루는 Key-Value Data를 저장하는 Document-Oriented DB이다. [그림 1]은 Couchbase가 관리하는 Document가 Node에 어떻게 Mapping 되는지를 나타내고 있다. Couchbase의 Document는 **Bucket**이라고 불리는 Document Group에 위치한다. Document는 Document의 Key를 CRC32 Hashing 알고리즘을 통해서 **vBucket**이라고 불리는 Shard에 분리되어 저장된다. Couchbase는 vBucket 단위로 Replication, Rebalancing을 수생한다. vBucket은 각 Bucket마다 1024개씩 존재한다. vBucket은 다시 vBucket-Node Map을 통해서 Couchbase Cluster를 구성하고 있는 특정 Node로 Mapping된다.

Couchbase는 Memcached를 기반으로하는 **Built-in Cache**를 갖고 있다. 대부분의 Data관련 동작은 Built-in Cache, 즉 Memory에서 수행되기 때문에 빠른 Data 처리가 가능하다. Built-in Cache에 저장되거나 변경된 Data는 Disk에 비동기적으로 기록될 수 있도록 설계되어 있다. Couchbase는 Built-in Cache를 활용하여 기존의 Memcached를 Couchbase로 대체할 수 있도록 Memcached 호환 기능도 제공한다.

#### 1.1. Bucket

Bucket은 Couchbase에서 관리하는 Document Group이다. 하나의 CouchBase Cluster에 여러개의 Bucket이 존재할 수 있으며, 각 Bucket마다 Resource 사용량을 제한할 수 있다. Bucket에는 Couchbase, Ephemeral, Memcached 3가지 Type이 존재한다.

* Couchbase - memory + disk를 이용하는 Bucket Type이다. Data는 Memory와 Disk에 저장되며, Memory가 가득찬 경우 Memory에 Data는 덮어씌워 진다. 하지만 Data는 Disk에 남아있기 때문에 Data의 손실로 이어지지는 않는다. Replication, Rebalancing을 지원한다.

* Ephemeral - memory만 이용하는 Bucket Type이다. Data는 Memory에만 저장되며, Memory가 가득찬 경우 기존의 Data는 덮어씌워진다. 이는 곧 Data의 손실로 이어진다. Replication, Rebalancing을 지원한다.

* Memcached - memory만 이용하는 방식이다. memcached처럼 Ketama consistent hashing을 이용하여 Data를 저장한다. Replication, Rebalancing을 지원하지 않는다.

#### 1.2. Replication

Couchbase의 Replica는 오직 HA를 위해서 존재한다. Replica는 Failover로 인하여 Active 상태가 되기전까지 다른 Client에게 제공되지 않는다. Couchbase Cluster는 Client의 Write 동작에 대하여 다음과 같은 4가지 ACK 옵션을 제공한다.

* Memory - Data가  Memroy에 저장되면 ACK를 전송한다.
* Memory, Disk - Data가 Primary Node의 Memory와 Disk에 저장되면 ACK를 전송한다.
* Memory, Replica - Data가 Primary Node의 Memory, Secondary Node의 Memory에 저장되면 ACK를 전송한다.
* Memory, Disk, Replica - Data가 Primary Node의 Memory와 Disk, Secondary Node의 Memory에 저장되면 ACK를 전송한다.

### 2. 참조

* [https://docs.couchbase.com/server/5.0/architecture/core-data-access-buckets.html](https://docs.couchbase.com/server/5.0/architecture/core-data-access-buckets.html)
* [https://docs.couchbase.com/server/6.0/learn/buckets-memory-and-storage/vbuckets.html](https://docs.couchbase.com/server/6.0/learn/buckets-memory-and-storage/vbuckets.html)
* [https://docs.couchbase.com/server/4.1/concepts/data-management.html](https://docs.couchbase.com/server/4.1/concepts/data-management.html)
