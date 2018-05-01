---
title: DB Isolation Level
category: Theory, Analysis
date: 2018-04-30T12:00:00Z
lastmod: 2017-04-30T12:00:00Z
comment: true
adsense: true
---

DB의 Isolation Level 및 Isolation Level에 따라 발생하는 Issue를 분석한다.

### 1. Isolation Level

#### 1.1. Serializable

#### 1.2. Repeatable Read

#### 1.3. Read Commited

#### 1.4. Read Uncommited

### 2. Isolation Level & Issue

#### 2.1. Lost Update

#### 2.2. Dirty Read

#### 2.3. Non-Repeatable Read

#### 2.4. Phantom Read

### 3. 구현

#### 3.1. MySQL

#### 3.2. MySQL

### 4. 참조

* [http://whiteship.tistory.com/1554](http://whiteship.tistory.com/1554)
* [http://hundredin.net/2012/07/26/isolation-level/](http://hundredin.net/2012/07/26/isolation-level/)
* [https://blog.pythian.com/understanding-mysql-isolation-levels-repeatable-read/](https://blog.pythian.com/understanding-mysql-isolation-levels-repeatable-read/)
* [https://vladmihalcea.com/a-beginners-guide-to-database-locking-and-the-lost-update-phenomena/](https://vladmihalcea.com/a-beginners-guide-to-database-locking-and-the-lost-update-phenomena/)
* [https://docs.microsoft.com/ko-kr/sql/t-sql/statements/set-transaction-isolation-level-transact-sql?view=sql-server-2017](https://docs.microsoft.com/ko-kr/sql/t-sql/statements/set-transaction-isolation-level-transact-sql?view=sql-server-2017)
