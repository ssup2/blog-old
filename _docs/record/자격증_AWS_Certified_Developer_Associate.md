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
  * Web Server Tier : EC2 Instance가 ASG로 묶여 있고, ELB로부터 Traffic 수신하여 처리 
  * Worker Tier : EC2 Instance가 ASG로 묶여 있고, SQS로부터 Job을 수신하여 처리
* CloudFormation을 기반으로 동작

#### 5.1. Deployment Mode

* All at once : 한번에 모든 New Version App 배포, 일시적 App 중단 발생
* Rolling : 소수의 Old Version App을 New Version App으로 점차적으로 교체, 배포한 New Version App이 정상 상태가 되어야 다음 Old Version App이 배포 수행, Old Version App을 먼저 제거하고 제거한 만큼 New Version App을 구동하는 방식이기 때문에 New Version App 개수 + Old Version App의 개수는 변하지 않음
* Rolling with Additional Batches : Rolling 방식과 유사하지만 New Version App을 먼저 생성하고 Old Version App을 제거하는 방식이기 때문에 일시적으로 New Version App 개수 + Old Version App의 개수 증가
* Immutable : 새로운 AGS를 생성하고 생성한 ASG에 New Version App을 모두 구동한 이후 Swap 방식으로 한번에 교체
* Blue/Green : Elastic Beanstalk에서 지원하는 방식은 아니지만 수동으로 Blue/Green 배포 수행 가능. 별도의 배포 환경을 생성하고 생성한 배포환경에 New Version App을 구동. 이후에 Route53을 이용하여 Traffic을 점차적으로 New Version App으로 넘김

#### 5.2. Configuration

* zip 파일 에 배포할 Code가 위치
* Elastic Beanstalk의 설정은 zip 파일 내부에서도 설정 가능
* zip 파일의 .ebextensions 하위 Dir에 위치
* YAML, JSON Format 둘다 지원
* .config 확장자를 가지고 있어야함
  * Ex) logging.config
* option_setting 파일을 통해서 Default 설정 변경 가능
* Elastic Beanstalk는 CloudFormation을 기반으로 하고 있기 때문에 .ebextensions Dir하위에 CloudFormation 설정파일을 두어 AWS Resource 배포 가능

#### 5.3. Cloning

* Clone을 통해서 동일한 환경 구축 가능
  * 모든 Resource를 그대로 복제
* Test 환경 구축시 용이
* Clone 이후에는 독립적으로 설정 변경 가능

#### 5.4. Migration

* ELB Migration
  * ELB 환경 구성 이후에는 ELB Type 변경은 불가능
  * ELB Type을 변경하기 위해서는 ELB를 제외한 나머지 Resource만 Clone을 수한한 이후에 Route53을 통해서 Traffic Migration을 수행
* RDS Migration
  * RDS를 Elastic Beanstalk로 생성시에 Elastic Beanstalk 삭제시 RDS도 같이 삭제되는 문제 발생
  * RDS를 유지하면서 App만 별도의 환경을 Migration 하기 위해서 다음의 과정 수행
    * RDS가 존재하는 Elastic Beanstalk의 설정을 변경하여 삭제시 RDS는 삭제하지 않도록 변경
    * 새로운 환경의 Elastic Beanstalk를 생성, 이경우 RDS는 새로 생성하지 않도록 설정하며 기존의 RDS를 이용하도록 설정
    * Route53을 이용하여 새로 생성한 Elastic Beanstalk로 Traffic을 전달하도록 설정
    * 기존의 Elastic Beanstalk 삭제

#### 5.5. with Docker

* Single Docker Mode
  * EC2 Instance에 Docker를 설치하고 단일 Container만 실행
  * Dockerfile 또는 Dockerrun.aws.json 파일을 통해서 EC2 Instance에 실행할 Container Image 및 설정 가능
