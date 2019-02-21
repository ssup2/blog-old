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

![]({{site.baseurl}}/images/theory_analysis/Kafka/Kafka_Partition_Consumer_Group.PNG){: width="750px"}

Kafka는 Publish-subscribe 기반의 분산 Message Queue이다. 위의 그림은 Kafka의 구성요소를 나타내고 있다. Kafka Cluster는 **Topic**이라는 단위로 Message를 관리한다. Topic은 다시 **Partition**이라는 작은 단위로 쪼개지며, Kafka는 Partiton을 통해서 Message 처리량을 높일 수 있다. Producer는 Message를 Kafka Cluster에게 전송(Publish)하는 App을 의미한다. Consumer는 Kafka Cluster로부터 Message를 전달받는 App을 의미한다. 마지막으로 **Consumer Group**은 의미그대로 다수의 Consumer 묶는 역활을 수행하며, Kafka는 Consumer Group을 이용하여 Consumer의 Message 처리량을 높일 수 있다.

Kafka는 Message의 높은 신뢰성에 초점을 맞춘 Message Queue가 아니라 높은 Message 처리량에 초점을 맞춘 Message Queue이다. 따라서 Kafka는 Topic을 이용하는 단순한 Publish-subscribe 기반의 Message 전달 방식만 제공한다. Producer가 특정 Topic으로 Message를 전송(Publish)하면, Kafka Cluster는 해당 Topic을 구독(Subscribe)하고 있는 모든 Consumer Group에게 Producer로부터 전달받은 Message를 전달한다. Partition과 Consumer Group 또한 Message의 신뢰성보다는 높은 Message 처리량을 위해 나온 기법이다. 이와같은 Kafka의 높은 Message 처리량을 위한 설계는 Kafka가 Spark, Storm 같은 빅데이터 처리 Platform의 Stream Queue로도 많이 이용되도록 만들었다.

#### 1.1. Partition

**Partition은 Topic을 Kafka Cluster를 구성하는 각 Broker에게 분산하기 위한 단위 및 Message를 순차적으로 저장하는 Queue**를 의미한다.

Topic마다 Partition의 개수를 다르게 설정할 수 있다. 위의 그림에서 Topic C는 3개의 Partiton으로 이루어져 있기 때문에 각 Partiton은 서로 다른 3개의 Broker에 분산된다. Topic C는 3개의 Broker를 이용하기 때문에 하나의 Topic을 이용하는 Topic B에 비해서 최대 3배 빠르게 Message를 처리 할 수 있다. 하지만 3개의 Partiton을 이용한다는 의미는 3개의 Queue에 Message를 나누어 저장한다는 의미이기 때문에 Producer 전송한 Message의 순서와 Consumer가 수신하는 Message의 순서는 달라질 수 있다. Topic B는 하나의 Partition만을 이용하기 때문에 Message 순서는 그대로 유지된다.

Partition은 Message 보존을 위해서 Memory가 아닌 **Disk**에 존재한다. 일반적으로 Disk는 Memory에 비해서 Read/Write 성능이 떨어진다. 특히 Random Read/Write의 성능은 Disk가 Memory에 비해서 많이 떨어진다. 하지만 Sequential Read/Write의 경우 Disk의 성능이 Memory의 성능에 비해서 크게 떨어지지 않기 때문에, Kafka는 Partition 이용시 최대한 Sequential Read/Write를 많이 이용하도록 설계되어 있다. 또한 Kafka는 Kernel의 Disk Cache (Page Cache)에 있는 Message가 Kafka를 거치지 않고 Kernel의 Socket Buffer로 바로 복사되도록 만들어, Message를 Network를 통해 Consumer로 전달시 발생하는 Copy Overhead를 최소한으로 줄였다. 이처럼 Kafka는 Disk 사용에의한 성능 저하를 다양한 기법을 통해 최소하하고 있다.

#### 1.2. Consumer Group

Consumer Group은 다수의 Consumer를 묶어 하나의 Topic을 다수의 Consumer가 동시에 처리할 수 있도록 만들어준다. 가장 위의 그림에서 Consumer Group C는 Consumer C, Consumer D 2개의 Consumer를 갖고있고 Topic B와 Topic C로부터 Message를 수신한다.

#### 1.3. Cluster

![]({{site.baseurl}}/images/theory_analysis/Kafka/Kafka_Cluster.PNG){: width="700px"}

### 2. 참조

* [https://en.wikipedia.org/wiki/Apache_Kafka](https://en.wikipedia.org/wiki/Apache_Kafka)
* [https://www.quora.com/What-is-Apache-Kafka](https://www.quora.com/What-is-Apache-Kafka)
* [https://sookocheff.com/post/kafka/kafka-in-a-nutshell/](https://sookocheff.com/post/kafka/kafka-in-a-nutshell/)
* [https://epicdevs.com/17](https://epicdevs.com/17)
* [https://medium.freecodecamp.org/what-makes-apache-kafka-so-fast-a8d4f94ab145]

