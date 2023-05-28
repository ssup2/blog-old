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

### 1. Collection

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

### 1.1. Kinesis Data Streams

* 다수의 Shard로 구성
* Retention : 1 ~ 365 Days
* 저장된 Data는 지울수 없음
* Producer
  * Record를 생성하여 Stream에 전달
  * 성능 : Shard당 1 MB/sec, 1000 msg/sec 제한
  * Ex) Application, SDK KPL, Kinesis Agent
* Record
  * Partition Key : Record가 어느 Shard로 전달될지 결정
  * Data Blob : Data 저장소
* Consumer
  * 성능
    * Default : 2 MB/sec all Consumer
    * Enhanced : 2 MB/sec per Consumear
  * Ex) Application, Lambda, Kinesis Data Firehose, Kinesis Data Analytics
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

### 1.2. Kinesis Data Firehose

### 2. 참고

* [https://www.udemy.com/course/aws-data-analytics/](https://www.udemy.com/course/aws-data-analytics/)