---
title: DB Isolation Level
category: Theory, Analysis
date: 2018-05-02T12:00:00Z
lastmod: 2018-05-02T12:00:00Z
comment: true
adsense: true
---

DB의 Isolation Level 및 Isolation Level에 따라 발생하는 Issue를 분석한다.

### 1. Isolation Level

ACID의 Isolation의 원칙에 따라 각 Transaction은 서로 완전히 독립적으로 동작해야 한다. 하지만 완전한 Isolation을 구현하기 위해서는 Coarse-grained Lock을 많이 이용해야 하고 그만큼 DB의 성능저하로 이어진다.

이러한 문제를 해결하기 위해 대부분의 DB는 Isolation Level을 지원한다. Isolation Level이 낮을수록 각 Transaction이 서로 많은 영향 미치지만, 그만큼 DB 성능이 증가 한다. DB Isolation Level에는 Serializable, Repeatable Read, Read Committed, Read Uncommited 4가지가 존재한다.

#### 1.1. Serializable

가장 높은 Isolation Level이다. Transaction의 Query에 연관된 모든 Table에 Table Lock을 걸고 Query를 수행한다. 따라서 각 Transaction은 서로 완전히 독립되어 수행된다.

#### 1.2. Repeatable Read

두번째로 높은 Isolation Level이다. Transaction이 수행되는 동안 한번 읽었던 Row를 반복해서 읽을경우 언제나 동일한 Data가 나오는 것을 보장해주는 Level이다. 하지만 외부 Transaction에 의해 추가된 **새로운 Row**가 Read 결과에 반영되기 때문에 완전한 Isolation을 보장하지는 못한다. 이렇게 외부 Transaction에 의해서 새롭게 추가된 Row가 결과에 반영되는 현상을 **Phantom Read**라고 한다.

Repeatable Read Level에서 DB는 Transaction의 Query에 연관된 모든 Table의 Row에 Row Lock을 걸고 수행하고, Transaction이 종료될때 Lock을 푼다. 따라서 Transaction에서 Read를 수행한 Row를 외부 Transaction에서 변경하지 못한다. 하지만 Row Lock만 걸기 때문에 외부 Transaction에서 해당 Table에 새로운 Row를 추가 할 수 있다.

#### 1.3. Read Commited

세번째로 높은 Isolation Level이다. Transaction이 수행되는 동안 발생한 외부 Transaction의 Commit이 현재 Transaction에 영향을 미치는 Level이다. 즉 Transaction 수행 중 읽었던 Row를 외부 Transaction에서 Update & Commit를 통해 변경하면, 변경 내용이 현재 Transaction에 반영된다. 이렇게 Transaction에서 하나의 Row를 반복해서 읽을때 외부 Transaction의 Commit에 따라서 값이 변경되는 현상을 **Non-repeatable Read**라고 한다.

Read Commited Level에서 DB는 Query에 연관된 Row의 Row Lock을 걸고 Query를 수행하고, Query 수행이 마치면 해당 Row Lock을 푼다. Transaction 단위가 아닌 Query 단위로 Lock 동작을 수행하기 때문에 Transaction 수행 중에도 외부 Transaction Commit 내용이 반영된다.

#### 1.4. Read Uncommited

가장 낮은 Isolation Level이다.

### 2. Isolation Level & Issue

#### 2.1. Lost Update

#### 2.2. Dirty Read

#### 2.3. Non-repeatable Read

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
* [https://en.wikipedia.org/wiki/Isolation_(database_systems)](https://en.wikipedia.org/wiki/Isolation_(database_systems))
