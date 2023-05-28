---
title: 자격증 AWS Certified Data Analytics
category: Record
date: 2023-05-29T12:00:00Z
lastmod: 2023-05-29T12:00:00Z
comment: true
adsense: true
---

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

* 다수의 Shard로 구성되어 있으며, Stream 생성시 사용자 지정 필요
* Producer
  * Record를 생성하여 Stream에 전달
  * Ex) SDK KPL, Kinesis Agent
* Record
  * Partition Key : Record가 어느 Shard로 전달될지 결정
  * Data Blob : Data 저장소
* Consumer
  * 

### 1.2. Kinesis Data Firehose

### 2. 참고

* [https://www.udemy.com/course/aws-data-analytics/](https://www.udemy.com/course/aws-data-analytics/)