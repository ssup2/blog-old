---
title: RabbitMQ DLX (Dead Letter Exchange)
category: Theory, Analysis
date: 2020-10-16T12:00:00Z
lastmod: 2020-10-16T12:00:00Z
comment: true
adsense: true
---

RabbitMQ의 DLX(Dead Letter Exchange)를 분석한다.

### 1. RabbitMQ DLX(Dead Letter Exchange)

RabbitMQ DLX(Dead Letter Exchange)는 Dead Letter가 된 Massage를 지정된 Exchange에 전송하는 기능이다. Message가 Dead Letter가 되는 조건은 다음의 3가지가 존재한다.

* Reqeueu False로 설정되어 있는 Consumer가 reject/nack 응답을 통해서 거절한 Message. Requeue True로 설정되어 있는 Consumer가 reject/nack 응답을 통해서 거절한 Message는 Message가 존재했던 Queue에 다시 Requeue되고 DLX 기능은 동작하지 않는다.
* Per-message TTL (Time to Leave)이 만료한 Message.
* Queue가 가득차서 버려진 Message.

![[그림 1] RabbitMQ DLX(Dead Letter Exchange)]({{site.baseurl}}/images/theory_analysis/RabbitMQ_DLX/RabbitMQ_DLX.PNG)

[그림 1]은 Consumer의 Message 거절에 따른 RabbitMQ의 DLX 기능의 처리과정을 나타내고 있다. Exchange A와 Exchange B는 Queue A와 Binding 되어 있다. Queue A는 DLX로 Exchange B가 설정되어 있다. Dead Letter Routing Key는 DLX로 전송하는 Message의 Routing Key를 설정하는 옵션이다. Queue A의 Dead Letter Routing Key는 "ssup2" 문자열로 설정되어 있다. Queue에 Dead Letter Routing Key는 반드시 설정될 필요는 없으며 필요에 따라 설정하면 된다. Message 처리 과정은 다음과 같다.

* Producer가 Consumer에게 전송한 Message는 Exchange A, Queue A를 지나 Consumer에게 전송한다. 
* Consumer는 RabbitMQ로부터 전송 받은 Message를 Requeue 설정이 되어있지 않는 reject 또는 nack 응답을 통해서 거절한다. 
* Message는 Routing Key로 "ssup2" 문자열와 함께 DLX로 지정되어 있는 Exchange B로 전송된다.
* Exchange B는 Binding 되어있는 Queue A에게 Message를 전송한다.
* Message는 다시 Consumer에게 전송된다.

Dead Letter가 된 Message의 "x-death" Header에는 Message가 Dead Letter가 된 이유 및 관련 정보가 저장되어 있다. "x-death" Header에 저장되어 있는 주요 정보는 다음과 같다.

* reason : Message가 Dead Letter가 된 이유.
* time : Message가 Dead Letter가 시간.
* count : 동일한 reason, 동일한 queue에서 Message가 Dead Letter가 된 횟수. 
* queue : Message가 Dead Letter가 되기전에 존재했던 Queue.
* exchange : Dead Letter가 된 Message를 마지막으로 처리한 Exchange. 여러번 DLX에 의해서 처리된 Message의 경우 DLX 정보가 저장되어 있을 수 있다.

### 2. 참조

* [https://www.rabbitmq.com/dlx.html](https://www.rabbitmq.com/dlx.html)
