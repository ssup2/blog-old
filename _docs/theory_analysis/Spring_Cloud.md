---
title: Spring Cloud
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

![]({{site.baseurl}}/images/theory_analysis/Spring_Cloud/Circuit_Breaker.PNG){: width="500px"}

Hystrix는 분산된 Service 사이에 **Circuit Breaker**를 삽입하여 Service 호출을 제어하고, Service 사이의 Isolation Point를 제공하는 Library이다. 위의 그림은 Hystrix를 이용하여 생성 및 삽입한 Circuit Breaker를 나타내고 있다. Service D가 이용불가능인 상태이거나 Service D의 응답이 늦어 Circuit이 Open되어 있는 경우, Circuit Breaker는 Service A 또는 Service B에서 수행하는 Service D 호출을 차단하여 불필요한 Resource 사용을 방지한다. 또한 등록된 Fallback Service인 Service E를 수행하여 유연한 장애대처가 가능하도록 만든다. Circuit Breaker의 Open/Close 기준은 개발자의 설정을 통해 정해진다.

#### 2.1. Flow

![]({{site.baseurl}}/images/theory_analysis/Spring_Cloud/Hystrix_Flow.PNG)

위의 그림은 Hystrix의 동작과정을 나타내고 있다. HystrixCommand Instance는 **Service 호출 Logic을 감싸고 있는** Instance로써 Service 호출은 HystrixCommand Instance를 통해서 제어된다.

* 1 - Circuit이 Open되어 있는지 확인한다. 만약 Circuit이 열려있다면 Service 호출은 중단되고 Fallback Service를 호출한다.
* 2 - Circuit이 Open되어 있더라도, Service 호출에 필요한 Thread Pool의 Thread나 남은 Semaphore가 없는 경우 Service 호출은 중단되고 Fallback Service를 호출한다.
* 3 - Service 호출뒤 제대로 Service가 호출되었는지 확인한다. 만약 Service 호출이 성공하지 못했다면 Fallback Service를 호출한다.
* 4 - Service 호출은 완료되었지만 Timeout이 발생하였는지 확인한다. 만약 Timeout이 발생하였다면 Fallback Service를 호출한다. 만약 Timeout이 발생하지 않았다면 Service 호출 결과를 Return한다.
* 5 - 2,3,4 과정의 결과(Metric)를 통해서 Hystrix는 Circuit을 Close할지 Open할지 결정한다. 또한 결과를 모아 개발자에게 보고하여 현재 Hystrix의 상태를 쉽게 파악 할 수 있도록 도와준다.
* 6 - 2,3,4 과정중 실패하면 Fallback Service를 호출한다. 만약 Fallback Service가 정의되어있지 않거나 Fallback Service 호출이 실패하는 경우 Error를 Return한다. Fallback Service 호출이 성공하는 경우 Fallback Service 결과를 Return한다.

#### 2.2. Thread

Hystrix는 **Thread Pool**, **Semaphore** 2가지 Thread 정책을 이용하고 있다.

##### 2.1.1. Thread Pool

Thread Pool 정책은 의미그대로 HystrixCommand Instance가 이용가능한 Thread Pool을 이용하여 Service를 호출하는 방식이다. 각 HystrixCommand Instance에 할당된 Thread Pool의 Thread를 이용하는 방식이기 때문에 **높은 Isolation**이 특징이다. HystrixCommand Instance 내에서 할당된 Thread를 낭비하더라도 WAS가 관리하는 User Request Thread나 다른 HytrixCommand Instance가 이용하는 Thread Pool에게는 영향을 주지 않기 때문이다. 반면 Thread Pool 관리 Overhead 및 Service 호출시 발생하는 Thread Context Switching Overhead 때문에, Semaphore 정책에 비해서 낮은 성능은 단점이라고 할 수 있다.

Thread Pool 정책에서 최대로 Service를 동시 호출할 수 있는 개수는 Thread Pool의 Thread 개수에 따라 정해진다. 따라서 Service가 얼마나 동시에 많이 호출될지 예측한 뒤 적절한 Thread 개수를 Thread Pool에 할당해야 한다. 다수의 HystrixCommand Instance가 하나의 Thread Pool를 공유하여 이용하도록 설정 할 수도 있다. Netflix에서는 Service Isolation을 위해서 Thread Pool 정책을 권하고 있다.

##### 2.1.2. Semaphore

Semaphore 정책은 HystrixCommand Instance에 별도의 전용 Thread를 이용하는 방식이 아닌 HystrixCommand Instance를 통해서 Service 호출을 요청하는 Thread를 그대로 이용하는 방식이다. 따라서 Service 호출시 Thread Context Switching이 발생하지 않아 Thread Pool 정책에 비해서 빠른 성능이 장점이다. 하지만 Thread를 공유하기 때문에 낮은 Isolation이 단점이다.

Thread Pool 정책에서 최대로 Service를 동시 호출할 수 있는 개수는 Semaphore 개수에 따라 정해진다. 따라서 Service가 얼마나 동시에 많이 호출될지 예측한 뒤 적절한 Semaphore 개수를 설정 해야한다. Netflix에서는 엄청난 부하가 발생하는 Non-network 호출, 즉 Network를 거치지 않는 Service 호출이나 함수를 호출할 경우 이용하라고 가이드하고 있다.

### 3. Eureka

### 4. Ribbon

### 5. Zuul

### 6. 참조
* Spring Cloud - [https://readme.skplanet.com/?p=13782](https://readme.skplanet.com/?p=13782)
* Hystrix - [https://github.com/Netflix/Hystrix/wiki](https://github.com/Netflix/Hystrix/wiki)
* Hystrix - [http://woowabros.github.io/experience/2017/08/21/hystrix-tunning.html](http://woowabros.github.io/experience/2017/08/21/hystrix-tunning.html)
