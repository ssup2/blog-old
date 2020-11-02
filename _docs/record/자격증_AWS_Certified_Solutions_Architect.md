---
title: 자격증 AWS Certified Solutions Architect
category: Record
date: 2019-11-01T12:00:00Z
lastmod: 2020-07-14T12:00:00Z
comment: true
adsense: true
---

### 1. IAM

### 2. EC2

#### 2.1. User Data

* EC2 Instance가 **처음 부팅**될때 딱 한번만 실행되는 Script를 의미한다.
* root User로 실행된다.

#### 2.2. Lunch Type Type

* On-Demand Instance : 예상하지 못한 Event 발생을 대처하기 위해서 예약없이 투입된 Instance를 의미한다. 가장 높은 이용비를 갖는다.

* Reserved Instance
  * Reserved Instance : 예약된 Instance를 의미한다. On-Demand Instance에 비해서 최대 75% 저렴하다. 1~3년 단위로 예약이 가능하다.
  * Convertible Reserved : 예약된 Instance이지만 Type을 변경할 수 있다. On-Demand Instance에 비해서 최대 54% 저렴하다.
  * Scheduled Reserved : 날짜, 주, 월 주기로 예약된 Instance를 의미한다.

* Spot Instance : 언제든지 중단될수 있는 Instance를 의미한다. 가장 저렴한 Instacnce이다. On-Demand Instance에 비해서 최대 90% 저렴하다.

* Dedicated Instance : ??

* Dedicated Host : ??

#### 2.3. Snapshot

#### 2.4. Placement Groups

* EC2 Instance의 배치 전략을 설정할 수 있다.
* Cluster : Low Latency를 위해서 하나의 Availability Zone안의 하나의 Rack(Partition)에 위치시킨다.
* Spread : 다수의 Availability Zone에 분산시켜 가용성(High Availability)을 올린다.
* Partition : 하나의 Availability Zone에서 다수의 Rack(Partition)에 분산시킨다.

### 3. Security Group

* Default 정책 : 모든 Inboud Traffic은 거부, 모든 Outbound Traffic은 허용한다.
* Src IP, Dest IP, Security Group 단위로 허용 여부를 설정할 수 있다.

#### 4. ENI (Elastric Network Interfaces)

* VPC에서 하나의 Virtual Network Card를 의미한다.
* 하나의 Primary Private IPv4와 다수의 Secondary IPv4를 갖을 수 있다.
* 하나의 Private IPv4 하나당 하나의 Elastic IP를 갖을 수 있다.
* 하나의 Public IP를 갖을 수 있다.
* 하나 이상의 Security Group에 포함될 수 있다.
* 하나의 MAC Address를 갖는다.
* 동일한 Availability Zone 내부의 EC2 Instance 사이에 속성 변경없이 이동이 가능하다. Failover시 유용한 기능이다.

#### 5. ELB (Elastric Load Balancing)

* Load Balancer
* Upgrade, Maintenance, High Availability 보장
* Classic Load Balancer : HTTP, HTTPS, TCP를 지원한다. v1, Old Generation Load Balancer이다.
* Application Load Balancer : HTTP, HTTPS, WebScoket를 지원한다. v2, New Generation Load Balancer이다.
* Network Load Balancer : TCP, TLS, UDP를 지원한다. v2, New Generation Load Balancer이다.

