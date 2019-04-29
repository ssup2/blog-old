---
title: RabbitMQ ACK
category: Theory, Analysis
date: 2019-04-01T12:00:00Z
lastmod: 2019-04-01T12:00:00Z
comment: true
adsense: true
---

RabbitMQ의 ACK를 분석한다.

### 1. RabbitMQ ACK

![]({{site.baseurl}}/images/theory_analysis/RabbitMQ_ACK/RabbitMQ_ACK.PNG){: width="750px"}

RabbitMQ는 Producer와 Consumer 사이의 Message 전달을 보장하기 위한 기법으로 ACK를 제공한다. [그림 1]은 RabbitMQ의 ACK 과정을 나타내고 있다. RabbitMQ에서는 Producer가 RabbitMQ에게 Message를 전송한 다음 RabbitMQ으로부터 ACK를 받는 기법을 **Producer Confirm**이라고 명칭한다. 이와 유사하게 RabbitMQ에서는 RabbitMQ가 Consumer에게 Message를 전송한 다음 Consumer으로부터 ACK를 받는 기법을 **Consumer Acknowledgement**라고 명칭한다.

ACK 기법은 **Message가 최소 한번 이상은 전달되는 것을 보장한다.** 송신자는 Message를 전송한 이후에 수신자로부터 ACK를 받지 못한다면, 수신자에게 ACK를 받을때까지 반복해서 Message를 전송해야 한다. 따라서 Producer는 ACK를 받지 못하면 Message를 재전송 하도록 구현되어 있어야한다. 송신자가 Message를 처리한 다음 수신자에게 ACK를 전송하여도 일시적 장애로 인하여 수신자에게 ACK가 전달되지 않을 수 있다. ACK를 받지 못한 송신자는 동일한 Message를 다시 수신자에게 전송할 수 있다. 즉 **수신자는 동일한 Message를 2번이상 받을 수 있다.** 따라서 Consumer는 동일한 Message를 수신하더라도 동작에 이상이 없도록 구현되어 있어야한다. 이러한 성질을 멱등성 (Idempotent)라고 표현한다.

#### 1.1. Producer Confirm

Producer가 RabbitMQ에게 Message를 전송하면, RabbitMQ는 받은 Message를 Exchange에게 전달한다. Exchange는 Exchange에 설정된 규칙에 따라서 받은 Message를 버리거나, Queue 또는 다른 Exchange에게 전달한다. 만약 Message가 버려진다면 RabbitMQ는 Producer에게 바로 ACK를 전송한다. Message가 Queue로 전송되면 Queue가 Message를 저장한 이후에 Producer에게 ACK를 보낸다. 이때 Queue가 Mirroring 되어 있다면 Message는 Mirroring된 모든 Queue에 복사된 이후에 Producer에게 ACK를 보낸다. Producer는 Producer의 설정에 따라서 ACK를 기다리지 않을 수도 있다.

#### 1.2. Consumer Acknowledgement

RabbitMQ가 Consumer에게 Message를 전송하면, Consumer는 받은 Message를 처리한 다음 RabbitMQ에게 ACK를 전송한다. RabbitMQ는 Consumer의 설정에 따라서 ACK를 기다리지 않을 수도 있다.

### 2. 참조

* [https://www.rabbitmq.com/reliability.html](https://www.rabbitmq.com/reliability.html)
* [https://www.rabbitmq.com/confirms.html](https://www.rabbitmq.com/confirms.html)