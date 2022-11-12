---
title: 자격증 AWS Solutions Architect Associate 이론 정리
category: Record
date: 2022-11-01T12:00:00Z
lastmod: 2022-11-01T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. Region, Availability Zone

#### 1.1. Region

* 다수의 Availabiliy Zone을 포함하는 단위

#### 1.1. Availability Zone

* 하나 또는 하나 이상의 Data Center를 의미
* 각 Availability Zone는 Fault Isolation을 고려하여 설계됨
  * AZ-1에서 장애가 발생하더라도 AZ-2에는 영향을 미치지 않음

### 2. IAM

* 인증/인가 서비스

#### 2.1. User

* 사용자를 의미
* 하나의 User가 다수의 Group에 소속 가능

#### 2.2. Group

* 사용자의 Group을 의미
* 오직 User만 포함할 수 있으며, 다른 Group을 포함할 수 없음

#### 2.3. Role

* AWS Service, User에게 부여할 수 있으며, Role을 부여받은 AWS Service, User는 Role이 가지고 있는 Policy 권한을 획득
  * User에게 Role을 부여하는 동작을 Assume라고 명칭함

#### 2.4. Policy

* User, Group, Role에게 부여하는 허용/금지 정책
* JSON 형태로 구성
* Least Privilege Principle 권장
  * 최소한의 권한만을 허용
* IAM Policy Simulator를 통해서 Policy Simulation 가능

#### 2.5. Root User

* 모든 권한을 갖고 있는 User
  * 결제 정보
  * 개인 Data
  * AWS 
* Root User 이용을 지양하고 별도의 관리자 계정을 생성하여 이용하는것을 권장
  * IAM 관리자 계정 생성
  * Root 사용자 자격 증명 잠금
  * IAM 관리자 계정 이용
* Root User는 MFA(Multi Factor Authentication)를 이용하여 인증하도록 권장

### 3. EC2

* Compute Service

#### 3.1. Instance Type (Flavor)

* Instance Type Format
  * <FamilyName><GenerationNum>.<Size>
    * t3.large / c5.xlarge / p3.2xlarge
* Instance Type
  * General Purpose : t로 시작
  * Compute Optimized : c로 시작
  * Memory Optimized : r,x,z으로 시작
  * Storage Optimized : i,d,h으로 시작
* Flavor Scale Up/Down 가능
* Genration이 높을수록 가성비가 좋아짐

#### 3.2. User Data

* EC2 Instance가 처음 부팅시 오직 한번만 실행되는 Script를 의미
* root User로 실행됨

#### 3.3. Security Group

* EC2 Instance 앞에 존재하는 L4 Firewall
* 하나의 Security Group에 다수의 EC2 Instance를 포함
* Inbound, Outbound Rule 각각 설정 가능
* Rule에는 Protocol, Dest IP, Dest Port, Security Group에 따라서 Traffic 허용/거부 설정 가능
* Default 정책
  * Inbound : 모두 거부
  * Outbound : 모두 허용

#### 3.4. Spot Instance

* 일시적으로 실행되는 Instance
  * Current Spot Price는 AWS 가용 EC2 Instance에 따라서 실시간으로 변경
  * Max Spot Price는 사용자가 설정
  * "Max Spot Price > Current Spot Price" 상황일 경우에만 실행
  * "Max Spot Price < Current Spot Price" 상황이 되는 경우 실행되던 Instance는 Stop 또는 Termintate 상태가 됨
  * Stop, Terminate 상태가 되는것을 특정 시간 (1 ~ 6시간) 동안 방지할 수 있는 Spot Block Type도 존재
* On-demand Instance에 따라서 최대 90% 비용 절감
* Batch Job을 처리하는데 적합
* Spot Request Type
  * one-time : Spot Instnace를 구동하고 이후에는 관여 X
  * persistance : Spot Instance를 구동하고 이후에도 Spot Instance가 잘 동작하고 있는지 확인, 만약에 동작하고 있지 않다면 Spot Instance를 다시 생성
    * persistance Type일 경우 Spot Request를 먼저 제거하고 persistance Type 제거 필요
* Spot Fleets
  * 사용자가 원하는 Instance Type, OS, AZ에 따라서 다수의 Spot Instance를 생성
    * Spot Instance는 단일 AZ, 단일 Flavor만 지정가능
  * Spot Instance + On-Demand Instance (Optional)

#### 3.5. Elastic IP

* EC2 Instance에 붙이고 땔 수 있는 Public IP
* Elastic IP는 제거되지 않는 이상 IP가 변경되지 않음
* 하나의 계정당 기본적으로 5개까지 이용 가능
  * Quota 증가로 5개 이상 이용 가능
* Elastic IP 이용 권장 X
  * Random Public IP + DNS Name 이용 권장

#### 3.6. Placement Group

* EC2 Instance의 배치 전략
* Cluster : Low Latency를 위해서 하나의 Availability Zone안의 하나의 Rack(Partition)에 배치
* Spread : 다수의 Availability Zone에 분산 배치하여 가용성(High Availability) 확보
* Partition : 하나의 Availability Zone에서 다수의 Rack(Partition)에 분산

#### 3.7. ENI (Elastic Network Interface)

* VPC에서 하나의 Virtual Network Card를 의미
* 하나의 Primary Private IPv4와 다수의 Secondary IPv4를
* 하나의 Private IPv4 하나당 하나의 Elastic IP를 갖을 수 있다.
* 하나의 Public IP를 갖을 수 있다.
* 하나 이상의 Security Group에 포함될 수 있다.
* 하나의 MAC Address를 갖는다.
* 동일한 Availability Zone 내부의 EC2 Instance 사이에 속성 변경없이 이동이 가능하다. Failover시 유용한 기능이다.

#### 3.8. Hibernate

* EC2 Instance가 Hibernate를 이용하여 Stop 상태 진입시 EC2 Instance Memory의 내용을 Root EBS Volume에 저장하고 종료
* 이후 EC2 Instance가 Running 상태가 되면 Root EBS Volume에 저장한 EC2 Instance Memory 내용을 바탕으로 빠르게 Stop 상태 이전의 동작 상태로 복구 가능
* Root EBS Volume에 EC2 Instance Memory 내용이 저장되므로, EC2 Instance의 Root EBS Volume은 암호화 되어야함

#### 3.9. Nitro

* New Virtualization Technology
* 더 빠른 Network, EBS Volume 성능 제공

#### 3.10. Metadata

* EC2 Instance 내부에서 "http://169.254.169.254/latest"로 접근하여 EC2 Instance의 Meta 정보들 확인 가능
* 다음의 정보들 확인 가능
  * Instance-IP
  * Local-IPv4
  * IAM
  * ETC...

### 4. EC2 Instance Storage

* EC2 Instance 저장소

#### 4.1. EBS (Elastic Volume Service)

* Network 기반 Volume Storage
* 하나의 EBS Volume은 동시에 하나의 EC2 Instance에만 Attach 가능
  * 예외 적으로 io1, io2 Volume은 동시에 여러개의 EC2 Instance에 Attach 가능 (Multi Attach)
* EBS Volume은 AZ에 종족되며, 동일한 AZ에 위치한 EC2 Instance에만 Attach 가능

##### 4.1.1. EBS Snapshot

* EBS의 특정 상태를 저장
* EBS는 생성된 Snapshot 상태로 복구 가능
* Detach하지 않더라도 Snapshot 동작이 가능하지만 권장되지 않음
* EBS Snapshot을 기반으로 AMI를 생성 가능
  * EBS Snapshot 상태를 갖는 EC2 Instance 생성은 불가능하며, 반드시 EC2 Snapshot을 기반으로 AMI를 생성하고 생성한 AMI를 이용하여 EC2 Instance를 생성해야함

##### 4.1.2. EBS Volume Type

* gp2, gp3 : General Purpose SSD, Boot Volume으로 이용 가능
* io1, io2 : Highest-performance SSD, Boot Volume으로 이용 가능, Multi Attach 가능
* st : Low cost HDD
* sc : Lowest cost HDD

##### 4.1.3. EBS Encription

* EBS 생성시 Encription 설정 가능
* Encription 설정시 자동으로 암호화, 복호화 실행
* Encription Overhead는 낮은편

#### 4.2. AMI (Amazon Machine Image)

* EC2 Instance의 Booting Image
* EC2 Instance Snapshot
* EC2 Instance를 원하는 상태로 설정한 이후에 AMI 생성 기능을 통해서 AMI 생성
  * AMI를 생성하면서 Snapshot 생성도 가능
* 하나의 AMI에 다수의 EBS Volume 포함 가능

#### 4.3. EC2 Instance Store

* 물리 Disk 기반 Volume Storage
* EBS보다 빠른 성능을 갖지만 Data는 언제든지 소실될 수 있음
* Cache와 같이 빠르지만 임시로 Data를 저장하는 경우에 활용
* 다음의 경우에는 Data가 소실되지 않음
  * EC2 Instance Reboot
* 다음의 경우에는 Data가 소실됨
  * EC2 Instance 중지, 종료, Hibernate 될때
  * 물리 Disk 장애시

#### 4.4. EFS 

* NFS Server
* NFSv4.1 Protocol 이용
* File System 크기는 자동으로 증가하며, 사용 용량에 따라서 비용 발생
* Linux에만 이용 가능
* Muti AZ, Single AZ 설정 가능

##### 4.4.1. EFS Storage Class

* Storage Tiers
  * Standard : 표준
  * Infrequent Access : Data 저장에는 적은 비용을 지불하지만, 저장된 Data 이용시 비용 발생

### 5. ELB (Elastic Load Balancer)

