---
title: Service Mesh Architecture
category: Theory, Analysis
date: 2018-12-04T12:00:00Z
lastmod: 2018-12-04T12:00:00Z
comment: true
adsense: true
---

Service Mesh Architecture를 분석한다.

### 1. Service Mesh Architecture

![]({{site.baseurl}}/images/theory_analysis/Service_Mesh_Architecture/Service_Mesh_Architecture.PNG)

Service Mesh Architecture는 다수의 Service를 이용하는 MSA (Mirco Service Archiecture)의 **중앙 제어**가 쉽지 않다는 단점을 극복하기 위해서 설계된 **Infra Level** Architecture이다. Google의 Istio는 대표적인 Service Mesh Architecture 구현체이다. 위의 그림은 Service Mesh Architecture를 나타내고 있다.

Service와 Proxy는 1:1 관계를 갖으며, Service는 Business Logic을 제외한 대부분의 기능을 Service가 아닌 Service와 Mapping된 Proxy에서 수행(Offloading)한다. 이러한 Proxy를 Sidecar Pattern이 적용된 **Sidecar Proxy**라고 부른다. Service의 대부분의 기능이 Proxy로 Offlaoding 되었기 때문에 Proxy 제어을 통해서 Service를 간접적으로 제어할 수 있다. 이러한 Proxy들을 중앙에서 제어하는 Control Plane을 통해서 다수의 Service를 편리하게 제어하는 것이 Service Mesh Architecture의 핵심이다.

Proxy는 Applicaiton Network Function의 역활을 수행한다. Service에서 다른 Service 요청은 반드시 Proxy를 통해서 밖으로 전달되기 때문에, Proxy를 통해서 Service Discovery, Circuit Breaker, Client-size LB, 인증/인가, Timeout, Retry, Logging 등의 기능 수행이 가능하다. 또한 요청을 받는 Service 또한 반드시 Proxy를 통해서 요청을 전달받기 때문에 요청 Filtering, Logging 등의 기능이 Proxy에서 수행 가능하다. Proxy는 HTTP, gRPC, TCP등 다양한 Protocol을 지원한다.

Service는 Business Logic과 Primitive Network Function으로 구성되어있다. Business Logic은 Business Function, Data 개산/가공, 다른 Service/System과의 통합 등을 담당한다. Primitive Network Function은 Service에서 Proxy와 통신 할 수 있는 High-level Library/Interface 역활을 의미한다.

#### 1.1. 장단점

Service Mesh Architecture의 가장 큰 장점은 MSA의 Access Control, Logging, Security 등의 다양한 요구사항을 Proxy와 Control Plane을 통해 중앙에서 쉽게 제어 할 수 있다는 점이다. 또 하나의 큰 장점은 Serivce 구현시 Language 선택 자유도가 높다는 점이다. Spring Cloud의 Hystrix, Ribbon, Eureka등은 MSA 구성시 MSA의 문제 해결을 도와주는 Framework/Library이지만 Java기반 Service에서만 사용할 수 있다는 단점을 가지고 있다. Service Mesh Architecture는 Language와 의존성이 없는 Proxy를 이용하는 방식이기 때문에 Language 선택 자유도가 높다. 이러한 높은 Language 선택 자유도는 기존의 개발된 Service를 재사용 할 수 있게 만든다.

Service Mesh Architecture의 단점은 Proxy의 Overhead이다. Service와 동일 수의 Proxy도 같이 동작해 하기 때문에 Runtime이 최소 2배가 필요하다. 또한 Proxy에의한 추가적인 Network Hope이 발생하기 때문에 Network 성능 저하가 발생한다.

### 2. 참조

* [https://medium.com/microservices-in-practice/service-mesh-for-microservices-2953109a3c9a](https://medium.com/microservices-in-practice/service-mesh-for-microservices-2953109a3c9a)
* [http://tech.cloudz-labs.io/posts/service-mesh/](http://tech.cloudz-labs.io/posts/service-mesh/)