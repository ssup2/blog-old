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

![]({{site.baseurl}}/images/theory_analysis/Serverless_Architecture_BaaS_FaaS/Serverless_Architecture.PNG){: width="700px"}

Serverless Architecture는 Server의 기능을 Client에 넘겨 Server의 기능을 최소화하는 Architecture를 의미한다. Serverless Architecture의 Server는 한정된 기능만 수행하기 때문에 Server의 관리 및 배포가 일반 Server에 비해 수월하다. 이러한 특징을 이용하여 Cloud Service Provider는 개발자가 Serverless Architecture 기반의 App 개발시, Server 관리를 완전히 자동화하여 App 개발자가 App Logic에만 집중하도록 도와주는  환경을 제공하고 있다. BaaS (Backend as a Service)와 FaaS (Function as a Service)는 Serverless Architecture를 활용한 대표적인 기법이다.

### 2. BaaS (Backend as a Service)

BaaS는 의미 그대로 DB, Storage, 인증 등의 Backend 기능을 Service로 제공하는 기법을 의미한다. Google의 Firebase가 대표적인 BaaS이다. BaaS는 Backend Service 기능을 제공하는 Server들을 스스로 관리하고 제어하기 때문에 App 개발자는 App Logic 개발에 집중 할 수 있게된다. 위의 그림에서 가장 왼쪽에 있는 Client는 BaaS의 DB Service를 이용하는 모습을 나타내고 있다. Client가 직접 BaaS의 DB를 접근하는 구조이기 때문에, Server에서 구현되던 Backend Logic들이 Client로 이동하여 Client에서 구현되어야 한다.

대부분의 BaaS는 DB나 Storage의 사용량에 따라서 사용요금을 지불한다. 따라서 App에서 적은양의 Data를 저장하는 경우 BaaS를 이용하여 빠른 App 개발이 가능하다. 하지만 App에서 대용량의 Data를 저장하는 경우 많은 사용요금을 지불해야하고 세밀한 DB, Storage 튜닝이 불가능하기 때문에 BaaS 이점을 제대로 활용할 수 없게 된다.

### 3. FaaS (Function as a Service)



### 4. 참조

* [https://martinfowler.com/articles/serverless.html](https://martinfowler.com/articles/serverless.html)
* [https://hackernoon.com/what-is-serverless-architecture-what-are-its-pros-and-cons-cc4b804022e9](https://hackernoon.com/what-is-serverless-architecture-what-are-its-pros-and-cons-cc4b804022e9)
* [https://velopert.com/3543](https://velopert.com/3543)
