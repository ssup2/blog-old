---
title: Consul
category: Theory, Analysis
date: 2020-05-01T12:00:00Z
lastmod: 2020-05-01T12:00:00Z
comment: true
adsense: true
---

Consul을 분석한다.

### 1. Consul

Consul은 **Service Mesh Architecture에서 Control Plan**이 수행하는 Service Discovery, Service Health Check, Service 상태/설정 정보 관리 등의 역활을 수행한다. 이러한 Consul에서 제공하는 기능들은 Consul이 제공하는 **Key-value Store**를 기반으로 하고 있다. Consule의 Key-value Store는 다수의 Consule Cluster로 구성되며 Raft Algorithm, gossip Protocol을 이용하여 High Availability에 중점을 두고 있다.

Service 등록은 Consul API를 통해서 진행되며, 등록된 Service는 DNS 또는 HTTP Request를 통해서 Discovery 할 수 있다. Service 정보에는 해당 Service의 Health Check 방법도 포함되어 있으며, Consul은 등록된 Service의 Health Check 방법을 통해서 해당 Service의 Health를 주기적으로 검사한다. 만약 Consul이 정상 상태가 아닌 Service를 발견하면 해당 Service는 Discovery 대상에서 제외하여, Traffic이 정상 상태가 아닌 Service로 전달되지 않도록 한다.

#### 1.1. Architecture

![[그림 1] Consul Architecture]({{site.baseurl}}/images/theory_analysis/Consul/Consul_Architecture.PNG)

[그림 1]은 Muti-data Center에서 동작하는 Consul의 Architecture를 나타내고 있다. Consul은 다수의 Server/Client들의 집합인 Cluster로 구성되어 동작한다. Consul Cluster는 **gossip Protocol**을 통해서 내부적으로 다수의 gossip Pool을 구성하고 Cluster Member를 관리한다. gossip Pool에는 WAN gossip Pool과 LAN gossip Pool 2가지 Type이 존재한다. WAN gossip Pool은 모든 Data Center에 존재하는 Server들로 구성되어 있다. LAN gossip Pool은 동일 Data Center안에 존재하는 Server/Client들로 구성되어 있다.

gossip Protocol을 통해서 Cluster를 구성하고 있는 Member들은 서로의 Health 상태를 빠르게 검사할 수 있다. 또한 Consul Client는 gossip Protocol을 통해서 LAN gossip Pool의 Server들 중에서 하나의 Server 정보만 알고 있어도 나머지 Server들에 접근할 수 있게 된다. gossip Protocol은 내부적으로 Serf라고 불리는 Algorithm을 이용한다.

### 2. 참조

* [https://www.consul.io/intro/index.html](https://www.consul.io/intro/index.html)
* [https://www.consul.io/docs/internals/architecture.html]*(https://www.consul.io/docs/internals/architecture.html)
* [https://www.consul.io/docs/internals/gossip.html](https://www.consul.io/docs/internals/gossip.html)