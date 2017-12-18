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

AMQP는 **표준 MQ Protocol**으로써 App사이의 Message를 전달할 때 Message를 어떻게 Queuing하고 Routing 할지 정의하고 있다. AMQP는 다양한 Message 전달 옵션을 정의하고 있기 때문에 많은 App들이 AMQP를 이용하여 Message 전달 규칙을 설계하고 이용하고 있다. RabbitMQ는 AMQP를 제공하는 대표적인 MOM(Message-Oriented Middleware)으로써 많은 곳에서 이용되고 있다.

![]({{site.baseurl}}/images/theory_analysis/AMQP_MQTT/AMQP_Architecture.PNG){: width="700px"}

위의 그림은 AMQP의 Architecture를 나타내고 있다. AMQP는 Message를 Routing하고 Queuing하는 Broker의 역활이 매우 중요하다. Broker는 Exchange와 Queue로 구성되어 있다.

#### 1.1 Exchange

Exchange는 Message를 Routing하거나 Filtering하는 역활을 수행한다. Exchange는 Fanout, Direct, Topic, Header 4가지 Mode를 지원한다.

* Fanout - Broker에 존재하는 모든 Queue에게 Message를 전달한다. (Broadcast)
* Direct - 특정 Queue에게 Message를 전달한다. (Unicast)
* Topic - Wildcard 형태의 특수문자를 이용하여 다수의 Queue에게 Message를 전달한다. (Multicast)
* Header - Message Header에 포함된 Key값에 따라서 다수의 Queue에게 Message를 전달한다. (Multicast)

#### 1.2. Queue

Queue는 Subscriber에게 전달될 Message를 임시로 저장하는 곳이다. Broker는 Queue의 Message를 Subscriber에게 전송 한뒤 바로 삭제하지 않고, Subscriber에게 ACK Message를 받은 후에 삭제 한다. Broker는 Subscriber에게 ACK Message를 받지 못하면 Broker에 설정된 일정 횟수만큼 Message를 재전송한다. 여러번 Message를 전송한 후에도 ACK Message를 받지 못하면 Message를 Queue에서 삭제하거나, 다시 Exchange로 보내어 다른 Subscriber에게 전달 되도록 할 수 있다.

하나의 Queue에게 다수의 Subscriber가 붙으면 Message는 Round-Robin 알고리즘에 따라 Subscriber에게 전달된다. 이러한 특징은 Subscriber를 쉽게 Scale-Out 할 수 있도록 만든다.

### 2. MQTT (Message Queuing Telemetry Transport)

![]({{site.baseurl}}/images/theory_analysis/AMQP_MQTT/MQTT_Architecture.PNG){: width="700px"}

MQTT는 IoT 환경같은 **부족한 Resource 환경에서 이용되는 PUB(Publish)/SUB(Subscribe) 기반**의 Messaging Protocol이다. 위의 그림은 MQTT를 간략하게 나타내고 있다. PUB/SUB은 **Topic**을 기준으로 동작한다. Publisher가 특정 Topic으로 Message를 Broker에게 전달하면 Broker는 해당 Topic을 구독하는 모든 Subscriber에게 Message를 전달한다. 따라서 MQTT는 AMQP와 다르게 Multicast 동작만을 수행한다.

#### 2.1. Topic

![]({{site.baseurl}}/images/theory_analysis/AMQP_MQTT/MQTT_Topic.PNG){: width="600px"}

위의 그림은 MQTT의 Topic 구조를 나타내고 있다. Topic은 Directory 구조 처럼 /를 기준으로 계층 구조를 갖게 된다.

#### 2.2. QoS

![]({{site.baseurl}}/images/theory_analysis/AMQP_MQTT/MQTT_QoS.PNG)

MQTT는 3단계의 QoS를 제공한다. 위의 그림은 QoS에 따른 Message 전달 및 ACK 과정을 나타내고 있다.

* Level 0 - Publisher는 Broker에게 Message 전달 후 ACK를 받지 않고 Message를 삭제한다.
* Level 1 - Publisher는 Broker에게 Message 전달한다. Broker는 Publisher에게 Message를 전달한 다음에 ACK를 받는다. Broker는 다시 Publisher에게 ACK(PUBACK)를 전달하고 Message를 삭제한다. ACK를 받은 Publisher는 Message를 삭제한다.
* Level 2 - Level 1과 비슷하지만 차이점은 Broker가 ACK(PUBREC)를 Publisher에게 전달 후에 바로 삭제하지 않고 Publisher에게 ACK(PUBREC)의 ACK(PUBREL)를 받는다는 점이다.

Level 0은 Subscriber에게 Message가 전달되는 것을 보장하지 못한다. Level 1은 Subscriber가 Message를 받는 것을 보장하지만, Subscriber가 여러번 동일 Message를 받을 수 있다. Level 1에서 Broker는 Publisher에게 ACK(PUBACK)가 전달 된 것을 확인 하지 않기 때문에, Publisher가 ACK(PUBACK)을 받지 못하면 한번더 동일 Message를 Broker에게 전송하기 때문이다. Level 2는 Level 1의 문제점이 해결되기 때문에 Subscriber가 Message를 한번 받는것을 보장한다.

### 3. 참조

* [https://www.slideshare.net/javierarilos/rabbitmq-intromsgingpatterns](https://www.slideshare.net/javierarilos/rabbitmq-intromsgingpatterns)
* [http://gjchoi.github.io/rabbit/rabbit-mq-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0/](http://gjchoi.github.io/rabbit/rabbit-mq-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0/)
* [https://www.joinc.co.kr/w/man/12/MQTT/Tutorial](https://www.joinc.co.kr/w/man/12/MQTT/Tutorial)
* [http://dalkomit.tistory.com/111](http://dalkomit.tistory.com/111)
