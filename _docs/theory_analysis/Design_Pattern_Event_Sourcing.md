---
title: Design Pattern Event Sourcing
category: Theory, Analysis
date: 2021-06-02T12:00:00Z
lastmod: 2021-06-02T12:00:00Z
comment: true
adsense: true
---

Event Sourcing Pattern을 분석한다.

### 1. Event Sourcing Pattern

![[그림 1] Event Sourcing vs Normal CRUD]({{site.baseurl}}/images/theory_analysis/Design_Pattern_Event_Sourcing/Event_Sourcing_Normal_CRUD.PNG){: width="500px"}

Event Sourcing Pattern은 발생하는 **모든 Event를 저장**하고, 저장한 Event를 바탕으로 Data 조작을 수행하는 Pattern이다. [그림 1]은 주문 정보를 저장할때 DB를 이용하는 일반적인 CRUD 방식과 Event Store를 이용하는 Event Sourcing 방법을 나타내고 있다. 일반적인 CRUD 방식은 DB에 현재의 주문 상태 정보만을 저장한다. 반면 Event Sourcing 방법은 발생하는 모든 주문 정보를 저장한다.

[그림 1]의 Event Store에 저장된 주문 정보를 Projection 시키면 DB에 저장되어 있는 현재의 주문 상태와 동일한 것을 확인할 수 있다. Event Sourcing 기법에서 Create, Update, Delete 동작은 단순히 Event Store에 Event 하나가 추가되는 방식으로 동작한다. 반면에 Read 동작의 경우에는 Event Store에 저장된 모든 Event를 Projection시켜야 한다. 따라서 Event Store에 Event가 많이 저장될 수록 Read 동작이 오래 걸리는 문제가 존재한다. 이러한 문제점을 해결할 수 있는 방법이 **Snapshot**과 **CQRS Pattern**을 이용하는 방식이 존재한다.

#### 1.1. Snapshot

#### 1.1. with CQRS Pattern

![[그림 2] Event Sourcing Pattern]({{site.baseurl}}/images/theory_analysis/Design_Pattern_Event_Sourcing/Event_Sourcing_Pattern.PNG){: width="600px"}

### 2. 참조

* [https://docs.microsoft.com/en-us/azure/architecture/patterns/event-sourcing](https://docs.microsoft.com/en-us/azure/architecture/patterns/event-sourcing)
* [https://dzone.com/articles/microservices-with-cqrs-and-event-sourcing](https://dzone.com/articles/microservices-with-cqrs-and-event-sourcing)
* [https://edykim.com/ko/post/eventsourcing-pattern-cleanup/](https://edykim.com/ko/post/eventsourcing-pattern-cleanup/)
* [https://community.risingstack.com/event-sourcing-vs-crud/](https://community.risingstack.com/event-sourcing-vs-crud/)
