---
title: MySQL Replication
category: Theory, Analysis
date: 2018-12-14T12:00:00Z
lastmod: 2018-12-14T12:00:00Z
comment: true
adsense: true
---

MySQL의 HA(High Availabilty)를 위한 Replicaiton 기법들을 분석한다.

### 1. Master-Slave Replication

![]({{site.baseurl}}/images/theory_analysis/MySQL_Replication/Master_Slave_Replication.PNG){: width="600px"}

Master-Slave Replication은 하나의 Master DB와 다수의 Slave DB들을 통해 Replication을 수행하는 방식이다. 위의 그림은 Master-Slave Replication을 나타내고 있다. Client는 LB의 VIP (Virtual IP)를 통해서 DB에 접근한다. Master는 Read/Write Mode로 동작하고 Slave들은 Read Mode로 동작한다. 따라서 LB는 Client로부터 오는 DB 변경 Query는 Master에게만 전달하도록 설정되어 있어야 한다. 또한 LB는 Client로부터 오는 DB 조회 Query를 적절한 Master/Slave DB로 Load Balancing하여 Read 성능을 높일 수 있다.

Master는 Client로부터 받은 DB 변경 Query에 따라 DB를 변경하고, 변경 내용을 Slave DB에게 전달하여 Replication을 수행한다. Replication 방식에는 Async, Semi-sync 2가지 방식을 지원한다. 두 방식 모두 완전히 동기화가 되는 Sync 방식은 아니기 때문에 Slave DB는 짧은 순간 Master DB와 동기화되지 않는 상태일 수 있다. Slave DB의 개수가 늘어날수록 동시에 Read를 수행할 수 있는 DB도 증가하기 때문에 Read 성능을 높일 수 있다. 하지만 Slave DB의 개수가 늘어나도 DB 변경 Query는 Master DB에서부터 전파되는 방식이기 때문에 Write 성능은 개선되지 않는다.

Master DB에 장애가 발생한다면 DB 관리자는 Slave DB를 Master DB로 승격시키고, LB 설정을 변경하여 DB 변경 Query가 새로운 Master DB로 전달되도록 **수동**으로 설정하여 Failover를 수행해야한다. 새로운 Master DB 설정을 완료하였어도, Master DB와 Slave DB가 완전한 동기방식의 Replication을 이용하지 않기 때문에 Data 손실이 발생 할 수 있다. 만약 Slave DB에 장애가 발생할 경우에는 어떠한 Replication 방식을 적용했는지에 따라서 대응이 달라진다.
 
#### 1.1. Async Replication

![]({{site.baseurl}}/images/theory_analysis/MySQL_Replication/Master_Slave_Async_Replication.PNG){: width="550px"}

Replication 동작 과정을 이해하기 위해서는 **Binary Log**, **Relay Log**를 이해해야한다. Binary Log는 모든 MySQL DB에서 이용되며 DB 변경 내용을 기록하는데 이용하는 Log이다. Relay Log는 Slave DB에만 위치하며, Master DB의 Binary Log 내용을 기록하는데 이용하는 Log이다.

위의 그림은 Async Replication을 나타내고 있다. Master DB는 Slave DB에 관계없이 DB를 변경하고 DB 변경 내용을 Binary Log에 기록한다. Slave DB는 Master DB에 연결하여 주기적으로 변경된 Master의 Binary Log를 얻어 자신의 Relay Log에 기록하고, Relay Log 내용을 바탕으로 자신의 DB 변경 및 Binary Log를 갱신한다.

Master DB는 Transaction 수행 중 Slave DB로 인한 추가적인 동작을 수행하지 않는다. 따라서 Master DB는 Slave DB로 인한 성능 저하가 거의 발생하지 않는다. Async 방식이기 때문에 Master DB에서 Transaction이 완료된 DB 변경 내용이더라도 Slave에는 바로 반영되지 않는다. 이는 Master DB의 갑작스러운 장애가 Data 손실로 이어질 수 있다는 의미이다. Slave DB의 장애는 Master DB의 Transaction에 아무런 영향을 주지 않는다. 장애가 발생했던 Slave DB는 복구 된 후 자신의 Relay Log, Binary Log 및 Master DB의 Binary Log를 바탕으로 중단되었던 Replication을 이어서 진행한다.

#### 1.2. Semi-sync Replication

