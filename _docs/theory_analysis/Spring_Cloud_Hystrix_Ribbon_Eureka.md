---
title: Spring Cloud Hystrix,Ribbon,Eureka
category: Theory, Analysis
date: 2018-11-10T12:00:00Z
lastmod: 2018-11-10T12:00:00Z
comment: true
adsense: true
---

Spring Cloud를 분석한다.

### 1. Spring Cloud

Spring Cloud는 Cloud같은 분산 환경에서 **Cloud-native App 구축 및 운영**을 도와주는 도구이다. Cloud-native App을 구성하는 Service들의 설정, 배포, Discovery, Routing, Load-balancing 등을 개발자가 쉽게 이용 할 수 있도록 도와준다. 이러한 동작을 가능하게 하는 핵심 모듈인 Hystrix, Eureka, Ribbon, Zuul은 Netflix의 OSS(Open Source Software)의 Project이다.

### 2. Hystrix

![[그림 1] Spring Cloud Hystrix]({{site.baseurl}}/images/theory_analysis/Spring_Cloud_Hystrix_Ribbon_Eureka/Circuit_Breaker.PNG){: width="500px"}

Hystrix는 분산된 Service 사이에 **Circuit Breaker**를 삽입하여 Service 호출을 제어하고, Service 사이의 Isolation Point를 제공하는 Library이다. [그림 1]은 Hystrix를 이용하여 생성 및 삽입한 Circuit Breaker를 나타내고 있다. Service D가 이용불가능인 상태이거나 Service D의 응답이 늦어 Circuit이 Open되어 있는 경우, Circuit Breaker는 Service A 또는 Service B에서 수행하는 Service D 호출을 차단하여 장애 전파 및 불필요한 Resource 사용을 방지한다. 또한 등록된 Fallback Service인 Service E를 수행하여 유연한 장애대처가 가능하도록 만든다. Circuit Breaker의 Open/Close 기준은 개발자의 설정을 통해 정해진다.

#### 2.1. Flow

![[그림 2] Spring Cloud Hystrix 동작과정]({{site.baseurl}}/images/theory_analysis/Spring_Cloud_Hystrix_Ribbon_Eureka/Hystrix_Flow.PNG)

[그림 2]는 Hystrix의 동작과정을 나타내고 있다. HystrixCommand Instance는 **Service 호출 Logic을 감싸고 있는** Instance로써 Service 호출은 HystrixCommand Instance를 통해서 제어된다.

* 1 : Circuit이 Open되어 있는지 확인한다. 만약 Circuit이 Open되어 있다면 Service 호출은 중단되고 Fallback Service를 호출한다.
* 2 : Circuit이 Open되어 있더라도, Service 호출에 필요한 Thread Pool의 Thread나 남은 Semaphore가 없는 경우 Service 호출은 중단되고 Fallback Service를 호출한다.
* 3 : Service 호출뒤 제대로 Service가 호출되었는지 확인한다. 만약 Service 호출이 성공하지 못했다면 Fallback Service를 호출한다.
* 4 : Service 호출은 완료되었지만 Timeout이 발생하였는지 확인한다. 만약 Timeout이 발생하였다면 Fallback Service를 호출한다. 만약 Timeout이 발생하지 않았다면 Service 호출 결과를 Return한다.
* 5 : 2,3,4 과정의 결과(Metric)를 통해서 Hystrix는 Circuit을 Close할지 Open할지 결정한다. 또한 결과를 모아 개발자에게 보고하여 현재 Hystrix의 상태를 쉽게 파악 할 수 있도록 도와준다.
* 6 : 2,3,4 과정중 실패하면 Fallback Service를 호출한다. 만약 Fallback Service가 정의되어있지 않거나 Fallback Service 호출이 실패하는 경우 Error를 Return한다. Fallback Service 호출이 성공하는 경우 Fallback Service 결과를 Return한다.

#### 2.2. Thread

Hystrix는 **Thread Pool**, **Semaphore** 2가지 Thread 정책을 이용하고 있다.

##### 2.2.1. Thread Pool

Thread Pool 정책은 의미그대로 HystrixCommand Instance가 이용가능한 Thread Pool을 이용하여 Service를 호출하는 방식이다. 각 HystrixCommand Instance에 할당된 Thread Pool의 Thread를 이용하는 방식이기 때문에 **높은 Isolation**이 특징이다. HystrixCommand Instance 내에서 할당된 Thread를 낭비하더라도 WAS가 관리하는 User Request Thread나 다른 HytrixCommand Instance가 이용하는 Thread Pool에게는 영향을 주지 않기 때문이다. 반면 Thread Pool 관리 Overhead 및 Service 호출시 발생하는 Thread Context Switching Overhead 때문에, Semaphore 정책에 비해서 낮은 성능은 단점이라고 할 수 있다.

