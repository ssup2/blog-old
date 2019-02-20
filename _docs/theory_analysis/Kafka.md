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

Kafka는 Publish-subscribe 기반의 분산 Message Queue이다. 위의 그림은 Kafka의 구성요소를 나타내고 있다. Kafka는 크게 Message를 생성하는 Producer, Message를 소비하는 Consumer, 그리고 Producer와 Consumer 사이에서 Message를 전달하는 Kafka Cluster 3가지 구성요소로 이루어져 있다. Producer와 Consumer는 Kafka를 이용하는 Application이다. Kafak Cluster는 Broker라고 불리는 Server의 집합이다.

Kafka Cluster는 **Topic**이라는 단위로 Message를 관리한다. Producer가 특정 Topic으로 Message를 Publish하면 Kafka Cluster는 해당 Topic을 Subscribe하고 있는 모든 Consumer에게 전달받은 Message를 전달한다. 이처럼 Kafka는 단순한 Topic 기반의 Publish-subscribe 방식을 이용하기 때문에 대용량의 Message를 빠르게 전달 할 수 있다. 하지만 Kafka를 이용해 세밀한 Message 전달은 불가능하다. Kafka는 대용량 Message를 빠르게 전달할 수 있기 때문에 Spark, Storm 같은 빅데이터 처리 Platform의 Stream Queue로도 많이 이용된다.

#### 1.1. Partition, Consumer Group

![]({{site.baseurl}}/images/theory_analysis/Kafka/Kafka_Partition_Consumer_Group.PNG){: width="750px"}

Kafka는 대용량의 Message 분산 처리를 위한 기법으로 Partiton 및 Consumer Group 기능을 제공한다.  **Partition은 Topic을 Kafka Cluster를 구성하는 각 Broker에게 분산하기 위한 단위 및 Queue**를 의미한다. Topic 마다 Partition의 개수를 다르게 설정할 수 있다. 위의 그림에서 Topic C는 3개의 Partiton으로 이루어져 있기 때문에 각 Partiton은 서로 다른 3개의 Broker에 분산된다. Topic C는 3개의 Broker를 이용하기 때문에 하나의 Topic을 이용하는 Topic B에 비해서 최대 3배 빠르게 Message를 처리 할 수 있다. 하지만 3개의 Partiton을 이용한다는 의미는 3개의 Queue에 Message를 나누어 저장한다는 의미이기 때문에 Producer 전송한 Message의 순서와 Consumer가 수신하는 Message의 순서는 달라질 수 있다. Topic B는 하나의 Partition만을 이용하기 때문에 Message 순서는 그대로 유지된다.

#### 1.2. Cluster

![]({{site.baseurl}}/images/theory_analysis/Kafka/Kafka_Cluster.PNG){: width="700px"}

### 2. 참조

* [https://en.wikipedia.org/wiki/Apache_Kafka](https://en.wikipedia.org/wiki/Apache_Kafka)
* [https://www.quora.com/What-is-Apache-Kafka](https://www.quora.com/What-is-Apache-Kafka)
* [https://sookocheff.com/post/kafka/kafka-in-a-nutshell/](https://sookocheff.com/post/kafka/kafka-in-a-nutshell/)
* [https://epicdevs.com/17](https://epicdevs.com/17)

