---
title: AWS EC2
category: Theory, Analysis
date: 2022-07-30T12:00:00Z
lastmod: 2022-07-30T12:00:00Z
comment: true
adsense: true
---

AWS EC2 Service를 정리한다. EC2 Service는 AWS에서 Instance(Server)를 생성하여 Computing 자원을 제공하는 Service이다.

### 1. Instance Type

#### 1.1. General Purpose

General Purpose Instance는 CPU, Memory, Disk, Network 모두 평범한 성능을 갖는 Instance Type이다. 일반적인 용도로 가장 많이 이용되는 Instance Type이다. Bustable Performance Instance와 Fixed Performance Instance로 구분할 수 있다.

##### 1.1.1. Burstable Performance Instance

General Purpose Type중에서 Burstable Performance Instance는 의미 그대로 오직 **일시적으로 최대 성능의 CPU**를 활용할 수 있는 Instance를 의미한다. Fixed Performance Instnace에 비해서 저렴한 가격이 가장 큰 장점이다. 평상시에는 사용량이 높지 않지만 일시적으로 높은 CPU 성능이 필요한 경우 고려할 수 있는 Instance Type이다. 다음과 같이 **T**로 시작되는 Instance Type이 Burstable Performance를 지원하는 Instance Type을 의미한다.

* T4g, T3, T3a, T2...

Burstable Performance Instance는 **Credit**을 통해서 최대 성능의 CPU를 이용할 수 있는 시간이 달라진다. Credit은 EC2 Instance가 **Baseline**이라고 불리는 기준 CPU 사용률보다 더 많은 CPU를 이용하고 있다면 차감되며, Baseline CPU 사용률보다 적은 CPU를 이용하고 있다면 Credit은 축적된다. Credit이 모두 차감되면 해당 EC2 Instance는 Credit이 충전되기 전까지 성능 제한이 걸린다. Credit은 시간단위로 충전되며, Instance Type마다 Credit 충전량 및 최대로 충전할 수 있는 Credit의 개수도 다르다. Instance Type별 Credit량은 [Link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-credits-baseline-concepts.html#earning-CPU-credits)에서 확인 가능하다.

Burstable Performance Instance를 이용할경우 Instance 내부에서는 CPU 사용율에 **Steal Time**이 나타날 수 있다. 일반적인 Cloud 환경에서 Steal Time은 Noisy Neighbor로 인한 성능 간섭의 영향으로 간주하지만, AWS의 Burstable Performance의 경우에는 모든 Credit 소모로 인해서 성능 제한이 걸린다는 의미다.

##### 1.2.1. Fixed Performance Instance

General Purpose Type중에서 Fixed Perforamnce Instance는 의미 그대로 고정된 성능을 이용할 수 있는 Instnace를 의미한다. Burstable Performance Instane와 달리 Instance 내부에서 Steal Time이 발생하지 않는다. 다음과 같이 **M**으로 시작되는 Instance Type이 Fixed Performance를 Instance Type을 의미한다.

* M6g, M6i, M5...

#### 1.2. Compute Optimized

#### 1.3. Memory Optimized

#### 1.4. Storage Optimized

### 2. Pricing

### 3. 참조

* EC2 Instance Type : [https://aws.amazon.com/ec2/instance-types/](https://aws.amazon.com/ec2/instance-types/)
* Steal Time : [https://stackoverflow.com/questions/20133739/amazon-aws-micro-instance-with-100-cpu-and-unresponsive](https://stackoverflow.com/questions/20133739/amazon-aws-micro-instance-with-100-cpu-and-unresponsive)