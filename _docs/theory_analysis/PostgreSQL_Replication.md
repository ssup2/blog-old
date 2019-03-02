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

#### 1.1. WAL (Write Ahead Log) Replication

![]({{site.baseurl}}/images/theory_analysis/PostgreSQL_Replication/WAL_Replication.PNG){: width="500px"}

#### 1.2. Streaming Replication

![]({{site.baseurl}}/images/theory_analysis/PostgreSQL_Replication/Streaming_Replication.PNG){: width="400px"}

#### 1.3. Pgpool-II

![]({{site.baseurl}}/images/theory_analysis/PostgreSQL_Replication/Pgpool.PNG){: width="600px"}

### 2. 참조

* [https://severalnines.com/blog/postgresql-streaming-replication-deep-dive](https://severalnines.com/blog/postgresql-streaming-replication-deep-dive)