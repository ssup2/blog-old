---
title: 자격증 AWS Solutions Architect Professional 이론 정리
category: Record
date: 2019-11-01T12:00:00Z
lastmod: 2021-08-09T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. IAM

### 2. S3

* Object Storage
* Size Limit가 존재하지 않음
* Static Data 저장소
  * Object Update시 Object 전체를 다시 Upload를 수합해야 때문에 Update가 잘 발생하지 않는 Static Data 저장에 적합
  * 분석용 Data Store
  * 백업용 Store

#### 2.1. Bucket

* Bucket 이름 중복 불가능

#### 2.2. 용량

* 각 Object의 용량은 최대 5TB
* Object의 개수 무제한

#### 2.3. Replication

* Region 단위 복제 수행

#### 2.4. Access Control

* IAM 기반 정책
* Bucket 기반 정책 (Resource 기반 정책)
  * Web Console에서 Bucket 단위로 설정
  * Public : 외부 User에게 공개
  * Private : 외부 User에게 비공개
  * Limited Access : 특정 User
* CORS 기능 제공

#### 2.5. 비용

* 비용 발생
  * 사용하고 있는 Size 비례, 단위는 GB
  * Region 경계를 넘어서 Object 송수신
    * 다른 Region 또는 외부 Internet으로 전송시 발생

* 비용 발생 X
  * Region 내부에서의 Object 송수신
    * CloudFront <-> S3 사이의 송수신  

#### 2.6. Storage Class

* S3 Standard
  * 표준 Class
* S3 Standard IA 
  * 저장 비용은 감소하지만 Access 비용은 증가
  * 자주 접근하지 않는 Object를 이용하는 경우 유리
* S3 One Zone IA
  * 하나의 Region에서만 Object를 저장
  * 저장 비용 감소
* Glacier
  * Cold Data 저장소
  * Object를 압축해서 저장
  * 압축된 Object를 이용하기 위해서는 복원과정 필요
  * 복원이된 Object는 일정 기간동안 S3에서 Access 가능
* S3 Inteligent Tiering
  * Maching Learning 기반으로 Pattern을 분석하여 적절한 Storage Class로 이용
  * Pattern 분석 비용 발생

#### 2.7. Event Trigger 수행

* Lamba Service Event Trigger 역활 수행

#### 2.8. Static Web Server 기능 제공

* Bucket 단위로 Static Web Server 기능 On/Off 가능
* Bucket 권한을 Public으로 설정 필요
* 하나의 Bucket당 하나의 Web Server만 제공 가능

#### 2.9. Versioning

* 이전 Data를 저장하는 Versioning 기능 제공
* Versioning으로 인해 늘어난 용량 만큼 비용 청구

#### 2.10. Multi Part Upload

* 사용자가 지정한 크기로 파일을 쪼개어 병렬로 Upload 기능
* 병렬로 Upload된 이후에 S3 내부에서 통합
* Web Console 지원 X

#### 2.10. Transfer Accelation

* CloudFront Edge를 통해서 AWS 내부 Backbone Network를 활용하여 Object Upload 가능

#### 2.11. Snowball, Snowmobile

* 저장 장치를 AWS로 전송받아 저장후 AWS에게 저장 장치를 전달하여 S3에 복사하는 방법
* 일반적으로 7일 정도 시간이 소요되기 때문에, S3로 Upload가 7일 이상 걸린다면 이용을 고려

### 3. EC2

* Compute Instance 제공

#### 3.1. Flavor

* Flavor Format
  * <FamilyName><GenerationNum>.<Size>
    * t3.large / c5.xlarge / p3.2xlarge 
* Flavor Scale Up/Down 가능
* Genration이 높을수록 가성비가 좋아짐

#### 3.2. User Data

* EC2 Instance가 **처음 부팅**될때 딱 한번만 실행되는 Script를 의미한다.
* root User로 실행된다.

#### 3.3. Block Storage

* EBS
  * 비휘발성 Storage
  * Flavor에 따라서 선택 가능
  * EBS 최적화 Instance 기능 제공 (Flavor로 선택 가능)
    * EBS를 위한 추가 Network Bandwidth 할당
    * EBS와 다른 Traffic 사이의 경합 최소화
  
* Instance Storage
  * 휘발성 Storage
  * Hypervisor Local Storage 이용
  * EBS에 비해서 높은 성능
  * Flavor에 따라서 선택 가능

#### 3.4. File Stroage

* EFS
  * Linux File Server
  * NFS Server
* FSx
  * Windows File Server
  * NTFs

#### 3.5. 비용에 따른 

* On-Demand Instance : 예상하지 못한 Event 발생을 대처하기 위해서 예약없이 투입된 Instance를 의미한다. 가장 높은 이용비를 갖는다.

* Reserved Instance
  * Reserved Instance : 예약된 Instance를 의미한다. On-Demand Instance에 비해서 최대 75% 저렴하다. 1~3년 단위로 예약이 가능하다.
  * Convertible Reserved : 예약된 Instance이지만 Type을 변경할 수 있다. On-Demand Instance에 비해서 최대 54% 저렴하다.
  * Scheduled Reserved : 날짜, 주, 월 주기로 예약된 Instance를 의미한다.

