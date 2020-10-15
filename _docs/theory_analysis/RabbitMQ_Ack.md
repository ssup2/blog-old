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

ACK 기법은 **Message가 최소 한번 이상은 전달되는 것을 보장한다.** 이러한 성질을 **"At Least Once"**라고 명칭한다. 송신자는 Message를 전송한 이후에 수신자로부터 ACK를 받지 못한다면, 수신자에게 ACK를 받을때까지 반복해서 Message를 전송해야 한다. 따라서 Producer는 ACK를 받지 못하면 Message를 재전송 하도록 구현되어 있다. 송신자가 Message를 처리한 다음 수신자에게 ACK를 전송하여도 일시적 Network 장애로 인하여 수신자에게 ACK가 전달되지 않을 수 있다. ACK를 받지 못한 송신자는 동일한 Message를 다시 수신자에게 전송할 수 있다. 즉 **수신자는 동일한 Message를 2번이상** 받을 수 있다. 따라서 Consumer는 동일한 Message를 수신하더라도 동작에 이상이 없도록 멱등성(Idempotent)을 고려하여 구현되야 한다.

#### 1.1. Producer Confirm

Producer가 RabbitMQ에게 Message를 전송하면, RabbitMQ는 수신한 Message를 Exchange에게 전달한다. Exchange는 Exchange에 설정된 규칙에 따라서 수신한 Message를 버리거나, Queue 또는 다른 Exchange에게 전달한다. 만약 Message가 버려진다면 RabbitMQ는 Producer에게 바로 ACK를 전송한다. Message가 Queue로 전송되면 Queue가 Message를 저장한 이후에 Producer에게 ACK를 보낸다. 이때 Queue가 Mirroring 되어 있다면 Message는 Mirroring된 모든 Queue에 복사된 이후에 Producer에게 ACK를 보낸다.

만약 RabbitMQ가 Producer에게 전송한 ACK가 일시적 Network 장애로 인해서 Producer에게 전송되지 못할경우, Producer는 RabbitMQ와의 연결이 재생성된 이후에 ACK를 받지 못한 Message를 재전송한다. 따라서 RabbitMQ는 Producer로부터 동일한 Message를 중복해서 수신할 수 있고, 중복된 Message는 그대로 Consumer에게 여러번 전송된다. Producer는 Producer의 설정에 따라서 RabbitMQ의 ACK를 기다리지 않을 수도 있다.

#### 1.2. Consumer Acknowledgement

RabbitMQ가 Consumer에게 Message를 전송하면, Consumer는 수신한 Message를 처리한 다음 RabbitMQ에게 ACK를 전송한다. Consumer는 Message를 수신한 다음 반드시 특정 시간내에 ACK를 전송할 필요 없다. 즉 ACK의 Timeout은 존재하지 않는다. 대신 RabbitMQ는 Message를 전송한 Consumer로부터 ACK를 받지 못한 상태에서 Consumer와의 연결이 끊어지게 되면, Consumer가 Message를 제대로 처리하지 않는것으로 간주하고 Consumer와의 연결이 재생성된 이후에 Consumer에게 Message를 재전송한다.

Consumer가 Message를 정상적으로 수신하였어도, Consumer에 의해서 Message는 reject또는 nack 될수 있다. reject는 하나의 Message에 대해서만 거절하는 응답이고, nack는 RabbitMQ에게 ACK를 전송하지 않은 모든 Message에 대해서 거절하는 응답이다. 거절된 Message는 Reject/nack 응답과 함께 전송된 Requeue 옵션에 따라서 처리가 달라진다. 

Requeue 옵션이 설정되어 있다면 Message는 Message가 원래 있던 Queue로 돌아간다. Queue로 돌아간 Msssage는 다시 Consumer로 재전송된다. Requeue 옵션이 설정되어 있지 않다면 Message는 Message가 원래 있던 Queue의 DLX(Dead Letter Exchange) 옵션에 따라서 처리가 달라진다. DLX 옵션이 설정되어 있다면 Message는 DLX로 전송되며, DLX 옵션이 설정되어 있지 않다면 Message는 버려진다. RabbitMQ는 Consumer의 설정에 따라서 Consumer의 ACK를 기다리지 않을 수도 있다.

### 2. 참조

* [https://www.rabbitmq.com/reliability.html](https://www.rabbitmq.com/reliability.html)
* [https://www.rabbitmq.com/confirms.html](https://www.rabbitmq.com/confirms.html)
* [https://stackoverflow.com/questions/30546977/is-there-a-timeout-for-acking-rabbitmq-messages](https://stackoverflow.com/questions/30546977/is-there-a-timeout-for-acking-rabbitmq-messages)