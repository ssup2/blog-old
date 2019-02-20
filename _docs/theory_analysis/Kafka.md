---
title: Kafka
category: Theory, Analysis
date: 2019-02-22T12:00:00Z
lastmod: 2019-02-22T12:00:00Z
comment: true
adsense: true
---

kafka를 분석한다.

### 1. Kafka

![]({{site.baseurl}}/images/theory_analysis/Kafka/Kafka_Architecture.PNG){: width="700px"}

Kafka는 Publish-subscribe 기반의 분산 Message Queue이다. 위의 그림은 Kafka의 구성요소를 나타내고 있다. Kafka는 크게 Message를 생성하는 Producer, Message를 소비하는 Consumer, 그리고 Producer와 Consumer 사이에서 Message를 전달하는 Kafka Cluster 3가지 구성요소로 이루어져 있다. Kafka Cluster는 **Topic**이라는 단위로 Message를 관리한다. Producer가 특정 Topic으로 Message를 Publish하면 Kafka Cluster는 해당 Topic을 Subscribe하고 있는 모든 Consumer에게 전달받은 Message를 전달한다. 

이처럼 Kafka는 단순한 Topic 기반의 Publish-subscribe 방식을 이용하기 때문에 대용량의 Message를 빠르게 전달 할 수 있다. 따라서 Kafka는 Message Queue 뿐만 아니라 Spark, Storm같은 빅데이터 처리 Platform의 Stream Queue로도 많이 이용된다.

#### 1.1. Partition, Consumer Group

![]({{site.baseurl}}/images/theory_analysis/Kafka/Kafka_Partition_Consumer_Group.PNG){: width="750px"}

#### 1.2. Cluster

![]({{site.baseurl}}/images/theory_analysis/Kafka/Kafka_Cluster.PNG){: width="700px"}

### 2. 참조

* [https://en.wikipedia.org/wiki/Apache_Kafka](https://en.wikipedia.org/wiki/Apache_Kafka)
* [https://www.quora.com/What-is-Apache-Kafka](https://www.quora.com/What-is-Apache-Kafka)
* [https://sookocheff.com/post/kafka/kafka-in-a-nutshell/](https://sookocheff.com/post/kafka/kafka-in-a-nutshell/)
* [https://epicdevs.com/17](https://epicdevs.com/17)

