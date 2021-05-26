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

![[그림 1] Two-Phase Commit]({{site.baseurl}}/images/theory_analysis/MSA_Transaction/Two_Phase_Commit.PNG){: width="600px"}

![[그림 2] Two-Phase Commit Failed]({{site.baseurl}}/images/theory_analysis/MSA_Transaction/Two_Phase_Commit_Failed.PNG){: width="600px"}

##### 1.2. SAGA Pattern

![[그림 3] SAGA Chreography Pattern]({{site.baseurl}}/images/theory_analysis/MSA_Transaction/SAGA_Chreography.PNG){: width="700px"}

![[그림 4] SAGA Chreography Pattern Failed]({{site.baseurl}}/images/theory_analysis/MSA_Transaction/SAGA_Chreography_Failed.PNG){: width="700px"}

![[그림 5] SAGA Chreography Pattern]({{site.baseurl}}/images/theory_analysis/MSA_Transaction/SAGA_Orchestration.PNG){: width="700px"}

![[그림 6] SAGA Chreography Pattern Failed]({{site.baseurl}}/images/theory_analysis/MSA_Transaction/SAGA_Orchestration_Failed.PNG){: width="700px"}

### 2. 참조

* [http://blog.neonkid.xyz/243](http://blog.neonkid.xyz/243)
* [https://microservices.io/patterns/data/saga.html](https://microservices.io/patterns/data/saga.html)
* [https://hyunsoori.tistory.com/9](https://hyunsoori.tistory.com/9)
* [https://www.howtodo.cloud/microservice/2019/06/19/microservice-transaction.html](https://www.howtodo.cloud/microservice/2019/06/19/microservice-transaction.html)
* [https://www.popit.kr/rest-%EA%B8%B0%EB%B0%98%EC%9D%98-%EA%B0%84%EB%8B%A8%ED%95%9C-%EB%B6%84%EC%82%B0-%ED%8A%B8%EB%9E%9C%EC%9E%AD%EC%85%98-%EA%B5%AC%ED%98%84-1%ED%8E%B8/](https://www.popit.kr/rest-%EA%B8%B0%EB%B0%98%EC%9D%98-%EA%B0%84%EB%8B%A8%ED%95%9C-%EB%B6%84%EC%82%B0-%ED%8A%B8%EB%9E%9C%EC%9E%AD%EC%85%98-%EA%B5%AC%ED%98%84-1%ED%8E%B8/)