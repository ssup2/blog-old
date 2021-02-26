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

OpenTracing은 Distributed Tracing을 위한 API를 정의합니다. 여기서 Distributed Tracing은 MSA(Micro Service Architecture)를 위한 Profiling 및 Monitoring 기법을 의미합니다. [그림 1]은 OpenTracing에서 API와 함께 정의하는 Trace를 Graph와 시간축을 기반으로 나타내고 있습니다.

**Trace**는 하나의 요청을 처리하는 큰 흐름을 의미합니다. 여기서 요청은 Client의 요청으로 이해하면 됩니다. 즉 Client가 하나의 요청을 Service에게 전송하고 응답을 기다리는 행위는 OpenTracing 관점에서는 하나의 Trace를 생성하는 과정을 의미합니다. Trace는 Span의 DAG(Directed Acycle Graph)로 구성됩니다. **Span**은 하나의 논리적 실행 단위를 의미합니다. 하나의 Service로 이해하면 됩니다. 즉 Service가 외부의 요청을 처리하는 과정은 OpenTracing 관점에서는 하나의 Span을 생성하는 것을 의미합니다.

### 2. 참조

* [https://opentracing.io/docs/overview/](https://opentracing.io/docs/overview/)
* [https://github.com/opentracing/specification/blob/master/specification.md](https://github.com/opentracing/specification/blob/master/specification.md)