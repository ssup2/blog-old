---
title: Jaeger Architecture
category: Theory, Analysis
date: 2021-02-24T12:00:00Z
lastmod: 2021-02-24T12:00:00Z
comment: true
adsense: true
---

Jaeger Architecture를 분석한다.

### 1. Jaeger Architecture

Jaeger는 MSA(Micro Service Architecture) Service(App)의 Profiling 및 Monitoring을 제공하는 Distributed Tracing System이다. **OpenTracing** 표준을 따른다. Jaeger는 Kafka를 이용하지 않고 구축하는 방식과 Kafka를 이용하는 방식으로 구축할 수 있다.

#### 1.1 Without Kafka

![[그림 1] Jeager Architecture without Kafka]({{site.baseurl}}/images/theory_analysis/Jeager_Architecture/Jeager_Architecture_without_Kafka.PNG)

[그림 1]은 Kafka를 이용하지 않고 Jaeger를 구축 하였을때의 Architecture를 나타내고 있다. **App** (Service)은 외부의 요청에 의해서 Business Logic을 수행전 또는 수행후에 jaeger-client Library Instumentation을 실행한다. Business Logic을 수행 전 실행하는 Instumentation에서는 Span을 생성하고, Business Logic을 수행 후 실행하는 Instumentation에서는 생성한 Span에 Business Logic 수행에 따른 Trace 관련 정보를 저장하고 jaeger-agent로 전송하는 역활을 수행한다. 여기서 Span은 OpenTracing에서 정의하는 Execution 단위를 의미하며 Trace 정보의 일부를 의미한다.

**jaeger-agent**는 App이 동작하고 있는 동일 Host 또는 동일 Container에서 동작하며 jaeger-client로부터 받은 Trace 정보를 jaeger-collector로 Push하여 전달한다. **jaeger-collector**는 Trace 정보를 Storage에 저장하고, jaeger-agent를 통해서 jaeger-client를 제어하는 역활도 수행한다. jaeger-client를 제어가 필요한 이유는 Trace 정보를 얼마나 수집할지를 결정하는 **Sampling 정책**을 설정하기 위해서이다.

App이 처리하는 모든 Business Logic에 대해서 Span 및 Trace 정보를 생성하면 Host 또는 Container에게도 많은 부하가 발생한다. 이러한 문제를 최소화 하기 위해서 jaeger-client는 App이 처리하는 모든 Business Logic이 아닌 일부만을 Sampling하여 jaeger-agent에게 전송한다. jaeger-collector는 여러개가 동작할 수 있다. 다수의 jaeger-collector가 동작하는 경우 jaeger-client는 Parameter를 통해서 얻은 다수의 jaeger-collector의 IP/Port 정보를 바탕으로 Round Robin 방식으로 Trace 정보를 분산하여 전송한다. 또는 DNS와 같은 Infra Service를 이용하여 jaeger-collector가 Trace 정보를 다수의 jaeger-collector로 분산하도록 만들수도 있다.

**Storage**는 jaeger-collector가 수집한 Metric 정보를 저장한다. 현재 Jeager가 지원하는 Storage의 Backend는 Cassandra, Elasticsearch, BadgerDB, Memory를 지원하며, Jaeger는 Cassandra 이용을 권장하고 있다. Storage에 저장된 Trace 정보는 **Spark Job**을 통해서 분석되며 분석된 Trace 정보를 다시 Storage에 저장한다. **jeager-ui**는 **jeager-query**를 통해서 Storage에 저장되어 있는 원래의 Trace 정보 또는 분석된 Trace 정보를 얻어와 Jeager 이용자에게 보여준다.

Jaeger는 **all-in-one** Binary를 제공하며 all-in-one Binary를 통해서 Jaeger를 동작시키는 경우 Jeager Backend에 포함되어 있는 jaeger-collector, Storage(BadgerDB, Memory), jaeger-query, jaeger-ui가 하나의 Process 안에서 동작하게 된다. Storage의 경우에는 BadgerDB, Memory만 지원하며, Spark Job은 포함되지 않는다.

#### 1.2. With Kafka

![[그림 2] Jeager Architecture with Kafka]({{site.baseurl}}/images/theory_analysis/Jeager_Architecture/Jeager_Architecture_with_Kafka.PNG)

너무 많은 Trace 정보가 Storage로 전송되어 Storage가 너무 큰 부하를 받게되는 경우, Kafka를 도입하여 Storage의 부하를 낮출 수 있다. [그림 2]는 Kafka를 이용하여 Jeager를 구축 하였을때의 Architecture를 나타내고 있다. Host 또는 Container 부분은 [그림 1]과 동일하지만 Jaeger Backend 부분이 달라진것을 확인할 수 있다. jaeger-collector는 Trace 정보를 Storage에 바로 전송하지 않고 Kafka에게 전송한다. Kafka는 Trace 정보 Queue의 역활을 수행한다.

**jaeger-ingester**는 Kafka로부터 Trace 정보를 얻어와 Storage에 저장하는 역활을 수행한다. **Flink Streaming**은 Kafka로부터 Trace 정보를 얻은 다음 분석하여 Storage에 저장한다.

### 2. 참조

* [https://www.jaegertracing.io/docs/1.22/architecture/](https://www.jaegertracing.io/docs/1.22/architecture/)
* [https://www.jaegertracing.io/docs/1.22/deployment/](https://www.jaegertracing.io/docs/1.22/deployment/)
* [https://www.scalyr.com/blog/jaeger-tracing-tutorial/](https://www.scalyr.com/blog/jaeger-tracing-tutorial/)
* [https://github.com/jaegertracing/spark-dependencies](https://github.com/jaegertracing/spark-dependencies)
* [https://github.com/jaegertracing/jaeger-analytics-flink](https://github.com/jaegertracing/jaeger-analytics-flink)
* [https://github.com/opentracing/specification/blob/master/specification.md](https://github.com/opentracing/specification/blob/master/specification.md)