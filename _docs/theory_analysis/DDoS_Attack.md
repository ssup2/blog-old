---
title: DDoS Attack
category: Theory, Analysis
date: 2022-09-14T12:00:00Z
lastmod: 2022-09-14T12:00:00Z
comment: true
adsense: true
---

DDoS (Distributed Denial-of-Service) Attack을 정리한다.

### 1. DDoS (Distributed Denial-of-Service) Attack

DDoS Attack은 특정 Server/Service에 비정상적인 Traffic을 전송하여 Server/Service의 장애를 유발하는 모든 공격을 의미한다. 여러 기법의 DDoS Attack이 존재하며, 대부분의 DDoS Attack 기법의 공격자는 Server/Service에 접근 가능한 불특정 다수가 될수 있다는 특징을 가지고 있다. 따라서 Public Network로 노출되는 Server/Service의 경우에는 반드시 DDoS Attack에 대비해야 한다.

### 2. DDoS Attack Type

DDoS Attack은 특성에 따라서 Volumetric Attack, Protocol Attack, Application Layer Attack Type으로 구분할 수 있으며, 하나의 DDoS Attack 기법이 여러 Type에 포함될 수도 있다.

#### 2.1. Volumetric Attack

Volumetric Attack은 대용량의 Traffic을 특정 Server/Service에게 전송하여 특정 Server/Service의 장애를 유발하는 Type을 의미한다. Traffic 부하로 인해서 Network 장애를 유발시키거나, Server 부하를 발생시켜 Server 장애를 유발시킨다. 대부분의 DDoS Attack 기법이 Volumetric Type에 해당한다. 다음과 같은 Volumetric Type 기법들이 존재한다.

* HTTP Flood
* DNS 증폭/반사

#### 2.2. Protocol Attack

Procotol Attack은 Protocol을 활용하여 Server를 Resource 부족 상태로 만들어 장애를 유발시킨다. 다음과 같은 Procotol Attack이 존재한다.

* Sync Flood
* Smurf Attack

#### 2.3. Application Layer Attack

Application Layer Attack은 Application Layer Protocol을 활용하여 특정 Server/Service의 부하를 발생시켜 장애를 유발시킨다.

* HTTP Flood

### 3. DDoS Attack 기법

#### 3.1. Sync Flood

Sync Flood는 TCP Protocol의 3-Way Handshake시 이용하는 Sync Packet을 활용한 공격 기법이다. TCP 3-Way Handshake에 의해서 Sync Packet을 받은 Server는 Sync + ACK Packet을 Client에 전송한 이후에 Client로부터 전송되는 ACK Packet을 대기하게 된다. Server가 ACK Packet을 대기하는 동안에도 Server는 TCP Connection 관련 자원을 이용하게 된다. 따라서 Server의 TCP Connection 관련 자원이 ACK Packet 대기로 인해서 고갈되는 경우, Server는 새로운 TCP Connection을 더이상 맺을 수 없다.

Sync Flood는 이러한 약점을 이용하는 공격 기법이다. 공격자는 Server에게 전송하는 Sync Packet의 Source IP를 유효하지 않는 IP로 변경하여 전송한다. Server는 Sync Packet 수신한 이후에 Sync Packet의 Source IP를 대상으로 Sync + ACK Packet을 전송하지만 유효하지 않는 IP이기 때문에 Server는 ACK Packet을 받지 못하고 ACK Packet을 계속 대기하는 상태가 된다. 공격자가 다수의 Source IP가 변경된 Sync Packet을 보낸다면 Server의 TCP Connection 관련 자원은 고갈되고, Server는 새로운 TCP Connection을 맺을수 없으면서 장애가 발생한다.

Sync Flood 기법은 L4 기반 Protocol Attack Type이며, 일반적으로 TCP ACK Packet을 탐지할 수 있는 L4 기반의 Firewall을 활용하여 공격으로부터 보호한다.

#### 3.2. HTTP Flood

HTTP Flood는 HTTP Procotol을 활용하여 특정 Server/Service에게 다수의 요청을 전송하는 공격 기법이다. 일반적으로 HTTP Protocol의 각 요청을 탐지할 수 있는 L7 기반의 Firewall을 활용하여 공격으로부터 보호한다. HTTP Keepalived Protocol을 이용하면 하나의 TCP Connection 내부에서 다수의 요청을 전송하는 것이 가능하기 때문에, L4 기반의 Firewall을 활용해서는 HTTP Flood를 막을 수 없다.

#### 3.3. Smurf Attack



### 4. 참조

* [https://www.akamai.com/ko/our-thinking/ddos](https://www.akamai.com/ko/our-thinking/ddos)
* [https://www.imperva.com/learn/ddos/ddos-attacks/](https://www.imperva.com/learn/ddos/ddos-attacks/)
* [https://www.onelogin.com/learn/ddos-attack](https://www.onelogin.com/learn/ddos-attack)
* [https://cybersecurity.att.com/blogs/security-essentials/types-of-ddos-attacks-explained](https://cybersecurity.att.com/blogs/security-essentials/types-of-ddos-attacks-explained)
* Sync Flood : [https://www.cloudflare.com/learning/ddos/syn-flood-ddos-attack/](https://www.cloudflare.com/learning/ddos/syn-flood-ddos-attack/)