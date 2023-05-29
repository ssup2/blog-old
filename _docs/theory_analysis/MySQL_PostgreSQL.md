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

* 

#### 1.1. Client Connection

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