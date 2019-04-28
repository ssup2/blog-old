---
title: RabbitMQ Ack
category: Theory, Analysis
date: 2019-04-01T12:00:00Z
lastmod: 2019-04-01T12:00:00Z
comment: true
adsense: true
---

RabbitMQ의 Ack를 분석한다.

### 1. RabbitMQ Ack

![]({{site.baseurl}}/images/theory_analysis/RabbitMQ_Ack/RabbitMQ_Ack.PNG){: width="750px"}

RabbitMQ는 Producer와 Consumer 사이의 Message 전달을 보장하기 위한 기법으로 Ack를 제공한다. [그림 1]은 RabbitMQ의 Ack 과정을 나타내고 있다. RabbitMQ에서는 Producer가 RabbitMQ에게 Message를 전송한 다음 RabbitMQ으로부터 Ack를 받는 기법을 **Producer Confirm**이라고 명칭한다. 이와 유사하게 RabbitMQ에서는 RabbitMQ가 Consumer에게 Message를 전송한 다음 Consumer으로부터 Ack를 받는 기법을 **Consumer Acknowledgement**라고 표현한다.

#### 1.1. Producer Confirm

#### 1.2. Consumer Acknowledgement

### 2. 참조

* [https://www.rabbitmq.com/reliability.html](https://www.rabbitmq.com/reliability.html)
* [https://www.rabbitmq.com/confirms.html](https://www.rabbitmq.com/confirms.html)