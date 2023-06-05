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

* AWS Service, 3rd Party Application에 Data 적재
* Fully Managed Service : Auto-scaling 지원
* Near Real Time : 최소 60초 지연 발생
* 압축 지원 : GZIP, ZIP, SNAPPY
* Producer
  * SDK KPL, Kinesis Agent, Kinesis Data Streams, Amazon CloudWatch, AWS IoT
  * 하나의 Record 당 최대 1MB
* Consumer
  * Amazon S3, Amazon OpenSearch, Datadog, splunk, New Relic, MongoDB, HTTP Endpoints
  * Batch Write 수행
* Transformation
  * Lambda를 활용하여 Data 변환 가능

### 3. Processing

#### 3.1. Glue

* Serverless ETL 수행
* S3, RDS, Redshift의 Data 처리 가능
* Glue Crawler
  * S3의 Data로 부터 Schema 생성
  * 생성된 Schema는 Glue Data Catalog에 저장
* Glue Data Catalog
  * Schema 정보 저장소
  * 사용자의 입력 또는 Glue Crawler를 통해서 생성 가능
  * EMR Hive의 Metastore를 Glue Data Catalog로 변환 가능
  * EMR Hive에서 Hive의 Metastore로 제공 가능
* Glue Studio : Glue Job을 Visual Interface를 통해서 처리
* Glue Data Quality
  * Data의 품질 평가 및 검사 서비스
  * DQDL (Data Quality Definition Language) 이용하여 규칙 정의
  * Glue Studio에서 이용 가능

#### 3.2. Glue DataBrew

#### 3.3. Lake Formation

* Data Lake (S3)의 Data 접근 권한 관리
* Data Monitoring 기능 제공
* Data 변환 기능 제공
* Glue 기반

#### 3.4. Amazon Security Lake

* Data 보안 중앙화
* Multi Account, On-premise 환경포함 Data 정규화
* Data Life-cycle 관리

#### 3.5. EMR

* EC2 기반 관리형 Hadoop Framework
  * Spark, HBase, Presto, Flink
  * EMR Notebooks 

#### 3.5.1. EMR Cluster

* Master Node
  * Task 상태 추적, Cluster 상태 관리 
* Core Node
  * HDFS 제공, Task 수행
  * Multi Node Cluster의 경우에 반드시 하나 이상의 Core Node가 존재
    * 일부 Hadoop Echo System에서 여전히 HDFS가 이용되기 때문
  * Scale Up&Down이 가능하지만 Data Loss Risk 가능성 존재
* Task Node
  * Task 수행
  * HDFS와 같이 Data를 저장하고 있지 않기 때문에 제거시에도 Data Loss Risk가 존재하지 않음
  * Spot Instance 이용에 적합
* Transient vs Long-Running Cluster
  * Transient Cluster
    * Task 수행 완료후 Cluster 제거
    * Batch Job에 적합
  * Long-running Cluster
    * RI Instance를 이용하여 Stream Task 수행
    * Spot Instnace를 이용하여 Batch Task 수행
* Task 제출
  * Master Node에 직접 접근하여 Task 제출
  * AWS Console을 통해서 Task 제출

#### 3.5.2. EMR with AWS Services

* S3에 Input Data, Output Data 저장 수행
* CloudWatch를 통해서 Performance Monitoring 수행
* IAM을 통해서 인가 관리 수행
* CloudTrail을 통해서 Audit 수행
* AWS Data Pipeline, AWS Step Function을 통해서 Task Scheduling, Workflow 구성

#### 3.5.3. EMR Stroage

* HDFS
  * Core Node의 Cluster로 구성
  * EMR Cluster의 Life-cycle과 동일, EMR Cluster 제거시 HDFS의 데이터도 삭제됨
  * EMRFS보다 빠른 성능을 보이기 때문에 임시 Data를 저장하는 Caching 용도의 사용 권장
* EMRFS
  * S3 기반 Filesystem
  * EMR Cluster와 별개의 Life-cycle를 갖음, EMR Cluster 제거시에도 Data 보존
  * S3에서 Strong Consisteny 보장
* Local Filesystem
  * 임시 Cache 용도로 이용

#### 3.5.4. EMR Managed Scailing

* EMR Automatic Scailing
  * CloudWatch Metric 기반
  * Instance Group만 지원
* EMR Managed Scailing
  * Instance Group, Instance Fleet 지원
  * Spark, Hive, YARN Workload 지원

#### 3.5.5. EMR Serverless

