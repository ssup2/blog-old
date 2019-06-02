---
title: Couchbase Memcached 호환
category: Theory, Analysis
date: 2019-05-03T12:00:00Z
lastmod: 2019-05-03T12:00:00Z
comment: true
adsense: true
---

Couchbase의 Memcached 호환 기능을 분석한다.

### 1. Couchbase Memcached 호환

![[그림 1] Couchbase와 Moxi를 이용한 Memcached 호환]({{site.baseurl}}/images/theory_analysis/Couchbase_Memcached_Compatible/Couchbase_Memcached_Compatible.PNG){: width="600px"}

Couchbase는 기존의 Memcached를 Couchbase로 대체할 수 있도록 하는 Memcached 호환 기능을 제공한다. 기존의 Memcached Cluster를 Couchbase Cluster로 교체하면 Data 처리 성능은 떨어지지만, Memcached Cluster가 제공하지 못하는 Data Replication, HA, Data Rebalancing 기능을 이용할 수 있게 된다. 또한 Couchbase Type Bucket을 이용하면 Memcached에서 모든 메모리 공간을 이용할때 Data 덮어쓰기로 인해 발생하는 Data 손실도 방지할 수 있다.

[그림 1]은 Couchbase와 Moxi를 이용하여 기존의 Memcached를 대체하는 방법을 나타내고 있다. Couchbase Library, Server Side Moxi, Client Side Moxi 3가지 방법을 제공한다. **Moxi**는 Memcached Client와 Couchbase Server 사이에서 Memcached Procotol을 Couchbase Protocol로 변환하는 작업을 수행하는 Proxy 서버이다.

* Couchbase Library : 기존의 Memecached Library를 Couchbase Library로 변경하는 방법이다. 성능 저하를 최소화 할 수 있지만 기존의 Application을 수정해야하는 단점을 갖고 있다.

* Server Side Moxi : Server Node에 Moxi를 구동하여 Memcached Procotol을 Couchbase Protocol로 변경하는 방법이다. SPOF (Single point of failure) 문제로 인하여 현재는 권장하지 않는 방법이다.

* Client Side Moxi : Client Node에 Moxi를 구동하여 Memcached Procotol을 Couchbase Protocol로 변경하는 방법이다. Memcached Library가 Server Node의 Memcacehd가 아닌 Client Node의 Moxi에 접속하도록 Appliation을 수정해야 한다.

### 2. 참조

* [https://forums.couchbase.com/t/moxi-with-memcached-bucket/18438](https://forums.couchbase.com/t/moxi-with-memcached-bucket/18438)
