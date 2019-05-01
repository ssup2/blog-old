---
title: Couchbase Memcached 호환
category:
date: 2019-05-01T12:00:00Z
lastmod: 2019-05-01T12:00:00Z
comment: true
adsense: true
---

Couchbase를 분석한다.

### 1. Couchbase

![[그림 1] Document-Node Mapping]({{site.baseurl}}/images/theory_analysis/Couchbase_Memcached_Compatible/Couchbase_Memcached_Compatible.PNG){: width="600px"}

CouchBase Cluster는 Memcached Cluster가 제공하지 못하는 Data Replication 및 HA 기능을 제공한다.
CouchBase Cluster는 Memcached Cluster가 제공하지 못하는 Data Rebalancing 기능을 제공한다.

Memecached의 경우 할당받은 Memory 공간이 가득차 있을경우 기존의 Data를 지우고 새로운 Data를 쓰는 형태이지만, CouchBase는 Memory (Cache) 공간이 가득차 있을경우 기존의 Data를 Disk에 써서 보관하고, 새로운 Data를 Cache에 쓴다.

### 2. 참조

* [https://forums.couchbase.com/t/moxi-with-memcached-bucket/18438](https://forums.couchbase.com/t/moxi-with-memcached-bucket/18438)
