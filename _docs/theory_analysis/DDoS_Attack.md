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
* ICMP Flood
* DNS 증폭/반사

#### 2.2. Protocol Attack

Procotol Attack은 Protocol을 활용하여 Server를 Resource 부족 상태로 만들어 장애를 유발시킨다. 다음과 같은 Procotol Attack이 존재한다.

* Sync Flood
* smurf

#### 2.3. Application Layer Attack

Application Layer Attack은 Application Layer Protocol을 활용하여 특정 Server/Service의 부하를 발생시켜 장애를 유발시킨다.

* HTTP Flood

### 3. DDoS Attack 기법

#### 3.1. HTTP Flood

#### 3.2. Sync Flood

#### 3.3. ICMP Flood

### 4. 참조

* [https://www.akamai.com/ko/our-thinking/ddos](https://www.akamai.com/ko/our-thinking/ddos)
* [https://www.imperva.com/learn/ddos/ddos-attacks/](https://www.imperva.com/learn/ddos/ddos-attacks/)
* [https://www.onelogin.com/learn/ddos-attack](https://www.onelogin.com/learn/ddos-attack)
* [https://cybersecurity.att.com/blogs/security-essentials/types-of-ddos-attacks-explained](https://cybersecurity.att.com/blogs/security-essentials/types-of-ddos-attacks-explained)