* Multi Docker Container
  * EC2 Instance에 다수의 Container를 실행
  * Elastic Beanstalk에서 ECS Cluster를 생성하고 이용
  * Dockerrun.aws.json 파일을 통해서 ECS Task 정의 가능
  * Container Image는 사전에 ECR과 같은 Registry에 저장되어 있어야 한다.

#### 5.6. HtTPS Certificate 설정

* ALB에 Certificate 지정을 통해서 HTTPS 이용 가능
* Certificate 지정은 Web Console에서 지정하거나, .ebextensions/securelistner-alb.config 파일에 지정 가능
* Certificate는 ACM 또는 CLI를 통해서 설정 가능

### 6. CI/CD

#### 6.1. CodeCommit

* Git Repository Service
* Managed Service
* VPC 내부에 존재
* IAM과 인가/인가 연계 가능
* KMS Key로 암호화 수행
* Repository 공유를 위해서 IAM Role + STS를 통해서 공유
* Event는 SNS 또는 Chatbot을 통해서 외부로 전달 가능

#### 6.2. CodePipeline

* Workflow Service
* Stage Type
  * Source : CodeCommit, EC#, S3, Bitbucket, Github
  * Build : CodeBuild, Jenkins, CloudeBees, TeamCity
  * Test : CodeBuild, AWS Device Farm
  * Deploy : CodeDeploy, Elastic Beanstalk, CloudFormation, ECS, S3
* 각 Stage은 직렬 또는 병렬로 수행 가능
* Manual Approval 기능도 제공
* Artifacts
  * 각 Stage의 결과물을 Artifact라고 명칭
  * Artifact는 S3에 저장되며 다음 Stage로 전달 가능
* 각 Stage 처리 과정은 CloudWatch Event, Event Bridge를 통해서 전달 받을 수 있음

#### 6.3. CodeBuild

* Code 위치 : CodeCommit, S3, Bitbucket, Github
* Code에 존재하는 buildspec.yml 파일을 통해서 Build 수행
* Output Log는 S3 또는 CloudWatch Logs에 저장되어 확인 가능
* CloudWatch Metric을 이용하여 Build 관련 통계 확인 가능
* CloudWatch Events를 이용하여 실패한 Build에 대해 Notification 가능
* CloudWatch Alarms를 이용하여 Thresholds를 넘긴 Build에 대해서 Notification 가능
* Build는 Container 내부에서 수행되며, Build를 수행하는 Container의 Image는 Customize 가능
* Local 환경에서도 구동할 수 있도록 제공
  * Docker, CodeBuild-Agent 설치 필요
* 기본적으로 VPC 외부에서 Build를 수행하지만, VPC 지정을 통해서 VPC 외부에서도 Build 가능
  * VPC 내부의 Resource에 접근해야할 경우 이용

##### 6.3.1. buildspec.yaml

* 반드시 Code의 Root에 위치
* Env : 환경 변수
  * variables : plaintext 이용
  * parameter-store : SSM Parameter Store의 저장값 이용
  * secrets-manager : Secret Manager의 저장값 이용
* Phases : 명령어 정의
  * install : Build Dependency 해결을 위한 명령어
  * pre_build : Build 수행전 마지막 명령어
  * Build : Build 수행을 위한 명령어
  * post_build : Build 수행후 실행하는 명령어
* Artifacts : S3에 Upload 되어야하는 파일
* Cache : Build 성능 향상을 위해 Caching 되어야 하는 File

#### 6.4. CodeDeploy

* App을 다수의 EC2 Instance, On-premise Server에 배포
* EC2 Instance, On-premise Server에 CodeDeploy Agent 설치 필요
* appspec.yml 파일을 통해서 배포 수행
* 배포 Group (EC2 Instance), 배포 Type (Once At A Time, Half At A Time, All At Once, Custom), IAM Instance Profile, App Revision등 지정 가능

##### 6.4.1. CodeDeploy Agent

* CodeDeploy Agent는 Polling을 통해서 CodeDeploy Service에게 배포할 App이 있는지 확인하고
* 배포해애햘 App이 있다면 Code + appspec.yml 파일을 Download한 이후에 배포 수행

