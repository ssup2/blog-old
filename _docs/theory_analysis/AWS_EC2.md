---
title: AWS EC2
category: Theory, Analysis
date: 2022-07-30T12:00:00Z
lastmod: 2022-07-30T12:00:00Z
comment: true
adsense: true
---

AWS EC2 Service를 분석한다.

### 1. AWS EC2

EC2 Service는 AWS에서 Instance(Server)를 생성하여 Computing 자원을 제공하는 Service이다.

#### 1.1. Instance Type

#### 1.2. Performance

##### 1.2.1. Burstable Performance Instnace

Burstable Performance Instance는 의미 그대로 오직 일시적으로만 최대 성능의 CPU를 활용할 수 있는 Instance를 의미한다. 고정된 성능을 보여주는 Instnace에 비해서 저렴한 가격이 가장 큰 장점이다. 평상시에는 사용량이 높지 않지만 일시적으로 높은 CPU 성능이 필요한 경우 고려할 수 있는 Instance Type이다. "T"로 시작되는 Instance Type이 Burstable Performance를 지원하는 Instance Type을 의미한다.

Burstable Performance Instance는 **Credit**을 통해서 최대 성능의 CPU를 이용할 수 있는 시간이 달라진다. Credit은 EC2 Instance가 Baseline이라고 불리는 기준 CPU 사용률보다 더많은 CPU를 이용하고 있다면 차감되며, Baseline CPU 사용률보다 적은 CPU를 이용하고 있다면 Credit은 축적된다. Credit이 모두 차감되면 해당 EC2 Instance는 Credit이 충전되기 전까지 제대로 동작하지 않는다. Credit은 시간단위로 충전되며, Instance Type마다 Credit 충전량 및 최대로 충전할 수 있는 Credit의 개수도 다르다.



### 2. 참조

* EC2 Instance Type : [https://aws.amazon.com/ec2/instance-types/](https://aws.amazon.com/ec2/instance-types/)
* Steal Time : [https://stackoverflow.com/questions/20133739/amazon-aws-micro-instance-with-100-cpu-and-unresponsive](https://stackoverflow.com/questions/20133739/amazon-aws-micro-instance-with-100-cpu-and-unresponsive)