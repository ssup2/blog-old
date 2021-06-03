---
title: Design Pattern CQRS (Command and Query Responsibility Segregation)
category: Theory, Analysis
date: 2021-06-02T12:00:00Z
lastmod: 2021-06-02T12:00:00Z
comment: true
adsense: true
---

CQRS (Command and Query Responsibility Segregation) Pattern을 분석한다.

### 1. CQRS (Command and Query Responsibility Segregation) Pattern

![[그림 1] CQRS Pattern]({{site.baseurl}}/images/theory_analysis/Design_Pattern_CQRS/CQRS_Pattern.PNG){: width="600px"}

CQRS (Command and Query Responsibility Segregation) Pattern은 의미 그대로 Command Responsibility와 Query Responsibility을 분리하는 Pattern을 의미한다. 여기서 Responsibility는 Model을 의미한다. 즉 Command와 Query가 다른 **Model**을 이용하여 동작하는 방식을 의미한다. 

[그림 1]은 CQRS Pattern을 나타내고 있다. **Command**는 **State, Report**를 변경하는 Create, Update, Delete 동작을 의미하고, **Query**는 State, Report를 Read하는 동작을 의미한다. Command와 Query는 서로 다른 Model로 동작하며, Command Model의 Command가 Query Model로 전파되어 Query Model의 State, Report를 변경한다. [그림 1]에서는 Command Model과 Query Model이 서로다른 Database를 이용하는 것을 나타냈지만, Database에 따라서 하나의 Database에서 처리될 수 있다.

![[그림 2] Event Sourcing Pattern]({{site.baseurl}}/images/theory_analysis/Design_Pattern_CQRS/Event_Sourcing_Pattern.PNG){: width="600px"}

CQRS Pattern을 이용하는 대표적인 곳이 Event Sourcing Pattern이다. [그림 2]는 Event Sourcing Pattern을 이용하는 Order Service에 적용한 CQRS Pattern을 나타내고 있다. Event Soucing Pattern에서 Event는 CQRS Pattern의 Command와 일치한다. Create, Update, Delete Order 동작을 통해서 생성된 Event는 Event Store에 저장되며, Message Queue를 통해서 Read Database에 비동기 적으로 Event가 반영된다. 이후에 Read Order 동작은 Read Database에 저장된 Order의 상태 정보를 이용한다.

### 2. 참조

* [https://martinfowler.com/bliki/CQRS.html](https://martinfowler.com/bliki/CQRS.html)
* [https://dzone.com/articles/microservices-with-cqrs-and-event-sourcing](https://dzone.com/articles/microservices-with-cqrs-and-event-sourcing)
* [https://justhackem.wordpress.com/2016/09/17/what-is-cqrs/](https://justhackem.wordpress.com/2016/09/17/what-is-cqrs/)