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

![]({{site.baseurl}}/images/theory_analysis/Hadoop/Hadoop.PNG){: width="400px"}

Hadoop은 Compute Cluster에 분포된 대용량 Data를 동시에 쉽게 처리 할 수 있도록 도와주는 Framework이다. Hadoop V2에서는 위의 그림과 같이 HDFS, YARN, MapReduce 3개의 Layer로 분리되어 있다.

HDFS는 Data Redundancy, Data Reliable을 보장하는 Distributed Filesystem이다. HDFS을 통해서 대용량 Data는 Cluster안에서 안전하게 저장된다. YARN은 MapReduce같은 App이 어느 Node에서 수행될지 결정하는 Job Scheduling 동작을 수행하고, Cluster를 구성하는 각 Node의 Computing Resource를 관리하는 Daemon이다. MapReduce는 HDFS, YARN 위에서 많은 Data를 쉽게 처리할 수 있도록 도와주는 App Framework이다.

### 2. HDFS

![]({{site.baseurl}}/images/theory_analysis/Hadoop/HDFS_Architecture.PNG){: width="700px"}

HDFS는 Data Redundancy, Data Reliable을 보장하는 Distributed Filesystem이다. HDFS는 Master/Slave Architecture를 가지고 있으며, Master 역활을 수행하는 **Name Node**와 Slave 역활을 수행하는 **Data Node**로 이루어져 있다. Name Node는 HDFS을 위한 Meta Data를 관리 및 Client에게 File Open, Close, Rename 같은 Namespace 기능을 제공한다. Data Node는 File 저장을 위한 Storage가 붙어 있는 모든 Node를 의미하며, Block 단위로 쪼개진 File들을 Storage에 저장하고 Client에게 제공하는 역활을 수행한다.

Meta Data에는 Namespace 정보, File-Block Mapping 정보등을 저장하고 있다. Name Node는 Meta Data를 Memory에 유지하고 이용한다. 또한 Name Node는 Meta Data 내용 보존을 위해서 Name Node안에 fsimage File 및 EditLog File에 Meta Data 내용을 저장한다. NameNode는 주기적으로 Checkpoint 동작을 통해 Memory의 Meta Data를 fsimage File로 저장한다. 그리고 Checkpoint 동작 수행 후 Meta Data 변경 내역을 EditLog File에 저장한다. 따라서 fsimage File과 EditLog File을 통해서 Meta Data를 복구할 수 있게 된다. fsimage File과 EditLog File은 Name Node를 재시작하거나 Name Node 장애시 Meta Data 복구를 위해 이용된다.

#### 2.1. Read, Write

위의 그림에서 빨간선은 HDFS의 Read 과정을 나타내고 있다.

* 1,2 - Client는 Name Node로부터 읽을 파일의 Block 정보를 얻어온다.
* 3,4 - Client는 Block 정보를 바탕으로 및 Block이 위치한 Data Node들에게 직접 Block Read 요청을 전송하고, Block Data를 전달 받는다. Read할 Block이 다수의 Data Node에게 위치하면 동시에 Block Read를 수행한다. 따라서 HDFS은 높은 Read 성능을 얻을 수 있다.

위의 그림에서 파란선은 HDFS의 Write 과정을 나타내고 있다.

* 1,2 - Client는 Name Node로부터 Write될 Block 정보를 얻는다. 이때 Replication 설정에 따라서 Block 복제본이 저장될 Data Node 정보도 Client에게 전달된다.
* 3 - Client는 전달 받은 Data Node중 임의의 Data Node에 직접 Block Data를 전송한다. 또한 해당 Block이 복제되어 저장될 다른 Data Node 정보도 Data Node에게 전달한다.
* 4,5 - Data Node는 전달 받은 Block을 Disk에 Write한다. Write가 완료되면 Write한 Block이 복제되어 저장될 다른 Data Node에게 해당 Block을 다시 전송한다. Block 전송, Block Write 과정은 HDFS의 Replication 설정 만큼 반복된다.
* 6,7,8 - 마지막 Data Node에 Block이 Write되면 Block이 복제된 역순으로 ACK Message가 전달되고, 마지막으로 Client가 ACK Message를 받는다. 이처럼 Data Node사이의 Block 복제 기법을 **Replication Pipelining**이라고 한다. Replication Pipelining 때문에 HDFS은 낮은 Write 성능을 갖는다.