* Load 분산
* 장애(EC2 Instance, AZ, Network)시 고가용성 제거
* User App의 단일 Endpoint 제공
* SSL Terminiation 제공
* Sticky Session 제공
* Managed Load Balancer
  * AWS에서 동작 보장 (Upgrade, Maintenance, HA 보장)
  * 약간의 설정 Options들 제공

#### 5.1. CLB (Classic Load Balancer)

* Deprecated
* L4, L7 Load Balancer
  * TCP + TCP Health Check, HTTP, HTTPS + HTTP Health Check 지원
* Cross-Zone Load Balancing
  * Default Disable, 설정으로 Enable 가능
  * 추가 비용 발생 X
* SSL 지원 X

#### 5.2. ALB (Application Load Balancer)

* L7 Load Balancer
  * HTTP/1.1, HTTP/2, WebSocket 지원
  * Less Latency : 400ms
* Redirect 지원
* Routing 정책
  * URL에 존재하는 Path 기반
  * URL에 존재하는 Hostname 기반
  * Quert String, Header 기반
* ALB Target Group Type
  * EC2 Instance
  * ECS Task
  * Lambda Function
* 고정된 Hostname을 갖음
  * XXX.region.elb.amazonaws.com
* Cross-Zone Load Balancing
  * 항상 Enable 상태이며 Disable 불가능
  * 추가 비용 발생 X
* App Server가 받는 Packet의 Src IP는 ALB IP이기 때문에 App Server는 Packet의 Src IP를 통해서 Client IP를 알 수 없음
  * X-Forwarded-For Header를 통해서 App Server에게 Client IP를 App Server에게 전달
  * X-Forwarded-Port Header를 통해서 Client의 Port를 App Server에게 전달
  * X-Forwarded-Proto Header를 통해서 Client의 Protocol을 App Server에게 전달

#### 5.3. NLB (Network Load Balancer)

* L4 Load Balancer
  * TCP, UDP 지원
  * Less Latency : 100ms
* NLB Target Groups
  * EC2 Instnace
  * Private IP Address
  * ALB
* Cross-Zone Load Balancing
  * Default Disable, 설정으로 Enable 가능
  * 추가 비용 발생

#### 5.4. GWLB (Gateway Load Balancer)

* L3 Load Balancer
* Packet을 App Server에 전달하기 전에 가로체어 Firewall, 침입 탐지같은 동작을 수행하는 Third Party Network Virtual Appliance에게 전송하는 역할 수행
* GWLB Target Group
  * EC2 Instance
  * Private IP Address

#### 5.5. Sticky Session (Session Affinity)

* 동일한 Client는 언제나 LB 뒤에 존재하는 동일한 App Server에 접속하도록 하는 기법
  * CLB, ALB에서 이용 가능
  * Cookie 정보를 활용하여 CLB, ALB는 Packet을 어느 App에 전달할지 결정
* Cookie 종류
  * Application-based Cookie
    * Custom Cookie
      * TODO
    * Application Cookie
      * AWSALBAPP 이름의 Cookie 이름 이용
  * Duration-based Cookie
    * TODO

#### 5.6. SSL

* SSL Termination 지원
* SNI (Server Name Indication) 지원
  * ALB, NLB에서만 이용 가능하며 CLB에서는 제공하지 않음
* 인증서는 ACM (AWS Certificate Manager)에서 관리

#### 5.7. Connection Draining

* CLB에서는 Connection Draining, ALB/NLB에서는 Deregistration Delay라교 명칭
* DRAINING 상태에 존재하는 Target (EC2 Instance)은 기존의 TCP Connection은 유지되지만, 신규 TCP Connection은 생성되지 않음
* Draining Timeout을 0초로 설정할 경우 Connection Draining 기능 Disable

#### 5.8. ASG (Auto Scaling Group)

* Scale-out, Scale-in 가능
  * EC2 Instnace 개수를 Minimum, Disred, Maximum 3가지 관점에서 설정 가능
  * CloudWatch 기반의 Metric 정보를 바탕으로 Auto Scale-out, Scale-in 수행
* EC2 Instnace가 장애시 자동 복구

##### 5.8.1. ASG Launch Template

* AGS를 쉽게 생성할 수 있는 Template 제공
* Luanch Template에는 다음의 정보들이 포함 
  * AMI + Instance Type
  * EC2 User Data, EBS Volume
  * Security Group
  * SSH Key Pair
  * IAM Roles for EC2 Instance
  * Network + Subnet Info
  * Load Balancer Info

##### 5.8.2. Auto Scailing Policy

* Target Tracking Scailing
  * AGS Group의 다음의 Metric들이 유지되도록 Scailing 수행
    * ASG Group에 평균 CPU 사용량
    * ASG Group의 평균 Inbound Traffic (All EC2 Network Interface)
    * ASG Group의 평균 Outbound Traffic (All EC2 Network Interface)
    * ASG Group의 평균 초당 Request

* Simple Scailing
  * CloudWatch Alarm 기반 정책
  * Metric이 특정 값을 도달하면 EC2 Instance 추가, 삭제 수행
  * Ex) ASG Group 평균 CPU 사용률이 70% 이상이면 EC2 Instnace 5개 추가, 40% 미만이면 5개 감소

* Step Scailing
  * CloudWatch Alarm 기반 정책
  * Metric이 구간에 따라서 EC2 Instance 추가, 삭제 수행
  * Ex) ASG Group 평균 CPU 사용률이 70% 이상일 경우 EC2 Instance 10개 추가, 60% 이상일 경우 5개 추가, 40% 미만이면 5개 감소, 30% 미만일 경우 10개 감소

* Predictive Scailing
  * 다음의 과거의 Metric을 기반으료 예측하여 Scaling 수행
    * ASG Group에 평균 CPU 사용량
    * ASG Group의 평균 Inbound Traffic
    * SG Group의 평균 Outbound Traffic
    * ASG Group의 평균 초당 Request
    * Custom Metric 기반으로 예측

* Scheduled Action
  * 시간대에 따른 Scaleing 수행

##### 5.8.3. Scailing Cooldown

* Scailing 수행후 다음 Scailing을 수행하기 전까지의 대기 시간
* Cooldown 기간동안에는 EC2 Instance를 증가시키거나 감소시키지 않음

### 6. RDS

* Managed RDB
  * 자동 Provisiong, OS Patch 제공
  * Continuous Backup, Restore 제공
  * Monitoring Dashboards 제공
  * Read Replica 쉽게 구성 가능
  * Multi AZ 쉽게 구성 가능
  * Scailing 쉽게 가능
* 다음의 RDB 이용가능
  * Postgres
  * MySQL
  * MariaDB
  * Oracle
  * Microsoft SQL Server
  * Aurora

#### 6.1. Storage Auto Scaling

* RDS Storage 부족시 자동으로 Storage Size 증가 시킴
* Maximum Stroage Threshold 설정을 통해서 최대 Storage Size 설정 필요
* 다음의 조건을 충족시 Storage Auto Scailing 수행
  * 남은 Storage 용량이 10% 미만이고, 5분 이상 지속될 경우
  * 마지막 Scale Up 수행후 6시간 이후

#### 6.2. Read Replica

* Read 전용 RDS Instance
* Master RDS Instance와 비동기 Replication 수행
* Master RDS Instance와 동일 AZ, Cross AZ, Cross Region으로 구성 가능
  * 동일 AZ, Cross AZ 구성시 Network 비용 발생 X
  * Cross Region 구성시 Network 비용 발생
* Read Replica RDS Instance는 Master RDS Instance로 승격 가능
  * 장애 Recovery를 위한 RDS Instance로 이용 가능 
  * 비동기 Replication을 수행하기 때문에 Data Loss 발생 가능

#### 6.3. Multi-AZ

* 장애 Recovery를 위한 Standby RDS Instance를 다른 AZ에 생성
* Standby RDS Instance와 Master RDS Instance와 동기 Replication 수행
  * 동기 Replication을 수행하기 때문에 Data Loss 발생 X
* Master RDS Instance와 Standby RDS Instance는 동일한 DNS Record를 이용
  * Master RDS Instance 장애시 DNS Record IP가 Standby RDS Instance로 변경
  * Application의 DB 재설정 불필요
* Multi-AZ 설정은 동적으로 가능
  * Mutli-AZ 설정시 Master RDS Instance Down 불필요
  * Standby RDS Instance는 Snapshot을 기반으로 생성한 다음 Master RDS Instance와의 Data 동기를 수행

#### 6.4. Encryption

* Master RDS Instance, Read Replica RDS Instance는 AWS KMS 기반 AES-256 암호화 가능
* Master RDS Instance가 암호화하지 않으면 Read Replica RDS Instance도 암호화 되지 않음
* Snapshot도 Master RDS Instance가 암호화를 수행해야 암호화 수행
* 암호화 되지 않은 Snapshot은 암호화 가능
* 암호화 되지 않은 RDS Instance를 암호화 하는 방법
  * Snapshot 생성
  * 생성한 Snapshot을 암호화
  * 암호화된 Snapshot을 바탕으로 RDS Instance 생성
  * App을 새로 생성된 RDS Instance를 이용하도록 설정 & 기존 RDS Instance 삭제
* Client, RDS Instance 사이는 SSL을 이용한 암호화 수행

#### 6.5. Network & Access Management

* 일반적으로 Private Subnet에 할당
  * Security Group을 활용하여 보안성 향상
* 기존의 IP/Password 기반 인증 가능
* IAM 기반 인증 가능
  * RDS Service를 통해서 Token 획득이후 RDS Instance에 접근

#### 6.6. Aurora

* AWS Cloud Optimized RDS
* MySQL, Progres와 호환
* Storage의 크기는 10GB로 시작하여 최대 128TB 까지 자동으로 증가
* 하나의 Master Instance + 최대 15 Read Replica Instance를 갖을 수 있음
  * Master만 Read/Write 수행 가능
  * Read Replica는 부하에 따라서 Auto Scaling 수행
  * Read Replica는 Cross Region 지원
