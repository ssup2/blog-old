---
title: SNMP (Simple Network Management Protocol)
category: Theory, Analysis
date: 2020-05-17T00:34:00Z
lastmod: 2020-05-17T00:34:00Z
comment: true
adsense: true
---

### 1. SNMP (Simple Network Management Protocol)

SNMP (Simple Network Management Protocol)는 의미처럼 Network 관리를 위해서 탄생한 UDP 기반 Protocol이다. SNMP를 통해서 Network Topology를 그릴수 있고 각 Network Segment의 Network 성능, 상태 정보등을 파악할 수 있다. 또한 SNMP의 유연성을 이용하여 Network에 참여하고 있는 Device의 CPU, Memory, Storage 관련 Metric 정보도 수집이 가능하다. SNMP는 v1, v2c, v3 3가지 Version이 존재하며 v2c은 v1에 비해서 Agent에서 한번에 많은양의 Data를 가져오는 Bulk 관련 기능이 추가되었고, v3는 v2에 비해서 인증과 보안 관련 기능이 추가되었다.

![[그림 1] SNMP Architecture]({{site.baseurl}}/images/theory_analysis/SNMP/SNMP_Architecture.PNG){: width="500px"}

[그림 1]은 SNMP의 Architecture를 나타내고 있다. SNMP는 Manager와 Agent로 구성되며 Manager와 Agent 사이의 통신에 이용되는 Protocol이 SNMP이다. [그림 1]에서는 다수의 Agent를 관리하는 Master Agent가 존재하는데 Manager의 입장에서는 Master Agent도 일반 Agent와 다르게 취급하지 않는다. Agent는 Manager의 요청에 의해서 또는 Agent 스스로 MIB라고 불리는 Database로부터 관련 Data를 얻어와 Manager에게 전달한다.

#### 1.1. MIB (Management Information Base)

![[그림 2] OID Tree for MIB]({{site.baseurl}}/images/theory_analysis/SNMP/OID_Tree.PNG)

MIB (Management Information Base)는 Network에 참여하고 각 Device들이 갖고 있는 Data를 관리하는 Database를 의미한다. MIB에서 Data는 Tree 형태로 관리되며 Data의 구분자로 OID (Ojbect ID)를 이용한다. OID는 Tree 형태의 계층 구조를 이용하기 때문에 Tree 형태로 Data를 관리하는 MIB의 Data의 구분자로 적합하다. 

[그림 2]는 MIB를 나타내기 위한 OID Tree를 나타내고 있다. OID Tree를 통해서 OID가 어떤 Data를 의미하는지를 파악할 수 있다. 만약 OID가 "1.3.6.1.2.1"로 시작한다면 OID Tree의 Root에서부터 OID의 앞에서 부터 숫자를 따라가다 보면 MIB 관련 Data를 나타낸다는 것을 알 수 있다. 또한 OID가 "1.3.6.1.2.1.4"라면 MIB의 IP를 나타내는 것을 알 수 있다. Manager는 Agent를 통해서 특정 Device의 IP 정보를 얻고 싶다면. OID "1.3.6.1.2.1.4"를 요청하여 Device의 IP 정보를 얻어온다.

#### 1.2. SNMP Message Type

SNMP Protocol의 Message Type에는 다음과 같은 종류가 존재한다. Message Type과 해당 Message Type이 도입된 SNMP의 Version, Message가 전송되는 방향도 같이 나타내고 있다.

* GetRequest / v1 / Manager->Agent : Manager가 Agent를 통해서 MIB의 특정 Data를 얻기 위해 이용한다.
* GetNextRequest / v1 / Manager->Agent : Manager가 Agent를 통해서 MIB가 저장하고 있는 Tree 구조 Data를 순회하기 위해서 이용된다. Manager가 Agent에게 GetNextRequest 요청을 전송 할때마다 하나의 Data를 응답 받는다.
* GetBulkRequest/ v2 / Manager->Agent : GetNextRequest의 Bulk Version이다. MIB가 저장하고 있는 Tree 구조의 Data중에서 Subtree의 모든 Data를 받기 위해서 이용한다.
* SetRequest/ v1 / Manager->Agent : Manager가 Agent를 통해서 MIB에 특정 Data를 설정하기 위해 이용한다.
* GetResponse/ v1 / Agent->Manager : Manager의 Get/Set 관련 요청에 대한 응답을 위해 이용한다.
* Trap / v1 / Agent->Manager : Manager의 요청때문이 아닌, Agent가 Manager에게 먼저 MIB의 Data를 전송하는 경우에 이용한다.
* InfoRequest / v2 / Manager->Agent : Manager가 Agent로부터 전달받은 Trap Message가 올바른 Message인지 확인하기 위해 이용된다.

### 2. 참조

* [https://www.joinc.co.kr/w/Site/SNMP/document/Intro_net_snmp](https://www.joinc.co.kr/w/Site/SNMP/document/Intro_net_snmp)
* [https://blog.naver.com/koromoon/120183340921](https://blog.naver.com/koromoon/120183340921)
* [https://www.ittsystems.com/what-is-snmp/](https://www.ittsystems.com/what-is-snmp/)
* [https://www.comparitech.com/net-admin/snmp-mibs-oids-explained/](https://www.comparitech.com/net-admin/snmp-mibs-oids-explained/)
* [https://www.paessler.com/it-explained/snmp](https://www.paessler.com/it-explained/snmp)