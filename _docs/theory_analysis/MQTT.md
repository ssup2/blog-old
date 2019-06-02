---
title: MQTT
category: Theory, Analysis
date: 2017-12-13T12:00:00Z
lastmod: 2017-12-13T12:00:00Z
comment: true
adsense: true
---

MQ(Message Queue) Protocol인 MQTT(Message Queuing Telemetry Transport)를 분석한다.

### 1. MQTT (Message Queuing Telemetry Transport)

![[그림 1] MQTT Architecture]({{site.baseurl}}/images/theory_analysis/MQTT/MQTT_Architecture.PNG){: width="600px"}

MQTT는 IoT 환경같은 **부족한 Resource 환경에서 이용되는 PUB(Publish)/SUB(Subscribe) 기반**의 Messaging Protocol이다. [그림 1]은 MQTT를 간략하게 나타내고 있다. PUB/SUB은 **Topic**을 기준으로 동작한다. Publisher가 특정 Topic으로 Message를 Broker에게 전달하면 Broker는 해당 Topic을 구독하는 모든 Subscriber에게 Message를 전달한다. 따라서 MQTT는 AMQP와 다르게 Multicast 동작만을 수행한다.

#### 1.1. Topic

![[그림 2] MQTT Topic]({{site.baseurl}}/images/theory_analysis/MQTT/MQTT_Topic.PNG){: width="500px"}

[그림 2]는 MQTT의 Topic 구조를 나타내고 있다. Topic은 Directory 구조 처럼 /를 기준으로 계층 구조를 갖게 된다.

#### 1.2. QoS

![[그림 3] MQTT QoS]({{site.baseurl}}/images/theory_analysis/MQTT/MQTT_QoS.PNG)

MQTT는 3단계의 QoS를 제공한다. [그림 3]은 QoS에 따른 Message 전달 및 ACK 과정을 나타내고 있다.

* Level 0 : Publisher는 Broker에게 Message 전달 후 ACK를 받지 않고 Message를 삭제한다.
* Level 1 : Publisher는 Broker에게 Message 전달한다. Broker는 Publisher에게 Message를 전달한 다음에 ACK를 받는다. Broker는 다시 Publisher에게 ACK(PUBACK)를 전달하고 Message를 삭제한다. ACK를 받은 Publisher는 Message를 삭제한다.
* Level 2 : Level 1과 비슷하지만 차이점은 Broker가 ACK(PUBREC)를 Publisher에게 전달 후에 바로 삭제하지 않고 Publisher에게 ACK(PUBREC)의 ACK(PUBREL)를 받는다는 점이다.

Level 0은 Subscriber에게 Message가 전달되는 것을 보장하지 못한다. Level 1은 Subscriber가 Message를 받는 것을 보장하지만, Subscriber가 여러번 동일 Message를 받을 수 있다. Level 1에서 Broker는 Publisher에게 ACK(PUBACK)가 전달 된 것을 확인 하지 않기 때문에, Publisher가 ACK(PUBACK)을 받지 못하면 한번더 동일 Message를 Broker에게 전송하기 때문이다. Level 2는 Level 1의 문제점이 해결되기 때문에 Subscriber가 Message를 한번 받는것을 보장한다.

### 2. 참조

* [https://www.slideshare.net/javierarilos/rabbitmq-intromsgingpatterns](https://www.slideshare.net/javierarilos/rabbitmq-intromsgingpatterns)
* [http://gjchoi.github.io/rabbit/rabbit-mq-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0/](http://gjchoi.github.io/rabbit/rabbit-mq-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0/)
* [https://www.joinc.co.kr/w/man/12/MQTT/Tutorial](https://www.joinc.co.kr/w/man/12/MQTT/Tutorial)
* [http://dalkomit.tistory.com/111](http://dalkomit.tistory.com/111)
