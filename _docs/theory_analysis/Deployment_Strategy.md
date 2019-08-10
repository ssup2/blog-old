---
title: Deployment Strategy
category: Theory, Analysis
date: 2019-08-10T12:00:00Z
lastmod: 2019-08-10T12:00:00Z
comment: true
adsense: true
---

다양한 Deployment Strategy를 분석한다.

### 1. Big-Bang Deployment

Big Bang Deployment는 의미 그대로 App 전체 또는 App 대부분을 한번에 배포하는 기법이다. 한번에 많은 변화가 일어나는 만큼 배포 과정중 App을 이용하지 못한다. 또한 배포된 App에 문제가 발생하여 Rollback을 수행하는 과정에서도 App을 이용하지 못하기 때문에, App의 문제는 App Availability에도 큰 영향을 미친다. 따라서 Big Bang Deployment는 App Availability가 중요한 Server-side App에는 적합하지 않다.

App Availability가 문제되지 않는 개발 환경이나, Local PC에 설치되어 단독으로 동작하는 App같은 경우에는 Big Bang Deployment를 적용하여 손쉽게 App을 배포하고 이용할 수 있다.

### 2. Blue-green Deployment

![[그림 1] Blue-green Deployment]({{site.baseurl}}/images/theory_analysis/Deployment_Strategy/Blue-green.PNG)

[그림 1]은 Blue-green Deployment를 나타내고 있다. Blue-green Deployment는 App이 구동될 수 있는 동일한 2개의 환경이 필요하다. 하나의 환경에는 Old App을 구동시키고, 나머지 환경에는 New App을 구동시키기 위해서이다. New App이 배포되기전에 LB는 모든 Packet을 Old App으로만 Routing하여 모든 User가 Old App만 이용하도록 한다. New App이 배포 및 구동 준비가 완료되면 LB를 조작하여 모든 User가 New App을 이용하도록 만든다.

2개의 환경에서 DB를 공유하도록 구성되어 있다면 DB Replication을 고려할 필요가 없지만, 각 환경이 별도의 DB를 이용하도록 구성되어 있다면 Old App DB의 Data가 New App DB에게 복사되도록 Replication 설정이 되어 있어야 한다. LB 조작으로 User가 New App을 이용하도록 설정되어 있다면 Old App으로의 Rollback을 대비하여 New App DB의 Data가 Old App DB에게 복사되도록 반대로 Replication 설정이 되어 있어야 한다.

Blue-green Deployment는 LB Routing 설정과 DB Replication 설정을 통해서 빠르게 Old App에서 New App으로 전환할 수 있는 장점을 갖고 있고, 동일한 이유로 빠른 Rollback이 가능하다는 장점을 갖고 있다. 또한 New App이 Old App과 동일한 환경에서 구동되는 만큼 New App을 User에게 제공하기전에 New App을 검증하기에도 쉽다는 장점을 갖고 있다. 하지만 동일한 2개의 환경을 구축하고 운영하는 만큼 많은 비용이 발생한다는 단점을 갖고 있다.

#### 2.1. vs A/B Testing

A/B Test는 다수의 동일한 환경에서 설정 또는 Version이 다른 App을 구동하고 결과를 비교하여 App을 분석하는 기법이다. Blue-green Deployment 기법처럼 다수의 동일한 환경을 이용한다는 점은 유사하지만, A/B Testing 기법은 의미그대로 App의 Testing을 위한 기법이다.

### 3. Canary Deployment

![[그림 2] Canary Deployment]({{site.baseurl}}/images/theory_analysis/Deployment_Strategy/Canary.PNG){: width="400px"}

[그림 2]는 Canary Deployment를 나타내고 있다. Canary Deployment는 일부의 Old App만 New App으로 배포하여 New App을 검증하는 기법이다. 대부분의 User는 Old App을 그대로 이용하고 일부 User만 New App을 이용하기 때문에, New App에 문제가 발생하여도 User에게는 큰영향을 주지 않게된다.

### 4. Rolling Deployment

![[그림 3] Rolling Deployment]({{site.baseurl}}/images/theory_analysis/Deployment_Strategy/Rolling.PNG)

[그림 3]은 Rolling Deployment를 나타내고 있다. Rolling Deployment는 하나씩 Old App을 New App으로 Update해 나가는 기법이다. 하나씩 Update하는 기법이기 때문에 Update로 인한 App 구동 중단이 User에게는 큰영향을 주지 않는다는 장점을 갖고 있다. 하지만 App이 많을수록 New App으로 전환 및 Old App으로 Rollback 시간이 오래걸린다는 단점을 갖고 있다. 일반적으로 Canary Deployment로 검증된 New App을 Rolling Deployment로 배포하여 New App을 적용하는 방식을 많이 이용한다.

### 5. 참조

* [https://octopus.com/docs/deployment-patterns/rolling-deployments](https://octopus.com/docs/deployment-patterns/rolling-deployments)
* [https://dev.to/mostlyjason/intro-to-deployment-strategies-blue-green-canary-and-more-3a3](https://dev.to/mostlyjason/intro-to-deployment-strategies-blue-green-canary-and-more-3a3)
* [https://opensource.com/article/17/5/colorful-deployments](https://opensource.com/article/17/5/colorful-deployments)
* [https://blog.christianposta.com/deploy/blue-green-deployments-a-b-testing-and-canary-releases/](https://blog.christianposta.com/deploy/blue-green-deployments-a-b-testing-and-canary-releases/)
* [http://cgrant.io/article/deployment-strategies/](http://cgrant.io/article/deployment-strategies/)