---
title: Elasticsearch Shard, Replica
category: Theory, Analysis
date: 2020-05-05T12:00:00Z
lastmod: 2020-05-05T12:00:00Z
comment: true
adsense: true
---

Elasticsearch의 Shard, Replica 관련 내용을 분석한다.

### 1. Elasticsearch Shard, Replica

![[그림 1] Shard, Replica Recovery]({{site.baseurl}}/images/theory_analysis/Elasticsearch_Shard_Replica/Elasticsearch_Shard_Replica.PNG){: width="600px"}

[그림 1]는 Elastic Search에서 관리하는 Shard와 Replica를 나타낸다. 원본 Shard를 Primary Shard 라고 명칭하며 Primary Shard의 복제본을 Replica라고 명칭한다. [그림 1]에서는 Shard의 개수는 5개, Replica의 개수는 1개인 Index를 나타내고 있다. Shard와 Replica는 모두 **Index 단위**로 설정이 가능하며, Shard의 개수는 Index가 생성 될때만 설정이 가능하고 Index가 생성된 이후에는 변경이 불가능하다. Replica의 개수는 자유롭게 변경이 가능하다. Elasticsearch 6.0 이하 Version에서는 Default Shard는 5이고 Default Replica는 1이다. Elasticsearch 7.0 이상 Version에서는 Default Shard는 1이고 Default Replica는 1이다.

[그림 1]에서는 Data Node에 장애가 발생하였을때 Shard, Replica의 복구 과정도 나타내고 있다. Data Node C에서 장애가 발생할 경우, Data Node C에는 1번 Primary Shard가 존재하고 있었기 때문에 Data Node D에 있던 1번 Replica는 Primary Shard가 된다. 그 후 Replica 개수 1개를 맞추기 위해서 Data Node D에 있는 1번 Primary Shard를 1번 Replica가 존재하지 않는 Data Node B에 복제되었다. Data Node C에는 4번 Replica가 존재하고 있었기 때문에, Replica 개수 1개를 맞추기 위해서 Data Node B에 있는 4번 Primary Shard는 4번 Replica가 존재하지 않는 Data Node D에 복제되었다.

### 2. 참조

* [https://esbook.kimjmin.net/03-cluster/3.2-index-and-shards](https://esbook.kimjmin.net/03-cluster/3.2-index-and-shards)
* [https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-replication.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-replication.html)
* [https://nesoy.github.io/articles/2019-01/ElasticSearch-Document](https://nesoy.github.io/articles/2019-01/ElasticSearch-Document)