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

![[그림 1] Document-Node Mapping]({{site.baseurl}}/images/theory_analysis/Couchbase/Document_Node_Mapping.PNG){: width="700px"}

Couchbase는 JSON처럼 계층을 이루는 Key-Value Data를 저장하는 Document-Oriented DB이다. [그림 1]은 Couchbase가 관리하는 Document가 Node에 어떻게 Mapping 되는지를 나타내고 있다.

Couchbase의 가장 큰 특징은 Memory에서 구동되는 **Built-in Cache**이다. 대부분의 Data관련 동작은 Built-in Cache, 즉 Memory에서 수행되기 때문에 빠른 Data 처리가 가능하다. Built-in Cache에 저장되거나 변경된 Data는 Disk에 비동기적으로 기록될 수 있도록 설계되어 있다.

NoSQL Document-Oriented DB이다.
Built-in Cache가 존재하며 대부분의 동작은 Built-in Cache에서 이루어진다.
Memcached와 100% 호환이 가능하다.

Couchbase는 Bucket을 다시 vBucket이라고 불리는 Shard 단위로 쪼개어 Bucket을 관리한다.
Couchbase User모르게 Couchbase는 vBucket 단위로 Replication, Rebalancing 등을 수행한다.

#### 1.1. Bucket

CouchBase는 Bucket이라는 Key-value Group 기능을 제공한다.
하나의 CouchBase에 여러개의 Bucket이 존재할 수 있으며, Bucket마다 Resource 사용량을 제한할 수 있다.

* Couchbase - memory + disk를 이용하는 방식이다. Data는 Memory와 Disk에 저장되며, Memory가 가득찬 경우 Memory에서는 Data가 지워저도 Disk에는 Data가 남아있기 때문에 Data 손실이 발생하지 않는다. Replication, Rebalancing을 지원한다.

* Ephemeral - memory만 이용하는 방식이다. Data는 Memory에만 저장되며, Memory가 가득찬 경우 기존의 Data는 덮어씌워지기 때문에 Data 손실이 발생한다. Replication, Rebalancing을 지원한다.

* Memcached - memory만 이용하는 방식이다. memcached처럼 Ketama consistent hashing을 이용하여 Data를 저장한다. Replication, Rebalancing을 지원하지 않는다.

#### 1.2. Replication

### 2. 참조

* [https://docs.couchbase.com/server/5.0/architecture/core-data-access-buckets.html](https://docs.couchbase.com/server/5.0/architecture/core-data-access-buckets.html)
* [https://docs.couchbase.com/server/6.0/learn/buckets-memory-and-storage/vbuckets.html](https://docs.couchbase.com/server/6.0/learn/buckets-memory-and-storage/vbuckets.html)