![]({{site.baseurl}}/images/theory_analysis/MySQL_Replication/Master_Slave_Semi-sync_Replication.PNG)

위의 그림은 Semi-sync Replication을 나타내고 있다. Semi-sync Replication은 Master DB가 Slave DB로부터 Relay Log 기록이 완료되었다는 ACK를 받고 Transaction을 진행하는 방식이다. 따라서 Async Replication 방식에 비해서 좀더 많은 DB 성능저하가 발생하지만, Master-Slave DB 사이의 동기화를 좀더 보장해준다. Semi-sync Replicaiton 방식에는 Master DB가 Slave DB에게 DB 변경 내용을 언제 전달하냐에 따라서 AFTER_COMMIT, AFTER_SYNC 2가지 방식으로 구분된다.

만약 Master DB가 Slave DB로부터 Relay Log를 받지 못하면 Transaction은 중단된다. 이러한 Transcation 중단은 다수의 Slave DB를 두어 최소화 할 수 있다. Master DB는 모든 Slave DB에게 DB 변경 내용을 전달하지만 하나의 Slave DB로부터 Relay Log ACK를 받으면 Transaction을 진행하기 때문이다.

### 2. Group Replication

![]({{site.baseurl}}/images/theory_analysis/MySQL_Replication/Group_Replication_Single-primary.PNG){: width="600px"}

Group Replication은 다수의 DB Instance를 Group으로 구성하여 Replication을 수행하는 방식이다. Client는 MySQL Router를 통해서 DB로 접근한다. MySQL Router는 Proxy, LB등의 역활을 수행한다. Group Replication은 **Single-primary**, **Multi-primary** 2가지 Mode를 지원한다.

위의 그림은 Single-primary Mode를 나타내고 있다. Master-slave Replication과 유사하게 동작하는 Mode이다. 하나의 DB만 Primary DB로 동작하며 MySQL Router로부터 유일하게 Read/Write 요청을 받아 처리하는 DB이다. 나머지 DB는 Secondary DB로 동작하며 MySQL Router로부터 Read 요청만을 받아 처리한다. Primary-Secondary DB 사이의 Replication은 Master-Slave Replication와 유사하게 Async, Semi-Sync 2가지 방식을 지원한다. Master-Slave Replication과 다른 점은 DB 장애가 발생해도 Primary/Secondary DB 및 MySQL Router를 **자동**으로 Failover하여 DB 관리자의 개입없이 계속 DB 사용이 가능하다는 점이다.

![]({{site.baseurl}}/images/theory_analysis/MySQL_Replication/Group_Replication_Multi-primary.PNG){: width="600px"}

위의 그림은 Multi-primary Mode를 나타내고 있다. Multi-primary Mode는 모든 DB가 Primary Node로 동작한다. 따라서 App의 Read/Write 요청은 모든 DB에게 전달이 가능하다. MySQL Router는 DB의 부하에 따라서 적절한 DB에게 요청을 전달한다. 만약 서로다른 Primary DB에서 같은 Row을 동시에 변경하여 Commit 충돌이 발생하였다면, **먼져 Commit**한 Primary DB는 변경 내용이 반영되고 나중에 Commit한 Primary DB는 Abort된다. Single-primary Mode와 동일하게 DB 장애가 발생해도 Primary DB 및 MySQL Router를 **자동**으로 Failover하여 DB 관리자의 개입없이 계속 DB 사용이 가능하다는 점이다.

![]({{site.baseurl}}/images/theory_analysis/MySQL_Replication/Group_Replication_Multi-primary_Certify_Replication.PNG){: width="550px"}

위의 그림은 Multi-primary Mode의 Certify 및 Replication 과정을 나타내고 있다. Certify는 Commit 충돌 검사 과정을 의미한다. App에게 Commit 요청을 받은 첫번째 Primary DB는 자신의 DB를 변경하고, Replication를 수행할 두번째 Primary DB에게 Certify 요청 및 DB 변경 내용을 전달한다. 두번째 Primary DB는 Certify 진행 및 Certify 결과를 첫번째 Primary DB에게 전달한 뒤 자신의 DB를 변경한다. 첫번째 Primary는 두번째 Primary로부터 Certify 완료를 전달받은 뒤에나 App에게 Commit 결과를 전달한다. 이러한 Certify 과정은 Commit Overhead의 주요 원인이 된다. Certify 및 Replication 과정은 완전한 Sync 방식이 아닌 Semi-sync 또는 2 Phase-Commit 방식과 유사하다.

