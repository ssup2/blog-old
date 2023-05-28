---
title: 자격증 AWS Certified Data Analytics
category: Record
date: 2023-05-29T12:00:00Z
lastmod: 2023-05-29T12:00:00Z
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

### 2. Collection

* RealTime : 실시간 Data 수집
  * Kinesis data Streams (KDS)
  * Simple Queue Service (SQS)
  * Internet of Things (IoT)

* Near-real Time : 준실시간 Data 수집
  * Kinesis Data Firehose (KDF)
  * Database Migration Service (DMS)

* Batch : 일괄 Data 수집
  * Snowball
  * Data Pipeline

#### 2.1. Kinesis Data Streams

* 다수의 Shard로 구성
* Retention : 1 ~ 365 Days
* 저장된 Data는 지울수 없음
* Producer
* Record
  * Producer가 전송하는 Data
  * Partition Key : Record가 어느 Shard로 전달될지 결정
  * Data Blob : Data 저장소
* Consumer
* Capacity Mode
  * Provisioned Mode
    * 사용자가 Shard의 개수를 지정
    * Shard 개수당 비용 발생
  * On-demand Mode
    * Traffic 양에 따라서 자동으로 Scaling 수행
    * 기본 성능 : 4 MB/sec, 4000 msg/sec
    * Shard 개수 및 Traffic 양에 따라서 비용 발생
* Security
  * IAM 기반 인증/인가
  * 전송 Data 암호화는 HTTPS 이용
  * 저장된 Data 암호환느 KMS 이용
  * VPC 내부에서 VPC Endpoint를 통해서 접근 가능
  * CloudTrail을 통한 추적

##### 2.1.1. Kinesis Producer

* Ex) Application, SDK KPL, Kinesis Agent, CloudWatch Logs, AWS IoT, Kinesis Data Analytics
* 성능
  * Shard당 1 MB/sec, 1000 msg/sec 제한
  * 초과시 ProvisionedThroughputExceeded Exception 발생
    * 더 많은 Data를 보내고 있는건지, Hot Shard가 발생하고 있는건지 확인 필요
    * Backoff 기반 재시도, Shard 증가, Partition Key 점검을 통해서 문제 해결
* API
  * 단일 : PutRecord
  * 복수 : PutRecords
* Kinesis Producer Library (KPL)
  * C++/Java 지원
  * Retry 로직 지원
    * 최대 30분 동안의 Data를 가지고 있으며, Retry 수행
  * Sync, Async API 지원
  * CloudWatch로 Metric 전송
  * Batching 수행
    * Throuput 증가, 비용 감소
    * RecordMaxBufferedTime의 시간 만큼 대기후 한번에 전송 (Default 100ms)
    * Write API를 직접 이용하는것 대비 Latency가 발생하기 때문에, Latency가 중요한 Application이라면 KPL 이용을 권장하지 않음
  * 압축은 제공하지 않으며 App에서 직접 구현 필요
  * KPL로 Encoding된 Record는 반드시 KPL 또는 Helper Library를 통해서 Decoding 필요
* Kinesis Agent
  * Log 파일을 Kinesis Data Streams로 전송
  * KPL 기반
  * Data 전처리 지원

##### 2.1.2. Kinesis Consumer

* Ex) Application, AWS Lambda, Kinesis Data Firehose, Kinesis Data Analytics
* 성능
  * Default : 2 MB/sec all Consumer
  * Enhanced Fan Out 이용시 : 2 MB/sec per Consumear
* API
  * GetRecords
    * 다수의 Record를 가져옴
    * Client의 Polling 필요
    * 한번의 호출로 각 Shard당 최대 2 MB Data 수신 가능
    * 한번의 호출로 최대 10 MB Data, 10000개의 Record 수신 가능
      * 10 MB 수신 시 성능 제한에 따라서 5초 동안 Throttled
    * 각 Shard당 초당 5번 접근 가능
* Kinesis Client Library (KCL)
  * Golang, Python, Ruby, NodeJs
  * Group 기능을 통해서 다수의 Consumer가 다수 Shard를 분배하여 처리 가능
  * Checkpointing 기능을 통해서 Data 처리 Resume 가능
  * KPL을 통해서 Aggregation된 Data를 De-aggregation 수행
* Kinesis Connector Library
  * Data를 다른 AWS Servce로 전달
  * EC2 Instance에서 구동 필요
  * Deprecated : Kinesis Firehorse로 대체
* Lambda
  * De-aggreagte되어 Lamba 함수에게 전달
  * Batch 사이즈 지정 가능

##### 2.1.3. Kinesis Scailing

* Shard 추가
  * Shard 추가시 기존의 Parent Shard를 대체하는 다수의 Child Shard가 생성
  * Parent Shard에 존재하는 Data를 모두 처리한 이후에, Child Shard의 Data 처리를 권장
    * KCL에서는 내부적으로 구현이 되어 있음
* Shard 통합
  * Chart 통합시 기존 다수의 Parent Shard를 대체하는 하나의 Child Shard 생성

##### 2.1.4. Deplicated Records

* Producer
  * 일시적 Network 장애로 인해서 동일한 Record가 중복되어 Stream에 저장될 수 있음
  * 중복된 저장을 회피할 수 없으며, Consumer에서 중복 처리 필요 
* Consumer
  * Data에 Unique ID를 집어 넣어, 동일한 Data를 수신하여도 중복 처리되지 않도록 App Logic 처리

#### 2.2. Kinesis Data Firehose

### 3. Processing

### 4. 참고

* [https://www.udemy.com/course/aws-data-analytics/](https://www.udemy.com/course/aws-data-analytics/)