##### 6.4.2. appspec.yml

* files : Source Code를 어디서 받을지 지정
* hooks : 배포를 어떻게 진행할지 설정
  * ApplicationStop
  * DownloadBundle
  * BeforeInstall
  * Install
  * AfterInstall
  * ApplicationStart
  * ValidateService : 정상적으로 배포가 되었는지 확인, 반드시 설정 필요

#### 6.5. CodeStar

* Github, CodeCommit, CodeBuild, CodeDeploy, CloudFormation, CodePipeline, CloudWatch 등의 Service 조합을 도와주는 Service

#### 6.6. CodeArtifact

* Software Package 저장소
* VPC 내부에 위치

#### 6.7. CodeGuru

* ML 기반 Code Review Service
* Profiler 기능 제공

### 7. CloudFormation

* IaC Service
* Stack을 생성하고, 생성한 Stack에 원하는 최종 Infra 형상을 Code로 저장하면 CloudFormation에서 Infra 자동 생성
* Infra 형상을 변경하고 싶다면, 변경된 최종 Infra 형상을 Stack에 저장하면 CloudFormation에서 기존 Infra 형상과 비교하여 변경된 부분을 자동으로 탐지하고 Infra 변경 수행
  * Cloud Formation에서 탐지한 변경된 부분을 ChangeSet이라고 명칭
* Stack을 삭제한 경우 Stack에 포함된 모든 Resource들도 삭제 수행
* 대부분의 AWS Resource를 CloudFormation을 통해서 생성 가능
* Parameter 기능을 활용하여 변수화 가능
* Mapping 기능을 활용하여 고정값(Const) 이용 가능
* 출력을 지원하며 출력값은 다른 Stack에서 전달받아 이용 가능
* 조건문 지원
* 내장 함수 지원
* Nested Stack 지원
  * Stack 내부에 Stack을 가질수 있음
  * Stack 재사용성을 위해서 이용
* CloudFormation을 통해 생성된 Resource를 User가 직접 변경 가능
  * 변경된 Resource를 Drift라고 명칭하며, Drift를 확인하는 기능 제공

#### 7.1. Rollback

* Stack 생성중 Error가 발생하면 모든 Resource 삭제 수행후 종료
* Stack Update중 Error가 발생하면 Update전 상태로 되돌리고 종료
* Rollback Option은 Enable/Disable 가능

### 8. X-Ray

* Tracing Service
* 지원 Service : AWS Lambda, Elastic Beanstalk, ECS, ELB, API Gateway, EC2 Instances
* 적용 방법
  * X-Ray SDK를 App 내부에서 이용
  * EC2 Instance에 X-Ray Daemon 설치

#### 8.1. X-Ray Concepts

* Segments : Application, Service에서 X-Ray에게 전송하는 최소 정보
* Subsegments : Segment에 좀더 자세한 정보를 붙여야할 경우 Segment 하위에 붙는 정보
* Trace : Segment의 집합으로 구성되는 추적 정보
* Sampling : X-Ray에게 정보를 전달하는 빈도수, X-Ray에게 많은 정보를 보낼수록 비용 증가
* Annotation : Trace의 Indexing에 이용되는 Key-Value Pair, Filter를 이용하여 Indexing된 Trace 검색 가능
* Metadata : Index되지 않는 Key-Value Pair, 검색에도 이용 불가능

#### 8.2. Sampling Rules

* X-Ray에게 더 많은 Trace를 전송할 수록 비용 증가
* Sampling Rule 변경은 X-Ray 중앙에서 설정하며, App에서는 변경 불필요
* Reservior : 초당 X-Ray로 전송되어야 Trace 정보
  * Ex) reservior 5 : 초당 5개의 Trace를 전송
* Rate : Reservior를 초과하는 Trace를 전송하는 비율

#### 8.3. with ECS

