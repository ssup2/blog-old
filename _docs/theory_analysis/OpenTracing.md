---
title: OpenTracing
category: Theory, Analysis
date: 2021-02-28T12:00:00Z
lastmod: 2021-02-28T12:00:00Z
comment: true
adsense: true
---

OpenTracing을 분석한다.

### 1. OpenTracing

![[그림 1] Trace]({{site.baseurl}}/images/theory_analysis/OpenTracing/Trace.PNG)

OpenTracing은 Distributed Tracing을 위한 API를 정의하고 있다. 여기서 Distributed Tracing은 MSA(Micro Service Architecture)를 위한 Profiling 및 Monitoring 기법을 의미한다. [그림 1]은 OpenTracing에서 API와 함께 정의하는 Trace를 Graph와 시간축을 기반으로 나타내고 있다.

OpenTracing에서 **Trace**는 하나의 요청을 처리하는 큰 흐름을 의미한다. 여기서 요청은 Client의 요청으로 이해하면 된다. 즉 Client가 하나의 요청을 Service에게 전송하고 응답을 기다리는 행위는 OpenTracing 관점에서는 하나의 Trace를 생성하는 과정을 의미한다. Trace는 OpenTracing에서 정의하는 하나의 논리적 실행단위인 **Span**의 DAG(Directed Acycle Graph)로 구성된다. 일반적으로는 Span은 하나의 Service를 의미한다. 따라서 [그림 1]의 DAG는 하나의 Client의 요청을 다수의 Service가 처리하는 MSA의 Service Call Graph라고 봐도 무방하다.

### 2. 참조

* [https://opentracing.io/docs/overview/](https://opentracing.io/docs/overview/)
* [https://github.com/opentracing/specification/blob/master/specification.md](https://github.com/opentracing/specification/blob/master/specification.md)