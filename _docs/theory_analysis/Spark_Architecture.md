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

[그림 1]은 Spark Architecture를 나타내고 있다. Spark는 Spark Core를 중심으로 Task 처리를 위한 Resource/Cluster Manager, Data를 저장하는데 이용하는 Storage, 다양한 기능을 수행하는 Libary로 구성되어 있다.

#### 1.1. Spark Core

Spark Core는 Data를 Task 단위로 분산하여 처리하는 역할을 수행한다. Task는 Spark의 RDD (Resillient Distributed Data)로 구성된다. Task 수행을 위한 Resource(CPU, Memory)는 Spark Standalone을 이용하여 구축이 가능하며 Hadoop YARN, Mesos, Kubernetes와 같이 별도의 Resource Manager 이용도 가능하다. Storage는 Data가 저장되는 공간을 의미하며 HDFS, Gluster FS, Amazon S3등을 지원한다. Spark Core는 Java, Scala, Python, R 언어로 API를 제공한다.

#### 1.2. Library

Library는 Spark Core를 기반으로 다양한 Type의 Workload 처리를 도와주는 역할을 수행한다. Library는 다양한 개발 언어를 통해서 이용할 수 있다. Library는 Spark SQL, MLib, GraphX, Streaming으로 구분지을 수 있다.

* Spark SQL : SQL Query를 통해서 정형화되어 있는 Data를 Spark의 DataFrame으로 가져오고 
* MLib : 
* GraphX : 
* Streaming : 

### 2. Spark Runtime Architecture

![[그림 2] Spark Runtime Architecture]({{site.baseurl}}/images/theory_analysis/Spark_Architecture/Spark_Runtime_Architecture.PNG){: width="550px"}

### 3. 참조

* [https://spark.apache.org/docs/latest/cluster-overview.html](https://spark.apache.org/docs/latest/cluster-overview.html)
* [https://datastrophic.io/core-concepts-architecture-and-internals-of-apache-spark/](https://datastrophic.io/core-concepts-architecture-and-internals-of-apache-spark/)
* [https://0x0fff.com/spark-architecture/](https://0x0fff.com/spark-architecture/)
* [https://www.alluxio.io/learn/spark/architecture/](https://www.alluxio.io/learn/spark/architecture/)
* [https://dwgeek.com/apache-spark-architecture-design-and-overview.html/](https://dwgeek.com/apache-spark-architecture-design-and-overview.html/)