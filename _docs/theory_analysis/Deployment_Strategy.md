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

App Availability가 문제되지 않는 개발 환경이나, Local PC에 설치되어 동작하는 단독으로 동작하는 App같은 경우에는 Big Bang Deployment를 적용하여 손쉽게 App을 배포하고 이용할 수 있다.

### 2. Blue-Green Deployment

![[그림 1] Blue-Green Deployment]({{site.baseurl}}/images/theory_analysis/Deployment_Strategy/Blue-Green.PNG)

#### 2.1. vs A/B Testing

### 3. Canary Deployment

![[그림 2] Canary Deployment]({{site.baseurl}}/images/theory_analysis/Deployment_Strategy/Canary.PNG){: width="400px"}

### 4. Rolling Deployment

![[그림 3] Rolling Deployment]({{site.baseurl}}/images/theory_analysis/Deployment_Strategy/Rolling.PNG)

### 5. 참조

* [https://dev.to/mostlyjason/intro-to-deployment-strategies-blue-green-canary-and-more-3a3](https://dev.to/mostlyjason/intro-to-deployment-strategies-blue-green-canary-and-more-3a3)
* [https://opensource.com/article/17/5/colorful-deployments](https://opensource.com/article/17/5/colorful-deployments)
* [https://blog.christianposta.com/deploy/blue-green-deployments-a-b-testing-and-canary-releases/](https://blog.christianposta.com/deploy/blue-green-deployments-a-b-testing-and-canary-releases/)
* [http://cgrant.io/article/deployment-strategies/](http://cgrant.io/article/deployment-strategies/)