* X-Ray Daemon을 2가지 형태로 구성 가능
* X-Ray Daemon Container : X-Ray Daemon을 모든 EC2 Instance에 하나씩 Container 형태로 구성
* Sidecar : X-Ray Daemon을 App Container의 Sidecar로 구성, Fargate 이용시 Sidecar 형태로만 구성 지원

### 9. CloudTrail

* AWS Account 관련 모든 활동(Event)을 기록하는 Service
  * Console, SDK, CLI, AWS Service
* Default로 활성화 되어 있음
* 활동 기록은 기본적으로 90일 동안 저장
* 90일 이상 저장하기 위해서는 CloudWatch Logs 또는 S3로 전송하여 저장 필요
* 활동 기록을 S3에 저장한 이후에 Athena를 활용하여 분석 가능

#### 9.1. CloudTrail Event (활동)

* CloudTrail에서 저장하는 Event
* Management Event
  * AWS Resource의 형상, 설정을 바꾸는 Event
  * Management Event은 CloudTraild에서 기본적으로 기록하도록 설정
  * Ex) Subnet Create
* Data Event
  * AWS Resource에 Data CRUD Event
  * Data Event는 CloudTrail에서 기본적으로 기록하지 않도록 설정 (설정시 많은 Event가 기록되기 때문)
  * Ex) S3 GetObject, S3 DeleteObject, S3 PutObject
* CloudTrail Insights Event
  * CloudTrail Insights에서 발생시키는 Event

#### 9.1. CloudTrail Insights

* CloudTrail의 활동 기록을 바탕으로 비정상 동작 탐지 수행
* 비정상 동작 탐지시 CloudTrail Insights Event를 발생
* CloudTrail Insights Events는 CloudTrila Console, S3 Bucket, EventBridge로 전송 가능

### 10. Lambda

* Function as as Service
* 동기 호출, 비동기 호출 지원
* Key-value String 기반 환경 변수 기능 제공
* CloudWatch Logs, Metrics를 통하여 Log 및 Metric 수집 가능
* X-Ray 연동을 해서 Tracing 가능
* Lambda 함수의 Timeout은 기본 3초이며 최대 15분까지 설정 가능

#### 10.1. with ALB, API Gateway

* ALB, API Gateway 뒤에 Lambda 추가 가능
* HTTP Request는 JSON으로 변환되어 오며, Lambda에서 JSON을 반환하면 다시 HTTP로 변환되어 Response 전송
* URL Query, HTTP Header에 동일한 Key를 기반으로 여러 Value가 설정되어 있을경우, 여러 Value들을 Array 형태로 Lambda에게 전달

#### 10.2. Lambda Edge

* Lambda를 Edge Location에서 실행
* 빠른 반응의 App 구현 가능
* 다음의 4곳에 Lambda를 위치 시켜 CDN Contents 변경 가능
  * Request : User -> CloudFront 사이
  * Request : CloudFront -> Origin 사이
  * Response : Origin -> CloudFront 사이
  * Response : CloudFront -> User 사이

#### 10.3. Async 호출

* S3, SNS, CloudWatch Event외 기타 Service에서 Async 호출 이용
* 호출 요청은 Lambda Service 내부의 EventQueue에 저장되며 하나씩 가져와 실행
* Lambda 함수 수행 실패시 최대 3번 Retry를 시도하며 1분, 2분 대기후 실행
  * Retry로 인해서 여러번 호출 될 수 있기 때문에 Lambda 함수 수행시 멱등성을 갖도록 개발 되어야 함
  * Dead-letter Queue 이용 가능 (SQS, SNS로 실행 실패 Event 전송)
* Destination 기능 제공 
  * Lambda 함수 수행 결과를 외부로 전송 가능
  * SQS, SNS, Lambda, EventBridge Bus
  * 현재 AWS에서는 Dead-letter Queue보다 Destination 기능 이용 권장

#### 10.4. with S3