* 빠른 Failover (30초 미만)
* 일반 RDS보다 20%정도 더 높은 비용 청구

#### 6.6.1. Storage HA

* 3개의 AZ에 6개의 복제본으로 구성
  * Write를 수행하기 위해서 4개의 복제본이 필요
  * Read를 수행하기 위해서 3개의 복제본이 필요
  * 장애시 Self Healing을 통해서 데이터 복제

#### 6.6.2. Endpoint 

* Writer Endpoint
  * Master Instance를 가리키는 DNS Record
* Reader Endpoint
  * Read Replica Instance들을 가리키는 DNS Reocrd
  * Read Replica가 Auto Scaling 되면 자동으로 Read Endpoint에 추가/제거 수행
* Custom Endpoint
  * 사용자 설정을 통해 일부 Read Replica Instnace들만 가리키는 DNS Record
  * Data 분석을 위해서 성능이 좋은 Read Replica Instance만 이용할 경우 활용

#### 6.6.3. Serverless

* Client는 Proxy Server (Proxy Fleet)를 통해서 Aurora Instance에 접근
* 필요에 따라서 자동으로 Aurora Instance를 초기화 하고 Auto Scaling 수행
* 간혈적으로 DB를 이용하는 경우에 유리
  * 초당 사용시간에 따라서 비용 청구

#### 6.6.4. Multi-Master

* 다수의 Master Instance가 존재하며 모든 Master Node는 Read/Write 동작 수행
* 일부 Master Instance가 장애로 동작하지 않더라도, 동작중인 Master Instance를 통해서 지속적인 Write 동작 수행 가능
* 다수의 Master Instance 중에서 Write 동작을 수행할 Instance 선택은 Client에서 수행
  * Aurora에서는 Master Instance Load Balancing 기능 제공 X

#### 6.6.5. Global Aurora

* Disaster 복구를 위한 Cross Region Read Replica
* Primary Region (Read/Write), Secondary Region (Read Only) 존재
  * Primary Region과 Secondary Region은 비동기로 복제되며 복제 시간은 최대 1초
  * 최대 5개의 Secondary Region 설정 가능
  * Primary Region 장애시 Secondary Region이 Primary Region으로 승격 가능

#### 6.6.6. Aurora Machine Learning

* AWS ML Service와 연동하여 SQL Query를 통해서 ML 기반 예측 정보를 가져올 수 있음
  * Ex) 침입 탐지, 광고 Target, 상품 추천

### 7. ElasticCache

* Managed Redis, Memcached
* AWS IAM 기반 인증 기능 제공 X

#### 7.1. Redis

* Mutli-AZ를 활용한 Auto-Failover 지원
* Read Replica를 활용한 Read Scaling 및 HA 제공
* AOF (Append Only File)를 활용한 Data 지속성 제공
* Backup & Restore 기능 제공
* Single-Thread Architecture
* 다양한 Data Type 존재
* ID/Password 기반의 인증 이용

#### 7.2. Memcached

* HA 제공 X
* Data 지속성 제공 X
* Backup & Restore 기능 제공 X
* Multi-Thread Architecture
* String 단일 Data Type 제공
* SASL 기반 인증

#### 7.3. ElasticCache Pattern

* Lazy Loading 
  * 읽은 Data를 Cache에 저장
  * Cache에 저장된 Data는 유효하지 않을 확률이 존재
* Write Through
  * Data를 저장할때 Cache에도 같이 저장
  * Cache에 저장된 Data는 유효
* Session Store
  * Session 정보를 저장
  * TTL 기능을 활용

### 8. Route 53

* Managed DNS

#### 8.1. Hosted Zones

* Public Hosted Zone : Public Network
* Private Hosted Zone : VPC Private Network

#### 8.2. CNAME vs Alias

* CNAME
  * Non-Root Domain 지정 가능
    * Ex) ssup2.com (Root Domain) 불가능
  * Root Domain 지정 불가능
    * Ex) blog.ssup2.com (Non-root Domain) 가능
* Alias
  * DNS Procotol에서 제공되지 않는 AWS 내부 Protocol
  * DNS Client시에는 Query Response시 A 또는 AAAA Record로 응답
  * Non-Root, Root Domain 둘다 지정 가능
  * 일부 AWS Resource를 대상으로만 설정 가능
* Supported Alias Target
  * Elastic Load Balancer
  * CloudFront Distributions
  * API Gateway
  * Elastic Beanstalk environments
  * S3 Websites
  * VPC Interface Endpoints
  * Global Accelerator
  * Route 53 record in the same hosted zone
* Not supported Alias Target
  * EC2 DNS record
  * RDS DNS record

#### 8.3. Routing Policy

* Simple
  * DNS Record에 Mapping되어 있는 모든 IP Address 반환
  * Health Check 이용 불가
* Weighted
  * DNS Record에 Mapping되어 있는 각 IP Address에 가중치를 부여하며, 가중치의 비율에 따라서 반환되는 IP Address의 비율을 결정
  * Health Check 이용 가능
* Latency Based
  * Client의 위치에 따라서 Latency가 가장 적은 IP Address 반환
  * Health Check 이용 가능
* Failover
  * Active-Passive 기반 정책
  * Health Check가 동작한다면 Primary로 지정된 IP Address 반환, Health Check가 실패한다면 Secondary로 지정된 IP Address 반환
* Geolocation
  * Client의 위치에 따라서 설정된 IP Address 반환
  * Client가 설정된 위치가 이나라면 Default IP Address 반환
  * Health Check 이용 가능
* Geoproximity
  * Client의 위치와 Bias 값에 의해서 특정 IP Address를 더 편향되게 많이 반환 할수 있도록 설정 가능
  * Bias 값이 큰 IP Address일수록 더 멀리 떨어져 있는 Client가 이용할 확률이 증가
* Muti-Value Answer
  * Health Check를 통해서 응답하는 모든 IP Address 반환
  * 최대 8개의 IP Address만 반환

#### 8.4. Health Check

* L4, L7 Health Check 지원
* Health Check Target
  * Endpoint : App의 Endpoint Health Check 수행
  * Other Health Check (Calculated Health Check) : 다수의 다른 Endpoint의 Health Check 결과들을 논리 조합(AND, OR, NOT)하여 Health Check 결과를 판단
  * CloudWatch : Route53은 Public Network에 존재하기 때문에 Private VPC 내부에 존재하는 Endpoint를 Health Check 수행 불가능. 이 경우 Private VPC 내부의 Endpoint를 감시하는 Cloud Watch를 설정하고, Route53은 이 Cloud Watch를 대상으로 Health Check를 수행

### 9. S3

* 무제한 용량의 Object Storage
* Strong Consistency 제공
* 특정 Origin을 허용하거나 모든 Origin 설정 가능

#### 9.1. Bucket

* S3의 최상위 Directory 역할
  * Bucket 하위의 Bucket은 구성 불가능
* Globally Unique한 이름 이용
* Bucket은 특정 Region 생성 (S3는 Global Service X)
* Naming Convention
  * 소문자만 이용 가능
  * _ (Underscore) 이용 불가능
  * 3~63 글자
  * IP 이용 불가능
  * 소문자 및 숫자로만 시작 가능

#### 9.2. Object

* S3의 File 역할
* 하나의 Key를 가지며 Full Path 역할 수행
  * s3://<bucket-name>/<object-key>
  * Ex) s3://ssup2-bucket/root-folder/sub-folder/file.txt
    * ssup2-bucket : Bucket 이름
    * root-folder/sub-folder/file.txt : Object Key
* 하나의 Object는 최대 5TB
  * 파일이 5TB 이상이면 Multi-Part Upload 기능을 활용하여 하나의 파일을 쪼개서 Upload 가능
* Metadata
  * Key-Value 기반
  * System 또는 User Meta 정보 저장
* Tag
  * Key-value 기반
  * 최대 10개까지 설정 가능
  * 주로 IAM 기반 인가 설정시 이용
* Version ID
  * Bucket의 Versioning 기능 Enable시 각 Object는 Version ID를 갖음

#### 9.3. Versioning 

* Bucket 단위의 Enable/Disable 가능
* 예상하지 못한 삭제시 복구, 기존 Version으로의 Rollback 가능
* Version 기능 Disable -> Enable 변경으로 인해서 Verion을 갖고 있지 않는 Object는 Null Version으로 표기

#### 9.4. Encryption

* 암호화 방법
  * SSE-S3 : AWS S3 Service에서 관리하는 암호화 Key 이용
    * Server Side Encrpytion
    * AES-256 암호화
    * HTTP Request Header에 "x-amz-server-side-encryption":"AES256" 설정
  * SSE-KMS : AWS KMS Service에서 관리하는 암호화 Key 이용
    * Server Side Encrpytion
    * HTTP Request Header에 "x-amz-server-side-encryption":"aws:kms" 설정
  * SSE-C : 자신만의 암호화 Key 이용
    * AWS에서 암호화 Key 관리 X
    * HTTPS 이용
    * 모든 HTTP Header에 암호화 Key를 설정하여 전송
  * Client Side 암호화
    * Data를 송신하기전에 Client에서 직접 암호화 수행
    * Data를 수신하기전에 Client에서 집접 복호화 수행
* 전송중 암호화
  * HTTPS를 이용한 SSL/TLS 이용
  * HTTP를 통해서 암호화 없이 전송도 가능하지만 HTTPS를 이용하는것을 권장

#### 9.5. Security

* User Base
  * IAM Policy를 이용하여 설정
