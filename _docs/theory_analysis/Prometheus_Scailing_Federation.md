---
title: Prometheus Scaling, Federation
category: Theory, Analysis
date: 2020-01-13T12:00:00Z
lastmod: 2020-01-13T12:00:00Z
comment: true
adsense: true
---

Prometheus Federation을 분석한다.

### 1. Prometheus Scailing, Federation

![[그림 1] Prometheus Horizontal Sharding]({{site.baseurl}}/images/theory_analysis/Prometheus_Federation/Prometheus_Scailing.PNG)

수집해야할 Metric이 증가하여 단일 Prometheus Server에서 모든 Metric 정보를 수집하기 힘든경우, 다수의 Prometheus Server를 띄우고 Metric을 분산하여 수집하는 Horizontal Sharding 기반의 Scaling 기법을 이용할 수 있다. [그림 1]은 Horizontal Sharding을 이용한 Scaling 기법을 나타내고 있다.

![[그림 2] Prometheus Federation 구성]({{site.baseurl}}/images/theory_analysis/Prometheus_Federation/Prometheus_Federation.PNG)

### 2. 참조

* [https://prometheus.io/docs/prometheus/latest/federation/](https://prometheus.io/docs/prometheus/latest/federation/)
* [https://www.robustperception.io/federation-what-is-it-good-for]
(https://www.robustperception.io/federation-what-is-it-good-for)
* [https://stackoverflow.com/questions/48751632/prometheus-federation-match-params-do-not-work](https://stackoverflow.com/questions/48751632/prometheus-federation-match-params-do-not-work)


