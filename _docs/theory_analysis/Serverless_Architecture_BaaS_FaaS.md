---
title: Serverless Architecture, BaaS, FaaS
category: Theory, Analysis
date: 2018-11-10T12:00:00Z
lastmod: 2018-11-10T12:00:00Z
comment: true
adsense: true
---

Serverless Architecture을 분석하고, Serverless Achitecture 기반의 Service인 BaaS(Backend as a Service)와 FaaS(Function as a Service)를 분석한다.

### 1. Serverless Architecture

![[그림 1] Serverless Architecture]({{site.baseurl}}/images/theory_analysis/Serverless_Architecture_BaaS_FaaS/Serverless_Architecture.PNG){: width="700px"}

Serverless Architecture는 Server의 기능을 Client에 넘겨 Server의 기능을 최소화하는 Architecture를 의미한다. Serverless Architecture의 Server는 대부분 Side Effect가 없는 작은 기능만을 수행하기 때문에 Server의 관리, 배포, Scale Out이 일반 Server에 비해 수월하다. 이러한 특징을 이용하여 Cloud Service Provider는 개발자가 Serverless Architecture 기반의 App 개발시, Server 관리를 완전히 자동화하여 App 개발자가 App Logic에만 집중하도록 도와주는 환경을 제공하고 있다. BaaS (Backend as a Service)와 FaaS (Function as a Service)는 Serverless Architecture를 활용한 대표적인 기법이다.

#### 1.1. BaaS (Backend as a Service)

BaaS는 의미 그대로 DB, Storage, 인증 등의 Backend 기능을 Service로 제공하는 기법을 의미한다. Google의 Firebase가 대표적인 BaaS이다. Backend Service는 BaaS에 의해서 자동으로 관리, 복구되고 사용량에 따라 자동으로 Scale In/Out된다. 따라서 App 개발자는 App Logic 개발에 집중 할 수 있게된다. [그림 1]에서 Client는 BaaS의 DB Service와 인증 Service를 이용하는 모습으로 간주 될 수 있다. Client가 직접 BaaS의 DB를 접근하는 구조이기 때문에, Server에서 구현되던 Backend Logic들이 Client로 이동하여 Client에서 구현되어야 한다.

대부분의 BaaS는 DB나 Storage의 사용량에 비례하여 사용요금을 지불하기 때문에, App에서 적은양의 Data를 저장하는 경우 BaaS를 이용하여 빠르고 적은 비용으로 App 개발이 가능하다. 하지만 App에서 대용량의 Data를 저장하는 경우 많은 사용요금을 지불해야하고 세밀한 DB, Storage 설정이 불가능하기 때문에 BaaS 이용이 비효율적일 수 있다.

#### 1.2. FaaS (Function as a Service)

FaaS는 의미그대로 Function을 Service로 제공하는 기법을 의미한다. AWS의 Lambda, Google의 Cloud Function이 대표적인 FaaS이다. 개발자는 Function을 개발하여 FaaS에게 넘긴다. 개발된 Function은 FaaS에 의해서 자동으로 Server에 배포, 관리, 복구되고 사용량에 따라 자동으로 Scale In/Out된다. 따라서 개발자는 Server에 신경 쓸필요 없이 Function 개발 및 App 개발에만 집중하면 된다.

Function은 Event가 전달될때 수행되는 **Event Handler** 형태로 작성된다. Event는 API Gateway를 지나온 Client의 요청이 될 수도 있고, Message Queue를 지나온 Service나 Function의 요청이 될 수도 있다. Event와 Function Mapping은 개발자에 의해서 설정된다. Function은 FaaS에서 제공하는 API를 이용하여 DB에 접근하거나 Message Queue에 Event를 전송 할 수 있기 때문에, Server에서 구현되던 Backend Logic의 일부는 Function에 구현될 수 있다. 하지만 FaaS는 의미그대로 Function을 제공하는 Service이기 때문에 전반적인 App Logic은 Client에 포함되어 있다. [그림 1]에서 Client는 API Gateway 및 Message Queue를 통하여 FaaS의 Function을 이용하는 모습으로도 간주 될 수 있다.

Function은 항상 구동되지 않고 Event가 발생 할때마다 해당 Function을 가지고 있는 Instance(Container) 구동하는 방식이다. 따라서 FaaS의 과금 방식은 Function이 호출된 횟수에 비례한다. 이러한 특징 때문에 FaaS는 Instance를 계속 띄워두는 기존의 Cloud Service에 비해서 적은 비용이 발생한다. 따라서 자주 사용되지 않는 App 개발시 FaaS를 이용하면 빠르고 적은 비용으로 App 개발이 가능하다. 하지만 FaaS의 단점도 존재한다.

Function은 Event Handler 형태로 구현되기 때문에 반드시 Stateless해야 한다. 또한 Function은 작은 기능을 수행하는 단위로 간주되기 때문에, Function의 최대 수행시간은 짧게 제한된다. 따라서 Function에는 오랜 시간이 걸리는 Logic을 구현 할 수 없다. Event가 발생할때 마다 Function Instance를 새로 구동하는 방식이기 때문에, Function 수행하기전 Runtime 초기화로 인한 Start Latency가 발생한다. Function이 자주 호출 될 수록 Start Latency로 인한 성능 저하를 고려해야한다. Function을 구동하는 Server 및 Container가 자동으로 관리되기 때문에 세밀한 Server, Container, Network 설정이 불가능한 단점도 존재한다.

#### 2. 참조

* [https://martinfowler.com/articles/serverless.html](https://martinfowler.com/articles/serverless.html)
* [https://hackernoon.com/what-is-serverless-architecture-what-are-its-pros-and-cons-cc4b804022e9](https://hackernoon.com/what-is-serverless-architecture-what-are-its-pros-and-cons-cc4b804022e9)
* [https://velopert.com/3543](https://velopert.com/3543)