* Resource Base
  * 다수의 Account에 공통적으로 적용
  * Object Access Control List : Object 단위로 권한 설정
  * Bucket Access Control List : Bucket 단위로 권한 설정
* S3 Object에 접근이 필요하기 위해서 다음과 같은 조건 만족 필요
  * (User IAM Role Allow OR Resource Policy Allow) AND 명시적 Deny
* VPC 내부에서 Endpoint 제공
* S3 Access Log는 다른 S3 Bucket에 저장 가능
  * S3 Access Log를 다른 S3 Bucket이 아니라 자기 자신으로 설정할 경우 Logging Loop가 발생하기 때문
  * 저장된 Access Log는 AWS Athena를 통해서 분석 가능
* AWS CloudTrail의 Log 저장소로 S3를 이용
* MFA Delete: Object 제거시 MFA를 이용하도록 강제 가능
* Pre-Signed URL: 일정시간 동안 유효한 URL을 생성

#### 9.6. Websites

* Static Webserver 기능 제공
* URL
  * <bucket-name>.s3-website-<AWS-region>.amazonaws.com
  * <bucket-name>.s3-website.<AWS-region>.amazonaws.com
* Error
  * 403 Error 발생시 권한 확인 필요

#### 9.7. Replication

* Region 사이의 복제 기능 제공
  * 비동기 복제 수행
  * CRR (Cross Region Replication)
  * SRR (Same Region Replication)
* Source S3 Bucket은 반드시 Versioning 기능 Enable 필요
* S3에게 IAM 권한 설정 필요
* Replication을 설정한 이후 새로 생성된 Object에 대해서만 복제 수행
  * 기존의 Object들은 S3 Batch Replication을 통해서 복제 수행 가능
* Delete 동작
  * Source Object 삭제시 복제본 Object도 삭제할지 설정 가능
  * Source Object의 특정 Version 삭제시 복제되지 않음
* Replication Chain 구성 불가능

#### 9.8. Pre-signed URL

* 임시로 Download, Upload가 가능한 임시 URL 생성 가능
  * Download : CLI, SDK를 통해서 생성 가능
  * Upload : SDK를 통해서만 생성 가능
* 기본적으로 3600초의 유효시간을 갖으며 Pre-signed URL 생성시 유효시간 설정 가능

#### 9.9. Storage Class

* Storage Class에 따라서 가격, 성능, 가용성 차이를 갖음
* 모든 Storage Class는 99.999999999% 내구성 보장
* Object 단위로 설정 가능

##### 9.10.1. General Purpose

* 종종 접근하여 이용하는 경우 이용
* 99.99% 가용성 보장
* Low Latency, High Throughput
* Usage Example : Big Data 분석, Content 배포

##### 9.10.2. Infrequent Access

* 낮은 빈도로 접근하지만 빠른 접근이 필요한 경우 이용
* Standard Class보다 낮은 비용
* Standard Infrequent Access Class (Standard-IA)
  * 99.9% 가용성
  * Usage Example : Disaster Recovery, Backup
* One Zone Infraquent Access Class (S3 One Zone-IA)
  * 95.9% 가용성
  * 단일 AZ에 저장하는 방식이라 AZ 손실시 Data 손실로 이어짐
  * Usage Example : 임시 Backup, 재생성이 가능한 Data Backup

##### 9.10.3. Glacier Storage Class

* Archiving, Backup을 위한 저비용 Storage
* Object 저장 비용은 낮지만, Object 검색시 비용 발생

##### 9.10.4. Glacier Instant Retrieval Class

* Milisecond 단위의 검색 속도
* 최소 90일 기간의 저장 비용이 청구

##### 9.10.5. Glacier Flexisble Retrieval Class

* Data 검색에 오랜시간이 소모되며, 아래와 같은 설정에 따라서 필요 검색시간이 달라짐
  * Expedited : 1~5분, 비용 발생
  * Standard : 3~5시간, 비용 발생
  * Bulk : 5~12시간, 무료
* 최소 90일 기간의 저장 비용 청구

##### 9.10.6. Glacier Deep Archive

* Data 검색에 가장 오랜시간 소모되며, 아래와 같은 설정에 따라서 필요 검색시간이 달라짐
  * Standard : 12시간
  * Bulk : 48시간
* 최소 180일 기간의 저장 비용 청구

##### 9.10.7. Intelligent-Tiering

* Object의 사용량에 따라서 자동으로 Tier를 변경
* Tier 변경시 무료
* 다음과 같은 Tier가 존재
  * Frequent Access Tier : Default Tier, 자동 설정
  * Infrequent Access Tier : 30일동안 Object에 접근이 없을시, 자동 설정
  * Archive Instant Access Tier : 90일동안 Object에 접근이 없을시, 자동 설정
  * Archive Access Tier : 90일에서 700일 이상 접근하지 않을시, Optional
  * Deep Archive Access Tier : 180일에서 700일 이상 접근하지 않을시, Optional

##### 9.10.8. Storage Class 이동

