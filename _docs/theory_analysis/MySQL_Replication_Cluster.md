---
title: MySQL Replication, Cluster
category: Theory, Analysis
date: 2018-12-14T12:00:00Z
lastmod: 2018-12-14T12:00:00Z
comment: true
adsense: true
---

MySQL의 HA(High Availabilty)를 위한 Replicaiton, Cluster 기법을 분석한다.

### 1. Master-Slave Replication

![]({{site.baseurl}}/images/theory_analysis/MySQL_Replication_Cluster/Master_Slave_Replication.PNG){: width="600px"}

Master-Slave Replication은 하나의 Master DB와 다수의 Slave DB들을 통해 Replication을 수행하는 방식이다. 위의 그림은 Master-Slave Replication을 나타내고 있다. Client는 LB의 VIP (Virtual IP)를 통해서 DB에 접근한다. Master는 Read/Write Mode로 동작하고 Slave들은 Read Mode로 동작한다. 따라서 LB는 Client로부터 오는 DB 변경 Query는 Master에게만 전달하도록 설정되어 있어야 한다. 또한 LB는 Client로부터 오는 DB 조회 Query를 적절한 Master/Slave DB로 Load Balancing하여 Read 성능을 높일 수 있다.

Master는 Client로부터 받은 DB 변경요청에 따라 DB를 변경하고, 변경 내용을 Slave DB에게 전달하여 Replication을 수행한다. Replication 방식에는 Async, Semi-sync 2가지 방식을 지원한다. 두 방식 모두 완전히 동기화가 되는 Sync 방식은 아니기 때문에 Slave DB는 짧은 순간 Master DB와 동기화되지 않는 상태일 수 있다. Slave DB의 개수가 늘어날수록 동시에 Read를 수행할 수 있는 DB도 증가하기 때문에 Read 성능을 높일 수 있다. 하지만 Slave DB의 개수가 늘어나도 DB 변경 Query는 Master DB에서부터 전파되는 방식이기 때문에 Write 성능은 개선되지 않는다.

Master DB에 장애가 발생한다면 DB 관리자는 Slave DB를 Master DB로 승격시키고, LB 설정을 변경하여 DB 변경 Query가 새로운 Master DB로 전달되도록 설정해야한다. 새로운 Master DB 설정을 완료하였어도, Master DB와 Slave DB가 완전한 동기방식의 Replication을 이용하지 않기 때문에 Data 손실이 발생 할 수 있다. 만약 Slave DB에 장애가 발생할 경우에는 어떠한 Replication 방식을 적용했는지에 따라서 대응이 달라진다.
 
#### 1.1. Async Replication

![]({{site.baseurl}}/images/theory_analysis/MySQL_Replication_Cluster/Master_Slave_Async_Replication.PNG){: width="550px"}

Replication 동작 과정을 이해하기 위해서는 **Binary Log**, **Relay Log**를 이해해야한다. Binary Log는 DB 변경 내역을 기록하는 Log이다. Relay Log는 Slave DB에 위치하며, Master DB는 Master DB의 변경된 Binary Log를 Slave의 Relay Log에 기록한다. Slave DB는 Relay Log 내용을 바탕으로 비동기적으로 DB를 변경한다.

위의 그림은 Async Replication을 나타내고 있다. Async Replicaiton은 Master DB가 Slave DB에게 DB 변경 내용을 전달만하고 Slave DB의 상태를 확인하지 않는다. 따라서 Master DB가 Async Replication 동작을 수행해도 DB 성능저하가 거의 발생하지 않는다. 또한 Slave DB에 장애가 발생하여도 Transaction은 중단되지 않고 진행된다.

#### 1.2. Semi-sync Replication

![]({{site.baseurl}}/images/theory_analysis/MySQL_Replication_Cluster/Master_Slave_Semi-sync_Replication.PNG)

위의 그림은 Semi-sync Replication을 나타내고 있다. Semi-sync Replication은 Master DB가 Slave DB로부터 Relay Log 기록이 완료되었다는 ACK를 받고 Transaction을 진행하는 방식이다. 따라서 Async Replication 방식에 비해서 좀더 많은 DB 성능저하가 발생하지만, Master-Slave DB 사이의 동기화를 좀더 보장해준다. Semi-sync Replicaiton 방식에는 Master DB가 Slave DB에게 DB 변경 내용을 언제 전달하냐에 따라서 AFTER_COMMIT, AFTER_SYNC 2가지 방식으로 구분된다.

만약 Master DB가 Slave DB로부터 Relay Log를 받지 못하면 Transaction은 중단된다. 이러한 Transcation 중단은 다수의 Slave DB를 두어 최소화 할 수 있다. Master DB는 모든 Slave DB에게 DB 변경 내용을 전달하지만 하나의 Slave DB로부터 Relay Log ACK를 받으면 Transaction을 진행하기 때문이다.

### 2. Group Replication

![]({{site.baseurl}}/images/theory_analysis/MySQL_Replication_Cluster/Group_Replication.PNG){: width="650px"}

### 3. 참조

* [http://skillachie.com/2014/07/25/mysql-high-availability-architectures/](http://skillachie.com/2014/07/25/mysql-high-availability-architectures/)
* [https://www.percona.com/blog/2017/02/07/overview-of-different-mysql-replication-solutions/](https://www.percona.com/blog/2017/02/07/overview-of-different-mysql-replication-solutions/)
* Master-Slave Replication - [https://blurblah.net/1505](https://blurblah.net/1505)
* Semi-sync - [http://www.mysqlkorea.com/gnuboard4/bbs/board.php?bo_table=develop_03&wr_id=73](http://www.mysqlkorea.com/gnuboard4/bbs/board.php?bo_table=develop_03&wr_id=73)
* Semi-sync - [http://gywn.net/tag/semi-sync-replication/](http://gywn.net/tag/semi-sync-replication/)
* Group Replication - [https://www.percona.com/live/17/sessions/everything-you-need-know-about-mysql-group-replication](https://www.percona.com/live/17/sessions/everything-you-need-know-about-mysql-group-replication)
* Group Replicaiton - [https://scriptingmysql.wordpress.com/category/mysql-replication/](https://scriptingmysql.wordpress.com/category/mysql-replication/)
* Group Replication, Galera Cluster -  [https://www.percona.com/blog/2017/02/24/battle-for-synchronous-replication-in-mysql-galera-vs-group-replication/](https://www.percona.com/blog/2017/02/24/battle-for-synchronous-replication-in-mysql-galera-vs-group-replication/)
* Group Replicaiton, Galera Cluster - [https://severalnines.com/resources/tutorials/mysql-load-balancing-haproxy-tutorial](https://severalnines.com/resources/tutorials/mysql-load-balancing-haproxy-tutorial)
* Replication, Master - [https://stackoverflow.com/questions/38036955/when-to-prefer-master-slave-and-when-to-cluster](https://stackoverflow.com/questions/38036955/when-to-prefer-master-slave-and-when-to-cluster)

