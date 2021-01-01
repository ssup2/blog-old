---
title: Istio Architecture
category: Theory, Analysis
date: 2019-05-14T12:00:00Z
lastmod: 2019-05-15T12:00:00Z
comment: true
adsense: true
---

### 1. Istio Architecture

![[그림 1] Istio Architecture]({{site.baseurl}}/images/theory_analysis/Istio_Architecture/Istio_Architecture.PNG){: width="600px"}

[그림 1]은 Istio Architecture를 나타내고 있다. istio는 istio를 제어하는 Control Plan과 Service 사이의 Data를 주고 받는 Data Plan으로 나눌수 있다.

Control Plan은 Pliot, Mixer, Citadel, Mixer 4가지로 구성되어 있다. Pilot은 Service Discovery를 통해 얻은 Service 정보와 istio User가 설정한 Service Routing 정보를 Envoy에게 전달하여, Envoy가 적절한 Service(App)에게 Packet을 Routing 하도록 도와준다. Mixer는 Service 사이의 Packet 허용 정책을 Envoy에게 전달하여, Service가 자신에게 허용된 다른 Service만 호출할 수 있도록 제한한다. 또한 Mixer는 Envoy를 통해 수집된 Metric 정보를 받아 Metric Collector 역활을 수행하는 Adaptor로 Metric 정보를 전달한다. 대표적인 Adaptor로는 Prometheus가 존재한다. Citadel은 Envoy에게 인증서를 전달하여 Envoy 사이의 통신 보안을 담당한다. 마지막으로 Gallery는 Control Plan의 나머지 구성요소들을 설정하고 관리하는 역할을 수행한다.

Data Plan에는 Envoy가 존재한다. Envoy는 모든 Service(App) Pod의 별도의 Container 안에서 동작하며, Service가 전송한 모든 Packet을 받아 대신 전송하고, Service가 수신해야하는 모든 Packet을 대신 수신하여 Service에게 전달하는 **Sidecar** 역할을 수행한다. Envoy는 Control Plan의 구성요소들의 도움을 받아 Service Load Balancing, Circuit Breaker, Healt Check 등의 기능을 수행하여 Packet을 적절한 Service에게 전달하는 역할을 수행한다. 또한 Envoy가 전송/전달 받는 Packet의 Metric 정보 수집하고 Mixer에게 전달한다. Envoy 사이의 통신은 HTTP/1.1, HTTP/2, gRPC, TCP등의 다양한 Protocol을 지원한다.

![[그림 2] Istio Architecture After v1.5]({{site.baseurl}}/images/theory_analysis/Istio_Architecture/Istio_Architecture_1.5.PNG){: width="700px"}

Istio는 v1.5 Version 이후부터 Architecture가 변경되었다. [그림 2]는 v1.5 Version 이후의 Istio Architecture를 나타내고 있다. Pliot, Mixer, Citadel이 Istiod라고 불리는 하나의 Component (Binary)로 통합되었다. Mixer는 Deprecated 되었으며 Envoy에서 수집된 Metric 정보는 Prometheus, Jeager에서 직접 수집한다.

### 2. 참조

* Introducing Istio Service Mesh for Microservices
* [https://istio.io/docs/concepts/what-is-istio/](https://istio.io/docs/concepts/what-is-istio/)
* [https://stackoverflow.com/questions/48639660/difference-between-mixer-and-pilot-in-istio](https://stackoverflow.com/questions/48639660/difference-between-mixer-and-pilot-in-istio)
* [https://istio.io/latest/news/releases/1.5.x/announcing-1.5/upgrade-notes/](https://istio.io/latest/news/releases/1.5.x/announcing-1.5/upgrade-notes/)
* [https://istio.io/latest/blog/2020/istiod/](https://istio.io/latest/blog/2020/istiod/)
* [https://developer.ibm.com/components/istio/blogs/istio-15-release/](https://developer.ibm.com/components/istio/blogs/istio-15-release/)