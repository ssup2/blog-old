---
title: MSA (Micro Service Architecture)
category: Theory, Analysis
date: 2018-04-04T12:00:00Z
lastmod: 2018-04-04T12:00:00Z
comment: true
adsense: true
---

MSA (Micro Service Architecture)를 분석한다.

### 1. MSA (Micro Service Architecture)

MSA (Micro Service Architecture)는 **여러개의 작고, 독립적인 Service(기능)**들을 조합하여 구성하는 Architecture를 의미한다. 작고, 독립적인 Service들은 MSA에게 유연성을 부여한다. 이러한 유연성은 개발 및 운영 과정에 많은 이점을 가져다준다.

#### 1.1. Monolithic Architecture vs MSA

![[그림 1] Monolithic Architecture vs MSA]({{site.baseurl}}/images/theory_analysis/MSA/Monolithic_MSA.PNG){: width="700px"}

[그림 1]은 기존의 Monolithic Architecture와 MSA를 나타내고 있다. **Monolithic Architecture**는 특정 기능을 담당하는 Module의 집합으로 구성되며, 각 Module은 하나의 DB를 공유한다. [그림 1]에서 API Server에 모든 Module들이 모여 있고, 모든 Module들이 하나의 DB를 공유하고 있는것을 확인할 수 있다.

Monolithic Architecture는 일반적으로 Module 사이의 경계가 모호하고 다수의 Module이 하나의 Schema를 공유하여 이용하는 경우가 많다. 따라서 일부 Module 또는 DB가 변경되면 연관된 많은 Module들도 같이 변경되어야 한다. 이러한 **Side Effect**는 개발 효율을 떨어트리는 주요 원인중 하나이다. 또한 모호한 Module의 경계는 Module을 개발하는 팀의 구성 및 역활도 모호하게 만들어 팀이 주도적으로 개발을 못하게 만드는 원인이 된다.

Monolithic Architecture에서는 운영 중 특정 Module만 부하가 몰려 Scale Out이 필요한 경우, Scale Out이 불필요한 Module들도 같이 Scale Out이 되어야 하기 때문에 불필요한 자원 낭비가 발생한다. 특정 Module만 교체하고 싶은 상황에서도 모든 Module이 같이 교체되어야 하기 때문에 불필요하게 다른 Module에도 영향을 주게 된다.

하지만 Monolithic Architecture는 단순한 구조로 인하여 빠른 개발과, 쉬운 배포가 가능하다는 특징을 갖고 있다. 또한 하나의 DB를 공유하기 때문에 DB Transaction 기능을 이용하여 Race Condition 방지, Service Rollback 등을 쉽게 처리 할 수 있는 장점을 가지고 있다. 따라서 큰 큐모의 개발이 아닌 경우에는 Monolithic Architecture가 일반적으로 유리하다.

**MSA**는 Business Logic을 수행하는 다수의 Service와 다수의 DB로 구성된다. 각 Service는 일반적으로 별도의 DB를 이용한다. 따라서 각 DB는 반드시 동일한 DB를 이용할 필요가 없으며 Service가 수행하는 Business Logic에 맞는 DB를 선택하여 이용이 가능하다. 물론 필요에 따라서는 서로 다른 Service가 하나의 DB를 공유 할 수도 있다. [그림 1]에서 Service B와 Servicd D는 RDBMS를 이용하고 있고 Service C는 NoSQL을 이용하고 있는것을 확인 할 수 있다.

Service는 필요에 따라서 다른 Service를 호출할 수 있다. Service 호출은 각 Service가 제공하는 Interface를 통해서 호출한다. 일반적으로는 Network 기반의 REST API, GRPC를 Service의 Interface로 많이 이용하고 있다. 이러한 Network 기반의 Service Interface는 Service 사이의 경계를 명확하게 만든다. [그림 1]에서 Service A는 Service B와 Service C를 조합을 통해서 제공되는 Service를 나타내고 있다.

MSA는 Service의 경계와 역활이 명확하기 때문에 팀의 구성 및 팀의 역활도 분명하게 만들어, 각 팀이 적극적인 개발이 가능하도록 만든다는 장점도 갖고 있다. MSA에서는 특정 Service에 부하가 몰릴 경우 부하가 몰린 Service만 Scale Out이 가능하다. 따라서 다른 Service들이 불필요하게 Scale Out될 필요가 없다. 또한 특정 Service를 교체하더라도 나머지 Service에는 영향을 주지 않는다는 장점을 가지고 있다.

MSA는 다수의 Service로 구성되는 만큼 유연하다는 장점을 가지고 있지만, 다수의 Service를 관리해야 하기 때문에, 유지 보수 측면에서는 복잡하다는 단점을 가지고 있다. 이러한 단점을 극복하기 위해서는 개발자가 하나씩 Service 관리를 직접하는 방식이 아니라 별도의 Tool이나 Platform을 이용해야 한다. MSA 구성시 일반적으로 각 Service는 **Container**화 되어 Kubernetes와 같은 **Container Orchestrator**를 통해서 관리된다.

또한 MSA는 각 Service가 서로 다른 DB를 이용하기 때문에 Transaction 처리가 힘들어진다는 단점을 가지고 있다. MSA에서 Transaction을 처리하기 위해서는 DB의 **Two-Phase Commit**이나 **SAGA Pattern**을 이용해야 한다. Service의 조합으로 Service를 구성하는 경우 Service의 의존성으로 인해서 Debugging이 쉽지 않다는 단점을 가지고 있다. 이러한 단점은 **Service Mesh** 도입을 통해서 어느정도 해결할 수 있다.

