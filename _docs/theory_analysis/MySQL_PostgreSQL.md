---
title: MySQL vs PostgreSQL
category: Theory, Analysis
date: 2018-12-14T12:00:00Z
lastmod: 2018-12-14T12:00:00Z
comment: true
adsense: true
---

MySQL과 PostgreSQL을 비교 분석한다.

### 1. MySQL vs PostgresSQL

#### 1.1. 요약

* MySQL : 단순한 기능/Architecture을 기반으로 빠른 성능을 보임
* PostgreSQL : 다양한 기능을 기반으로 다양한 요구사항을 충족

MySQL는 PostgreSQL 대비 단순한 기능/Architecture를 갖는다. 따라서 PostgreSQL 대비 적은 Resource를 이용하며, 단순한 CRUD 동작의 경우에도 PosgreSQL 대비 일반적으로 빠른 성능을 보여주는 것으로 알려져 있다. 과거의 Monolithic Architecture에서는 많은 Business Logic을 Database에 넣었기 때문에 Database의 다양한 기능이 중요했지만, MSA (Micro Service Architecture)에서 일반적으로 Business Logic을 Application에서 처리하기 때문에 Database 기능의 중요성이 많이 떨어진다. 따라서 MSA에서의 OLTP를 위한 RDMBS 선택시 일반적으로 PosgreSQL보다 MySQL이 더 적합한 경우가 많다.

반면에 PostgreSQL의 다양한 기능은 Data 분석시에 유용한 경우가 많다. 즉 OLAP를 위한 RDBMS 선택시에는 PostgreSQL을 일반적으로 더 권장한다. 동일한 이유로 소규모의 Data Warehose 구축시에도 RDMBS를 이용하는 경우 PostgreSQL 보다 MySQL 이용을 권장한다.

#### 1.1. Relation Database vs Object-Relational Database

#### 1.2. Engine

#### 1.3. Replication

#### 1.4. Client Connection

* MySQL : Client Connection 생성 시에 새로운 Thread를 생성
* PostgreSQL : Client Connection 생성 시에 새로운 Process를 생성

MySQL은 새로운 Thread를 생성하는 방식이기 때문에 Process를 생성하는 PostgreSQL 대비 적은 Resource를 이용한다는 장점을 갖는다. Thread 생성에 필요한 Resource 보다 Process 생성에 필요한 Resource가 적게 들고, Thread 사이의 통신에 필요한 Resource도 Process 사이의 통신 비용보다 적게 들기 때문이다. 일반적으로 많은 Client Connection이 발생하면 MySQL이 PostgreSQL보다 안정적인 것으로 알려져 있다.

반면에 PostgreSQL은 Process를 생성하는 방식이기 때문에 Thread를 생성하는 MySQL 대비 Client 사이의 격리 수준 및 보안성은 더 좋은 편이다. 

### 2. 참조

* [https://developer.okta.com/blog/2019/07/19/mysql-vs-postgres](https://developer.okta.com/blog/2019/07/19/mysql-vs-postgres)
* [https://www.fivetran.com/blog/postgresql-vs-mysql](https://www.fivetran.com/blog/postgresql-vs-mysql)
* [https://www.sumologickorea.com/blog/postgresql-vs-mysql/](https://www.sumologickorea.com/blog/postgresql-vs-mysql/)
* [https://dbconvert.com/blog/mysql-vs-postgresql/](https://dbconvert.com/blog/mysql-vs-postgresql/)
* [https://uminoh.tistory.com/32](https://uminoh.tistory.com/32)
* [https://www.uber.com/en-KR/blog/postgres-to-mysql-migration/](https://www.uber.com/en-KR/blog/postgres-to-mysql-migration/)
* [https://www.holistics.io/blog/why-you-should-use-postgres-over-mysql-for-analytics-purpose/?utm_campaign=pg_mysql&utm_source=medium](https://www.holistics.io/blog/why-you-should-use-postgres-over-mysql-for-analytics-purpose/?utm_campaign=pg_mysql&utm_source=medium)