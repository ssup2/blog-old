---
title: Kafka Cluster, Replication
category: Theory, Analysis
date: 2019-04-15T12:00:00Z
lastmod: 2019-04-15T12:00:00Z
comment: true
adsense: true
---

Kafka의 Cluster, Replication 기법을 분석한다.

### 1. Kafka Cluster

![[그림 1] Kafka Cluster]({{site.baseurl}}/images/theory_analysis/Kafka_Cluster_Replication/Kafka_Cluster.PNG)

Kafka Broker는 일반적으로 Load Balancing 및 HA (High Availability)를 위해서 다수의 Node 위에서 Cluster를 이루어 동작한다. [그림 1]은 Kafka Cluster를 나타내고 있다. **Kafka Broker**는 Message를 수신, 관리, 전송하는 Kafka의 핵심 Server이다.  **Zookeeper**는 Cluster를 이루는 각 Kafka Broker의 동작 상태를 파악하고 상태 정보를 Producer 및 Consumer에게 전달한다.

Producer는 Kafka Cluster으로부터 Message를 전달하려는 Topic의 Partition 위치를 파악한 다음, Partition이 있는 Kafka Broker에게 직접 Message를 전달한다. Producer는 하나의 Topic에 다수의 Partition이 있는경우 기본적으로 Round-robin 순서대로 Message를 전달할 Partition을 선택한다. 만약 다른 Partition 선택 알고리즘이 필요하면, Producer 개발자는 Kafka가 제공하는 Interface를 통해 Partition 선택 알고리즘을 직접 개발 및 적용할 수 있다. 
Consumer도 Producer와 유사하게 Kafka Cluster으로부터 Message를 전달 받으려는 Topic의 Partition 위치를 파악한 다음, Consumer는 Partition이 있는 Kafka으로부터 Message를 직접 전달 받는다. 

Kafka Cluster는 Partition을 최대한 각 Node에 분산시켜 Load Balancing을 수행하고 Message 처리량도 높인다. Kafka Cluster를 구성하면 일부의 Kafka Broker가 죽어도 Producer와 Consumer는 Kafka를 계속 이용할 수 있지만 Message 손실을 막을 수 없다. 이러한 Message 손실을 막기위해 필요한 기법이 Replication이다.

### 2. Kafka Replication

![[그림 2] Kafka Replication]({{site.baseurl}}/images/theory_analysis/Kafka_Cluster_Replication/Kafka_Cluster_Replication.PNG)

Kafka는 Partition Replication을 지원한다. Replica는  [그림 2]는 Topic A와 Topic B는 Replica 2, Topic C는 Replica 3으로 설정한 상태를 나타내고 있다. Partition이 Replication이 되어도 Producer와 Consumer는 **오직 하나의 Partition**만을 이용한다. Kafka에서는 Producer와 Consumer가 이용하는 Partition은 **Leader**라고 부르며 나머지 복재본은 **Follower**라고 부른다. Leader Partition과 Follower Partition 사이의 Replication은 Producer의 ACK 설정에 따라서 Sync 방식, Async 방식 둘다 이용이 가능하다.

### 3. 참조

* [https://www.popit.kr/kafka-%EC%9A%B4%EC%98%81%EC%9E%90%EA%B0%80-%EB%A7%90%ED%95%98%EB%8A%94-topic-replication/](https://www.popit.kr/kafka-%EC%9A%B4%EC%98%81%EC%9E%90%EA%B0%80-%EB%A7%90%ED%95%98%EB%8A%94-topic-replication/)
* [https://www.tutorialspoint.com/apache_kafka/apache_kafka_cluster_architecture.htm](https://www.tutorialspoint.com/apache_kafka/apache_kafka_cluster_architecture.htm)
* [https://medium.com/@durgaswaroop/a-practical-introduction-to-kafka-storage-internals-d5b544f6925f](https://medium.com/@durgaswaroop/a-practical-introduction-to-kafka-storage-internals-d5b544f6925f)
* [https://www.linkedin.com/pulse/partitions-rebalance-kafka-raghunandan-gupta/](https://www.linkedin.com/pulse/partitions-rebalance-kafka-raghunandan-gupta/)
* [https://grokbase.com/t/kafka/users/1663h6ydyz/kafka-behind-a-load-balancer](https://grokbase.com/t/kafka/users/1663h6ydyz/kafka-behind-a-load-balancer)
