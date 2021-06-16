---
title: Consistent Hashing
category: Theory, Analysis
date: 2021-06-05T13:42:00Z
lastmod: 2021-06-05T13:42:00Z
comment: true
adsense: true
---

Consistent Hashing을 분석한다.

### 1. Consistent Hashing

![[그림 1] Consistent Hashing]({{site.baseurl}}/images/theory_analysis/Consistent_Hashing/Consistent_Hashing.PNG){: width="700px"}

Consistent Hashing은 Hashing Algorithm 중 하나이다. **분배 Algorithm**으로 Hashing을 이용할 경우 일반적으로 Consistent Hashing을 많이 이용한다. [그림 1]은 일반적으로 가장 많이 이용되는 Modular Hashing과 Consistent Hashing을 비교하고 있다. Modular Hashing의 경우 Bucket의 개수가 변경될 경우 Rebalancing 과정을 통해서 Bucket의 소속된 대부분의 Key도 같이 이동하게 된다. 이러한 많은 Key의 이동은 성능 저하의 원인이 된다.

예를들어 Modular Hashing을 기반으로 다수의 Disk 사이에서 Data를 Sharding해서 저장했다고 한다면, Disk가 추가/제거 될때마다 많은 Data의 이동이 발생하게 된다. 이러한 문제 해결을 위해서 Bucket을 추가/제거시 Key의 이동을 최소화 하기 위해서 만들어진 Hashing Algorithm이 Consistent Hashing이다. Consistent Hashing은 Bucket 추가/제거시 평균적으로 **(전체 Key의 개수)/Bucket** 개수의 Key가 이동한다.

#### 1.1. Ring Consistent Hashing

![[그림 2] Ring Consistent Hashing]({{site.baseurl}}/images/theory_analysis/Consistent_Hashing/Ring_Consistent_Hashing.PNG){: width="700px"}

#### 1.2. Jump Consistent Hashing

![[그림 3] Jump Consistent Hashing]({{site.baseurl}}/images/theory_analysis/Consistent_Hashing/Jump_Consistent_Hashing.PNG){: width="700px"}

### 2. 참조

* [https://dl.acm.org/doi/abs/10.1145/258533.258660](https://dl.acm.org/doi/abs/10.1145/258533.258660)
* [https://arxiv.org/ftp/arxiv/papers/1406/1406.2294.pdf](https://arxiv.org/ftp/arxiv/papers/1406/1406.2294.pdf)
* [https://www.joinc.co.kr/w/man/12/hash/consistent](https://www.joinc.co.kr/w/man/12/hash/consistent)
* [https://itnext.io/introducing-consistent-hashing-9a289769052e](https://itnext.io/introducing-consistent-hashing-9a289769052e)
* [https://www.popit.kr/consistent-hashing/](https://www.popit.kr/consistent-hashing/)
* [https://www.secmem.org/blog/2021/01/24/consistent-hashing/](https://www.secmem.org/blog/2021/01/24/consistent-hashing/)
* [https://www.popit.kr/jump-consistent-hash/](https://www.popit.kr/jump-consistent-hash/)