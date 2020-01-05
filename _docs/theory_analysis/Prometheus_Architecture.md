---
title: Prometheus Architecture
category: Theory, Analysis
date: 2020-01-05T12:00:00Z
lastmod: 2020-01-05T12:00:00Z
comment: true
adsense: true
---

Prometheus의 Architecture를 분석한다.

### 1. Prometheus Architecture

![[그림 1] Prometheus Architecture]({{site.baseurl}}/images/theory_analysis/Prometheus_Architecture/Prometheus_Architecture.PNG){: width="750px"}

[그림 1]은 Prometheus Architecture를 나타내고 있다. Prometheus는 크게 Server, Exporter, Alertmanager, Pushgateway로 구성되어 있다. Exporter는 Metric 정보를 **수집**하고 **Aggregate**하는 역활을 수행한다. 하나의 Server에 다수의 Exporter를 연동하여 이용할 수 있다. 일반적으로 Exporter는 용도별로 구분된다. 예를들어 Node Exporter는 특정 Node의 Metric 정보를 수집하는 역활을 수행한다. MySQL Exporter는 특정 MySQL DB의 Metric 정보를 수집하는 역활을 수행한다.

Exporter가 수집하고 Aggregate한 Metric정보는 Exporter에 의해서 먼져 Server에게 Push하는 방식이 아닌, Server에서 먼져 Exporter로부터 **Pull**하는 방식을 이용한다. 즉 모든 Metric 정보는 Exporter가 아닌 Server가 중심이 되어 수집된다. 이러한 Server 중심의 Metric 수집 방식은 Server 스스로 Metric 수집에 의한 부하를 조절할 수 있는 큰 장점을 갖게 된다. Exporter의 개수가 많아져 수집할 Metric의 양이 증가할 경우, Server가 각 Exporter의 Metric을 Pull하는 주기를 능동적으로 늘릴 수 있기 때문이다. 하지만 Pull 방식은 Event를 기록하기에는 적합한 방식은 아니다. Event가 발생하여 Exporter에 저장되어도 Server에 전달되는 시점은 Event와 관계없는 Server의 Metric 수집 주기에 의해서 결정되기 때문이다.

Pushgateway는 의미 그대로 Server가 수행하지 못하는 Push 방식으로 Metric 정보를 수집하여 Server에게 전달하는 역활을 수행한다. Batch Job과 같이 Short-lived Job의 Metric 정보의 경우 별도의 Exporter를 짧게 구동하여 해당 Metric을 수집하는 방법 보다는 Pushgateway를 통해서 수집하는 방법이 더욱 효율적이다. Exporter 또는 Pushgateway로 부터 Metric Pull 수행은 Server의 Scape Manager에 의해서 진행된다.

### 2. 참조

* [https://github.com/prometheus/prometheus](https://github.com/prometheus/prometheus)
* [https://github.com/prometheus/prometheus/blob/master/documentation/internal_architecture.md](https://github.com/prometheus/prometheus/blob/master/documentation/internal_architecture.md)
* [https://devconnected.com/the-definitive-guide-to-prometheus-in-2019/](https://devconnected.com/the-definitive-guide-to-prometheus-in-2019/)
* [https://badcandy.github.io/2018/12/25/prometheus-architecture/](https://badcandy.github.io/2018/12/25/prometheus-architecture/)
