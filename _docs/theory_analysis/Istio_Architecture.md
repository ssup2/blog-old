---
title: Istio Architecture
category: Theory, Analysis
date: 2019-05-14T12:00:00Z
lastmod: 2019-05-15T12:00:00Z
comment: true
adsense: true
---

### 1. Istio Architecture

![[그림 1] Istio Architecture]({{site.baseurl}}/images/theory_analysis/Istio_Architecture/Istio_Architecture.PNG){: width="700px"}

[그림 1]은 Istio Architecture를 나타내고 있다. istio는 istio를 제어하는 Control Plan과 App사이의 Data를 주고 받는 Data Plan으로 나눌수 있다. Control Plan은 Pliot, Mixer, Citadel, Mixer 4가지로 구성되어 있고, Data Plan에는 Service를 제공하는 App Pod이 존재한다. 여기서 Service는 Kubernetes의 Service Object 또는 Istio의 Virtual Service Object를 의미한다. App Pod는 실제 App이 동작하는 App Container와 Sidecar Container로 구성되어 있다. 여기서 Sidecar는 App Pod 전용 Proxy Server를 의미한다. Sidecar Container는 실제 Sidecar 역할을 수행하는 Envoy와 Envoy를 Control Plan의 명령에 따라서 설정하는 pilot-agent로 구성되어 있다.

Control Plain의 Pilot은 Kubernetes API Server를 통해서 Kubernetes Cluster에 존재하는 Service를 발견하고, 발견한 Service 정보를 pilot-agent에게 전달하여 Envoy가 Service와 연결된 적절한 App에게 Packet을 Load Balancing 하도록 만든다. Mixer는 App 사이의 Packet 전송 허용 정책을 pilot-agent에게 전달하여 Envoy 사이(App 사이)의 통신을 제한한다. 또한 Mixer는 App Pod에 존재하는 pilot-agent 및 Envoy를 통해 수집된 Metric 정보를 받아, Metric Collector 역할을 수행하는 Adaptor로 Metric 정보를 전달한다. 대표적인 Adaptor로는 Prometheus가 존재한다. Citadel은 pilot-agent에게 인증서를 전달하여 Envoy 사이의 통신 보안을 담당한다. 마지막으로 Gallery는 Control Plan의 나머지 구성요소들을 설정하고 관리하는 역할을 수행한다.

Data Plan의 Envoy는 모든 App Pod의 별도의 Container안에서 동작하며, App이 전송한 모든 Packet을 받아 대신 전송하고, App이 수신해야하는 모든 Packet을 먼저 수신한 다음 다시 App에게 전달하는 Sidecar 역할을 수행한다. pilot-agent는 Control Plan 구성 요소들로부터 필요한 정보들을 받아, Envoy가 Packet Load Balancing, Packet Encap/Decap, Rate Limit, Circuit Breaker 등의 기능을 수행하도록 설정한다. pilot-agent 및 Envoy는 Metric 정보를 수집하고, 수집된 Metric 정보를 Mixer에게 전송한다.

![[그림 2] Istio Architecture After v1.5]({{site.baseurl}}/images/theory_analysis/Istio_Architecture/Istio_Architecture_1.5.PNG){: width="750px"}

Istio는 v1.5 Version 이후부터 Architecture가 변경되었다. [그림 2]는 v1.5 Version 이후의 Istio Architecture를 나타내고 있다. Pliot, Mixer, Citadel이 Istiod라고 불리는 하나의 Component(Binary)로 통합되었고, Mixer는 Deprecated 되었다.

Mixer가 수행하던 App 사이의 Packet 허용 정책은 Envoy의 기능 및 Citadel의 보안 기능으로 대체되었다. Mixer가 수행하던 Rate Limiting도 Envoy의 기능을 이용하도록 변경되었다. Mixer가 수집하던 pilot-agent 및 Envoy의 Metric 정보는 Prometheus, Jeager에서 직접 수집하도록 변경되었다.

### 2. 참조

* Introducing Istio Service Mesh for Microservices
* [https://istio.io/docs/concepts/what-is-istio/](https://istio.io/docs/concepts/what-is-istio/)
* [https://stackoverflow.com/questions/48639660/difference-between-mixer-and-pilot-in-istio](https://stackoverflow.com/questions/48639660/difference-between-mixer-and-pilot-in-istio)
* [https://istio.io/latest/news/releases/1.5.x/announcing-1.5/upgrade-notes/](https://istio.io/latest/news/releases/1.5.x/announcing-1.5/upgrade-notes/)
* [https://istio.io/v1.5/docs/tasks/policy-enforcement/enabling-policy/](https://istio.io/v1.5/docs/tasks/policy-enforcement/enabling-policy/)
* [https://istio.io/latest/blog/2020/istiod/](https://istio.io/latest/blog/2020/istiod/)
* [https://developer.ibm.com/components/istio/blogs/istio-15-release/](https://developer.ibm.com/components/istio/blogs/istio-15-release/)