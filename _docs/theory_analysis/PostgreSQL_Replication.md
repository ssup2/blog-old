---
title: PostgreSQL Replication
category: Theory, Analysis
date: 2019-03-10T12:00:00Z
lastmod: 2019-03-10T12:00:00Z
comment: true
adsense: true
---

PostgreSQL의 HA(High Availabilty)를 위한 Replicaiton 기법을 분석한다.

### 1. PostgreSQL Replication

![]({{site.baseurl}}/images/theory_analysis/PostgreSQL_Replication/Master_Slave.PNG){: width="600px"}

PostgreSQL의 Replication은 기본적으로 Master-Slave Replication에 기반을 두고 있다. Master-Slave Replication은 하나의 Master DB와 다수의 Slave DB들을 통해 Replication을 수행하는 방식이다. 위의 그림은 Master-Slave Replication을 나타내고 있다. Master는 Client로부터 받은 DB 변경 Query에 따라 DB를 변경하고, 변경 내용을 Slave DB에게 전달하여 Replication을 수행한다. 따라서 Master는 Read/Write Mode로 동작하고 Slave들은 Read Mode로 동작한다. Client는 Write 요청을 반드시 Master에게 전달해야 하고, Read 요청은 적절한 Master 또는 적절한 Slave에 전달하면 된다. 일반적으로 Slave앞에는 LB(Load Balancer)를 두어 Slave로 오는 Read 요청을 분산시키고, Read 성능을 높인다.

#### 1.1. Replication

Replication 방식에는 WAL (Write Ahead Log) 방식과 Streaming 방식 2가지를 지원한다.

##### 1.1.1. WAL (Write Ahead Log) Replication

![]({{site.baseurl}}/images/theory_analysis/PostgreSQL_Replication/WAL_Replication.PNG){: width="500px"}

WAL (Write Ahead Log) Replication을 이해하기 위해서는 WAL을 이해해야 한다. WAL은 의미그대로 Write 동작으로 인한 DB 변경 내용을 실제 Disk에 반영하기 전에 기록하는 Log이다. MySQL의 DB Engine인 InnoDB가 기록하는 Redo Log과 동일하다고 보면 된다. PostgreSQL은 Disk 접근을 최소화 하기 위해서 DB 변경 내용을 Buffer Memory와 WAL에 기록했다가 Checkpoint라는 동작을 통해서 한번에 Disk에 반영한다. 이때 Disk에 반영된 WAL은 삭제되기 때문에 WAL은 계속 Disk에 유지 되지 않고 일정한 규칙에 의해서 주기적으로 삭제되는 특징을 갖는다. WAL은 Replication 뿐만 아니라 Query 재실행, Query Rollback등의 다양한 Query 관련 동작에서도 이용된다.

WAL Replication은 WAL을 Slave에 전달하여 Replication을 수행하는 기법이다. 위의 그림은 WAL Replication을 나타내고 있다. WAL은 주기적으로 삭제되는 특징을 갖고있기 때문에 WAL Replication이 설정된 PostgreSQL은 WAL을 주기적으로 Archive에 복사한다. Slave DB는 Master DB의 Archive에 있는 WAL을 복사하여 가져온뒤 WAL에 있는 DB 변경 내용을 자신의 WAL에 반영하여 Replication을 진행한다.

WAL Replication은 WAL을 저장하는 파일 단위인 **Segment** 단위로 수행되기 때문에, Master DB의 변경 내용이 쪼개져 Slave DB에 자주 전달되는 방식이 아니라 많은 변경 내용이 한꺼번에 전달되는 방식이다. 따라서 갑작스러운 Master DB의 죽음은 많은 Data의 손실로 이어질 수 있고, Slave DB에 Master DB 변경 내용이 적용되는데 시간이 걸리는 기법이다. 이러한 단점을 해결하기 위해서 나온 기법이 Streaming Replication이다.

##### 1.1.2. Streaming Replication

![]({{site.baseurl}}/images/theory_analysis/PostgreSQL_Replication/Streaming_Replication.PNG){: width="400px"}

Streaming Replication은 WAL에 기록된 변경 내용을 바로 Slave DB에게 전달하는 기법이다. 위의 그림은 Streaming Replication을 나타내고 있다. Master DB는 WAL Sender를 통해 WAL에 기록된 Master DB 변경 내용을 Slave DB의 WAL Receiver에게 전달한다. Slave DB는 WAL Receiver을 통해 받은 Master DB의 변경 내용을 자신의 WAL에 기록하여 Replication을 수행한다. Streaming Replication은 Master DB의 변경 내용을 변경 내용 단위인 **Record** 단위로 바로 Slave DB에게 전달하기 때문에 갑작스러운 Master DB의 죽음으로 인한 Data 손실을 최소화 할 수 있다.

Streaming Replication은 Archive에 있는 WAL을 이용하지 않고 원본 WAL을 이용하여 수행된다. 따라서 Checkpoint으로 인해서 삭제된 WAL안의 Master DB 변경 내용은 Streaming Replication을 통해서 Slave DB에게 전달되지 못한다. 다시 말해 시간이 오래 경과된 Master DB 변경 내용은 Streaming Replication을 통해서 Slave DB에게 전달되지 못한다는 의미이다. 이러한 문제를 해결하기 위해서 PostgreSQL은 Streaming Replication 이용시 WAL Replication을 보조로 이용할 수 있다. WAL Replication을 보조로 이용하는 Slave DB는 먼져 Master DB의 Archive에 있는 WAL을 복사하여 가져와 Replication을 수행한다. 그 뒤 Streaming으로 넘어오는 WAL Record를 통해서 Replication을 마무리한다.

Streaming Replication은 Sync, Async 2가지 방식 모두 지원하고 있으며, 기본 설정은 Async 방식을 이용하도록 설정되어 있다.

#### 1.2. Pgpool-II

![]({{site.baseurl}}/images/theory_analysis/PostgreSQL_Replication/Pgpool.PNG){: width="600px"}

### 2. 참조

* Replication - [https://severalnines.com/blog/postgresql-streaming-replication-deep-dive](https://severalnines.com/blog/postgresql-streaming-replication-deep-dive)
* Replication - [https://blog.2ndquadrant.com/basics-of-tuning-checkpoints/](https://blog.2ndquadrant.com/basics-of-tuning-checkpoints/)
* Pgpool - [https://dev.mysql.com/doc/mysql-router/8.0/en/mysql-router-innodb-cluster.html](https://dev.mysql.com/doc/mysql-router/8.0/en/mysql-router-innodb-cluster.html)