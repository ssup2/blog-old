---
title: DB Partioning, Sharding
category: Theory, Analysis
date: 2021-06-06T12:00:00Z
lastmod: 2021-06-06T12:00:00Z
comment: true
adsense: true
---

DB의 Partitioning, Sharding을 분석한다.

### 1. DB Partitioning

![[그림 1] DB Partitioning]({{site.baseurl}}/images/theory_analysis/DB_Partitioning_Sharding/DB_Partitioning.PNG){: width="700px"}

### 2. DB Sharding

#### 2.1. Hashing

![[그림 2] DB Sharding Hash]({{site.baseurl}}/images/theory_analysis/DB_Partitioning_Sharding/DB_Sharding_Hash.PNG){: width="500px"}

#### 2.2. Range

![[그림 3] DB Sharding Range]({{site.baseurl}}/images/theory_analysis/DB_Partitioning_Sharding/DB_Sharding_Range.PNG){: width="500px"}

#### 2.3. List

![[그림 4] DB Sharding List]({{site.baseurl}}/images/theory_analysis/DB_Partitioning_Sharding/DB_Sharding_List.PNG){: width="500px"}

### 3. 참조

* [https://www.digitalocean.com/community/tutorials/understanding-database-sharding](https://www.digitalocean.com/community/tutorials/understanding-database-sharding)
* [https://blog.yugabyte.com/how-data-sharding-works-in-a-distributed-sql-database/](https://blog.yugabyte.com/how-data-sharding-works-in-a-distributed-sql-database/)
* [https://hazelcast.com/glossary/sharding/](https://hazelcast.com/glossary/sharding/)
* [https://hevodata.com/learn/understanding-mysql-sharding-simplified/](https://hevodata.com/learn/understanding-mysql-sharding-simplified/)
* [https://devopedia.org/database-sharding](https://devopedia.org/database-sharding)
* [https://woowabros.github.io/experience/2020/07/06/db-sharding.html](https://woowabros.github.io/experience/2020/07/06/db-sharding.html)
