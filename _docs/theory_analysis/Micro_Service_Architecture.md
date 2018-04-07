---
title: Micro Service Architecture (MSA)
category: Theory, Analysis
date: 2018-04-04T12:00:00Z
lastmod: 2018-04-04T12:00:00Z
comment: true
adsense: true
---

Micro Service Architecture룰 분석한다.

### 1. Micro Service Architecture (MSA)

MSA(Micro Service Architecture)는 **여러개의 작고, 독립적인 Service(기능)**들을 조합하여 복잡한 App을 구성하는 Architecture를 의미한다. 작고, 독립적인 Service들은 MSA에게 유연성을 부여한다. 이러한 유연성은 개발 및 운영 과정에 많은 이점을 가져다준다.

#### 1.1. 장단점

![]({{site.baseurl}}/images/theory_analysis/Micro_Service_Architecture/Monolithic_Architecture.PNG){: width="700px"}

위의 그림은 기존의 Monolithic Architecture를 나타내고 있다. Monolithic Architecture는 여러개의 Service들이 WAR파일에 단위로 WAS에 배포되어 동작한다. 또한 모든 Service들이 하나의 DB를 이용한다. 각 Service들은 명확하게 구분되어 있지않고 DB도 공유하는 구조이기 때문에, 하나의 Service가 Update되려면 다른 Service들도 동시에 Update되야 한다. 또한 일부 Service에만 부하가 몰려 Scale Out 수행시, Service는 WAR파일 단위로 배포되기 때문에 배포가 불필요한 Service들도 같이 배포되는 문제가 있다.

![]({{site.baseurl}}/images/theory_analysis/Micro_Service_Architecture/MSA_Architecture.PNG){: width="600px"}

위의 그림은 MSA를 나타내고 있다. 각 Service들은 독립된 Server와 DB를 이용하여 동작하기 때문에 Service 단위로 쉽게 개발 및 Update를 수행 할 수 있다. 또한 일부 Service에만 부하가 몰려 Scale Out 수행시, 해당 Service만 Scale Out을 수행하면 된다. 하지만 Monolithic Architecture에 비해 단점도 존재한다.

다수의 DB를 이용하기 때문에 Transaction 적용이 힘들다. Monolithic Architecture에서는 단순히 DB의 Transaction 관리 기능을 이용하면 되지만, MSA에서는 DB의 분산 Transaction을 이용하거나 Service에서 Transaction Logic을 직접 구현해야 한다. 또한 하나의 요청을 수행하는데 많은 Service들이 호출되기 때문에 경로 추적 및 Debugging이 힘든 단점이 있다. 마지막으로 Service간의 통신 방식이 REST API같은 API 기반 통신을 이용하기 때문에, 기존의 IPC 방식에 비해 성능이 떨어지는 단점이 존재한다.

#### 1.2. API Gateway

API Gateway는 MSA의 수많은 Service들을 통합하여 Client에게 하나의 Endpoint를 제공하는 Component이다. Proxy, Routing, Load Balancing, Logging, 인증 같은 MSA의 Service들이 필요한 **공통된 기능**을 제공한다.

#### 1.3. Transaction

MSA는 다수의 DB를 이용하기 때문에 DB간의 Consistency 유지를 위한 Transaction 처리에 많은 비용이 필요하다. 가장 쉬운 방법은 DB에서 제공하는 분산 Transaction을 이용하는 방법이다. 하지만 다양한 종류의 DB가 구동되는 MSA에서 분산 Transaction 기능을 이용 할 수 없는 경우가 대부분이다. 따라서 Service에서 직접 Transaction Logic을 구현해야 한다.

Service에서는 **Eventual Consistency**를 유지하는 방식을 이용하여 여러개의 DB Transaction을 하나의 Transaction으로 묶는다. Eventual Consistency를 유지하는 방법은 크게 2가지가 있다. 첫번째 방법은 실패한 Transaction을 LOG로 기록했다가 나중에 다시 실행하는 방법이다. 하나의 Transaction이라도 성공했으면 성공으로 간주하는 방법이다. 두번째 방법은 실패한 Transaction은 그대로 놔두고 성공한 Transaction을 원래대로 되돌리는 **Compensating Transaction**을 수행하는 방법이다. 하나의 Transaction이라도 실패할 경우 실패로 간주하고 원래의 상태로 돌리는 방법이다. 만약 Compensating Transaction의 수행이 실패하면 LOG에 기록되고 나중에 다시 수행된다.

2가지 방법 모두 Transaction을 LOG에 기록하고 나중에 수행하는 방식을 이용하기 때문에 완전한 Transaction을 보장하지는 못한다. 만약 반드시 하나의 완전한 Transaction 안에서 여러개의 DB Transaction을 수행해야 하는 경우라면, 여러개의 Service들을 하나의 Service로 재구성하여 하나의 DB Transaction을 이용해야 한다.

### 2. 참조

* [https://www.slideshare.net/Byungwook/msa-52918441](https://www.slideshare.net/Byungwook/msa-52918441)
* [https://www.joinc.co.kr/w/man/12/MicroserviceArchitecture](https://www.joinc.co.kr/w/man/12/MicroserviceArchitecture)
* [https://www.slideshare.net/saltynut/building-micro-service-architecture](https://www.slideshare.net/saltynut/building-micro-service-architecture)
* [http://microservices.io/articles/scalecube.html](http://microservices.io/articles/scalecube.html)
* [http://cyberx.tistory.com/64](http://cyberx.tistory.com/64)
* [https://readme.skplanet.com/?p=13782](https://readme.skplanet.com/?p=13782)
