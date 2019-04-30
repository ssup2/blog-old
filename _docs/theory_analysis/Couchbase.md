---
title: Couchbase
category:
date: 2019-05-01T12:00:00Z
lastmod: 2019-05-01T12:00:00Z
comment: true
adsense: true
---

Couchbase를 분석한다.

### 1. Couchbase

Couchbase는 Document-Oriented DB이다. Couchbase의 가장 큰 특징은 **Built-in Cache**이다. 대부분의 Data관련 동작은 Memory에서 수행되며 Disk에 저장은 나중에 수행된다.

NoSQL Document-Oriented DB이다.
Built-in Cache가 존재하며 대부분의 동작은 Built-in Cache에서 이루어진다.
Memcached와 100% 호환이 가능하다.

CouchBase는 Bucket이라는 Key-value Group 기능을 제공한다.
하나의 CouchBase에 여러개의 Bucket이 존재할 수 있으며, Bucket마다 Resource 사용량을 제한할 수 있다.
Couchbase, Ephemeral, Memcached 3가지 Type이 존재한다.
Couchbase - memory + disk를 이용하는 방식이다. Data는 Memory와 Disk에 저장되며, Memory가 가득찬 경우 Memory에서는 Data가 지워저도 Disk에는 Data가 남아있기 때문에 Data 손실이 발생하지 않는다. Replication, Rebalancing을 지원한다.
Ephemeral - memory만 이용하는 방식이다. Data는 Memory에만 저장되며, Memory가 가득찬 경우 기존의 Data는 덮어씌워지기 때문에 Data 손실이 발생한다. Replication, Rebalancing을 지원한다.
Memcached - memory만 이용하는 방식이다. memcached처럼 Ketama consistent hashing을 이용하여 Data를 저장한다. Replication, Rebalancing을 지원하지 않는다.
1.1.2. vBuckets
Couchbase는 Bucket을 다시 vBucket이라고 불리는 Shard 단위로 쪼개어 Bucket을 관리한다.
Couchbase User모르게 Couchbase는 vBucket 단위로 Replication, Rebalancing 등을 수행한다.
CouchBase Cluster는 Memcached Cluster가 제공하지 못하는 Data Replication 및 HA 기능을 제공한다.
CouchBase Cluster는 Memcached Cluster가 제공하지 못하는 Data Rebalancing 기능을 제공한다.
Memecached의 경우 할당받은 Memory 공간이 가득차 있을경우 기존의 Data를 지우고 새로운 Data를 쓰는 형태이지만, CouchBase는 Memory (Cache) 공간이 가득차 있을경우 기존의 Data를 Disk에 써서 보관하고, 새로운 Data를 Cache에 쓴다.
Memcached Client : Application Layer에서는 그대로 Memcached Client를 이용한다. CouchBase Node의 Proxy Server를 이용하여 Key-Value Data를 vBucket에 Mapping하는 작업을 진행한다. ( * 그림 오류 : Memcached Client는 11211 Port로 접속한다. / 현재 Deprecated)
Memcached Client + Local Proxy : Application Layer에서는 그대로 Memcached Client를 이용하지만 Memcached Client는 CouchBase가 아닌 Local Proxy에 접속한다. Local Proxy에서는 Key-Value Data를 vBucket에 Mapping하는 작업을 진행한다.
Couchbase Client : Application Layer에서는 Memcached Client 대신 Couchbase Client를 이용한다. Couchbase Client는 Key-Value Data를 vBucket에 Mapping하는 작업을 진행한다.
Memcached → Couchbase 변환 역활을 수행하는 Proxy는 일반적으로 moxi를 이용한다.

### 2. 참조

* [https://docs.couchbase.com/server/5.0/architecture/core-data-access-buckets.html](https://docs.couchbase.com/server/5.0/architecture/core-data-access-buckets.html)
* [https://forums.couchbase.com/t/moxi-with-memcached-bucket/18438](https://forums.couchbase.com/t/moxi-with-memcached-bucket/18438)
