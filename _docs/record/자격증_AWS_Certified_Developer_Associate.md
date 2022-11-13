---
title: 자격증 AWS Certified Developer Associate 이론 정리
category: Record
date: 2022-11-10T12:00:00Z
lastmod: 2022-11-10T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. Base

아래의 정리된 내용을 바탕으로 부족한 내용 정리

* [AWS Solutions Architecture Assosicate](https://ssup2.github.io/record/%EC%9E%90%EA%B2%A9%EC%A6%9D_AWS_Solutions_Architect_Associate/)

### 2. AWS API & CLI

#### 2.1. API Call Limit (Quota)

* API 호출에 제한이 걸려 있음
  * Ex) EC2 DescribeInstance : 100 Call Per Seconds
  * Ex) S3 GetObject 5500 : 5500 Call Per Seconds, Per Prefix
  * 제한을 넘길시 ThrottlingException 오류 발생
  * Exponential Backoff 수행
* Exponential Backoff
  * AWS SDK를 이용한 API 호출시 AWS SDK 내부적으로 Exponential Backoff Logic이 포함되어 있음
  * AWS API를 직접 호출시 Client에서 Exponential Backoff Logic을 직접 구현
    * 5XX Error 발생시에만 Backoff를 시도하도록 구현 필요
    * 4XX Error 발생시 Backoff 수행 X

#### 2.2. Credential Provider Chain

* 다음의 순서대로 Credential을 찾아 적용
  * CLI Option : "--region", "--output", "--profile"
  * Env : AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN
  * CLI Credential File : ~/.aws/credentials
  * CLI Configuration File : ~/.aws/config
  * Container Credential
  * Instance Profile Credential

#### 2.3. Signing Request

* 대부분의 API 호출시 Access Key, Secret Access key를 이용하여 요청에 Signing 필요
* SDK, CLI를 통한 AWS API 호출시 SDK, CLI 내부적으로 Signing을 알아서 수행
* AWS API를 직접 호출시 "SigV4" 방식으로 요청을 Signing하여 전송

### 3. CloudFront

* CDN Service
* DDoS 보호

#### 3.1. CloudFront Origin

* S3 Bucket
  * S3 Object Caching 수행 가능
  * "OAI (Origin Access Identity)"를 이용하여 Security 강화 가능
  * Cloud Front를 통해서 S3 Object Upload도 가능
* Custom Origin
  * HTTP Protocol을 지원하는 Resource는 CloudFront Origin으로 이용 가능
  * Ex) ALB, EC2 Instance, HTTP Backend Server

#### 3.2. Caching Invalidation

* Caching된 정보는 TTL 설정을 통해서 얼만큼 유지 될지 설정 가능
* 명시적으로 Invalid API 호출을 통해서 Caching된 정보 갱신 가능

#### 3.3. Security

* 국가 단위로 Blacklist, Whitelist 설정 가능
* Client -> Edge Location
  * HTTPS 기반 암호화 가능
  * 정책 : HTTPS Only, HTTP to HTTPS Redirect를 통해서 HTTP 사용 억제 가능
* Edge Location -> Origin
  * HTTPS 기반 암호화 가능
  * 정책 : HTTPS Only, Match Viwer (Client -> Edge Location 사이가 HTTP일 경우 HTTP, HTTPS일 경우 HTTPS)

#### 3.4. Signed URL, Signed Cookie

* Cloud Front의 Data를 특정 User에게만 노출하고 싶은경우 Signed URL, Signed Cookie 이용 가능
* Signed URL, Signed Cookie에는 다음의 정보가 포함되어 있음
  * TTL, 접근 가능한 IP Range, Signer
* Signed URL 
  * 각 File마다 하나의 URL이 필요
* Signed Cookie
  * 하나의 Cookie로 다수의 File 접근 가능
* CloudFront Signed URL vs S3 Pre-Signed URL
  * TODO
* Signer Type
  * Trusted Key Group (현재 권장 Recommand)
    * Private Key : Application에서 URL Sign으로 이용
    * Public Key : CloudFront에서 Sign한 URL 검증용으로 이용
  * CloudFront Key Pair를 갖고 있는 계정 이용 (기본 방식, 권장 X)

### 4. ECS

* Container Orchestator Service
* ALB, NLB 연동 지원
* EFS 사용 권장

#### 4.1. Launch Type

* EC2 Launch Type
  * EC2 Instance 관리 필요
  * EC2 Instance 내부에는 ECS Agent가 동작
* Fargate Luanch Type
  * Serverless
  * EC2 Instance 관리 불필요

#### 4.2. IAM Role

* ECS Agent는 EC2 Instance Profile을 이용하여 IAM을 통해서 ECS, ECR, CloudWatch 호출
  * EC2 Launch Type일 경우만 해당
