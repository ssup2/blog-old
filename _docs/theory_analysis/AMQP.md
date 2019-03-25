---
title: AMQP
category: Theory, Analysis
date: 2017-12-13T12:00:00Z
lastmod: 2017-12-13T12:00:00Z
comment: true
adsense: true
---

MQ(Message Queue) Protocol인 AMQP(Advanced Message Queuing Protocol)를 분석한다.

### 1. AMQP (Advanced Message Queuing Protocol)

AMQP는 **표준 MQ Protocol**으로써 App사이의 Message를 전달할 때 Message를 어떻게 Queuing하고 Routing 할지 정의하고 있다. AMQP는 다양한 Message 전달 옵션을 정의하고 있기 때문에 많은 App들이 AMQP를 이용하여 Message 전달 규칙을 설계하고 이용하고 있다. RabbitMQ는 AMQP를 제공하는 대표적인 MOM(Message-Oriented Middleware)으로써 많은 곳에서 이용되고 있다.

![]({{site.baseurl}}/images/theory_analysis/AMQP_MQTT/AMQP_Architecture.PNG){: width="700px"}

위의 그림은 AMQP의 Architecture를 나타내고 있다. AMQP는 Message를 Routing하고 Queuing하는 Broker의 역활이 매우 중요하다. Broker는 Exchange와 Queue로 구성되어 있다. Exchange와 Queue를 연결을 통해 Message 전달 규칙이 정해지는데 이러한 연결 과정을 AMQP에서는 **Binding**이라고 한다.

#### 1.1 Exchange

Exchange는 Message를 Routing하거나 Filtering하는 역활을 수행한다. Exchange는 Fanout, Direct, Topic, Header 4가지 Mode를 지원한다.

* Fanout - Broker에 존재하는 모든 Queue에게 Message를 전달한다. (Broadcast)
* Direct - 특정 Queue에게 Message를 전달한다. (Unicast)
* Topic - Wildcard 형태의 특수문자를 이용하여 다수의 Queue에게 Message를 전달한다. (Multicast)
* Header - Message Header에 포함된 Key값에 따라서 다수의 Queue에게 Message를 전달한다. (Multicast)

#### 1.2. Queue

Queue는 Subscriber에게 전달될 Message를 임시로 저장하는 곳이다. Broker는 Queue의 Message를 Subscriber에게 전송 한뒤 바로 삭제하지 않고, Subscriber에게 ACK Message를 받은 후에 삭제 한다. Broker는 Subscriber에게 ACK Message를 받지 못하면 Broker에 설정된 일정 횟수만큼 Message를 재전송한다. 여러번 Message를 전송한 후에도 ACK Message를 받지 못하면 Message를 Queue에서 삭제하거나, 다시 Exchange로 보내어 다른 Subscriber에게 전달 되도록 할 수 있다.

하나의 Queue에게 다수의 Subscriber가 붙으면 Message는 Round-Robin 알고리즘에 따라 Subscriber에게 전달된다. 이러한 특징은 Subscriber를 쉽게 Scale-Out 할 수 있도록 만든다.

### 2. 참조

* [https://www.slideshare.net/javierarilos/rabbitmq-intromsgingpatterns](https://www.slideshare.net/javierarilos/rabbitmq-intromsgingpatterns)
* [http://gjchoi.github.io/rabbit/rabbit-mq-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0/](http://gjchoi.github.io/rabbit/rabbit-mq-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0/)