* Transition Action : Object가 생성되고 경과된 시간에 따라서 자동으로 Storage Class를 변경
* Expiration Action : Object가 생성되고 경과된 시간이 지나면 자동으로 Object 삭제
* Action Target : Action은 Object Tag 또는 Object Path Prefix (s3://mybucket/music/*)에 따라서 설정 가능
* S3 Analysics 기능을 통해서 언제 Standard Class에서 Standard IA Class로 변경하면 좋을지 분석 가능

#### 9.11. Performance

* 100~200ms의 지연을 보장하도록 S3 내부에서 Automatically Scaling 수행
* 하나의 Prefix당 3500 PUT/COPY/POST/DELETE, 5500 GET/HEAD Request per Seconds 성능 제공
  * 하나의 Bucket 내부에 Prefix 제한이 존재하지 않음
  * 다수의 Prefix를 사용하는 형태로 구성하여 성능 증가 가능
* SSE-KMS를 이용하여 암호화를 수행하는 경우, SSE-KMS 성능에 따라서 S3도 영향을 받음
  * Region에 따라서 5500, 10000, 30000 request for second의 성능 제한이 존재
* Edge Location의 전용선을 통해서 더 빠르게 S3에 Upload 가능
* Byte-Range Fetch
  * Object의 특정 영역만 Download 가능
  * 서로 다른 영역을 대상으로 동시에 Byte-Range Fetch를 수행하여 Download 성능 증가 가능
  * Object의 일정 부분만 검색 가능

#### 9.12. Event

* S3의 동작을 Event로 생성하여 전파 가능
* 다음의 Service로 전파가 가능
  * SNS, SQS, Lambda Function, Event Bridge

#### 9.13. Athena

* S3 Object를 위한 Serverless Query Service
* TB Scan당 5$ 지불
  * Object를 압축하거나 Object의 Data를 Column 형태로 저장하여 Scan 비용 절감 가능

#### 9.14. Glacier Vault Lock

* WORM (Write Once Read Many) 구현
* Object 생성후 Lock을 걸어 설정 가능
* Compliance 충족을 위해서

### 10. CloudFront

* CDN Service
* Shield Service, WAF와 함께 DDoS 공격 방지 가능

#### 10.1. Origin

* 다음의 Origin을 이용 가능
* S3
  * S3 Object Caching 수행
  * S3의 Upload 경로로도 사용 가능
  * OAI (Origin Access ID)를 활용하여 S3의 Object에 접근
* Custom Origin : HTTP Protocol을 이용하면 Origin으로 이용 가능
  * ALB, EC2 Instance, S3 Website, HTTP Backend API
* Origin Group 기능 제공
  * Primary Origin이 동작하지 않을 경우 Secondary Origin을 이용하도록 설정 가능

#### 10.2. Geo Restriction

  * 국가 단위로 Content에 접근 가능한 Whitelist, Content에 접근 불가능한 Blacklist 존재
  * 국가의 기준은 3rd Party의 Geo-IP DB를 기반으로 결정

#### 10.3. Pricing

* Edge Location에 따라서 이용 가격이 다름
* Price Class
  * Caching을 수행하는 Edge Location의 개수를 줄여 비용 절감 가능
  * Class ALL : 모든 Edge Location을 이용하며, 가장 높은 비용
  * Class 200 : 가장 비싼 Region을 제외한 나머지 Region들을 포함
  * Class 100 : 제일 저렴한 Region만 포함

#### 10.4. Global Accelerator

* Edge Location의 전용 Network를 통해서 AWS 다른 Region에 빠르게 접근

### 11. Storage

#### 11.1. AWS Snow Family

* Portable Device를 활용하여 Data Migration, Edge Computing 수행
* 용량 기능에 따라서 다음의 장비들로 구성
  * Snowcone : Data Migration, Edge Computing 지원
  * Snowball : Data Migration, Edge Computing 지원 
  * Snowmobile : Data Migration 지원
* OpsHub를 Labtop에 설치하여 장비를 손쉽게 관리 가능
* Glacier로 Data Migration을 진행하기 위해서는 Data를 S3에 먼져 저장한 이후 Glacier로 전환

#### 11.2. FSx

* 3rd Party High Performance Filesystem을 제공하기 위한 서비스
  * for Windows File Server
  * for NetApp ONTAP

#### 11.3. Storage Gateway

* On-premise 환경에서 S3를 접근을 도와주는 징검다리 역할
* On-Premise의 File, Volume, Tapes와 AWS의 EBS, S3, Glacier를 연결하는 징검다리 역할 수행
* Storage Gateway Type
  * VM 기반 : VMware, Hyper-V, Linux KVM, EC2
  * Hardware 기반 : 전용 Hardware 임대 가능
* File Gateway 
  * S3 Standard, S3 Standard-IA, Glacier을 On-Premise 환경에서 NFS, SMB Protocol로 접근 가능
* Volume Gateway 
  * S3를 On-Premise 환경에서 iSCSI로 접근 가능
  * 2가지 형태의 Volume 제공
    * Cached Volume : 자주 접근하는 Data만 Volume Gateway에 위치시키고 자주 이용되지 않는 Data는 S3에 저장
    * Stored Volume : 전체 Data를 Volume Gateway에 위치시키고 주기적으로 EBS Snapshot을 생성하여 Backup 수행
* Tape Gateway
  * S3, Glacier를 iSCSI로 접근 가능

#### 11.4. Transfer Family

* S3, EFS을 FTP Protocol을 통해서 이용가능
* 지원하는 Protocol : FTP, FTPS, SFTP
* Managed Service
* Endpoint 개수 + 전송 Data양에 따라서 비용 부과
* 지원하는 인증 방법 : Microsoft Active Directory, LDAP, Okta, Cognito
* User -> Route 53 -> Transfer Family --(IAM Role)--> S3, EFS 형태로 구성

### 12. Messaging

#### 12.1. SQS

* Queue Service
* 무제한 Throughput
* Low Latency (< 10ms)
* Message는 기본 4일동안 보관하며 설정을 통해서 최대 14일까지 보존 가능
* 하나의 Message당 최대 256KB 제한
* At Least Once QoS 보장
* Message의 순서는 변경될 수 있음
* Delay 기능 지원

##### 12.1.1. Consumer

* Polling을 통해서 Message 존재 확인 (Event 기반 X)
  * Long Polling 기능 제공
* 한번에 최대 10개의 Message 수신 가능
* Message 수신 및 동작 수행후 DeleteMessage API를 통해서 Message 삭제 필요 (ACK)
* CloudWatch Metric Queue Length -> CloudWatch Alarm -> ASG Scaling 형태로 구성하여 Consumer Autoscaling 구성 가능

##### 12.1.2. Security

* Encryption
  * In-flight Encription : HTTPS 이용
  * At-rest Encription : KMS Key 이용
  * Client가 자체적으로 Encryption/Decryption 수행 가능
* Access Control
  * IAM Policy 제어
  * SQS Access Policy 제공 : Cross-Account Access 활용시 유용

##### 12.1.3. Message Visibility Timeout

* 특정 Consumer가 Message를 수신한뒤 Message를 삭제하지 않아도 Message Visibility Timeout 시간동안에는 다른 Consumer들도 해당 Message 확인 불가능
* Message Visibility Timeout 시간이 지나면 다른 Consumer들도 Message 확인이 가능하며, Message 처리도 가능
  * Message가 Queue로 다시 Requeue 된다고 간주해도 무방
  * Message를 처음 수신한 Consumer가 Message Visibility Timeout 내에 Messsage 처리 및 삭제를 수행하지 않으면, 다른 Consumer가 Message를 여러번 처리할 수 있음
* Default 30초

##### 12.1.4. Dead Letter Queue

* Message Visibility Timeout이 초과하여 Requeue되는 횟수가 MaximumRecevies를 초과하는 경우 Message는 Dead Letter Queue로 전송
* Debugging, 장애 처리를 위해 이용
* Redrive : Dead Letter Queue에 저장되어 있는 Message를 다시 원래의 Queue로 전송하는 기능

##### 12.1.5. FIFO Queue

* Message 순서 보장
* Exactly-Once QoS 지원
* 수신 300 msg/s, 송신 3000 msg/s 성능 제한
* 일반 Queue에 비해서 성능은 떨어지지만, Message 순서 유지 및 Exactly-Once QoS를 이용하고 싶을때 활용

#### 12.2. SNS

* Pub-Sub Service
* Producer만 Message 송신 가능
* Topic당 최대 12500000 구독 가능
* 가능한 Subscriber
  * SQS, Lambda, Kinesis Data, Firehose, Emails, SMS, Mobile Notification, HTTP Endpoints
* Filter 기능을 이용하여 일부 Subscriber에게만 Message 전송 가능

##### 12.1. FIFO Topic

* 순서를 보장하는 Topic
* Group ID를 활용하여 Ordering 수행
* Deduplication ID를 활용하여 Deduplication 수행
* SQS Topic만 Subscription 가능

#### 12.3. Kinesis

* 실시간 Streaming Data Collect, Process, Analyze Service
  * Application Log, Metrics, IoT Telemetry
* Kinesis Data Stream : Data Stream 구성
* Kinesis Data Firehose : Data Stream을 Data Store에 저장 
* Kinesis Data Analytics : Data Stream을 SQL, Apache Flink를 이용하여 분석
* Kinesis Video Streams : Video Stream 구성

##### 12.3.1. Kinesis Data Stream

* Shard
  * Shard 개수에 따라서 병렬 처리르 통해서 성능 증가 가능
  * 하나의 Shard는 1MB/sec or 1000 Msg/sec 수신 가능
  * 하나의 Shard는 2MB/sec 송신 가능
* Record
  * Input : Partition Key, Data Blob (최대 1MB) 구성
  * Output : Partition Key, Sequence Number, Data Blob 구성
* Data 보관 기간은 1일부터 365일 설정 가능
* Data 재처리 가능
* Data가 Kinesis에 들어가면 제거 불가능
* 동일한 Partition Key를 갖는 Data는 동일한 Shard로 전송 (Ordering)
* Capacity Mode
  * Provisioned Mode
    * Shard의 개수를 수동으로 설정 가능
    * Shard의 개수 및 Shard가 Provisioning된 시간에 따라서 비용 청구
  * On-demend Mode
    * Capacity 설정 불필요
    * 30일 동안의 사용량을 보고 AutoScailing 수행
    * Stream 개수, Stream이 이용된 시간, Data 송수신량에 따라서 비용 청구

##### 12.3.2. Kinesis Data Firehose

* Managed Service
* Near Real Time
  * 최소 60초 딜레이
  * 최소 32MB를 한번에 전송
* Store Target
  * AWS : Redshift, S3, ElasticSearch
  * 3rd Party : Splunk, MongoDB, DataDog, NewRelic
  * Custom HTTP Endpoint 생성 가능
* 다양한 Data Format, Conversion, Transforamtion, Compress 지원
* Lambda를 활용한 Custom Transformation 가능

### 13. Container

#### 13.1. ECS

##### 13.1.1. ECS Launch Type

* EC2 Launch Type
  * EC2 Instance에 Container가 구동되는 방식
  * EC2 Instance Provisioning, 유지보수 필요
  * EC2 Instnace 내부적으로 ECS Agent를 구동중
  * IAM Role
    * EC2 Instance Profile : ECS Agent가 이용하는 Role, ECS Service API 호출/Container Log CloudWatch로 전송/ECR으로부터 Docker Image Pull 허용
    * ECS Task Role : ECS Task를 위한 Role, Task별 별도의 Role 할당 가능
* Fargate Launch Type
  * Infra Provsioning 불필요 (Serverless)
  * Task에 필요한 CPU / Memory만큼 Fargate를 활용하여 구동

##### 13.1.2. Load Balancer

* ALB : L7 Protocol을 이용하는 대부분의 Service에 적용 가능
* NLB : High Throughput을 위해서 이용, AWS Private Link와 연동하기 위해서 이용
* CLB : 이용을 권장하지 않음, Fargate와 연동 불가능

##### 13.1.3. Volumes

* 일반적으로 EFS를 이용하도록 권장
  * 다중 AZ 지원
  * Serverless 특징
* FSx For Lustre 지원 X

##### 13.1.4. Auto Scaling

* Service Auto Scailing
  * 부하에 따라서 ECS Task를 자동으로 Scaling 하는 기능
* EC2 Auto Scailing
  * ECS Task 부하에 따른 EC2 Instance를 자동으로 Scaling 하는 기능
  * ASG 방식 : Auto Scailing Group을 활용하여 Scailing 수행
  * Cluster Capacity Provider 방식 : EC2 Instance에 ECS Task를 생성할 가용 Resource가 없는 경우 새로운 EC2 Instance Scailing Out 수행

##### 13.1.5. Rolling Update

* Minimum Health Percent, Maximum Percent 각각 설정 가능
* Ex) Min 50%, Max 100% : 4개의 Task가 동작하고 있다면 Old Version 2개 제거, New Version 2개 생성, Old Version 2개 제거, New Version 2개 생성 과정 진행
* Ex) Min 100%, Max 150% : 4개의 Task가 동작하고 있다면 New Version 2개 생성, Old Version 2개 제거, New Version 2개 생성, Old Version 2개 제거 과정 진행

#### 13.2. ECR (Elastic Container Registry)

* Container Image 저장소
* Private, Public Repository : https://gallery.ecr.aws/
* Backend Storage로 S3 이용

### 14. Serverless

#### 14.1. Lambda

* Virtual Function : Server 관리 불필요
* 실행시간 제한 : 짧은 실행만 수행 가능
* 필요할때만 실행 가능하며, 실행한 시간만큼 비용 청구
* Autoscaling 지원
* 다양한 AWS Service와의 연계 지원
* CloudWatch를 통한 Monitoring 지원
* 최대 10GB까지 Memory 할당 가능
  * 더 많은 Memory 크기를 할당할 수록 CPU, Network의 성능도 증가
* 다음의 언어 지원
  * Node.js, Python, Java, C#, Golang, C#, Ruby, Custom API (Community Supported)
* Container Image 지원
  * Lambda Runtime API를 지원하도록 Contianer Image 지원시, 해당 Container Image를 Lambda에서 구동 가능

###### 14.1.1. Lambda Integration

