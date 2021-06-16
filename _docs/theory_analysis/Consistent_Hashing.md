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

예를들어 Modular Hashing을 기반으로 다수의 Disk 사이에서 Data를 Sharding해서 저장했다고 한다면, Disk가 추가/제거 될때마다 많은 Data의 이동이 발생하게 된다. 이러한 문제 해결을 위해서 Bucket을 추가/제거시 Key의 이동을 최소화 하기 위해서 만들어진 Hashing Algorithm이 Consistent Hashing이다. Consistent Hashing은 Bucket 추가/제거시 평균적으로 **(전체 Key의 개수)/(전체 Bucket의 개수)** 개수의 Key가 이동한다.

#### 1.1. Ring Consistent Hashing

![[그림 2] Ring Consistent Hashing]({{site.baseurl}}/images/theory_analysis/Consistent_Hashing/Ring_Consistent_Hashing.PNG){: width="700px"}

Ring Consistent Hashing은 Consistent Hashing이라는 용어를 처음으로 도입한 Hashing Algorithm이다. [그림 2]는 Ring Consistent Hashing을 나타내고 있다. Ring Consistent Hashing은 **Hash Ring**이라고 불리는 Hashing의 결과값으로 구성된 Ring을 이용한다. 여기서 Hashing은 Modular Hashing으로 이해해도 된다. [그림 2]에서 Hash Ring은 0 ~ 15의 값을 갖고 있다. 그리고 Hash Ring의 사이에 가상의 Bucket을 의미하는 **vBucket (vNode)**이 위치하게 된다.

Ring Consistent Hashing은 Hash Ring에서 시계방향으로 이동할 경우 가장 먼저 만나는 vBucket에 Key를 할당한다. [그림 2]에서 Bucket 크기가 3일 경우 'a' 문자의 Hashing 결과는 '1' 이라고 가정했을때 '1'은 '1'에서 시계방향으로 이동할 경우 2번 Bucket의 vBucket을 가장 먼저 만나기 때문에, 'a'문자는 2번 Bucket에 할당된다.

Bucket이 추가/제거될 경우 Hash Ring에 존재하는 vBucket도 같이 추가/제거된다. 이 경우 대부분의 문자는 옮겨지지 않고 그대로 Bucket에 위치하고 있는것을 확인할 수 있다. [그림 2]에서 Bucket 크기가 3에서 4로 증가하는 경우, '1' ~ '2' 사이에 Bucket 3의 vBucket이 추가되었기 때문에 'a' 문자는 3번 Bucket 3으로 이동한다. 반면에 'e' 문자는 그대로 2번 Bucket에 머무르게 된다.

Bucket하나에 다수의 vBucket이 Mapping되는데, vBucket이 필요한 이유는 각 Bucket에 Key를 골고루 분배하기 위해서이다. 만약 [그림 2]의 Hash Ring에 Bucket만 3~4개 존재한다고 생각한다면 문자가 특정 Bucket에만 몰릴수 있다는 사실을 알 수 있다. 일반적으로 vBucket은 Bucket 하나당 1000개 이상을 생성한다. 각 Bucket마다 Bucket과 vBucket의 비율을 조절하여 각 Bucket이 **서로 다른 비율 (Weight)**로 Key를 갖도록 만들 수 있다.

#### 1.2. Jump Consistent Hashing

![[그림 3] Jump Consistent Hashing]({{site.baseurl}}/images/theory_analysis/Consistent_Hashing/Jump_Consistent_Hashing.PNG){: width="700px"}

Jump Consistent Hashing은 Ring Consistent Hashing이 vBucket 할당을 위해서 이용하는 **Memory 공간을 줄이기 위해서** 탄생한 Hashing Algorithm이다. [그림 3]은 Jump Consistent Hashing을 나타내고 있다. Jump Consistent Hashing에서 Key는 '-1' 부터 시작하여 Random한 거리만큼 계속 Jump한다. Jump를 하다가 Bucket 크기를 넘으면 **Bucket 크기를 넘기 이전의 위치**가 Key의 Bucket이 된다.

[그림 3]에서 Bucket 크기가 7인경우 'c' 문자는 3번 위치에서 Jump하여 한번에 7번 위치까지 이동한다. Bucket의 크기가 7이기 7번 위치는 Bucket 크기를 넘는 위치이다. 따라서 'c' 문자열은 3번 Bucket에 위치한다. Bucket 크기가 8로 증가할 경우 7번 위치는 Bucket 크기에 포함된다. 이후 다음 점프는 Bucket 크기를 넘기 때문에 문자 'c'는 7번 Bucket에 포함된다.

각 Key가 Jump 거리하는 Random이며 Random의 Seed로 Key가 이용된다. 즉 각 Key마다 서로 다른 거리로 Jump를 수행하지만 Bucket의 크기에 따라서 Jump 거리가 변하지는 않는다는 의미다. [그림 3]에서도 Bucket 크기가 변경되어도 각 문자 (Key)마다 Jump 거리는 동일한 것을 확인할 수 있다. Bucket이 추가/제거 될때 Bucket 크기를 넘는 Jump만 영향을 받기 때문에 관련 Bucket의 Key만 이동하는 것을 확인할 수 있다.

Jump Consistent Hashing은 각 Key의 모든 Jump 과정을 저장할 필요 없이, Bucket 크기를 넘기 기전의 위치만 기억하면 되기 때문에 Ring Consistent Hashing과 같이 vBucket의 개념이 필요 없으며, Ring Consistent Hashing에 비해서 적은 Memory 공간을 이용한다. 단 Ring Consistent Hashing와 같이 각 Bucket이 서로 다른 비율로 Key를 갖도록 만들수는 없다. 시간 복잡도는 **ln(n)**이다.

### 2. 참조

* Ring Consistent Hashing : [https://dl.acm.org/doi/abs/10.1145/258533.258660](https://dl.acm.org/doi/abs/10.1145/258533.258660)
* Jump Consistent Hashing : [https://arxiv.org/ftp/arxiv/papers/1406/1406.2294.pdf](https://arxiv.org/ftp/arxiv/papers/1406/1406.2294.pdf)
* [https://www.joinc.co.kr/w/man/12/hash/consistent](https://www.joinc.co.kr/w/man/12/hash/consistent)
* [https://itnext.io/introducing-consistent-hashing-9a289769052e](https://itnext.io/introducing-consistent-hashing-9a289769052e)
* [https://www.popit.kr/consistent-hashing/](https://www.popit.kr/consistent-hashing/)
* [https://www.secmem.org/blog/2021/01/24/consistent-hashing/](https://www.secmem.org/blog/2021/01/24/consistent-hashing/)
* [https://www.popit.kr/jump-consistent-hash/](https://www.popit.kr/jump-consistent-hash/)