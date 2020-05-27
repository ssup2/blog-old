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

Consul은 **Service Mesh Architecture에서 Control Plan**이 수행하는 Service Discovery, Service Health Check, Service 상태/설정 정보 관리 등의 역활을 수행한다. 이러한 Consul에서 제공하는 기능들은 Consul의 **Key-value Store**를 기반으로 하고 있다. Consule의 Key-value Store는 다수의 Consule Cluster로 구성되며 Raft Algorithm, gossip Protocol을 이용하여 High Availability에 중점을 두고 있다.

Service 등록은 Consul API를 통해서 진행되며, 등록된 Service는 DNS 또는 HTTP Request를 통해서 Discovery 할 수 있다. Service 정보에는 해당 Service의 Health Check 방법도 포함되어 있으며, Consul은 등록된 Service의 Health Check 방법을 통해서 해당 Service의 Health를 주기적으로 검사한다. 만약 Consul이 정상 상태가 아닌 Service를 발견하면 해당 Service는 Discovery 대상에서 제외하여, Traffic이 정상 상태가 아닌 Service로 전달되지 않도록 한다.

#### 1.1. Architecture

![[그림 1] Consul Architecture]({{site.baseurl}}/images/theory_analysis/Consul/Consul_Architecture.PNG)

[그림 1]은 Muti-data Center에서 동작하는 Consul의 Architecture를 나타내고 있다. Consul은 다수의 Server/Client들의 집합인 Cluster로 구성되어 동작한다. Consul Cluster는 **gossip Protocol**을 통해서 내부적으로 다수의 gossip Pool을 구성하고 Cluster Member를 관리한다. gossip Pool에는 WAN gossip Pool과 LAN gossip Pool 2가지 Type이 존재한다. WAN gossip Pool은 모든 Data Center에 존재하는 Server들로 구성되어 있다. LAN gossip Pool은 동일 Data Center안에 존재하는 Server/Client들로 구성되어 있다.

gossip Protocol을 통해서 Cluster를 구성하고 있는 Member들은 서로의 Health 상태를 빠르게 검사할 수 있다. 또한 Consul Client는 gossip Protocol을 통해서 LAN gossip Pool의 Server들 중에서 하나의 Server 정보만 알고 있어도 나머지 Server들에 접근할 수 있게 된다. gossip Protocol은 내부적으로 Serf라고 불리는 Algorithm을 이용한다.

동일 Data Center에 존재하는 Server들 사이의 Data Consensus는 **Raft Algorithm**을 통해서 맞추어 진다. Server는 Raft Algorithm에 의해서 실제 Data를 처리하는 Leader와 Client와 Leader 사이에서 Proxy 역활만 수행하는 Follower로 구성되어 동작한다. Raft Algorithm에 의해서 Server에 저장된 Data들은 동일 LAN gossip Pool의 다른 Server에게 Replication 된다. Raft Algorithm에 참여한 Server들 중에서 동작하는 Server의 개수가 Quorum 이상이라면 Data Loss는 발생하지 않는다. 서로 다른 Data Center에 존재하는 Server들 사이에서는 Replication을 수행하지 않는다.

Client (Agent)는 모든 Node에서 동작하며 Consul에 등록된 Service의 Health Check 정보를 바탕으로 각 Service의 Health Check를 수행한다. Client는 Server로 요청 전송시 자신이 소속된 LAN gossip Pool에 소속된 Server들 중에서 임의의 Server에게 요청을 전송할 수 있다. Client로 부터 요청을 받은 Server는 요청이 자신이 소속된 LAN gossip Pool에서 처리 되어야 하는지 아니면 외부 Data Center에 존재하는 Server에서 처리되어야 하는지 판단한다. 만약 LAN gossip Pool에서 처리 되어야 한다면 Client의 요청은 Leader Server로 전달되어 처리된다.

만약 외부 Data Center에 존재하는 Server에서 처리되어야 한다면 Client 요청을 받은 Server는 WAN gossip Pool에 Client 요청을 처리할 수 있는 Server가 존재하는지 파악하고, Server가 존재한다면 해당 Server가 있는 Data Center의 임의의 Server로 요청을 다시 전달한다. Client 요청을 받은 외부 Data Center의 Server가 Follower라면 Client 요청은 Follower의 Leader로 다시 전달되어 처리된다.

### 2. 참조

* [https://www.consul.io/intro/index.html](https://www.consul.io/intro/index.html)
* [https://www.consul.io/docs/internals/architecture.html](https://www.consul.io/docs/internals/architecture.html)
* [https://www.consul.io/docs/internals/gossip.html](https://www.consul.io/docs/internals/gossip.html)