* 다양한 AWS Service와의 연계 지원
* API Gateway : Upstream으로 Lambda 호출
* Kinesis : Lambda를 활용하여 Data 변환
* DynamoDB : DynamoDB에서 Event 발생시 Lambda 호출
* S3 : S3에서 Event 발싱시 Lambda 호출
* CloudFront : Lambda Edge
* EventBridge : EventBridge에서 Event 발생시 Lambda 호출
* CloudWatch : TODO
* SNS : SNS에서 Event 송신시 Lambda 호출
* SQS : SQS에서 Message 송신시 Lambda 호출
* Cognito : Congino에서 Event 발생시 Lambda 호출

##### 14.1.2. Lambda Limit

* Execution
  * Memory : 128MB ~ 10GB
  * Maximum Execution Time : 15분
  * Maximum Env : 4KB
  * Disk Capacity : tmp DIR : 512MB
  * Concurrency Executions : 1000
* Deployment
  * Compressed Deployment Size (.zip): 50MB
  * Uncompressed Deployment Size : 250MB

##### 14.1.3. Lambda Edge

* Edge Location에서 Lambda 실행
* 빠른 응답의 Application 개발시 이용 가능
* CDN Contents Customization 가능

#### 14.2. DynamoDB

* Managed NoSQL Database
* Multiple AZ 제공
* 초당 만개 이상의 요청 처리, 100TB 저장공간
* IAM을 이용한 인증,인가 제공
* DynamoDB Streams를 활용한 Event Driven Programming 가능
* Low-cost & Auto-scaling 기능 제공
* Standard, IA (Infrequent Access) Table Class 제공

##### 14.2.1. Table, Item, Attribute

* DynamoDB는 Table의 구성으로 이루어져 있음
* Table은 하나의 Primary Key
* Table은 무한대의 Item을 갖을수 있음
* 각각의 Item(행)은 Atribute(열)을 갖을 수 있음
  * Attribute는 계속 동적으로 추가 가능
* Item의 크기는 최대 400KB
* Data Type
  * Scalar : String, Number, Binary, Boolean, Null
  * Document : List, Map
  * Set : String Set, Number Set, Binary Set
* Table
  * Partition Key : TODO
  * Sork Key : TODO
* TTL (Time To Live) 기능 제공
* Index
  * Partition Key, Sort Key를 제외한 나머지 Attribute Query를 수행하기 위해서는 Index 생성 필요
  * GSI (Global Secondary Index), LSI (Local Secondary Indexes)
* Transaction
  * 다수의 Data 변경 Operation을 하나의 Transaction으로 처리 가능

##### 14.2.2. Capacity Mode

* Provisioned Mode
  * Default Mode
  * 초당 Read/Write 횟수 지정
  * RCU (Read Capacity Units), WCU (Write Capacility Unit)만큼 비용 청구
  * RCU & WCU를 대상으로 Auto-scaliing을 수행 가능
  * 예측 가능한 Workload에 적합

* On-Demand Mode
  * Read/Write 자동으로 Scale Up/Down 수행
  * 용량 예측 불필요
  * Provisioned Mode에 비해서 2~3배 비쌈
  * 예측하기 힘든 Workload에 적합

##### 14.2.3. DynamoDB Accelerator (DAX)

* DynamoDB를 위한 Memory Cache Service
* Microseconds Latency 지원
* App의 Logic 수정없이 적용 가능
* Default 5분 TTL
* vs ElasticCache
  * DAX : Object 단위 Caching, Query & Scan Caching
  * ElastiCache : Aggregation Result 저장

##### 14.2.4. DynamoDB Streams

* Item Level의 변경 (Create/Update/Delete)을 Stream으로 수신 가능
* Stream Target
  * Kinesis Data Streams
  * AWS Lambda
  * Kinesis Client Library Application
* Stream은 최대 24시간 지속
* Usage Case
  * Item 변경 Event 기반 Logic 처리
  * 분석
  * 다양한 Data Store에 저장 (ElasticSearch)
  * Cross-region Replication

##### 14.2.5. DynamoDB Global Tables

* 다수의 Region에 Active-Active Replication을 구성
* 모든 Region의 DynamoDB에서 Read, Write 수행가능
* DynamoDB Streams 기능 활성화가 반드시 필요

#### 14.3. API Gateway

* Managed Service
* WebSocket Protocol 지원
* API Versioning 지원
* 환경 (Dev, Stage, Prod) 지원
* API Key 생성 지원
* Request Throttling 지원
* Swagger, Open API 기반 Import, Export 기능 지원
* API를 기반으로 SDK를 생성하거나, API Spec 생성 가능
* Request, Response를 필요에 따라 변경 및 검증 가능
* Response 응답 가능

##### 14.3.1. Integration

* Lambda의 Reverse-Proxy 역할 수행
* HTTP Protocol 기반 Backend Server 역할 수행
* 모든 AWS API를 API Gateway를 통해서 노출 가능

##### 14.3.2. Endpoint Type

* Edge-Optimized
  * Global Client를 위한 Type
  * API Gateway는 하나의 Region에 위치하며, Edge Location을 통해서 외부 Region의 요청을 받음
* Regional
  * Client는 오직 API Gateway와 동일한 Region에 위치
  * Edge Location 활용 정책을 사용자가 설정
* Private
  * VPC 내부에서만 접근 가능

##### 14.3.3. Security

* IAM을 통해서 API 접근 인가 설정 가능
* Lambda Authorizer
  * Header의 인증 Token을 Lambda에서 수신하고 Lambda 내부에서 인증,인가 동작 수행
  * Lambda는 User에게 적용할 위한 IAM Policy를 Return
* Congito User Pool
  * Congnito에 저장되어 있는 User 정보를 통해서 인증 검증 가능
  * 인증만 수행 가능

#### 14.4. Cognito

* User Pool
  * User 정보를 저장하고 있는 Pool
* Federated Identity Pool
  * TODO

#### 14.5. SAM (Serverless Application Model)

* Serverless Application 개발 및 배포 Framework
* YAML 파일을 통해서 설정
* Lambda, API Gateway, DynamoDB Local 구동을 지원하여 쉬운 개발일 가능하도록 지원
* CodeDeploy를 활용하여 Lambda 배포 지원

### 15. Database

* RDBMS : RDS, Aurora
* NoSQL : DynamoDB (JSON), ElasticCache (Key/Value), Neptune (Graphs)
* Object Store : S3 / Glacier
* Data Warehouse : Redshift, Athena
* Search : ElasticSearch (JSON)
* Graphs : Neptune

#### 15.1. Redshift

* PostgreSQL 기반 OLTP Database
* Columnar Storage
* MPP (Massively Parallel Query)를 활용한 병렬 Query 처리
* S3, DynamoDB, DMS와 같은 별도의 Database에서 Data를 Load
  * Amazon Kinesis를 활용한 Data Load
  * S3에서 직접 복사하여 Data Loading
  * EC2 In JDBC Driver를 활용하여 Data Loading
* 1개의 Node부터 128개의 Node까지 이용가능, 노드당 최대 128TB 이용가능
* Node Type
  * Leader Node : Query Plan, Result Aggregation 수행
  * Compute Node : Query 수행 및 결과를 Leader Node로 전송
* Redshift Spectrum : S3의 Object를 대상으로 바로 Query를 수행
* VPC Routing : VPC를 통해서 Data Copy, Unload 수행 가능

##### 15.1.1. Snapshot & DR

* Multi-AZ Mode 존재 X
* Snapshot은 S3에 저장됨
* 생성된 Snapshot을 통해서 새로운 Redshift Cluster를 생성하여 복구 가능
* 생성한 Snapshot을 주기적으로 다른 Region으로 복사하도록 설정 가능

#### 15.2. Glue

* ETL (Extract, Transform, Load) Service
  * Redshift로 Load
* Serverless Service
* Glue Data Catalog
  * Crawler : S3, RDS, DynamoDB와 같은 Data Store의 Meta Data 수집
  * Glue Data Catalog : Crawler가 수집한 Meta Data를 저장
  * Meta Data : Table 정보, Data Type, Column 정보
  * 저장된 Meta Data는 Athena, Redshift Spectrum, EMR에서 이용 가능

#### 15.3. Neptune

* Graph Database
  * High relation data
  * Social Networking
  * Wikipedia
* Managed Service
* 3개의 AZ를 활용하며, 최대 15개의 Read Replica 지원
* S3를 통한 Backup 지원

#### 15.4. OpenSearch

* 모든 Field를 대상으로 검색수행 가능
  * Big Data 분석용으로 많이 이용
* EC2 Cluster를 통해서 구성
  * EC2 Instance Node에 따라 과금
* Kinesis Data Firehose, AWS IoT, CloudWatch Log와 통합제공
* Cognito, IAM, KMS encryion, SSL & VPC를 활용한 보안 기법 제공
* OpenSearch Dashboard 제공

### 16. Monitoring, Audit

#### 16.1. CloudWatch Metric

* 모든 AWS Service는 고유의 Metric 값을 소유
* Metric은 Namespace에 종속
* Metric당 최대 10개의 Dimension 존재
* EC2 Instance는 기본적으로 5분 간격으로 Metric 수집
  * 추가 비용을 내고 1분 간격으로 Metric 수집
* 사용자의 Custom Metric도 정의 및 직접 API를 통해서 직접 Push 가능

#### 16.2. CloudWatch Dashboard

* Dashboard는 Global Resource
* Dashboard는 다른 계정 또는 다른 Region의 Graph도 포함시킬 수 있음
* AWS 계정이 없는 제 3자에게 공유 가능
  * Email 주소, Amazon Cognito 이용
* 3개의 Dashboard까지 무료, 이후에는 한달에 3$

#### 16.2. CloudWatch Log

* Log 수집 서비스
* Log Group이 존재하며 Group 이름은 일반적으로 App/Service 이름으로 이용
* Log 만료기간 설정 가능
  * 30일, 만료 X