* Spark, Hive, Presto 지원
* Cluster 크기를 자동으로 관리
* 사용자가 크기 지정 가능
* 하나의 Region 내부에서만 Task 처리

#### 3.5.6. EMR Spark

* Kinesis와 Spark Streaming 연동 가능
* Spark를 통해서 처리한 Data를 Redshift에 저장 가능
* Athena Console에서 Spark 실행을 통해서 Data 분석 가능

#### 3.5.7. EMR Hive

* SQL(HiveQL)을 이용하여 HDFS, EMRFS에 저장된 Data 조회 가능 
* MapReduce, Tez를 기반으로 SQL을 분산 처리 수행
* OLAP에 적합
* User Defined Function, Thrift, JDBC/ODBC Driver 지원
* Metastore
  * Data Structure 정보
  * Column 이름, Type 정보
  * 기본적으로 Master Node의 MySQL에 Metastore를 저장
  * AWS 환경에서는 Glue Data Catalog, Amazon RDS에 저장하는 방안을 권고
* AWS Service와 연동
  * S3로 부터 Load Data, Write Data 수행 가능
  * S3로 부터 Script Load 가능

#### 3.5.8. EMR Apache Pig

* Mapper, Reducer 작성을 빠르게 도와주는 Script 환경 제공
* SQL-like Syntax를 이용하여 Map, Reduce 단계 수행
* User Define 함수 제공 (UDF's)
* MapReduce, Tez를 기반으로 분산 처리 수행
* AWS Service와 연동
  * S3 Data Query 수행 가능
  * S3로 부터 JAR, Script Load 가능

#### 3.5.9. EMR Hbase

* Non-relational, Petabyte-scale Database
* HDFS 및 Google BigTable 기반
* Memory에서 연산 처리 수행
* AWS Service와 연동
  * EMRFS을 통한 S3 데이터 저장 지원
  * S3로 Backup 가능

#### 3.5.10. EMR Presto

* 다양한 Big Data Database에 연결 가능
* HDFS, S3, Cassandra, MongoDB, HBase, SQL, Redshift, Teradata
* OLAP Task에 적합

#### 3.5.11. EMR Hue, Splunk, Flume

* Hue
  * EMR Cluster 관리를 위한 Web Interface 제공
  * IAM과 통합 기능 제공
  * HDFS과 S3 사이의 Data 이동 기능 제공
* Splunk
* Flume
  * Log Aggregation Platform
  * HDFS, Hbase 기반
* MXNet
  * Neural Network 구성 Platform 
  * EMR에 포함

#### 3.5.12. EMR Security

* 다양한 인증/인가 방법 이용 가능
  * AM Policy, IAM Role, Kerberos, SSH
* Block Public Access
  * Public Access 접근 차단 

#### 3.6. AWS Data Pipeline

* S3, RDS, DynamoDB, Redshift, EMR을 Data 전송 목적지로 설정 가능
* Task 의존성 관리
* Task 재시도 및 실패 Notify
* Cross-region Pipeline 지원
* Precondition Check 지원
* On-premise Data Source 지원
* 고가용성 제공
* 다양한 Activity 제공
  * EMR, Hive, Copy, SQL, Script

#### 3.7. AWS Step Functions

* Workflow 서비스
* 쉬운 시각화 기능 제공
* Error Handling, Retry 기능 제공
* Audit 기능 제공
* 임의의 기간 동안 Wait 기능 제공

### 4. Analytics

#### 4.1. Kinesis Analytics

* 실시간 Data 처리 Service
* 구성 요소
  * Input Stream : Data가 인입되는 Stream
  * Reference Table : Data 처리시 참조하는 Table, S3의 Data Join 수행 가능
  * Output Stream : 처리된 Data를 내보내는 Stream
  * Error Stream : Data 처리시 발생한 Data를 내보내는 Stream
* with Lambda
  * Lambda를 Data의 목적지로 지정 가능
  * Data를 변경하고 AWS Service에 전달
* with Apache Flink
  * Apache Flink Framework 지원
  * SQL Query 대신 Flink Application 작성
  * Serverless
    * Auto-scailing 수행
    * KPU 단위로 비용 측정
    * 1 KPU = 1 vCPU, 4 Memory
  * 구성 요소
    * Flink Source : MSK, Kinesis Data Streams
    * Flink Datastream API
    * Flink Sink : S3, Kinesis Datastream, Kinesis Datafirehorse
  * RANDOM_CUT_FOREST
    * Abnormal Detection 수행 SQL 함수

### 5. 참고

* [https://www.udemy.com/course/aws-data-analytics/](https://www.udemy.com/course/aws-data-analytics/)