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

![[그림 1] Prometheus Architecture]({{site.baseurl}}/images/theory_analysis/Prometheus_Architecture/Prometheus_Architecture.PNG){: width="700px"}

[그림 1]은 Prometheus Architecture를 나타내고 있다. Prometheus는 크게 Server, Exporter, Alertmanager, Pushgateway로 구성되어 있다. Exporter는 Metric 정보를 **수집**하고 **Aggregate**하는 역활을 수행한다. 하나의 Server에 다수의 Exporter를 연동하여 이용할 수 있다. 일반적으로 Exporter는 용도별로 구분된다. 예를들어 Node Exporter는 특정 Node의 Metric 정보를 수집하는 역활을 수행한다. MySQL Exporter는 특정 MySQL DB의 Metric 정보를 수집하는 역활을 수행한다.

Exporter가 수집하고 Aggregate한 Metric정보는 Exporter에 의해서 먼져 Server에게 Push하는 방식이 아닌, Server에서 먼져 Exporter로부터 **Pull**하는 방식을 이용한다. 즉 모든 Metric 정보는 Exporter가 아닌 Server가 중심이 되어 수집된다. 이러한 Server 중심의 Metric 수집 방식은 Server 스스로 Metric 수집에 의한 부하를 조절할 수 있는 큰 장점을 갖게 된다. Exporter의 개수가 많아져 수집할 Metric의 양이 증가할 경우, Server가 각 Exporter의 Metric을 Pull하는 주기를 능동적으로 늘릴 수 있기 때문이다. 하지만 Pull 방식은 Event를 기록하기에는 적합한 방식은 아니다. Event가 발생하여 Exporter에 저장되어도 Server에 전달되는 시점은 Event와 관계없는 Server의 Metric 수집 주기에 의해서 결정되기 때문이다.

Pushgateway는 의미 그대로 Server가 수행하지 못하는 Push 방식으로 Metric 정보를 수집하여 Server에게 전달하는 역활을 수행한다. Batch Job과 같이 Short-lived Job의 Metric 정보의 경우 별도의 Exporter를 짧게 구동하여 해당 Metric을 수집하는 방법 보다는 Pushgateway를 통해서 수집하는 방법이 더욱 효율적이다. Exporter 또는 Pushgateway로 부터 Metric Pull 수행은 Server의 Scrape Manager에 의해서 진행된다. Scrap Manager는 수집한 Metric을 Storage에 저장한다. 또한 Scrap Manager는 Metric을 수집해야할 Target (Service)의 변경 내용을 발견하고, 필요에 따라서 Notifier에게 변경된 Target의 정보도 전달하는 역활도 수행한다. Target 정보는 K8s, Marathon, OpenStack, DNS 같은 특정 Platform 또는 Server로 부터 얻어온다.

Storage는 기본적으로 TSDB (Time Serise Data Base) 역활을 수행하는 Local Storage를 이용하며 추가적으로 외부에 있는 Remote Storage를 이용할 수 있다. 현재는 Remote Storage에서도 Metric 정보를 읽어올수 있지만 추후에 Remote Storage에는 Metric Write 동작만 허용하도록 변경될 예정이다. PromQL Engine은 Storage에 저장된 Metric 정보를 바탕으로 PromQL Query를 처리를 수행하는 역활을 수행한다. Grafana와 같은 Client는 PromQL Query를 통해서 원하는 Metric 정보를 얻는다.

Rule Manager는 Prometheus 사용자가 지정한 Alert Rule을 관리하고, PromQL Engine에게 PromQL Query를 통해서 설정한 Alret Rule의 조건이 충족되었는지 주기적으로 확인한다. 만약 Alret Rule의 조건이 충족되었다면 Rule Manager는 해당 Alret을 Notifier를 통해서 Alertmanager에게 전달한다. Notifier는 Rule Manager의 Alret뿐만 아니라 Target의 변경 내용을 발견하고 해당 변경 내용을 Alert으로 Alertmanager에게 전달하는 기능도 수행한다. Alertmanager는 Notifier로부터 전달 받은 Alret을 Alretmanager에 설정된 Alret 목적지 정보에 따라 전달한다. Alret 목적지로는 Email, HTTP/HTTPS, Webhook, Slack의 방법 등을 지원하고 있다.

### 2. 참조

* [https://github.com/prometheus/prometheus](https://github.com/prometheus/prometheus)
* [https://github.com/prometheus/prometheus/blob/master/documentation/internal_architecture.md](https://github.com/prometheus/prometheus/blob/master/documentation/internal_architecture.md)
* [https://devconnected.com/the-definitive-guide-to-prometheus-in-2019/](https://devconnected.com/the-definitive-guide-to-prometheus-in-2019/)
* [https://badcandy.github.io/2018/12/25/prometheus-architecture/](https://badcandy.github.io/2018/12/25/prometheus-architecture/)