* Log Target
  * S3, Kinesis Data Stream, Kinesis Data Firehose, AWS Lambda, ElasticSearch
* Log Source
  * SDK, CloudWatch Log Agent
    * CloudWatch Log는 기본적으로 EC2에 설치되어 있지않고, 사용자가 직접 설치 필요 
  * Elastic Beanstalk, ECS, AWS Lambda, VPC Flow Logs, API Gateway

#### 16.3. CloudWatch Alarms

* 어떠한 Metric이든 Alarm으로 Trigger 가능
  * Log의 경우에도 Metric 지표로 변환이 가능하며, 변환된 Metric을 통해서 Alarm 설정 가능
* Alarm 상태
  * OK : Alarm이 Trigger되지 않음
  * INSUFFICIENT_DATA : 상태를 결정할 Data가 부족
  * ALARM : Alarm이 Trigger됨
* Period
  * Metric을 Check하는 주기 설정 가능
  * 10초, 30초 그리고 60초 주기로 설정 가능
* 주요 Metric Target
  * EC2 Instance
  * Auto Scailing
  * SNS 

#### 16.4. CloudWatch Events

* AWS Service로부터 Event 수신 가능
* Event Source
  * Compute : Lambda, Batch, ECS Task
  * Integration : SQS, SNS, Kinesis Data Stream, Kinesis Data Firehose
  * Orchestration : Step Functions, CodePipeline, CodeBuild
  * Maintenance : SSM, EC2 Actions

#### 16.5. EventBridge

* Cloudwatch Event의 확장 Service
* Event Bus Type
  * Default Event Bus : AWS Service가 생성하는 Event Bus
  * Partner Event Bus : AWS 기반의 SaaS Service로 부터 발생하는 Event Bus
  * Custom Event Bus : 사용자 App의 Event Bus
* 다른 AWS 계정에서도 권한 설정을 통해서 Event Bus 이용 가능
* Event Bus로 전송한 Event를 Archiving 할수 있으며, Archive된 Event를 다시 재생 가능
* Schema Registry 
  * Event의 Schema를 추론하여 EventBridge가 저장
  * 추론을 통해 얻은 Schema는 App에서 편리하게 Event의 Data를 이용할 수 있도록 Struct로 제공
  * Schema Version 관리 지원
* Resource-based Policy 적용 가능
  * EventBus 단위로 정책 설정 가능
  * 다른 계정으로부터 전송되는 Event 허용, 차단 가능
  * AWS Region에 따라서도 Event 허용, 차단 가능

#### 16.6. CloudTrail

* User의 AWS 활동 기록을 Logging 수행
  * SDK, CLI, Console, IAM Users & Roles
* 활동 기록 Log를 CloudWatch Log나 S3에 저장도 가능
* 모든 Region 또는 단일 Region을 대상으로 기록 가능
* CloudTrail Event
  * Management Event : 기본적으로 활성화 되어 있음
  * Data Event : 기본적으로 비활성화 되어 있음 (Event 기록에 많은 용량이 필요하기 때문)

##### 16.6.1. CloudTrail Insight

* CloudTrail 활동 기록 Log를 바탕으로 수상한 행동 탐지
* 탐지한 행동 Event는 다음의 곳으로 전달
  * CloudTrail Console
  * S3 Bucket
  * EventBridge

#### 16.7. Config

* 현재의 Configuration이 올바른지 검토 기능 제공
  * 검토 Rule을 사용자가 생성
* Configuration의 변화를 기록하는 기능 제공
* Configuration 변화를 SNS로 수신 가능
* Region단위 Service이기 때문에 필요한 Region마다 설정 필요

### 17. Security, Encrpytion

#### 17.1. KMS (Key Management Service)

* Key 관리 Service
* 다양한 AWS Service에서 Key 필요시 대부분 KMS Service를 활용
* CLI, SDK를 통해서도 이용 가능
* CMK (Custom Master Key) Type
  * Symmetric (AES-256)
  * Asymmetric (RSA & ECC Key Pairs)
* CMK (Custom Master Key) Type
  * AWS Managed Service Default CMK : Free
  * User Keys created in KMS : $1 month
  * User Keys imported : $1/month
* Key Management Action : Create, Rotation Policy 설정, Disable/Enable
* Key 사용을 CloudTrail을 통해서 감시 가능
* KMS에 접근하기 위해서는 User에게 Key Policy 할당이 필요하며 IAM 설정도 필요
* KMS Key는 특정 Region에 종속되며, Region 사이의 이동 불가능
  * Region 사이의 복사한 Data가 KMS로 암호화 되어있다면, Data 복사이후 새로운 KMS key로 다시 암호화 필요

#### 17.1.1. Key Rotate

* Automate Key Rotate
  * Customer-managed CMK만을 대상으로 Automatic Key Rotate 기능 이용 가능
  * 1년 주기로 Key Rotate 수행
    * 주기는 변경되지 않음
  * Key Rotate를 수행한 이후에도 동일한 CMK ID를 갖음
  * Rotate 이후에도 Rotate 이전의 Key는 하위 호완성을 위해서 지원

* Manual Key Rotate
  * 새로운 Key를 생성하여 사용자가 원할때 Key Rotate를 수행
  * 새로운 Key를 생성하였기 때문에 다른 CMK ID를 갖음
  * 기존 Key를 그대로 유지해야 이전 Data 복호화 가능
  * App은 CMK ID가 아니라 Alias를 통해서 접근하는 것을 권장
    * 새로운 Key 생성후 이전 Key에 붙어 있던 Alias를 새로운 Key에게 할당
    * Manual Key Rotate 수행시 CMK ID가 변경되는데, App이 Alias를 통해서 Key를 변경한다면 App 수정 불필요

#### 17.2. SSM Parameter Store

* Parameter (Configuration, Secret) 저장소
* KMS를 이용한 암호화 기능 제공
* Serverless, Scalable, Durable, 쉬운 SDK를 갖고 있음
* Tracking 기능 제공
* CloudWatch Event로 변경 감지가능
* CloudFormation과 결합 가능
* Directory 형태로 Parameter 관리 가능 Ex) Vault
* Parameter Policies
  * 만료시 자동 삭제
  * 만료시 CloudWatch로 Event 전송
  * 특정 기간동안 Parameter가 변경되지 않으면 CloudWatch로 Event 전송

#### 17.3. Secret Manager

* Secret 저장에 특화 (vs SSM Parameter Store)
* Secret Rotate 기능 제공
  * Rambda를 활용하여 Rotate 수행시 암호도 자동 생성하도록 지원
* RDS Secret 관리용으로 이용 가능

#### 17.4. CloudHSM

* 암호화 Hardware Module
* SSE-C 유형의 암호화를 구현

#### 17.5. Sheid

* Standard
  * L3/L4 Layer 기반 DDoS 보호
  * Sync/UDP Flooding, Reflection Attack 방지
  * 무료
* Shield Advanced 
  * 추가 비용을 좀더 다양한 Resource를 대상으로 정교한 DDoS 공격 보호
  * 보호 Target : Amazone EC2, ELB, CloudFront, Global Accelerator, Route 53
  * DRP (DDoS Response Team) 접근 가능
  * DDoS 공격으로 인해서 더 많은 비용 요금이 청구되었다면, 더 청구된 비용만금 캄면 가능

#### 17.6. WAF (Web Application Firewall)

* Layer7 Firewall
* Target : ALB, API Gateway, CloudFront
* Web ACL 기능 제공
  * ACL Rule : IP Address, HTTP Header, HTTP Body, URI 포함
  * SQL Injection, Cross-Site Scripting 공격 방지
  * 특정 국가 Block
  * Rate-based Rule 설정 가능

#### 17.7. Firewall Manager

* Organization의 Shield, WAF를 중앙 집중식으로 관리 기능 제공
* 공통 Rule 설정 기능 제공

#### 17.8. GuardDuty

* AWS 계정을 보호하는 서비스
* Machine Learning 기반으로 이상 동작 탐지
  * CloudTrail Event Log, VPC Flow Log, DNS Log, Kubernetes Audit Log를 기반으로 탐지 수행
* CloudWatch Event를 통해서 이상 탐자시 노티를 받을 수 있음
* 암호화페 공격보호 가능

#### 17.9. Inspector

* 구성된 AWS Infra의 보안 평가 서비스
* 보안 평가 Target
  * EC2 Instance
    * EC2 Instance에 설치된 SSM Agent를 통해서 보안 평가 수행
    * 의도하지 않은 Network 접근 가능
    * OS 취약점 검사
  * Contaienr Image in ECR
    * Contaienr Image가 ECR에 Push되는 경우 Image 검사 수행
* 검사 결과는 Security Hub에 취합, 또는 Event Bridge에 전송

#### 17.10. Amazone Macie

* Machine Learning Pattern Matching 알고리즘을 통해서 민감한 Data가 존재하는지 탐색
* 탐색 결과를 CloudWath Events, EventBridge로 전송 가능

### 18. Network

#### 18.1. VPC (Virtual Private Cloud)

* 걔정마다 Default VPC 존재
* 하나의 계정에 최대 5개의 VPC까지 생성 가능 (Softlimit)
* CIDR
  * Min CIDR : /28 (16 IP Address)
  * Max CIDR : /16 (65536 IP Address)
* VPC는 Private Network이기 때문에 다음의 Network 영역만 할당 가능
  * 10.0.0.0 ~ 10.255.255.255 (10.0.0.0/8)
  * 172.16.0.0 ~ 172.31.255.255 (172.16.0.0/12)
  * 192.168.0.0 ~ 192.168.255.255 (192.168.0.0/16)
* VPC끼리 CIDR가 겹치면 안됨
* 하나의 VPC당 하나의 VPC Router 존재

#### 18.2. Subnet

