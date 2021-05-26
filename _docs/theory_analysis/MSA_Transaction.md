---
title: MSA Transaction
category: Theory, Analysis
date: 2018-04-04T12:00:00Z
lastmod: 2018-04-04T12:00:00Z
comment: true
adsense: true
---

Micro Service Architecture (MSA)를 분석한다.

### 1. MSA Transaction

MSA는 다수의 DB를 이용하기 때문에 DB의 Transaction 기능을 제대로 활용하기 어렵다. 따라서 MSA 설계시 Service 사이의 Consistency 유지를 위한 Transaction 처리에 많은 고민이 필요하다. MSA에서 Transaction을 구현하는 방법에는 **Two-Phase Commit**을 이용하는 방식과 **SAGA Pattern**을 방식이 존재한다.

두 방식 모두 완전한 Transaction을 보장하지는 못한다. 만약 반드시 다수의 Service Logic들이 하나의 완전한 Transaction안에서 실행되어야 한다면, 다수의 Service들을 하나의 Service로 구성하고 하나의 DB를 공유하는 방식으로 변경하는 것이 좋다.

##### 1.1. Two-Phase Commit

![[그림 1] Two-Phase Commit]({{site.baseurl}}/images/theory_analysis/MSA_Transaction/Two_Phase_Commit.PNG){: width="550px"}

Two-Phase Commit은 분산 Transiaction 기법이다. 의미 그대로 **Prepare**, **Commit** 2단계로 나누어 Transaction을 진행한다. [그림 1]은 MSA에 적용한 Two-Phase Commit을 나타내고 있다. Order Service가 Payment, Stock, Delivery Service와 함께 Transaction을 수행하고 싶다면, Order Service는 Payment, Stock, Delivery Service가 제공하는 Prepare API를 통해서 Transaction 준비를 요청한다.

이후에 Order Service가 Payment, Stock, Delivery Service에게 모두 준비가 완료되었다는 응답을 받으면 Payment, Stock, Delivery Service가 제공하는 Commit API를 통해서 실제 Transaction 수행을 요청한다. 이후에 Order Service가 Payment, Stock, Delivery Service에게 Commit 완료 응답을 받게되면 Transaction이 종료된다.

![[그림 2] Two-Phase Commit Failed]({{site.baseurl}}/images/theory_analysis/MSA_Transaction/Two_Phase_Commit_Failed.PNG){: width="550px"}

[그림 2]는 Two-Phase Commit이 실패하는 경우를 나타내고 있다. Order Service가 Payment, Stock, Delivery Service의 Prepare API를 통해서 Prepare 요청을 전송하였지만, Delivery Service에게는 응답을 받지 못한 상황을 나타내고 있다. 이 경우 Order Service는 Payment, Stock Service가 제공하는 Abort Service를 통해서 Abort를 요청하여 Transaction을 중단한다.

Prepare 단계가 완료가 되었어도, Commit 단계에서 실패가 발생할 수 있다. 이 경우는 Commit에 실패한 서비스가 성공할때 까지 반복해서 호출하거나, 서비스 관리자가 직접 완료되지 못한 Transaction을 처리해야 한다. 이러한 이유 때문에 Two-Phases Commit은 완전한 Transaction을 보장하지는 못한다.

Two-Phase Commit을 쉽게 구현하기 위해서는 DB가 제공하는 Two-Phase Commit 기능을 이용해야 한다. 문제는 하나의 Transaction으로 묶기는 Service들이 이용하는 모든 DB가 동일한 종류의 DB를 이용해야 하고, DB에서 Two-Phase Commit을 지원해야 한다. 그렇지 않으면 Service의 Logic으로 Two-Phase Commit을 구현해야 하는데 이럴경우 구현 복잡도가 너무 높아지는 단점이 존재한다.

일반적으로 RDBMS에서만 Two-Phase Commit을 지원하기 때문에 NoSQL DB를 이용하는 Service도 같이 하나의 Transaction에 묶여야 한다면 Two-Phase Commit을 적용하기 쉽지 않다. 또한 Two-Phase Commit은 Sync Call 기반의 방식이기 때문에 Service 사이의 강결합이 발생하고, Service의 Throughput을 낮추는 주요 원인이 되기도 한다. 이러한 이유 때문에 MSA에서는 Two-Phase Commit 보다는 SAGA Pattern을 많이 이용한다.

##### 1.2. SAGA Pattern

![[그림 3] SAGA Chreography Pattern]({{site.baseurl}}/images/theory_analysis/MSA_Transaction/SAGA_Chreography.PNG){: width="650px"}

![[그림 4] SAGA Chreography Pattern Failed]({{site.baseurl}}/images/theory_analysis/MSA_Transaction/SAGA_Chreography_Failed.PNG){: width="650px"}

![[그림 5] SAGA Chreography Pattern]({{site.baseurl}}/images/theory_analysis/MSA_Transaction/SAGA_Orchestration.PNG){: width="650px"}

![[그림 6] SAGA Chreography Pattern Failed]({{site.baseurl}}/images/theory_analysis/MSA_Transaction/SAGA_Orchestration_Failed.PNG){: width="650px"}

### 2. 참조

* [https://developers.redhat.com/blog/2018/10/01/patterns-for-distributed-transactions-within-a-microservices-architecture#possible_solutions](https://developers.redhat.com/blog/2018/10/01/patterns-for-distributed-transactions-within-a-microservices-architecture#possible_solutions)
* [https://developer.ibm.com/depmodels/microservices/articles/use-saga-to-solve-distributed-transaction-management-problems-in-a-microservices-architecture/](https://developer.ibm.com/depmodels/microservices/articles/use-saga-to-solve-distributed-transaction-management-problems-in-a-microservices-architecture/)
* [http://blog.neonkid.xyz/243](http://blog.neonkid.xyz/243)
* [https://microservices.io/patterns/data/saga.html](https://microservices.io/patterns/data/saga.html)
* [https://hyunsoori.tistory.com/9](https://hyunsoori.tistory.com/9)
* [https://www.howtodo.cloud/microservice/2019/06/19/microservice-transaction.html](https://www.howtodo.cloud/microservice/2019/06/19/microservice-transaction.html)
* [https://www.popit.kr/rest-%EA%B8%B0%EB%B0%98%EC%9D%98-%EA%B0%84%EB%8B%A8%ED%95%9C-%EB%B6%84%EC%82%B0-%ED%8A%B8%EB%9E%9C%EC%9E%AD%EC%85%98-%EA%B5%AC%ED%98%84-1%ED%8E%B8/](https://www.popit.kr/rest-%EA%B8%B0%EB%B0%98%EC%9D%98-%EA%B0%84%EB%8B%A8%ED%95%9C-%EB%B6%84%EC%82%B0-%ED%8A%B8%EB%9E%9C%EC%9E%AD%EC%85%98-%EA%B5%AC%ED%98%84-1%ED%8E%B8/)
* [https://developer.ibm.com/depmodels/microservices/articles/use-saga-to-solve-distributed-transaction-management-problems-in-a-microservices-architecture/](https://developer.ibm.com/depmodels/microservices/articles/use-saga-to-solve-distributed-transaction-management-problems-in-a-microservices-architecture/)