#### 1.2. Service Type

![[그림 2] Service Type]({{site.baseurl}}/images/theory_analysis/MSA/Service_Type.PNG){: width="700px"}

위에서 언급한것 처럼 MSA는 Service 제공시 다수의 Service를 조합하여 새로운 Service를 제공하는 형태도 가능하다. Service의 역활 및 위치에 따라서 Service를 분류할 수 있다. [그림 2]는 Service를 Core/Atomic Service, Composite/Integration Service, API/Edge Service Service Type으로 분류하고 Service Type별 관계도를 나타내고 있다. 각 Service Type은 아래와 같은 의미를 갖는다.

* Core/Atomic Service : Core Business Logic이나 Atomic한 Business Logic을 수행하는 Service이다.
* Composite/Integration Service : Core/Atomic Service를 조합하여 구성한 Service이다.
* API/Edge Service : Core/Atomic Service, Composite/Integration Service를 조합하여 App에게 노출되는 Service이다. API Gateway에 부하가 높을경우 API Gateway의 일부 역할도 수행할 수 있다.

#### 1.3. with API Gateway

![[그림 3] MSA with API Gateway]({{site.baseurl}}/images/theory_analysis/MSA/MSA_Architecture_API_Gateway.PNG){: width="600px"}

MSA 도입시 같이 도입해야 할 Component로 API Gateway가 있다. API Gateway는 의미 그대로 외부 Client의 요청을 대신 받아 Service에게 전달해주는 Gateway 역활을 수행한다. [그림 2]는 API Gateway를 도입한 MSA를 나타내고 있다. API Gateway는 Client의 모든 요청이 거쳐가는 Component이기 때문에, 모든 Service가 공통적으로 처리해야 하는 **Service의 공통 Logic**을 API Gateway에서 처리할 수 있다.

일반적으로 **인증/인가** 및 **암호화/복호화** 과정을 API Gateway에서 수행한다. [그림 2]의 경우처럼 API Gateway에서 인증/인가 및 암호화/복호화 처리를 수행하면 각 Service는 인증/인가 및 암호화/복호화 처리를 진행할 필요가 없다. 또한 API Gateway는 Client의 요청을 분배하는 **Load Balancer** 역활도 수행한다.

#### 1.4. with Message Queue

![[그림 4] MSA with Message Queue]({{site.baseurl}}/images/theory_analysis/MSA/MSA_Architecture_MQ.PNG){: width="600px"}

MSA 도입시 같이 도입을 검토 해볼만한 Component로 Message Queue가 있다. MSA에서 Message Queue는 Event Queue로 이용된다. 일반적으로 Kafka를 이용하여 Message Queue를 구축한다. [그림 3]은 Message Queue를 도입한 MSA를 나타내고 있다. Service A는 Service B, Service C 호출시 직접 호출하지 않고 Message Queue에게 Event를 Publish한다. 이후에 생성된 Event를 Subscribe 하는 Service B, Service C는 Event를 수신한 다음 Business Logic을 처리한다.

Message Queue가 도입되기 전에 Service A는 Service B, Service C의 존재를 알고 있어야 한다. 하지만 Message Queue를 도입하면서 Service A는 단순히 Event를 Message Queue에게 전달만 하면된다. Service A는 생성한 Event를 Service B, Service C가 이용한다는 정보를 알필요 없다. Service B, Service C 관점에서는 내가 필요한 Event가 생성되었을때 수신만 하면된다. 이처럼 Message Queue를 이용하면 Service 사이의 **의존성**을 낮출 수 있다.

또한 Service B, Service C의 부하가 일시적으로 높은 상태에서 Service A가 Service B, Service C를 직접 호출하는 경우에는 Service B, Service C의 부하를 더 높이게 된다. Message Queue를 도입하면 Service B, Service C는 현재 자신이 처리하고 있는 Event가 완료된 이후에 Message Queue에서 다음 Event를 가져와 처리하는 것이 가능하기 때문에 일시적 부하를 회피할 수 있게 된다. 이처럼 Message Queue를 이용하면 Event Queuing을 통해서 Service의 일시적 부하를 회피할 수 있다.

### 2. 참조

* [https://www.slideshare.net/Byungwook/msa-52918441](https://www.slideshare.net/Byungwook/msa-52918441)
* [https://www.joinc.co.kr/w/man/12/MicroserviceArchitecture](https://www.joinc.co.kr/w/man/12/MicroserviceArchitecture)
* [https://www.slideshare.net/saltynut/building-micro-service-architecture](https://www.slideshare.net/saltynut/building-micro-service-architecture)
* [http://microservices.io/articles/scalecube.html](http://microservices.io/articles/scalecube.html)
* [http://cyberx.tistory.com/64](http://cyberx.tistory.com/64)
* [https://readme.skplanet.com/?p=13782](https://readme.skplanet.com/?p=13782)
* [https://www.slideshare.net/wso2.org/wso2con-eu-2017-microservice-architecture-msa-and-integration-microservices-81654363](https://www.slideshare.net/wso2.org/wso2con-eu-2017-microservice-architecture-msa-and-integration-microservices-81654363)