* Subnet Reserved IP
  * 모든 Subnet마다 5개의 예약된 IP가 존재
  * Subnet의 CIDR가 10.0.0.0/24일 경우
  * 10.0.0.0 : Network Address
  * 10.0.0.1 : VPC Router
  * 10.0.0.3 : DNS Server
  * 10.0.0.255 : Broadcast Address, VPC 내부에서는 Broadcast 미지원하기 때문에 실제 이용 X

#### 18.3. Internet Gateway

* VPC 내부에 존재하는 Resource (EC2)를 외부 Internet과 통신하게 도와주는 통로
* Managed Service
* 하나의 VPC에는 하나의 Internet Gateway만 붙일 수 있음
* IPv4의 경우에는 NAT 수행 O, IPv6의 경우에는 NAT 수행 X
  * AWS에서 할당하는 IPv6 Address는 Public IP Address이기 때문에 NAT 수행 불필요

#### 18.4. Bastion Hosts

* Public Subnet에 존재한는 공용 Host
* Private Subnet에 존재하는 EC2 Instance에 접근하도록 도와줌
* Security Group을 통해서 22 Port만 허용하도록 설정 필요

#### 18.5. NAT Gateway

* Elastic IP 할당 필요
* Managed Service
* 일반적으로 Public Subnet에 위치시켜 Private Subnet에 존재하는 EC2 Instance들이 Internet Gateway를 통해서 Internet을 이용할 수 있도록 구성
* NAT Gateway는 하나의 AZ 내부에서만 Resilient를 유지, AZ 장애시에는 동작하지 못함
  * 따라서 AZ마다 별도의 NAT Gateway를 구성하여 고가용성 확보
* IPv4만 이용 가능하며, IPv6는 Egress-only Internet Gateway를 이용해야함

#### 18.6. Reachability Analyzer

* 2개의 Endpoint 사이의 Connectivity를 분석할 수 있음
* 실제 Packet을 전송하는 방식이 아니라, Network 설정을 통해서만 분석 수행

#### 18.7. VPC Peering

* 2개의 VPC를 연결
* 연결하는 VPC의 CIDR가 겹치면 안됨
* VPC Peering은 Not Transitive
  * A - B - C 형태로 VPC Peering을 통해서 VPC가 연결되어 있더라도 A - C VPC 사이에 통신을 하기 위해서는 A - C 사이의 VPC도 설정 필요

#### 18.8. VPC Endpoint

* VPC 내부에 존재하지 않는 AWS Service에 접근하기 위한 통로
  * Ex) DynamoDB, SNS
* Managed Service
* Endpoint Type
  * Interface Endpoint
    * ENI를 Provisioning하여 Endpoint 제공
    * 대부분의 AWS Service에 접근 가능
    * Security Group 설정 필요
  * Gateway Endpoint
    * Gateway를 통해서 Endpoint 제공
    * Routing Table 설정 필요
    * S3, DynamoDB Serivce 접근시 이용

#### 18.9. VPC Flow

* VPC의 Packet 흐름을 Logging
  * VPC Flow, Subnet Flow, ENI Flow 확인 가능
* Packet Monitoring, Trouble Shooting시 유용
* Log는 S3 또는 CloudWatch로 전송 가능

#### 18.10. Site-to-Site VPN

* AWS의 VPC와 기업의 Private Network를 Public Network를 통해서 연결하는 VPN
* VGW (Virtual Private Gateway) : VPC 내부에서 VPN과 연결되는 Gateway
* Customer Gateway : 기업 내부에서 VPN과 연결되는 Software Application 또는 물리 장치
* VPC에서 Route Propagation 옵션 반드시 설정 필요
* 다수의 기업와 VPC 하나가 연결될 수 있음
  * 이 경우 기업사이에도 VGW를 통해서 통신 가능

#### 18.11. Direct Connect

* AWS의 VPC와 기업의 Private Network를 Private Network를 통해서 연결
  * VGW (Virtual Private Gateway) : VPC 내부에서 VPC와 Direct Connection Location을 연결하는 Gateway
  * Direct Connection Endpoint : Direct Connection Location에서 Direct Connection Location과 VPC를 연결
  * Customer, Partner Router : Direct Connection Location에서 Direct Connection Location과 기업의 Network 연결
  * S3와 같이 Public Endpoint를 접근하는 경우 Direct Connection Endpoint에서 VGW의 경로가 아닌 Direct Connection Endpoint에서 Public Endpoint로 접근
  * Direct Connection Location에 Direct Connection Endpoint, Customer, Partner Router를 두개 이상두어 고가용성 구성 가능
* Direct Connect Gateway : Direct Connect을 통해서 다른 Region에 접근하고 싶은경우 이용
* Connection Type
  * Dedicated Connection
    * 1Gpbs, 10Gpbs
    * 고객에게 할당된 전용 Ethernet Port를 통해서 연결
  * Hosted Connection
    * 50Mbps, 500Mbps to 10Gbps
    * Capacity는 요구사항에 따라서 변경 가능
* 암호화 수행 X
  * VPN + IPSec를 통해서 별도의 암호화 설정 가능
  * 보안성은 향상되지만 구성이 복잡해짐

#### 18.12. PrivateLink

* 원하는 VPC를 PrivateLink를 이용하여 다른 VPC에게 노출가능
* NLB - ENI를 서로 다른 VPC에 위치시키고 AWS Private Link로 연결 수행
  * NLB가 Multiple AZ에 위치한다면 ENI도 각 AZ마다 위치해야함

#### 18.13. Transit Gateway

* 다수의 VPC를 하나의 Transit Gateway에 연결 가능
  * Direct Connect Gateway, Site-to-Site VPN도 연결 가능
* Traffic 제어 가능
* Regional Resource
* 다른 Account에게 공유 가능
  * RAM (Resource Access Manager)를 통해서 공유 가능
  * Peer Transit
* IP Multicast 지원
* Site-to-Stie VPN을 다수 연결하여 기업과 VPC 사이의 연결의 대역폭을 확장하는데 이용
  * ECMP기반

#### 18.14. IPv6

* VPC에서 IPv6를 Enable시켜 Dual Stack Mode 가능
  * IPv4는 Disable 불가능
* VPC가 Daul Stack으로 동작하는경우 해당 VPC에 EC2 Instance가 붙는경우 IPv4, IPv6 두개의 IP가 할당 가능
* IPv6 Address는 Public IP Address를 할당받음

#### 18.15. Egress-only Internet Gateway

* IPv6만을 위한 Engress Gateway
* IPv4는 이용 불가능, IPv4의 Nat Gateway 비슷한 역할 수행
* VPC에 할당하여 이용
  * NAT Gateway는 Subnet에 할당하기 때문에 약간은 다른 구조
* Managed Service
* NAT 수행 X
  * AWS의 IPv6는 Public IPv6이기 때문에 NAT 수행 X

### 19. Migration

#### 19.1. DMS (Database Migration Service)

* Migration 중에도 Src Database 이용 가능
* 이기종간 Database Migration 지원
  * SCT (Schema Conversion Tool)를 통해서 Schema 변환도 지원
* CDC (Continuous Data Replication) 방식
* Migration Task 수행을 위해서 EC2 Instance 생성 필요

#### 19.2. Data Sync

* On-Premises와 AWS 사이의 Data 동기화 수행
  * On-Premises Target : NFS, SMB
  * AWS Target : S3, EFS, FSx
  * On-Premises에 AWS DataSync Agent 설치 필요
* 동기화 주기는 시간, 일간, 주간으로 설정 가능
* AWS 사이의 동기화도 수행 가능
  * EFS Region A - EFS Region B

#### 19.3. Backup

* Storage Service를 S3로 백업 진행
  * Target : EC2, EBS, S3, RDS, DynamoDB, DocumentDB, EFS, Aurora, Neptune, FSx, Storage Gateway
* Cross Account 지원
* Cross Region 지원
* Backup Vault Lock 지원
  * WORM (Write Once Read Many) 정책
  * Vault Lock이 걸린 Backup의 경우에 삭제 불가능

### 20. Machine Learning

* Rekognition : 사진이나 영상에서 사물과 사람을 인식
* Transcibe : 목소리를 Text로 변환
* Polly : Text를 목소리로 변환
* Translate : 언어 변역
* Lex : Amazon Alexa 기능 제공
* Connect : 전화 상담
* Comprehend : NPL (Natural Language Processing)
* SageMaker : ML Model 구축을 적용을 위한 개발, 운영 환경 제공
* Forecast : 미래를 예측하는 기능
* Kendra : Document Search 기능
* Personalize : 개인 추천 기능
* Textract : Scan된 문서에서 Text 추출

### 21. Reference

* [https://www.udemy.com/course/best-aws-certified-solutions-architect-associate](https://www.udemy.com/course/best-aws-certified-solutions-architect-associate)
* EC2 Instance vs AMI : [https://cloudguardians.medium.com/ec2-ami-%EC%99%80-snapshot-%EC%9D%98-%EC%B0%A8%EC%9D%B4%EC%A0%90-db8dc5682eac](https://cloudguardians.medium.com/ec2-ami-%EC%99%80-snapshot-%EC%9D%98-%EC%B0%A8%EC%9D%B4%EC%A0%90-db8dc5682eac)
* Route53 Alias : [https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html)
* Route53 Alias : [https://serverfault.com/questions/906615/what-is-an-amazon-route53-alias-dns-record](https://serverfault.com/questions/906615/what-is-an-amazon-route53-alias-dns-record)
* Auto Scaliing Policy : [https://tutorialsdojo.com/step-scaling-vs-simple-scaling-policies-in-amazon-ec2/](https://tutorialsdojo.com/step-scaling-vs-simple-scaling-policies-in-amazon-ec2/)
