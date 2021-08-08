---
title: 자격증 AWS Solutions Architect Professional 이론 정리
category: Record
date: 2019-11-01T12:00:00Z
lastmod: 2021-08-09T12:00:00Z
comment: true
adsense: true
---

### 1. IAM

### 2. S3

* Object Storage
* Static Data 저장소
  * 분석용 Data Store
  * 백업용 Store

#### 2.1. 비용

#### 2.2. Versioning

* 이전 Data를 저장하는 Versioning 기능 제공
* Versioning으로 이해 늘어난 용량만큼 비용 청구

#### 2.3. Multi Part Upload

* 사용자가 지정한 크기로 파일을 쪼개어 병렬로 Upload 기능
* 병렬로 Upload된 이후에 S3 내부에서 통합
* Web Console 지원 X 

### 3. EC2

* Compute Instance 제공

#### 3.1. User Data

* EC2 Instance가 **처음 부팅**될때 딱 한번만 실행되는 Script를 의미한다.
* root User로 실행된다.

#### 3.2. Lunch Type

* On-Demand Instance : 예상하지 못한 Event 발생을 대처하기 위해서 예약없이 투입된 Instance를 의미한다. 가장 높은 이용비를 갖는다.

* Reserved Instance
  * Reserved Instance : 예약된 Instance를 의미한다. On-Demand Instance에 비해서 최대 75% 저렴하다. 1~3년 단위로 예약이 가능하다.
  * Convertible Reserved : 예약된 Instance이지만 Type을 변경할 수 있다. On-Demand Instance에 비해서 최대 54% 저렴하다.
  * Scheduled Reserved : 날짜, 주, 월 주기로 예약된 Instance를 의미한다.

* Spot Instance : 언제든지 중단될수 있는 Instance를 의미한다. 가장 저렴한 Instacnce이다. On-Demand Instance에 비해서 최대 90% 저렴하다.

* Dedicated Instance : ??

* Dedicated Host : ??

#### 3.3. Snapshot

#### 3.4. Placement Groups

* EC2 Instance의 배치 전략을 설정할 수 있다.
* Cluster : Low Latency를 위해서 하나의 Availability Zone안의 하나의 Rack(Partition)에 위치시킨다.
* Spread : 다수의 Availability Zone에 분산시켜 가용성(High Availability)을 올린다.
* Partition : 하나의 Availability Zone에서 다수의 Rack(Partition)에 분산시킨다.

#### 3.5 Security Group

* Default 정책 : 모든 Inboud Traffic은 거부, 모든 Outbound Traffic은 허용한다.
* Src IP, Dest IP, Security Group 단위로 허용 여부를 설정할 수 있다.

#### 3.6 ENI (Elastric Network Interfaces)

* VPC에서 하나의 Virtual Network Card를 의미한다.
* 하나의 Primary Private IPv4와 다수의 Secondary IPv4를 갖을 수 있다.
* 하나의 Private IPv4 하나당 하나의 Elastic IP를 갖을 수 있다.
* 하나의 Public IP를 갖을 수 있다.
* 하나 이상의 Security Group에 포함될 수 있다.
* 하나의 MAC Address를 갖는다.
* 동일한 Availability Zone 내부의 EC2 Instance 사이에 속성 변경없이 이동이 가능하다. Failover시 유용한 기능이다.

### 4. ELB (Elastric Load Balancing)

* Load Balancer
* Upgrade, Maintenance, High Availability 보장
* Classic Load Balancer (CLB) : HTTP, HTTPS, TCP를 지원한다. v1, Old Generation Load Balancer이다.
* Application Load Balancer (ALB) : HTTP, HTTPS, WebScoket를 지원한다. v2, New Generation Load Balancer이다.
* Network Load Balancer (NLB) : TCP, TLS, UDP를 지원한다. v2, New Generation Load Balancer이다.

