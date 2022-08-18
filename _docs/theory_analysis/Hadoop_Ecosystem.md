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

Resource Management는 Job/Task 수행을 위해서 다수의 Node로 구성된 Cluster의 CPU, Memory Resource 관리 및 Job/Task Scheduling 및 관리 역할을 수행한다.

##### 1.2.1. Hadoop YARN

Hadoop YARN은 Hadoop Ecosystem에서 오랜 시간동안 이용되고 있는 Resource Manager이다.

##### 1.2.2. Mesos

Mesos는 Hadoop Ecosystem 환경뿐만 아니라 다양한 Application, Platform에서 이용 가능한 Resource Manager이다. Hadoop Ecosystem에서도 Mesos를 적용하여 이용가능하다. Hadoop YARN에 대비하여 좀더 다양한 Job/Task Scheduling이 가능하다는 특징을 갖는다.

#### 1.3. Coordinate

Coordinate는 Hadoop Ecosystem의 Component들이 이용하는 고가용성의 Configuration 보관소 및 구성 형상을 관리하는 역할을 수행합니다.

##### 1.3.1. ZooKeeper

ZooKeeper는 오랜 시간동안 이용되고 있는 Distributed Coodinator이다. Tree 형태로 Data를 관리하며 Paxos Algorithm을 통해서 Data의 정합성을 관리한다. Hadoop Ecosystem에 존재하는 대부분의 Component들이 Zookeeper를 이용한다.

#### 1.4. Management & Monitoring

Management & Monitoring은 Hadoop Ecosystem의 Component 관리 및 Monitoring 역할을 수행합니다.

##### 1.4.1. Ambari

Ambari는 Hadoopm Ecosystem Component들의 설정 및 Monitoring을 Web에서 간편하게 수행할 수 있도록 도와줍니다.

#### 1.4. Scheduler

##### 1.4.1. ooZiE

##### 1.4.2. Airflow

#### 1.5. In-memory Processing

##### 1.5.1. Spark

##### 1.5.2. Ignite

#### 1.6. Stream Processing

##### 1.6.1. Kafka

##### 1.6.2. Storm

##### 1.6.3. Spark Stream

##### 1.6.4. Flink

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
* Hadoop Yarn vs Mesos : [https://www.linkedin.com/pulse/apache-mesos-vs-hadoop-yarn-whiteboard-walkthrough-jim-scott/](https://www.linkedin.com/pulse/apache-mesos-vs-hadoop-yarn-whiteboard-walkthrough-jim-scott/)
* Ambari : [https://techvidvan.com/tutorials/apache-ambari-tutorial/](https://techvidvan.com/tutorials/apache-ambari-tutorial/)
* Storm vs Spark Stream : [https://blog.udanax.org/2018/04/storm-vs-spark-streaming.html](https://blog.udanax.org/2018/04/storm-vs-spark-streaming.html)