Thread Pool 정책에서 최대로 Service를 동시 호출할 수 있는 개수는 Thread Pool의 Thread 개수에 따라 정해진다. 따라서 Service가 얼마나 동시에 많이 호출될지 예측한 뒤 적절한 Thread 개수를 Thread Pool에 할당해야 한다. 다수의 HystrixCommand Instance가 하나의 Thread Pool를 공유하여 이용하도록 설정 할 수도 있다. Netflix에서는 Service Isolation을 위해서 Thread Pool 정책을 권하고 있다.

##### 2.2.2. Semaphore

Semaphore 정책은 HystrixCommand Instance에 별도의 전용 Thread를 이용하는 방식이 아닌 HystrixCommand Instance를 통해서 Service 호출을 요청하는 Thread를 그대로 이용하는 방식이다. 따라서 Service 호출시 Thread Context Switching이 발생하지 않아 Thread Pool 정책에 비해서 빠른 성능이 장점이다. 하지만 Thread를 공유하기 때문에 낮은 Isolation이 단점이다.

Thread Pool 정책에서 최대로 Service를 동시 호출할 수 있는 개수는 Semaphore 개수에 따라 정해진다. 따라서 Service가 얼마나 동시에 많이 호출될지 예측한 뒤 적절한 Semaphore 개수를 설정 해야한다. Netflix에서는 엄청난 부하가 발생하는 Non-network 호출, 즉 Network를 거치지 않는 Service 호출이나 함수를 호출할 경우 이용하라고 가이드하고 있다.

### 3. Ribbon

![[그림 3] Spring Cloud Ribbon]({{site.baseurl}}/images/theory_analysis/Spring_Cloud_Hystrix_Ribbon_Eureka/Ribbon.PNG){: width="450px"}

Ribbon은 **Client-side Load Balancer**로써 의미그대로 Client에서 Server Load Balancing을 수행하는 Library이다. [그림 3]은 Ribbon을 나타내고 있다. Ribbon은 Rule, Ping, ServerList 3가지의 구성요소로 이루어져 있다.

#### 3.1. Rule

Rule은 Ribbon에서 이용하는 Load Balancing 알고리즘을 의미한다. Rule은 Ribbon에서 제공하는 Rule을 이용하거나, 개발자가 직접 정의한 Rule을 이용 할 수 있다. 다음의 3가지 Rule은 Ribbon에서 제공해주는 Rule이다.

* RoundRobinRule : Round Robin 알고리즘을 이용하는 방식이다.
* AvailabilityFilteringRule : 동작하지 않는 Server를 건너뛰는 방식이다. Error가 특정횟수 이상 연속으로 발생한 Server는 일정 시간동안 Load Balancing 대상 Server에서 제외시킨다. Error 발생 횟수, Load Balancing 제외 시간은 개발자가 자유롭게 설정이 가능하다.
* WeightedResponseTimeRule : Server의 평균응답시간에 반비례하계 Weight를 부여하는 방식이다.

#### 3.2. Ping

Ping은 Server의 생존 유뮤를 판단하는 구성요소이다. Ping은 Ribbon에서 제공하는 DummyPing Class를 이용하거나, 개발자가 정의한 Ping Class를 이용 할 수 있다.

#### 3.3. ServerList

Load Balancing이 수행가능한 Server List를 의미한다. Server List를 얻는 방식은 Ribbon에서 제공하는 이용하거나, 개발자가 직접 정의한 방식을 이용 할 수 있다. 다음의 3가지 방식은 Ribbon에서 제공해주는 방식이다.

* Adhoc static server list : Ribbon을 설정하는 Code에 Server List를 직접넣는 방식이다.
* ConfigurationBasedServerList : Ribbon을 설정하는 Config 파일에 Server List를 직접넣는 방식이다.
* DiscoveryEnabledNIWSServerList : Eureka Client로 부터 Server List를 얻는 방식이다. 일반적으로 가장 많이 이용되는 방식이다.

또한 Ribbon은 Server List를 Filtering 할 수 있는 기능도 제공한다. Server List Filtering 방식도 Ribbon에서 제공하는 방식을 이용하거나, 개발자가 정의한 방식을 이용 할 수 있다. 다음의 2가지 방식은 Ribbon에서 제공해주는 방식이다.

* ZoneAffinityServerListFilter : Ribbon과 같은 Zone에 있는 Server List만 제공한다.
* ServerListSubsetFilter : 개발자가 설정한 조건에 맞는 Server List만 제공한다.

### 4. Eureka

![[그림 4] Spring Cloud Eureka]({{site.baseurl}}/images/theory_analysis/Spring_Cloud_Hystrix_Ribbon_Eureka/Eureka.PNG){: width="600px"}

