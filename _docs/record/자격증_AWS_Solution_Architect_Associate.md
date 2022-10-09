---
title: 자격증 AWS Solutions Architect Associate 이론 정리
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
      * ??
    * Application Cookie
      * AWSALBAPP 이름의 Cookie 이름 이용
  * Duration-based Cookie
    * ??

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
  * Ex) ASG Group 평균 CPU 사용률이 70%가 넘어가면 EC2 Instnace 5개 추가
  * Ex) ASG Group 평균 CPU 사용률이 40% 미만이면 EC2 Instance 5개 감소

* Step Scailing
  * CloudWatch Alarm 기반 정책
  * ???

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

### 7. Elastic Cache

### 8. Reference

* [https://www.udemy.com/course/best-aws-certified-solutions-architect-associate](https://www.udemy.com/course/best-aws-certified-solutions-architect-associate)
* EC2 Instance vs AMI : [https://cloudguardians.medium.com/ec2-ami-%EC%99%80-snapshot-%EC%9D%98-%EC%B0%A8%EC%9D%B4%EC%A0%90-db8dc5682eac](https://cloudguardians.medium.com/ec2-ami-%EC%99%80-snapshot-%EC%9D%98-%EC%B0%A8%EC%9D%B4%EC%A0%90-db8dc5682eac)

---

### 3. S3

* Object Storage
* Size Limit가 존재하지 않음
* Static Data 저장소
  * Object Update시 Object 전체를 다시 Upload를 수합해야 때문에 Update가 잘 발생하지 않는 Static Data 저장에 적합
  * 분석용 Data Store
  * 백업용 Store

#### 3.1. Bucket

* Bucket 이름 중복 불가능

#### 3.2. 용량

* 각 Object의 용량은 최대 5TB
* Object의 개수 무제한

#### 3.3. Replication

* Region 단위 복제 수행

#### 3.4. Access Control

* IAM 기반 정책
* Bucket 기반 정책 (Resource 기반 정책)
  * Web Console에서 Bucket 단위로 설정
  * Public : 외부 User에게 공개
  * Private : 외부 User에게 비공개
  * Limited Access : 특정 User
* CORS 기능 제공

#### 3.5. 비용

* 비용 발생
  * 사용하고 있는 Size 비례, 단위는 GB
  * Region 경계를 넘어서 Object 송수신
    * 다른 Region 또는 외부 Internet으로 전송시 발생

* 비용 발생 X
  * Region 내부에서의 Object 송수신
    * CloudFront <-> S3 사이의 송수신  

#### 3.6. Storage Class

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

#### 3.7. Event Trigger 수행

* Lamba Service Event Trigger 역활 수행

#### 3.8. Static Web Server 기능 제공

* Bucket 단위로 Static Web Server 기능 On/Off 가능
* Bucket 권한을 Public으로 설정 필요
* 하나의 Bucket당 하나의 Web Server만 제공 가능

#### 3.9. Versioning

* 이전 Data를 저장하는 Versioning 기능 제공
* Versioning으로 인해 늘어난 용량 만큼 비용 청구

#### 3.10. Multi Part Upload

* 사용자가 지정한 크기로 파일을 쪼개어 병렬로 Upload 기능
* 병렬로 Upload된 이후에 S3 내부에서 통합
* Web Console 지원 X

#### 3.11. Transfer Accelation

* CloudFront Edge를 통해서 AWS 내부 Backbone Network를 활용하여 Object Upload 가능

#### 3.12. Snowball, Snowmobile

* 저장 장치를 AWS로 전송받아 저장후 AWS에게 저장 장치를 전달하여 S3에 복사하는 방법
* 일반적으로 7일 정도 시간이 소요되기 때문에, S3로 Upload가 7일 이상 걸린다면 이용을 고려

### 7. EFS (Elastic File System)

### 8. RDS

* RDBMS Service
* Scale Out 자동 수행

#### 8.1. DB Engine

* MySQL, PostreSQL, Aurora 지원
* MySQL, PostreSQL은 사용자가 관리해야하는 부분 발생
* Aurora는 사용자가 관리를 최소화 하는 방향으로 발전중

### 9. DynamoDB

* Document DB
* Event 기능 제공 (Lambda)
* Scale Out

### 10. Neptune

* Graph DB

### 11 VPC (Virtual Private Network)

* Private Netowrk 구성
* 하나의 Region을 선택하여 생성
* 하나의 Region 내부 다수의 AZ에서 동시에 이용 가능
* 각 계정마다 각 Region에 5개의 VPC 생성 가능 (Soft Limit)
* 각 VPC 마다 하나의 Routing Table 지원

#### 11.1 Subnet

* 하나의 VPC 내부에 존재
* 하나의 AZ에 존재
* 각 Subnet마다 하나의 Routing Table과 연결 가능
  * 다수의 Routing Table 하나를 여러개의 Subnet이 이용 가능
  * Subnet에 Routing Table이 설정되어 있지 않으면 VPC Routing Table 이용
* 다른 Subnet과의 CIDR가 중복 불가
* CIDR는 변경 불가능, Subnet 생성시 여유롭게 생성하는것을 권장
* Subnet Type
  * Public Subnet 
    * 외부 Internet과 통신하는 Subnet
    * EC2 Instance에 Public IP 부여 가능
    * Routing Table에 Internet Gateway 정보 포함
  * Private Subnet 
    * Routing Table에 다른 Subnet과 연결을 위한 NAT Gateway 정보 포함
    * 외부 Internet과 Outbound 통신을 위해서는 NAT Gateway를 통해서 Public Subnet과 연결 필요

#### 11.2 Internet Gateway

* 외부 Internet과 통신 Gateway 역활 수행
* 수평 확장, 고가용성 지원

#### 11.3 NAT Gateway

* 다른 Subnet과의 연결 통로
* 수평 확장, 고가용성 지원 

### 12. ELB (Elastric Load Balancing)

* Load Balancer
* Upgrade, Maintenance, High Availability 보장
* 비정상 Instance 감지 및 Failover 수행

#### 12.1. CLB (Classic Load Balancer)

* HTTP, HTTPS, TCP를 지원. 
* v1, Old Generation Load Balancer

#### 12.2. NLB (Network Load Balancer)

* TCP, TLS, UDP를 지원
* v2, New Generation Load Balancer

#### 12.3. ALB (Application Load Balancer)

* Application Load Balancer (ALB)
* HTTP, HTTPS, WebScoket를 지원한다. v2, New Generation Load Balancer이다.

### 13. Route 53

* DNS Server
* 다중 Region, 고 가용성

#### 13.1 Routing Option

* Round Robin
* Weighted Round Robin
* 지연 시간 기반
* 지리적 위치 기반
* 장애 대응 기반

### 14. CloudFront

### 15. ElasticCache

* In-memory Cache
* Redis, Memcached 제공