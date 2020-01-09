---
title: Prometheus High Availability
category: Theory, Analysis
date: 2020-01-07T12:00:00Z
lastmod: 2020-01-07T12:00:00Z
comment: true
adsense: true
---

Prometheus의 High Availability 구성 방법을 분석한다.

### 1. Prometheus High Availability

![[그림 1] Prometheus HA 구성]({{site.baseurl}}/images/theory_analysis/Prometheus_High_Availability/Prometheus_HA.PNG){: width="700px"}

[그림 1]은 Prometheus Pushgateway와 Prometheus Server의 HA (High Availability) 구성 방법을 나타내고 있다. Promethues Pushgateway는 Load Balancer를 통해서 Batch Job에게 노출된다. 따라서 Promethues Pushgateway의 일부가 죽더라도 하나 이상의 Promethues Pushgateway가 살아있다면, Batch Job은 Load Balancer를 통해서 살아있는 Promethues Pushgateway로 Metric을 전송할 수 있다. 하지만 Promethues Server가 Prometheus Pushgateway에 저장된 Metric을 가져가기 전에 Prometheus Pushgateway가 죽는다면 Metric 유실이 발생한다.

### 2. 참조

* [https://www.perimeterx.com/blog/scaling-out-with-prometheus/](https://www.perimeterx.com/blog/scaling-out-with-prometheus/)
* [https://coreos.com/operators/prometheus/docs/latest/high-availability.html](https://coreos.com/operators/prometheus/docs/latest/high-availability.html)
* [https://prometheus.io/docs/introduction/faq/#can-prometheus-be-made-highly-available](https://prometheus.io/docs/introduction/faq/#can-prometheus-be-made-highly-available)
* [https://promcon.io/2017-munich/slides/alertmanager-and-high-availability.pdf](https://promcon.io/2017-munich/slides/alertmanager-and-high-availability.pdf)
* [https://github.com/prometheus/pushgateway/issues/241](https://github.com/prometheus/pushgateway/issues/241)