Eureka는 **Service Discovery**를 제공하는 Service이다. [그림 4]은 Eureka를 나타내고 있다. Service를 관리하는 Service Registry는 Eureka Server로 동작한다. 그리고 Eureka를 이용하는 Service는 Eureka Client로 동작한다. 동작을 시작한 Service Instance는 Eureka Client를 통해 Eureka Server에게 Service 이름,IP,Port 등의 Service 정보를 전달한다. Eureka Server는 Client로 받은 Service 정보를 저장한 뒤, Service Discover를 요청하는 Eureka Client에게 Service 정보를 전달한다.

Eureka Client는 Eureka Server에게 주기적으로 Service 정보를 요청하고 Caching한다. Service 정보 Cache는 Client 성능을 높이거나 HA(High Availability)를 위해서 이용된다. 또한 주기적으로 Heartbeat를 전달하여 Eureka Client의 동작 상태를 Eureka Server에게 전달한다. 만약 일정시간 Eureka Server에게 Heartbeat를 전달하지 않으면 해당 Eureka Client를 이용하는 Service는 Eureka Server로부터 비정상 상태라고 간주되어 Eureka Server가 관리하는 Server 정보에서 제외된다.

#### 4.1. HA(High Availability)

Eureka는 모든 Service 정보를 관리하는 중요한 Service이기 때문에 Eureka의 HA는 반드시 고려되야한다. 일반적으로 Eureka의 HA를 위해서 Eureka Server는 하나가아닌 다수의 Eureka Server를 구동하는 방식으로 구성된다. 다수의 Eureka Server 구동시 Eureka Server 사이의 Service 정보 정합성은 Eureka Server가 내장하고 있는 Eureka Client를 통해서 이루어진다. Eureka Server가 A,B,C 3개가 있다고 가정할때 Eureka Server A의 Eureka Client에는 Eureka Server B,C의 URL이 설정되어있어 Eureka B,C의 Service 정보를 주기적으로 가지고 온다.

이와 유사하게 Eureka를 이용하는 Service의 Eureka Client는 설정된 Eureka Server A,B,C의 URL을 이용하여 Service 정보를 주기적으로 가지고 온다. 만약 설정된 모든 Eureka Server가 동작하지 않는다면 Eureka Client는 Caching한 Service 정보를 이용한다.

### 5. Hystrix + Ribbon + Eureka

![[그림 5] Spring Cloud Hystrix + Ribbon + Eureka]({{site.baseurl}}/images/theory_analysis/Spring_Cloud_Hystrix_Ribbon_Eureka/Hystrix_Ribbon_Eureka.PNG){: width="700px"}

지금까지 분석한 Spring Cloud의 Hystrix, Ribbon, Eureka를 이용하여 Service를 구성하면 [그림 5]와 같은 구조가 된다. Service A의 Hystrix는 Service B가 제대로 동작하지 않는것을 파악한뒤, Service B의 Circuit을 Open하고 Fallback Service인 Service C를 호출하고 있다. Service A의 Eureka는 Eureka Server로 부터 Service 정보를 얻은뒤 Ribbon에게 전달한다. Eureka Server는 2개의 Instance가 구동하고 있고 첫번째 Eureka Server의 Eureka Client는 두번째 Eureka Server로부터 Service 정보를 얻고있다. Service A의 Ribbon은 Eureka로부터 얻은 Service D의 Instance 정보를 바탕으로 Load Balancing을 수행한다. Service D의 첫번째 Instance가 동작하지 않아 두번째 Instance로 Service D를 호출하고 있다.

Zuul은 API Gateway로써 Service End-point 역활을 수행한다. Zuul에서도 Hystrix, Ribbon, Eureka를 이용하여 안정적인 Service-end point를 제공한다.

### 6. 참조

* Spring Cloud : [https://readme.skplanet.com/?p=13782](https://readme.skplanet.com/?p=13782)
* Hystrix : [https://github.com/Netflix/Hystrix/wiki](https://github.com/Netflix/Hystrix/wiki)
* Hystrix : [http://woowabros.github.io/experience/2017/08/21/hystrix-tunning.html](http://woowabros.github.io/experience/2017/08/21/hystrix-tunning.html)
* Ribbon : [https://github.com/Netflix/ribbon/wiki/Working-with-load-balancers](https://github.com/Netflix/ribbon/wiki/Working-with-load-balancers)
* Ribbon : [https://www.baeldung.com/spring-cloud-rest-client-with-netflix-ribbon](https://www.baeldung.com/spring-cloud-rest-client-with-netflix-ribbon)
* Eureka : [https://www.todaysoftmag.com/article/1429/micro-service-discovery-using-netflix-eureka](https://www.todaysoftmag.com/article/1429/micro-service-discovery-using-netflix-eureka)