* ECS Task를 위한 전용 Role 할당 가능

#### 4.3. Component

* Task
  * 하나 또는 다수의 Container를 의미
  * 환경 변수을 통해서 Task에 Parameter 전달 가능
    * Hardcoding
    * SSM Parameter Store, Secret Manager의 값을 읽어서 환경 변수로 전달 가능
  * Task 내부의 Container 사이의 Data 공유를 위한 Volume 설정 가능 (Bind Mount)
    * EC2 Launch Type : EC2 Instance에 Data가 저장되기 때문에 EC2 Lifecycle에 따라서 Data의 Lifecycle도 저장, Volume Size도 EC2 Instance Type에 따라 결정
    * Fargate Launch Type : Volume Sie가 20GB가 Default이며 최대 200GB까지 이용 가능
* Service
  * Task의 집합
  * AutoScaling 지원
  * Task의 개수 유지 및 Rolling Update 지원
  * Load Balancer에 Service 단위로 연결 가능

#### 4.4. Auto Scaling

* Service를 대상으로 Auto Scaling 지원
* AWS Application Auto Scaling을 기반으로 동작
* 다음의 Metric 활용
  * ECS Service에 소속되어 있는 Task의 평균 CPU 사용량
  * ECS Service에 소속되어 있는 Task의 평균 Memory 사용량
  * ECS Service에 소속되어 있는 Task당 ALB가 보내는 평균 요청량
* 다음의 Algorithm 지원
  * Target Tracking : CloudWatch Metric이 특정 값을 충족시키도록 Scale In/Out 수행
  * Step Scailing : CloudWatch Alarm이 발생할때 마다 단계적으로 Scale In/Out 수행
  * Scheduled Scaling : Data/Time에 맞추어 Scale In/Out 수행
* EC2 Launch Type을 이용하는 경우 EC2 Instance도 Scaling 수행 필요
  * ASG를 활용하여 EC2 Instance Scaling 수행
    * ASG Group의 평균 CPU 사용률 기반
    * ECS Cluster Capacity Provider 기반 Task 수행에 필요한 CPU/Memory가 부족할시 Scaling Out 수행

#### 4.5. Rolling Update

* Minimum Health Percent, Maximum Percent 각각 설정 가능
* Ex) Min 50%, Max 100% : 4개의 Task가 동작하고 있다면 Old Version 2개 제거, New Version 2개 생성, Old Version 2개 제거, New Version 2개 생성 과정 진행
* Ex) Min 100%, Max 150% : 4개의 Task가 동작하고 있다면 New Version 2개 생성, Old Version 2개 제거, New Version 2개 생성, Old Version 2개 제거 과정 진행

#### 4.6. Load Balancing Packet Flow

* EC2 Launch Type
  * Client -> ELB -> EC2 Instance -> ECS Task의 경로로 Traffic 흐름 
  * EC2는 ELB로부터 Traffic을 받기 위해서 Host Port를 Mapping
  * EC2 Instance에 각 Task는 서로 Host Port를 이용하며 Random으로 부여됨
  * Host Port가 Random으로 부여되기 때문에 ELB -> EC2 Instance 사이에는 모든 Port가 열려있어야 하며 보안에 취약
* Fargate Launch Type
  * Client -> ELB -> ENI -> ECS Task의 경로로 Traffic 흐름
  * ENI와 ECS가 1:1로 Mapping되는 구조이기 대문에 각 ENI는 단일 Port만 이용가능 하며 단일 Port만 열려있으면 되기 때문에 보안에 유리

### 5. Elastic Beanstalk

* 개발자 관점의 배포 환경 구축 및 배포 Service
* EC2, ASG, ELB, RDS와 같은 일반적으로 이용되는 Service 모두를 Elastic Beanstalk를 통해서 빠르게 구성 가능
* Elastic Beanstalk 이용은 무료지만, Elastic Beanstalk로 구성된 Service 비용은 지불 필요
* App Version 관리 지원
* 다양한 배포 환경 구성 가능 : Ex) Dev, Stage, Prod...
* 다양한 언어 지원 : Ex) Go, Java, Java with Tomcat, .Net Core, Node.js, PHP...
* Tier
  * 배포 형상을 의미
  * Web Server Tier : EC2 Instance가 ASG로 묶여 있고, ELB로부터 Traffic 수신
  * Worker Tier : EC2 Instance가 ASG로 묶여 있고, ELB로부터 Traffic 수신
  
### 6. Reference

* [https://www.udemy.com/course/best-aws-certified-developer-associate/](https://www.udemy.com/course/best-aws-certified-developer-associate/)