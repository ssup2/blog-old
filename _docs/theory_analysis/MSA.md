---
title: MSA (Micro Service Architecture)
category: Theory, Analysis
date: 2018-04-04T12:00:00Z
lastmod: 2018-04-04T12:00:00Z
comment: true
adsense: true
---

MSA (Micro Service Architecture)를 분석한다.

### 1. Micro Service Architecture (MSA)

MSA(Micro Service Architecture)는 **여러개의 작고, 독립적인 Service(기능)**들을 조합하여 복잡한 App을 구성하는 Architecture를 의미한다. 작고, 독립적인 Service들은 MSA에게 유연성을 부여한다. 이러한 유연성은 개발 및 운영 과정에 많은 이점을 가져다준다.

#### 1.1. 장단점

![]({{site.baseurl}}/images/theory_analysis/MSA/Monolithic_Architecture.PNG){: width="700px"}

위의 그림은 기존의 Monolithic Architecture를 나타내고 있다. Monolithic Architecture는 여러개의 Service들이 하나의 WAR 파일에 들어가 WAR 파일 단위로 WAS에 배포되어 동작한다. 또한 모든 Service들이 하나의 DB를 공유한다.

Monolithic Architecture는 Service들의 경계가 모호하고 DB도 공유하는 구조이기 때문에 Service간의 의존성 및 DB 의존성이 높다. 따라서 Service가 변경되거나 DB가 변경되면 연관된 많은 Service들도 같이 변경되어야 한다. 모호한 Service 경계는 Service를 개발하는 팀의 구성 및 역활도 모호하게 만든다. WAR 파일 단위로 Service가 배포되기 때문에 운영중 특정 Service에 부하가 몰려 Scale Out이 필요한 경우, Scale Out이 불필요한 Service들도 같이 배포된다. 이에 따라 Service 배포 시간이 늘어나는 문제점도 갖고있다.

하지만 단순한 구조로 인하여 빠른 개발과, 쉬운 배포가 가능하다는 특징을 갖고 있다. 또한 하나의 DB를 공유하기 때문에 DB Transaction 기능을 이용하여 Race Condition 방지, Service Rollback 등을 쉽게 처리 할 수 있는 장점을 가지고 있다. 따라서 큰 큐모의 Service 개발이 아닌 경우에는 Monolithic Architecture가 유리하다.

![]({{site.baseurl}}/images/theory_analysis/MSA/MSA_Architecture.PNG){: width="600px"}

위의 그림은 MSA를 나타내고 있다. 각 Service들은 독립된 Server와 DB에서 동작한다. Service는 Service가 가지고 있는 Business Logic만을 이용하여 구성될 수 있지만, 필요에 따라 여러 Service들을 조합(Orchestration)으로도 구성 될 수도 있다. Service 사이의 통신은 일반적으로 RabbitMQ 같은 Message Queue를 이용한다. Message Queue는 개발 언어 및 환경에 비교적 덜 의존적이면서도 안전하게 Message를 송수신 할 수 있는 수단이다. Message Queue를 통해 Service 개발자는 Service 사이의 통신에 많은 신경을 쓸 필요 없이 Business Logic에 집중 할 수 있게 된다.

MSA의 Service는 독립된 Server와 DB에서 동작하고, Message Queue를 이용하여 Service와 Message 송수신 사이의 의존성을 줄이기 때문에 Service 사이의 경계가 명확하다. 따라서 Service 변경이나 DB 변경의 Side Effect가 적은 편이다. 명확한 Service의 경계는 팀의 구성 및 역활도 명확하게 만들고, 유연한 운영이 가능하도록 만든다.

운영중 특정 Service에 부하가 몰려 Scale Out이 필요한 경우 해당 Service만 Scale Out을 수행하면 된다. Service 변경시에도 변경된 Service만 Deploy를 수행하면 되기 때문에 DevOps시에도 유리하다. 이러한 MSA의 유연성은 유연한 Resource Scale Out이 가능한 Cloud 환경에서 더욱 빛난다. 하지만 Monolithic Architecture에 비해 단점도 분명 존재한다.

Service와 Message 송수신 사이의 의존성을 줄이기 위해 Message Queue를 두었지만, 성능 측면에서 Message Queue는 분명히 Overhead로 작용한다. 또한 Service 단위로 Deploy를 수행하면 되기 때문에 높은 유연성을 갖고 있지만, 반대로 많은 Service들의 Deploy를 관리해야 한다는 단점을 갖고 있다. MSA의 Service Deploy 부분은 반드시 자동화가 병행되어 개발자가 Service Deploy에 너무 많은 시간을 투자하지 않도록 해야한다.

Service들을 조합하여 Service를 구성하는 경우 Debugging이 쉽지 않다는 단점도 갖고 있다. 마지막으로 다수의 DB를 이용하기 때문에 DB의 Transaction 기능을 활용한 Service 개발에 제한적인 단점을 갖고 있다.

#### 1.2. API Gateway

#### 1.3. Orchestration

#### 1.4. Transaction

MSA는 다수의 DB를 이용하기 때문에 DB의 Transaction 기능을 제대로 활용하기 어렵다. 따라서 MSA 설계시 Service 사이의 Consistency 유지를 위한 Transaction 처리에 많은 고민이 필요하다. 첫번째 방법은 DB에서 제공하는 분산 Transaction을 이용하는 방법이다. 하지만 분산 Transaction은 Consistency 보장을 위해 너무 많은 성능 희생이 필요하다. 또한 분산 Transaction을 이용하더라도 완전한 Consistency를 제공하지는 못한다.

따라서 MSA에서는 성능 희생을 최소화 하면서 어느정도 Consistency를 유지하는 방식, 즉 **Eventual Consistency**를 유지하는 방식을 이용한다. Eventual Consistency를 유지하는 방법은 크게 2가지가 있다. 첫번째 방법은 실패한 Transaction을 LOG로 기록했다가 나중에 다시 실행하는 방법이다. 하나의 Transaction이라도 성공했으면 성공으로 간주하는 방법이다. 두번째 방법은 실패한 Transaction은 그대로 놔두고 성공한 Transaction을 원래대로 되돌리는 **Compensating Transaction**을 수행하는 방법이다. 하나의 Transaction이라도 실패할 경우 실패로 간주하고 원래의 상태로 돌리는 방법이다. 만약 Compensating Transaction의 수행이 실패하면 LOG에 기록되고 나중에 다시 수행된다.

2가지 방법 모두 Transaction을 LOG에 기록하고 나중에 수행하는 방식을 이용하기 때문에 완전한 Transaction을 보장하지는 못한다. 만약 반드시 다수의 Service Logic들이 하나의 완전한 Transaction안에서 실행되어야 한다면, 다수의 Service들을 하나의 Service로 구성하고 하나의 DB를 공유하는 방식으로 변경하는것이 좋다.

### 2. 참조

* [https://www.slideshare.net/Byungwook/msa-52918441](https://www.slideshare.net/Byungwook/msa-52918441)
* [https://www.joinc.co.kr/w/man/12/MicroserviceArchitecture](https://www.joinc.co.kr/w/man/12/MicroserviceArchitecture)
* [https://www.slideshare.net/saltynut/building-micro-service-architecture](https://www.slideshare.net/saltynut/building-micro-service-architecture)
* [http://microservices.io/articles/scalecube.html](http://microservices.io/articles/scalecube.html)
* [http://cyberx.tistory.com/64](http://cyberx.tistory.com/64)
* [https://readme.skplanet.com/?p=13782](https://readme.skplanet.com/?p=13782)
