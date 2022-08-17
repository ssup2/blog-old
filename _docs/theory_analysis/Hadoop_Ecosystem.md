---
title: Hadoop Ecosystem
category: Theory, Analysis
date: 2022-08-16T12:00:00Z
lastmod: 2022-08-16T12:00:00Z
comment: true
adsense: true
---

Hadoop Ecosystem을 간략하게 정리한다.

### 1. Hadoop Ecosystem

#### 1.1. Storage

Storage는 Data를 저장하는 저장소 역할을 수행한다.

##### 1.1.1. Hadoop HDFS

Hadoop HDFS는 큰 File 저장을 위해서 다수의 Node로 구성된 Distributed Filesystem이다. 고가용성이 특징이며 Seqence Read/Write에 특화되어 있어 Batch Job 수행에 유리한 특징을 갖는다.

##### 1.1.2. Alluxio

Alluxio는 Data Orchestration Layer의 역할을 수행하며 다양한 Storage를 원하는 Interface로 접근하도록 도와주는 역할을 수행하며, Data Caching을 통해서 성능을 올려주는 역할을 수행한다. 지원하는 Storage는 Hadoop HDFS, Ceph와 같은 Distributed Storage/Filesystem을 지원하며 AWS S3, GC Storage와 같은 Cloud Storage도 지원한다. 지원하는 Interface에는 Hadoop HDFS, Java File API, POSIX Interface, AWS S3, REST API 등이 존재한다.

#### 1.2. Resource Management

##### 1.2.1. Hadoop YARN

##### 1.2.2. Mesos

#### 1.3. Coordinate & Management

##### 1.3.1. Zookeeper

##### 1.3.2. Ambari

#### 1.4. Scheduler

##### 1.4.1. ooZiE

##### 1.4.2. Airflow

#### 1.5. In-memory Processing

##### 1.5.1. Spark

##### 1.5.2. Ignite

#### 1.6. Stream Processing

##### 1.6.1. Kafka

##### 1.6.2. Storm

##### 1.6.3. Flink

#### 1.7. SQL Over Hadoop

##### 1.7.1. Impala

##### 1.7.2. Drill

##### 1.7.3. HIVE

#### 1.8. NoSQL Database

##### 1.8.1. HBase

#### 1.9. Search Engine

##### 1.9.1. Solr

#### 1.10. Data Piping

##### 1.10.1. nifi

##### 1.10.2. Flume

##### 1.10.3. 

#### 1.11. Machine Learning

##### 1.11.1. MADLib

##### 1.11.2. mahout

##### 1.11.3. Spark MLlib

#### 1.12. Scripting

##### 1.12.1. Pig

#### 1.13. Meta Data Management

##### 1.13.1. Atlas

### 2. 참조

* [https://www.cloudduggu.com/hadoop/ecosystem/](https://www.cloudduggu.com/hadoop/ecosystem/)
* HDFS : [https://hadoop.apache.org/docs/r1.2.1/hdfs_design.html](https://hadoop.apache.org/docs/r1.2.1/hdfs_design.html)
* Alluxio : [https://www.alluxio.io/](https://www.alluxio.io/)
* Alluxio : [https://d2.naver.com/helloworld/3863967](https://d2.naver.com/helloworld/3863967)