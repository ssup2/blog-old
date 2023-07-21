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

#### 1.1. Span

각 Span은 다음과 같은 내용들로 구성되어 있다.

##### 1.1.1. Operation Name

Span은 Span이 수행하는 Operation의 이름을 저장하고 있다.

##### 1.1.2. Timestamp

Span은 Span이 시작되는 시간 정보인 Start Timestmp와 Span이 종료되는 시간 정보인 Finish Timestamp를 갖고 있다.

##### 1.1.3. Reference

MSA의 Service가 서로 참조(호출)관계를 갖는것 처럼 Span도 서로 참조 관계를 갖는다. Span은 Span 사이의 참조 관계 정보를 저자하고 있다. OpenTracing에서는 Span의 참조 관계를 **ChildOf**와 **FollowsFrom** 2가지를 정의하고 있다. ChildOf는 부모 Span이 자식 Span에게 의존성을 갖고 있어, 부모 Span이 자식 Span이 종료될때까지 기다리다가 자식 Span이 종료가 되면 다음 동작을 수행하는 관계를 의미한다. [그림 1]에서 Span B와 Span C, Span B와 Span C는 ChildOf 참조 관계를 갖고 있기 때문에, Span B는 Span C,D가 종료되기 전까지 대기한다.

FollowsFrom는 부모 Span이 자식 Span에게 의존성을 갖고 있지 않아, 부모 Span이 자식 Span을 호출만하고 자식 Span이 종료될때까지 대기하지 않는 관계를 의미한다. [그림 1]에서 Span E와 Span F, Span F와 Span G는 FollowsFrom 참조 관계를 갖고 있다. 따라서 Span E는 Span F가 종료되기 전에 먼저 종료되고 Span F는 Span G가 종료되기 전에 먼저 종료되는것을 확인 할 수 있다.

##### 1.1.4. Tag, Log

Span은 Span을 Query하거나 Filtering할때 이용하는 Annotation인 Tag 정보를 저장하고 있다. Tag는 Key-Value Pair로 구성되어 있다. 또한 Span은 App의 특정 상태나 App의 Event를 저장할때 이용하는 Log 정보도 저장하고 있다. Log도 Key-Value Pair로 구성되어 있다.

##### 1.1.5. SpanContext

Span은 다른 Span을 호출할 경우 SpanContext라고 불리는 Data도 같이 전달한다. SpanContext에는 일반적으로 Trace ID, Span ID 그리고 Baggage가 저장되어 있다. Trace ID는 Span이 소속되어 있는 Trace의 ID 정보를 의미하고, Span ID는 현재 Span의 ID를 의미한다. 따라서 하나의 Trace 안에서 Trace ID는 Span이 변경되도 유지되지만, Span ID는 Span이 변경될때 마다 같이 변경된다. Trace ID와 Span ID를 통해서 각각의 Trace와 Span을 구분하여 Distributed Tracing을 가능하도록 만든다.

Baggage는 하나의 Trace 내부에서 Span 사이에 공유(전달)되어야 하는 Data를 저장하는 공간이다. Baggage는 Key-Value Pair로 구성되어 있다.

### 2. Protocol

OpenTracing을 지원하는 Protocol은 [Trace-Context HTTP Headers](https://github.com/w3c/trace-context/tree/main/spec)과 [B3 HTTP Headers](https://github.com/openzipkin/b3-propagation)가 존재한다. 두 Protocol 모두 현재 많이 이용되고 있는 Protocol이다.

### 3. 참조

* [https://opentracing.io/docs/overview/](https://opentracing.io/docs/overview/)
* [https://opentracing.io/docs/overview/spans/](https://opentracing.io/docs/overview/spans/)
* [https://github.com/opentracing/specification/blob/master/specification.md](https://github.com/opentracing/specification/blob/master/specification.md)
* [https://github.com/opentracing/specification/blob/master/rfc/trace_identifiers.md](https://github.com/opentracing/specification/blob/master/rfc/trace_identifiers.md)
* [https://github.com/openzipkin/b3-propagation](https://github.com/openzipkin/b3-propagation)
* [https://github.com/w3c/trace-context/tree/main/spec](https://github.com/w3c/trace-context/tree/main/spec)