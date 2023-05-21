---
title: Spark Architecture
category: Theory, Analysis
date: 2023-05-05T12:00:00Z
lastmod: 2023-05-05T12:00:00Z
comment: true
adsense: true
---

Spark Architecture를 분석한다.

### 1. Spark Architecture

![[그림 1] Spark Architecture]({{site.baseurl}}/images/theory_analysis/Spark_Architecture/Spark_Architecture.PNG){: width="700px"}

[그림 1]은 Spark Architecture를 나타내고 있다. Spark는 Spark Core를 중심으로 Task 처리를 위한 Cluster Manager, Data를 저장하는데 이용하는 Storage, 다양한 기능을 수행하는 Libary로 구성되어 있다.

#### 1.1. Spark Core

Spark Core는 Data를 Task 단위로 분산하여 처리하는 역할을 수행한다. Task는 Spark에서 데이터 분산 처리를 위해 고안한 데이터 집합인 RDD (Resillient Distributed Data)의 일부로 구성된다. Cluster Manager는 Task를 수행하는 역할을 수행하며 Spark만을 이용하여 구성하는 Spark Standalone 부터 Hadoop YARN, Mesos, Kubernetes와 같은 별도의 Cluster Manager 이용도 가능하다. Storage는 Data가 저장되는 공간을 의미하며 HDFS, Gluster FS, Amazon S3등을 지원한다. Spark Core는 Java, Scala, Python, R 언어로 API를 제공한다.

#### 1.2. Library

Library는 Spark Core를 기반으로 다양한 Type의 Workload 처리를 도와주는 역할을 수행한다. Library는 다양한 개발 언어를 통해서 이용할 수 있다. Library는 Spark SQL, MLib, GraphX, Streaming으로 구분지을 수 있다.

* Spark SQL : SQL Query를 통해서 정형화되어 있는 Data를 Spark의 DataFrame으로 가져오고, Data를 조회하는 기능을 제공한다. DataFrame은 Spark SQL에서 정형화된 Data 처리를 위한 자료구조이다. Hive를 통해서 정형화된 Data를 Datafame으로 가져올 수 있으며, JDBC/ODBC도 지원하기 때문에 Database에 접근하여 정형화된 Data를 DataFrame으로 가져올 수 있다.
* MLib : Machine Learning이나 통계에 필요한 알고리즘을 제공한다.
* GraphX : Graphic Data 처리를 위한 알고리즘을 제공한다.
* Streaming : Kafka, Flume과 같은 Streaming Source로부터 Streaming Data를 실시간으로 수신하고 처리하는 기능을 제공한다. 시간별 RDD의 집합으로 구성되는 Dstream를 활용하여 Data를 처리한다.

### 2. Spark Runtime Architecture

![[그림 2] Spark Runtime Architecture]({{site.baseurl}}/images/theory_analysis/Spark_Architecture/Spark_Runtime_Architecture.PNG){: width="550px"}

[그림 2]는 Spark Runtime Architecture를 나타내고 있다. Driver Program의 SparkContext, Cluster Manager, Worker Node의 Executor로 구성되어 있다.

* SparkContext : SparkContext는 작업에 대한 전반적인 정보를 가지고 있는 객체이다. 작업을 Task로 분리하며 분리된 Task는 SparkContext 내부의 Scheulder를 통해서 Executor로 전송하여 실행된다. RDD도 SparkContext를 통해서 생성된다. SparkContext의 객체는 Driver Program에 의해서 초기화 된다. Driver Program는 main() 함수 호출을 통해서 Spark Application을 초기화하는 역할을 수행한다.

* Cluster Manager : SparkContext가 요구하는 Resource (CPU, Memory)를 갖는 Spark Executor를 실행하고 관리하는 역할을 수행한다.

* Executor : Executor는 SparkContext로부터 Task를 받아 수행하고 그 결과를 반환하는 역할을 수행한다. Executor는 SparkContext의 요청에 의해서 Cluster Manager로부터 생성되며, 생성이 완료된 Executor는 SparkContext로 접속하여 SparkContext로부터 실행할 Task를 대기한다. Executor는 하나의 SparkContext에 귀속되며 다수의 SparkContext와 공유되지 않는다. 따라서 각각의 Spark Application은 동일한 Cluster Manager를 이용하더라도 독립되어 실행된다. 따라서 SparkContext가 종료되면 Executor도 같이 종료된다.

### 3. 참조

* [https://www.interviewbit.com/blog/apache-spark-architecture/](https://www.interviewbit.com/blog/apache-spark-architecture/)
* [https://spark.apache.org/docs/latest/cluster-overview.html](https://spark.apache.org/docs/latest/cluster-overview.html)
* [https://datastrophic.io/core-concepts-architecture-and-internals-of-apache-spark/](https://datastrophic.io/core-concepts-architecture-and-internals-of-apache-spark/)
* [https://0x0fff.com/spark-architecture/](https://0x0fff.com/spark-architecture/)
* [https://www.alluxio.io/learn/spark/architecture/](https://www.alluxio.io/learn/spark/architecture/)
* [https://dwgeek.com/apache-spark-architecture-design-and-overview.html/](https://dwgeek.com/apache-spark-architecture-design-and-overview.html/)
