---
title: Hadoop
category: Theory, Analysis
date: 2018-10-01T12:00:00Z
lastmod: 2018-10-01T12:00:00Z
comment: true
adsense: true
---

Hadoop과 Hadoop을 구성하는 HDFS, YARN, MapReduce를 분석한다.

### 1. Hadoop (High-Available Distribute Object-Oriented Platform)

![]({{site.baseurl}}/images/theory_analysis/Hadoop/Hadoop.PNG){: width="300px"}

Hadoop은 Compute Cluster에 분포된 많은 Data를 동시에 쉽게 처리 할 수 있도록 도와주는 Framework이다. Hadoop V2에서는 위의 그림과 같이 HDFS, YARN, MapReduce 3개의 Layer로 분리되어 있다.

HDFS는 Data Redundancy, Data Reliable을 보장하는 Distributed Filesystem이다. HDFS을 통해서 많은 양의 Data는 Cluster안에서 안전하게 저장된다. YARN은 MapReduce같은 App이 어느 Node에서 수행될지 결정하는 Job Scheduling 동작을 수행하고, Cluster를 구성하는 각 Node의 Computing Resource를 관리하는 Daemon이다. MapReduce는 HDFS, YARN 위에서 많은 Data를 쉽게 처리할 수 있도록 도와주는 App Framework이다.

### 2. HDFS

![]({{site.baseurl}}/images/theory_analysis/Hadoop/HDFS_Architecture.PNG){: width="700px"}

HDFS는 Data Redundancy, Data Reliable을 보장하는 Distributed Filesystem이다. HDFS는 Master/Slave Architecture를 가지고 있으며, Master 역활을 수행하는 **Name Node**와 Slave 역활을 수행하는 **Data Node**로 이루어져 있다. Name Node는 HDFS을 위한 Meta Data를 관리 및 Client에게 File Open, Close, Rename 같은 Namespace 기능을 제공한다. Data Node는 File 저장을 위한 Storage가 붙어 있는 모든 Node를 의미하며, Block 단위로 쪼개진 File들을 Storage에 저장하고 Client에게 제공하는 역활을 수행한다.

Meta Data에는 Namespace 정보, File-Block Mapping 정보등을 저장하고 있다. Name Node는 Meta Data를 Memory에 유지하고 이용한다. 또한 Name Node는 Meta Data 내용 보존을 위해서 Name Node안에 fsimage File 및 EditLog File에 Meta Data 내용을 저장한다. NameNode는 주기적으로 Checkpoint 동작을 통해 Memory의 Meta Data를 fsimage File로 저장한다. 그리고 Checkpoint 동작 수행 후 Meta Data 변경 내역을 EditLog File에 저장한다. 따라서 fsimage File과 EditLog File을 통해서 Meta Data를 복구할 수 있게 된다. fsimage File과 EditLog File은 Name Node를 재시작하거나 Name Node 장애시 Meta Data 복구를 위해 이용된다.

#### 2.1. Replication

Block은 HDFS의 Replication 개수 설정에 따라 여러 Node에 복제되어 저장된다. 만약 Replication을 3으로 설정하였다면, Block은 3개로 복사되어 Data Node에 저장된다.

#### 2.2. Read, Write

Client에서 File을 Read할 경우 Client는 Name Node로 부터 읽을 파일의 Block 정보와 Block이 위치한 Data Node 정보를 얻어온다. 그 후 Client는 Data Node들에게 동시에 직접 접근하여 Block을 읽어온다. Client가 직접 Data Node에 접근하여 Block을 읽어오고, 동시에 여러개의 Data Node에서 Block을 읽기 때문에 높은 Read 성능을 얻을 수 있다.

Client에서 File을 Write할 경우 Client는 Name Node로부터 File의 Block 정보와 Block이 저장될 Data Node의 정보를 얻는다.

#### 2.3. Namespace

### 3. YARN

![]({{site.baseurl}}/images/theory_analysis/Hadoop/YARN_Achitecture.PNG){: width="700px"}

### 4. MapReduce

### 5. 참조
* Hadoop - [https://noobergeek.wordpress.com/2012/11/12/why-is-hadoop-so-fast/](https://noobergeek.wordpress.com/2012/11/12/why-is-hadoop-so-fast/)
* HDFS - [https://hadoop.apache.org/docs/r1.2.1/hdfs_design.html](https://hadoop.apache.org/docs/r1.2.1/hdfs_design.html)
* HDFS - [http://www.waytoeasylearn.com/2018/01/hdfs-read-write-architecture.html](http://www.waytoeasylearn.com/2018/01/hdfs-read-write-architecture.html)
* YARN - [https://www.popit.kr/what-is-hadoop-yarn/](https://www.popit.kr/what-is-hadoop-yarn/)
* YARN - [http://blog.cloudera.com/blog/2015/09/untangling-apache-hadoop-yarn-part-1/](http://blog.cloudera.com/blog/2015/09/untangling-apache-hadoop-yarn-part-1/)
* HDFS + YARN - [https://stackoverflow.com/questions/36215672/spark-yarn-architecture](https://stackoverflow.com/questions/36215672/spark-yarn-architecture)
