---
title: Prometheus with Thanos
category: Theory, Analysis
date: 2020-01-07T12:00:00Z
lastmod: 2020-01-07T12:00:00Z
comment: true
adsense: true
---

Thanos와 같이 동작하는 Prometheus를 분석한다.

### 1. Prometheus with Thanos

이러한 불완전한 Prometheus Server의 HA를 어느정도 해결해주는 기법중 하나가 Thanos를 이용하는 방법이다. Thanos는 HA를 위해 구성된 다수의 Prometheus Server들을 중계하는 역활을 수행한다. Thanos는 Prometheus Client의 요청을 Prometheus Server 대신 받은 다음 다시 각 Prometheus Server에게 전달한다. 그후 Thanos는 각 Prometheus Server로부터 받은 Metric 정보를 수집 및 Aggregation하여 Prometheus Client에게 전달한다.

다수의 Prometheus Server 대신 Prometheus Client의 요청을 대신 받은 다음 다시 다수의 Prometheus Server 각 Prometheus Server가 갖고 있는 Metric 정보를 하나의 공유 Storage에 모은 다음, Prometheus Client의 요청을 Prometheus Server대신 Thanos가 대신 받아 공유 Storage에 저장된 Metric 정보를 Prometheus Client에게 제공하는 방식을 이용한다. Thanos는 모든 Metric 정보는 하나의 공유 Storage에 저장되기 때문에 다수의 Thanos Server를 구동하는 방식으로 쉽게 HA를 구성할 수 있다.

### 2. 참조

* [https://github.com/thanos-io/thanos](https://github.com/thanos-io/thanos)
* [https://www.infoq.com/news/2018/06/thanos-scalable-prometheus/](https://www.infoq.com/news/2018/06/thanos-scalable-prometheus/)
