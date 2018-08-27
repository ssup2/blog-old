---
title: Cloud-Native
category: Theory, Analysis
date: 2018-08-27T12:00:00Z
lastmod: 2018-08-27T12:00:00Z
comment: true
adsense: true
---

Cloud-Native를 분석한다.

### 1. Cloud-Native

Cloud-Native는 **Cloud 환경의 이점을 최대한 활용하여 App을 개발하고, App을 구동하는 접근법**을 의미한다. 여기서 말하는 Cloud 환경의 이점은 확장성과 유연성이다. IaaS를 통해 Compute, Network, Storage 자원을 필요에 따라서 쉽게 할당받고 이용 할 수 있다. Contianer 기술을 통해 App은 App마다 독립된 환경을 유지하면서도 각 Compute 자원에 빠르게 배포될 수 있게 되었다.

이러한 Cloud의 확장성과 유연성을 최대한 활용하는 Architecture가 MSA (Micro Service Architecture)이다. MSA에서 App의 기능들은 여러개의 작은 Service들로 쪼개진다. 사용자에게 보여지는 App의 기능은 여러개의 Service들의 조합으로 이루어진다. MSA에서는 특정 Service에 부하가 몰린 경우 해당 Service만 Scale Out을 통해 쉽게 Load Balancing을 수행 할 수 있다. 또한 App을 계속 구동하면서 특정 Service만 Update하는 방식으로 유연한 CI (Continuous Integration)가 가능하다. 이러한 App의 유연성 때문에 Cloud-Native App은 MSA를 이용한다.

### 2. 참조

* [https://stackify.com/cloud-native/](https://stackify.com/cloud-native/)
* [https://pivotal.io/de/cloud-native](https://pivotal.io/de/cloud-native)