HDFS은 한번 Write된 Block의 수정을 지원하지 않기 때문에, HDFS에 한번 Write된 File은 변경 할 수 없다. 오직 File 끝에 Data(Block)를 추가하는 동작만 지원한다. File 내용을 수정하기 위해서는 HDFS에서 File을 지웠다가 변경된 File 전체를 복사해와야 한다. 하지만 이와 같은 제한은 HDFS 이용에 크게 문제 되지 않는다. HDFS은 위의 설명처럼 높은 Read 성능, 낮은 Write 성능을 갖기 때문에 HDFS에는 대부분 Read-Only Data를 저장하기 때문이다.

#### 2.2 Replication

File을 구성하는 Block은 HDFS의 Replication 설정 또는 File의 Replication 설정에 따라 여러 Node에 복제되어 저장된다. 만약 Replication을 3으로 설정하였다면, Block은 3개로 복사되어 Data Node에 저장된다. 위의 그림은 Replication을 3으로 설정 할 경우의 Block을 나타내고 있다. 같은색의 Block은 같은 Data를 가지고 있다는 의미이다.

Name Node는 Block Write시 Replication을 위한 Data Node를 선택할때 **Rack Awareness**, 즉 Rack Topology를 고려하여 Data Node를 선택한다. 위의 그림처럼 Replication 설정이 3일 경우 Name Node가 주황색 Block을 위한 Data Node로 Data Node B를 선택하였다면 나머지 2개의 Data Node는 Data Node B가 없는 Rack B의 Data Node중에서 2개를 선택한다.

같은 Rack안의 Data Node만을 선택하지 않기 때문에, Rack 하나에 장애가 발생에도 Client는 모든 File에 접근 할 수 있다. 2개의 Data Node 선택시 같은 Rack의 Data Node를 선택하는 이유는 Network Hope을 줄이기 위해서다. Block Write시 Replication Pipelining 때문에 Data Node사이의 Network Hope이 커질수록 Write 시간이 오래 걸리기 때문이다.

#### 2.3. Namespace

HDFS은 현재 대부분의 Filesystem에서 이용하는 **Tree** 구조를 이용하고 있다. User는 Directory를 만들고 Directory안에 File을 Write, Remove 할 수 있다.

### 3. YARN

![]({{site.baseurl}}/images/theory_analysis/Hadoop/YARN_Achitecture.PNG){: width="600px"}

### 4. MapReduce

### 5. 참조
* Hadoop - [https://noobergeek.wordpress.com/2012/11/12/why-is-hadoop-so-fast/](https://noobergeek.wordpress.com/2012/11/12/why-is-hadoop-so-fast/)
* HDFS - [https://hadoop.apache.org/docs/r1.2.1/hdfs_design.html](https://hadoop.apache.org/docs/r1.2.1/hdfs_design.html)
* HDFS - [http://www.waytoeasylearn.com/2018/01/hdfs-read-write-architecture.html](http://www.waytoeasylearn.com/2018/01/hdfs-read-write-architecture.html)
* HDFS - [https://www.quora.com/How-is-replication-done-in-Hadoop](https://www.quora.com/How-is-replication-done-in-Hadoop)
* YARN - [https://www.popit.kr/what-is-hadoop-yarn/](https://www.popit.kr/what-is-hadoop-yarn/)
* YARN - [http://blog.cloudera.com/blog/2015/09/untangling-apache-hadoop-yarn-part-1/](http://blog.cloudera.com/blog/2015/09/untangling-apache-hadoop-yarn-part-1/)
* HDFS + YARN - [https://stackoverflow.com/questions/36215672/spark-yarn-architecture](https://stackoverflow.com/questions/36215672/spark-yarn-architecture)