* Sync 기반 : S3 -> SQS -> Lambda
* Async 기반 : S3 -> Lambda
* S3 모든 Event를 받고 싶다면 S3 Versioning 기능 활성화 필요

#### 10.5. Event Source Mapping

* Kinesis Data, SQS, DynamoDB Streams와 같이 Client의 Polling이 필요한 경우 이용
* Lambda 내부에서 Polling 수행, Event 발생시 Event 처리
* with Stream
  * Kinesis Streams, DynamoDB Streams의 경우
  * 각 Shard마다 별도의 Interator를 생성하여 Polling 수행
  * Shard마다 최대 10개의 Batch 수행 가능
  * Error 발생시 기본적으로 다시 성공할때까지 Batch 반복 수행, 무기한 Retry 발생 가능
    * Old Event 버리기, Retry 횟수 제한, Event 분활 처리와 같은 방법으로 해결 가능
    * 버려진 Event는 SQS, SNS로 전송 가능
* with Queue
  * SQS, SQS FIFO의 경우
  * Long Polling을 통해서 Labmda는 Event 수신
  * 처리에 실패한 Event는 SQS를 Dead-letter Queue로 이용 가능

#### 10.6. 권한

* IAM 기반
  * Account User가 Lambda 함수를 실행하는 경우 이용
  * Lambda 함수를 위한 Role을 생성하고 붙임
* Resource Based Policy
  * 다른 Account User 또는 AWS Service가 Lambda 함수를 실행해야하는 경우 이용

#### 10.7. Network

* Default
  * AWS 내부에서 관리하는 전용 Lambda Network에서 Lambda 함수 실행
  * 외부 Internet 접근 가능, Account 내부의 VPC 접근 불가능
* With VPC
  * Lambda 함수가 ENI를 통해서 VPC 내부에 접근 가능하도록 설정 가능
  * Private Subnet, Public Subnet 설정 가능
  * Internet 접근은 VPC 내부의 NAT Gateway를 통해서 접근
    * Lambda함수가 Public Subnet에 위치하고 있더라도 Internet 접근은 NAT Gateway를 통해서 접근

#### 10.8. Spec

* Lambda 함수는 128MB ~ 10GB 이용가능
* Memory를 많이 이용할 수록 더 많은 vCPU Credit을 할당 받을 수 있음
  * 1729MB를 이용하면 하나의 vCPU를 할당 받는 효과
  * 1729MB 이후에는 하나 이상의 vCPU를 이용함. 따라서 Function이 Multi-thread를 이용하도록 수정 권장

#### 10.9. Context

* 동일한 Lamda 함수 사이의 Context를 공유하는 기능 제공
* Context EX) DB Connection, HTTP Client, SDK Client
* Context 공유를 통해서 Lambda 함수 초기화 시간을 줄일 수 있음
* /tmp Directory도 Context로 활용 가능

#### 10.10. Concurrency & Throttling

* 각 계정마다 Region당 최대 1000까지 동시에 실행 가능
  * Support Ticket을 열어 1000개 이상 Quota 증설 가능
* 함수마다 최대 몇개까지 동시에 실행할 수 있는지 설정 가능
* 최대 실행개수를 넘어가면 Throttling 발생
  * Sync 호출시 : 429 Error
  * Async 호출시 : Dead-letter Queue로 전송
* Provisioned Concurreny 방지 : 미리 Lambda 함수들을 초기화하여 Cold Start 방지

#### 10.11. Code Dependency

* Lambda 함수 Build를 위한 Package도 같이 제공 필요
  * Node.js : node_modules
  * Python : pip --target
  * Java : .jar
* ZIP 파일을 통해 Lambda에 직접 Upload, 50MB 초과시 S3를 활용
* Native Library는 ZIP 파일에 추가 필요, AWS SDK는 별도의 추가 필요 없음

### 11. Reference

* [https://www.udemy.com/course/best-aws-certified-developer-associate/](https://www.udemy.com/course/best-aws-certified-developer-associate/)