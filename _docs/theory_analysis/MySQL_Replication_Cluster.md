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

#### 1.1. Async Replication

![]({{site.baseurl}}/images/theory_analysis/MySQL_Replication_Cluster/Master_Slave_Async_Replication.PNG){: width="550px"}

#### 1.2. Semi-sync Replication

![]({{site.baseurl}}/images/theory_analysis/MySQL_Replication_Cluster/Master_Slave_Semi-sync_Replication_Commit.PNG){: width="550px"}

![]({{site.baseurl}}/images/theory_analysis/MySQL_Replication_Cluster/Master_Slave_Semi-sync_Replication_Sync.PNG){: width="550px"}

### 2. Group Replication

### 3. 참조

* [http://skillachie.com/2014/07/25/mysql-high-availability-architectures/](http://skillachie.com/2014/07/25/mysql-high-availability-architectures/)
* [https://www.percona.com/blog/2017/02/07/overview-of-different-mysql-replication-solutions/](https://www.percona.com/blog/2017/02/07/overview-of-different-mysql-replication-solutions/)
* Group Replication - [https://www.percona.com/live/17/sessions/everything-you-need-know-about-mysql-group-replication](https://www.percona.com/live/17/sessions/everything-you-need-know-about-mysql-group-replication)
* Group Replicaiton - [https://scriptingmysql.wordpress.com/category/mysql-replication/](https://scriptingmysql.wordpress.com/category/mysql-replication/)
* Group Replication, Galera Cluster -  [https://www.percona.com/blog/2017/02/24/battle-for-synchronous-replication-in-mysql-galera-vs-group-replication/](https://www.percona.com/blog/2017/02/24/battle-for-synchronous-replication-in-mysql-galera-vs-group-replication/)
* Replication, Master - [https://stackoverflow.com/questions/38036955/when-to-prefer-master-slave-and-when-to-cluster](https://stackoverflow.com/questions/38036955/when-to-prefer-master-slave-and-when-to-cluster)
* Semi-sync - [http://www.mysqlkorea.com/gnuboard4/bbs/board.php?bo_table=develop_03&wr_id=73](http://www.mysqlkorea.com/gnuboard4/bbs/board.php?bo_table=develop_03&wr_id=73)
* Semi-sync - [http://gywn.net/tag/semi-sync-replication/](http://gywn.net/tag/semi-sync-replication/)
