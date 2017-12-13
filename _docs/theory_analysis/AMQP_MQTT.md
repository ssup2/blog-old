---
title: AMQP, MQTT
category: Theory, Analysis
date: 2017-12-13T12:00:00Z
lastmod: 2017-12-13T12:00:00Z
comment: true
adsense: true
---

MQ(Message Queue) Protocol인 AMQP(Advanced Message Queuing Protocol)과 MQTT(Message Queuing Telemetry Transport)를 분석한다.

### 1. AMQP (Advanced Message Queuing Protocol)

AMQP는 **표준 MQ Protocol**으로써 App사이의 Message를 전달할 때 Message를 어떻게 Queuing하고 Routing 할지 정의하고 있다. AMQP는 다양한 Message 전달 옵션을 정의하고 있다. 따라서 대부분의 App이 필요한 Message 전달 규칙을 AMQP를 이용하여 구현 할 수 있다. RabbitMQ는 AMQP를 제공하는 대표적인 MOM(Message-Oriented Middleware)으로써 많은 곳에서 이용되고 있다.

![]({{site.baseurl}}/images/theory_analysis/AMQP_MQTT/AMQP_Architecture.PNG){: width="700px"}

위의 그림은 AMQP의 Architecture를 나타내고 있다. AMQP의 Broker는 Exchange와 Queue로 구성되어 있다.  

#### 1.1 Exchange

Exchange는 Message를 Routing하거나 Filtering하는 역활을 수행한다. Exchange는 Fanout, Direct, Topic, Header 4가지 Mode를 지원한다.

* Fanout - Broker에 존재하는 모든 Queue에게 Message를 전달한다. (Broadcast)
* Direct - 특정 Queue에게 전달한다. (Unicast)
* Topic - Wildcard 형태의 특수문자를 이용하여 전달할 Queue를 선택한다. (Mulicast, # - 여러단어 , * - 한단어))
* Header - Message Header에 포함된 Key값에 따라서 Message를 전달할 Queue를 선택한다. (Multicast)

#### 1.2. Queue

Qeueu는 Subscriber에게 전달될 Message를 임시로 저장하는 곳이다.

#### 1.3. Subscriber Error



### 2. MQTT (Message Queuing Telemetry Transport)

MQTT는

![]({{site.baseurl}}/images/theory_analysis/AMQP_MQTT/MQTT_Architecture.PNG){: width="700px"}

### 3. 참조

* [https://www.slideshare.net/javierarilos/rabbitmq-intromsgingpatterns](https://www.slideshare.net/javierarilos/rabbitmq-intromsgingpatterns)
* [http://gjchoi.github.io/rabbit/rabbit-mq-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0/](http://gjchoi.github.io/rabbit/rabbit-mq-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0/)