### 3. Galera Cluster

![]({{site.baseurl}}/images/theory_analysis/MySQL_Replication/Galera_Cluster.PNG){: width="600px"}

Galera Cluster는 Group Replication의 Multi-primary Mode와 매우 유사한 Multi-master Replication 기법이다. Galera Cluster 설명에는 Replication 과정이 Sync 또는 Virtual Sync 방식이라고 설명되어 있지만, 실제로는 Group Replication의 Multi-primary Mode처럼 Semi-sync 또는 2 Phase-Commit 방식과 유사하게 구현되어 있다. 위의 그림은 Galera Cluster를 의미한다. Client는 LB의 VIP (Virtual IP)를 통해서 DB에 접근한다. 각 DB는 wsrep(Write Set Replication) Plugin을 통하여 서로 wsrep API로 통신하며 Replication을 진행한다.

Galera Cluster와 Group Replication의 Multi-primary Mode은 유사하지만 몇가지 차이점을 가진다. Galera Cluster에서는 DB가 변경될 경우 모든 DB에 변경내용이 반영되어야 Commit을 성공한다. 만약 Galera Cluster가 3개의 DB로 이루어져 있다면 3개의 DB 모두 변경내용이 적용되어야 Commit에 성공한다는 의미이다. 반대로 Group Replication의 Multi-primary Mode의 경우 과반수 이상의 DB에만 변경내용이 반영되면 Commit을 성공한다. 만약 Group Replication의 Multi-primary Mode로 3개의 DB로 이루어져 있다면 3개의 DB 중에서 2개의 DB에만 변경내용이 반영되면 Commit을 성공한다. Galera Cluster는 MySQL기반인 MariaDB 및 Percona에서도 적용할 수 있지만 Group Replication은 현재 MySQL에서만 적용 할 수 있다.

### 4. 참조

* [http://skillachie.com/2014/07/25/mysql-high-availability-architectures/](http://skillachie.com/2014/07/25/mysql-high-availability-architectures/)
* [https://www.percona.com/blog/2017/02/07/overview-of-different-mysql-replication-solutions/](https://www.percona.com/blog/2017/02/07/overview-of-different-mysql-replication-solutions/)
* Master-Slave Replication - [https://blurblah.net/1505](https://blurblah.net/1505)
* Semi-sync - [http://www.mysqlkorea.com/gnuboard4/bbs/board.php?bo_table=develop_03&wr_id=73](http://www.mysqlkorea.com/gnuboard4/bbs/board.php?bo_table=develop_03&wr_id=73)
* Semi-sync - [http://gywn.net/tag/semi-sync-replication/](http://gywn.net/tag/semi-sync-replication/)
* Replication, Master - [https://stackoverflow.com/questions/38036955/when-to-prefer-master-slave-and-when-to-cluster](https://stackoverflow.com/questions/38036955/when-to-prefer-master-slave-and-when-to-cluster)
* Group Replication - [https://www.percona.com/live/17/sessions/everything-you-need-know-about-mysql-group-replication](https://www.percona.com/live/17/sessions/everything-you-need-know-about-mysql-group-replication)
* Group Replication - [https://lefred.be/content/mysql-group-replication-synchronous-or-asynchronous-replication/](https://lefred.be/content/mysql-group-replication-synchronous-or-asynchronous-replication/)
* Group Replicaiton - [https://scriptingmysql.wordpress.com/category/mysql-replication/](https://scriptingmysql.wordpress.com/category/mysql-replication/)
* Galera Cluster - [https://www.slideshare.net/MyDBOPS/galera-cluster-for-high-availability](https://www.slideshare.net/MyDBOPS/galera-cluster-for-high-availability)
* Group Replication, Galera Cluster -  [https://www.percona.com/blog/2017/02/24/battle-for-synchronous-replication-in-mysql-galera-vs-group-replication/](https://www.percona.com/blog/2017/02/24/battle-for-synchronous-replication-in-mysql-galera-vs-group-replication/)
* Group Replicaiton, Galera Cluster - [https://severalnines.com/resources/tutorials/mysql-load-balancing-haproxy-tutorial](https://severalnines.com/resources/tutorials/mysql-load-balancing-haproxy-tutorial)

