---
title: 자격증 AWS SysOps Administrator Associate 시험 정리
category: Record
date: 2023-02-10T12:00:00Z
lastmod: 2023-02-10T12:00:00Z
comment: true
adsense: true
---

### 1. Base

아래의 정리된 내용을 바탕으로 부족한 내용 정리

* [AWS Solutions Architecture Assosicate](https://ssup2.github.io/record/%EC%9E%90%EA%B2%A9%EC%A6%9D_AWS_Solutions_Architect_Associate/)

### 2. EC2

* Placement Group
  * EC2 Instance를 어떻게 배치할지 결정
  * Cluster
    * 하나의 AZ에 가능하면 하나의 Server Rack에 모든 EC2 Instance 배치
    * EC2 Instance 사이의 낮은 Network Latency 발생 가능, 하지만 가용성 측면에서는 가장 불리
  * Spread
    * EC2 Instance를 AZ, Server까지 고려하여 분배
    * 높은 가용성 확보 가능, 하지만 높은 Network Latency 발생
    * 하나의 Placement Group에서 하나의 AZ당 최대 7개의 EC2 Instance만 생성 가능, AZ 개수 * 7 만큼 EC2 Instance 생성 가능
  * Partition
    * Partition 이라는 논리적 Group 단위로 배치
    * Partition 장애시 다른 Partition에 영향을 주지 않음
    * 각 AZ당 7개의 Partition이 존재하며, 각 Partition당 최대 100개의 EC2 Instance 존재 가능

  * Luanch Exception
    * InstanceLimitExcceded
      * Region에서 이용가능한 vCPU 개수 초과
      * Service Quota로 증설 요청 가능
    * InsufficientInstanceCapacity
      * AZ에 이용가능한 Instance가 존재하지 않음
      * AWS의 Resource 부족 문제
      * 다른 Instance Type, 다른 AZ로 선택 생성하여 문제 우회 가능
    * Instance Terminates Immediately
      * EBS Volume Limit에 도달, EBS Snapshot 충동, EBS Volume이 암호화 되어 있지만 KMS 접근 권한이 없을 경우

  * Metric
    * without CloudWatch Agent
      * 5분 간격으로 Metric 수집, 1분 간격으로 Metric 수집 변경 가능 하지만 추가 비용 발생
      * CPU 사용률, Network I/O, Disk I/O Instance 상태 정보 수집 가능
    * with CloudWatch Agent
      * Memory 사용륭, Disk 사용률, Process 상태 (procstat Plugin)
      * 수집 간격 설정 가능 (최소 간격 1초)

  * Status Check
    * System Status Check
      * AWS System의 문제 검사 (Hypervisor, System Power..)
      * 문제 발생시 Instance를 Stop -> Start 시켜 복구 가능 (새로운 Hypervisor로 EC2 Instance Migration 수행)
        * CloudWatch Alarm과의 연동을 통해서 자동으로 Recover 하도록 구성 가능
        * Auto Scaling Group을 통해서 자동적으로 북구 되도록 구성 가능
    * Instance Status Check
      * EC2 Instance의 설정 문제 또는 EC2 Instance 내부의 문제 검사
      * 문제 발생시 관련 설정 변경 및 Instance 재시작을 통한 문제 복구 수행

### 3. AMI

* No Reboot Option과 함께 EC2 Instance 재시작 없이 AMI 생성 가능
* EC2 Image Builder를 통한 Image 제작 가능
* AMI Tag를 활용하여 Production 환경에서는 Production Tag가 붙어있는 AMI만 이용하도록 강제 가능
  * IAM Permission 활용 및 AWS Config 활용

### 4. Systems Manager

* EC2 Instance, On-premise System 관리 기능 수행
* 문제 탐지
* Patch 수행
* Windows, Linux에서 실행
* CloudWatch Metric, Dashboard와 연동해서 동작
* AWS Config와 연동 수행
* 공짜 이용
* EC2 Instance에 Agent 설치 필요
  * Amazon Linux2, Ubuntu에 기본 설치
* EC2 Instance에 SSM Action 수행 권한을 갖는 Role이 할당되어 있어야함

#### 4.1. SSM Resource Group

* Tag 기반으로 Resource Group 지정 생성 가능

#### 4.2. SSM Document & Run Command

* JSON, YAML 포맷 형태
* Parameter 지정
* Action 정의
* Run Command
  * Document 또는 Command 실행
  * 다수의 EC2 Instance 대상으로 실행 가능 (with Resource Group)
  * IAM, CloudTrail과 곹ㅇ함
  * SSH 불필요
  * 수행 결과는 CloudWatch, S3에 저장
  * SNS를 통해서 상태 전송 가능
  * EventBridge를 통해서 수행 가능

#### 4.3. SSM Automation

* 공통적으로 수행하는 유지, 배포 작업을 도와주는 서비스
  * Ex) Restart Instance, Create AMI, EBS Snapshot
* Automation Runbook
  * Automation을 위한 Document
  * Pre-defined 또는 User가 직접 제작 가능

#### 4.4. SSM Parameter Store

* Config 또는 Secret을 암호화 하여 저장하는 Storage (with KMS)
* Serverless
* Versioning 지원
* CloudFormation과 통합
* Directory 형태로 계층을 이룸
* Advanced Tier (유료)
  * Parameter Policy 지정 가능
  * Expiration, ExpirationNotification, NoChangeNotification 지정 가능

#### 4.5. SSM Inventory

* EC2 Instance, On-premise Metadata 수집
* Metadata
  * Software, OS Driver, OS Update, Running Services
* S3 저장 및 Athena Query + QuickSight를 통해서 시각화 가능
* Metadata 수집 주기 설정 가능

#### 4.6. SSM Stage Manager

* EC2 Instance, On-premise 관리를 위한 여러 동작들을 묶어서 자동화 기능 제공
* 언제 관리 동작을 수행할지 시간 설정 가능

#### 4.7. SSM Patch Manager

* EC2 Instance, On-premise Patch 수행
* Patch는 On-demand 또는 Maintenance Windows 시간에 수행
* Patch 수행 이후 결과 보고서 발행
* Patch Baseline
  * 수행할 Patch와 수행하면 안되는 Patch 정의
  * 사용자가 Custom Patch Baseline 작성 가능
  * 기본적으로 Critical Patch나 보안 관련 Patch는 설치 되도록 설정되어 있음

#### 4.8. SSM Session Manager

* EC2 Instance, On-premise에 Shell 접근 기능 제공
* SSH 방식 X, Bastion Host 불필요, SSH Key 불필요
* Session Log는 S3, CloudWatch Log에 저장 가능
* CloudTrail에 StartSession Event 기록이 남음

### 5. 참고

* [https://www.udemy.com/course/ultimate-aws-certified-sysops-administrator-associate](https://www.udemy.com/course/ultimate-aws-certified-sysops-administrator-associate)
