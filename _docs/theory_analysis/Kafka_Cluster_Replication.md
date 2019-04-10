---
title: Kafka Cluster, Replication
category: 
date: 2019-04-15T12:00:00Z
lastmod: 2019-04-15T12:00:00Z
comment: true
adsense: true
---

Kafka의 Cluster, Replication 기법을 분석한다.

### 1. Kafka Cluster

### 2. Kafka Replication

Kafka는 Partition Replication을 지원한다. [그림 4]는 3개의 Replica를 설정하였을때의 Partition을 나타내고 있다. Partition은 한개의 Leader와 다수의 Follower로 구성된다. Producer와 Consumer는 Leader Partition에만 Message를 Read/Write 한다. 따라서 Kafka는 Leader Partition의 분산을 통해 Load balancing을 수행한다. [그림 4]에서 각 Kafka Broker는 균등하게 2개의 Leader Partition을 갖고 있는것을 알 수 있다. Follower Partition들은 Leader Partition의 내용을 그대로 복사해온다. 복사 방식은 Sync 방식, Async 방식 둘다 지원한다.

### 3. 참조

* [https://www.tutorialspoint.com/apache_kafka/apache_kafka_cluster_architecture.htm](https://www.tutorialspoint.com/apache_kafka/apache_kafka_cluster_architecture.htm)
* [https://medium.com/@durgaswaroop/a-practical-introduction-to-kafka-storage-internals-d5b544f6925f](https://medium.com/@durgaswaroop/a-practical-introduction-to-kafka-storage-internals-d5b544f6925f)
* [https://www.linkedin.com/pulse/partitions-rebalance-kafka-raghunandan-gupta/](https://www.linkedin.com/pulse/partitions-rebalance-kafka-raghunandan-gupta/)