* Spot Instance : 언제든지 중단될수 있는 Instance를 의미한다. 가장 저렴한 Instacnce이다. On-Demand Instance에 비해서 최대 90% 저렴하다.

* Dedicated Instance : ??

* Dedicated Host : ??

#### 3.6. Snapshot

* EBS Snapshot 기능을 이용하여 EC2 Snapshot 수행 가능
* EC2 Snapshot은 S3에 저장

#### 3.7. Placement Groups

* EC2 Instance의 배치 전략을 설정할 수 있다.
* Cluster : Low Latency를 위해서 하나의 Availability Zone안의 하나의 Rack(Partition)에 위치시킨다.
* Spread : 다수의 Availability Zone에 분산시켜 가용성(High Availability)을 올린다.
* Partition : 하나의 Availability Zone에서 다수의 Rack(Partition)에 분산시킨다.

#### 3.8. Security Group

* Default 정책 : 모든 Inboud Traffic은 거부, 모든 Outbound Traffic은 허용한다.
* Src IP, Dest IP, Security Group 단위로 허용 여부를 설정할 수 있다.

#### 3.9. ENI (Elastric Network Interfaces)

* VPC에서 하나의 Virtual Network Card를 의미한다.
* 하나의 Primary Private IPv4와 다수의 Secondary IPv4를 갖을 수 있다.
* 하나의 Private IPv4 하나당 하나의 Elastic IP를 갖을 수 있다.
* 하나의 Public IP를 갖을 수 있다.
* 하나 이상의 Security Group에 포함될 수 있다.
* 하나의 MAC Address를 갖는다.
* 동일한 Availability Zone 내부의 EC2 Instance 사이에 속성 변경없이 이동이 가능하다. Failover시 유용한 기능이다.

### 4. AMI (Amazon Machine Image)

* EC2 Instance Image
* Backend Storage로 S3 이용 (Snapshot 동일)

### 5. EBS (Elastic Block Storage)

* Block Storage Service
* EC2에만 Mount하여 이용 가능

#### 5.1. Type

* 범용 SSD
  * 용량에 비례하여 IOPS 증가
* IOPS SSD
  * 특정 IOPS 이상의 성능이 필요한 경우 이용
* 최적화된 HDD
  * 자주 접근하는 Batch Job의 Storage로 유용
  * 대용량 Data, Streaming, Log 
  * Boot Volume X
* Cold HDD
  * 자주 접근하지 않는 대용량 Data 저장용
  * Boot Volume X 

### 6. EFS (Elastic File System)

### 7. RDS

* RDBMS Service
* Scale Out 자동 수행

#### 7.1. DB Engine

* MySQL, PostreSQL, Aurora 지원
* MySQL, PostreSQL은 사용자가 관리해야하는 부분 발생
* Aurora는 사용자가 관리를 최소화 하는 방향으로 발전중

### 8. DynamoDB

* Document DB
* Event 기능 제공 (Lambda)
* Scale Out

#### 8.1 RCU, WCU

#### 8.2. 일관성 Option

* Strongly Consistency
  * 

* Eventual Consistency
  * 일시적 불일치 허용 

* Transactional
  * 

#### 8.3. Global Table

### 9. Neptune

* Graph DB

### 10 VPC (Virtual Private Network)

* Private Netowrk 구성
* 하나의 Region을 선택하여 생성
* 하나의 Region 내부 다수의 AZ에서 동시에 이용 가능
* 각 계정마다 각 Region에 5개의 VPC 생성 가능 (Soft Limit)
* 각 VPC 마다 하나의 Routing Table 지원

#### 10.1 Subnet

* 하나의 VPC 내부에 존재
* 하나의 AZ에 존재
* 각 Subnet마다 하나의 Routing Table과 연결 가능
  * 다수의 Routing Table 하나를 여러개의 Subnet이 이용 가능
  * Subnet에 Routing Table이 설정되어 있지 않으면 VPC Routing Table 이용
* 다른 Subnet과의 CIDR가 중복 불가
* CIDR는 변경 불가능, Subnet 생성시 여유롭게 생성하는것을 권장
* Subnet Type
  * Public Subnet : Routing Table에 Internet Gateway 정보 포함
  * Private Subnet : Routing Table에 NAT Gateway 정보 포함

#### 10.2 Internet Gateway

* 

#### 10.3 NAT Gateway

* 

### 11. ELB (Elastric Load Balancing)

* Load Balancer
* Upgrade, Maintenance, High Availability 보장
* Classic Load Balancer (CLB) : HTTP, HTTPS, TCP를 지원한다. v1, Old Generation Load Balancer이다.
* Application Load Balancer (ALB) : HTTP, HTTPS, WebScoket를 지원한다. v2, New Generation Load Balancer이다.
* Network Load Balancer (NLB) : TCP, TLS, UDP를 지원한다. v2, New Generation Load Balancer이다.