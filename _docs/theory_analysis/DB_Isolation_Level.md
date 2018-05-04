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

이러한 문제를 해결하기 위해 대부분의 DB는 Isolation Level을 지원한다. Isolation Level이 낮을수록 각 Transaction이 서로 많은 영향 미치지만, 그만큼 DB 성능이 증가 한다. DB Isolation Level에는 Serializable, Repeatable-Read, Read Committed, Read UnCommitted 4가지가 존재한다.

#### 1.1. Serializable

가장 높은 Isolation Level이다. Transaction의 Query에 연관된 모든 Table에 Table Lock을 걸고 Query를 수행한다. 따라서 각 Transaction은 서로 완전히 독립되어 수행된다.

#### 1.2. Repeatable-Read

두번째로 높은 Isolation Level이다. Transaction이 수행되는 동안 한번 읽었던 Row를 반복해서 읽을경우 언제나 동일한 Data가 나오는 것을 보장해주는 Level이다. 하지만 외부 Transaction에 의해 추가된 **새로운 Row**가 Read 결과에 반영되기 때문에 완전한 Isolation을 보장하지는 못한다. 이렇게 외부 Transaction에 의해서 새롭게 추가된 Row가 결과에 반영되는 현상을 **Phantom Read**라고 한다.

Repeatable-Read Level에서 DB는 Transaction의 Query에 연관된 모든 Table의 Row에 Row Lock을 걸고 수행하고, Transaction이 종료될때 Lock을 푼다. 따라서 Transaction에서 Read를 수행한 Row를 외부 Transaction에서 변경하지 못한다. 하지만 Row Lock만 걸기 때문에 외부 Transaction에서 해당 Table에 새로운 Row를 추가 할 수 있다.

#### 1.3. Read Committed

세번째로 높은 Isolation Level이다. Transaction이 수행되는 동안 발생한 외부 Transaction의 Commit이 현재 Transaction에 영향을 미치는 Level이다. 즉 Transaction 수행 중 읽었던 Row를 외부 Transaction에서 Update & Commit를 통해 변경하면, 변경 내용이 현재 Transaction에 반영된다. 이렇게 Transaction에서 하나의 Row를 반복해서 읽을때 외부 Transaction의 Commit에 따라서 값이 변경되는 현상을 **Non-repeatable Read**라고 한다.

Read Committed Level에서 DB는 Query에 연관된 Row에 Row Lock을 건뒤 Query를 수행하고, Query 수행이 마치면 해당 Row Lock을 푼다. Transaction 단위가 아닌 Query 단위로 Lock 동작을 수행하기 때문에 Transaction 수행 중에도 외부 Transaction Commit 내용이 반영된다.

#### 1.4. Read Uncommitted

가장 낮은 Isolation Level이다. Transaction이 수행되는 동안 발생한 외부 Transaction의 Row 변경이 현재 Transaction에 영향을 미치는 Level이다. 즉 Transaction 수행 중 읽었던 Row를 외부의 Transaction에서 Commit없이 변경만 하더라도 변경 내용이 현재 Transaction에 반영된다. 이렇게 Commit 되지 않은 변경 내용이 다른 Transaction의 Read에 영향을 미치는 현상을 **Dirty Read**라고 한다.

Read Uncommitted Level에서 DB는 Lock을 걸지 않고 Query를 수행하기 때문에 Transaction 처리 과정이 외부 Transaction에 그대로 노출된다.

### 2. Isolation Level & Issue

Isolation Level에 따라서 다음과 같은 Issue가 발생한다.

| | Read Uncommitted | Read Committed | Repeatable-Read | Serializable |
|----|----|----|----|----|
| Lost Update | O | O | X | X |
| Dirty Read | O | X | X | X |
| Non-repeatable Read | O | O | X | X |
| Phantom Read | O | O | O | X |

#### 2.1. Lost Update

| T1 | T2 |
|----|----|
| SELECT age FROM users WHERE id = 1; | |
| | SELECT age FROM users WHERE id = 1; |
| UPDATE users SET age = 21 WHERE id = 1; <br> COMMIT; | |
| | UPDATE users SET age = 31 WHERE id = 1; <br> COMMIT;|

Lost Update는 2개 이상의 Transaction이 하나의 Row를 동시에 변경하는 경우 변경 내용이 사라지는 현상이다. Transaction 단위로 Lock을 걸지 않는 Read Uncommitted, Read Committed Level에서 발생한다. 위의 예제의 경우 Read UnCommitted, Read Committed Level에서 T1의 21값은 사라진다. 하지만 Repeatable Read, Serializable Level에서는 T2의 Commit 수행시 Exception이 발생하면서 31값으로 변경되지 않는다.

#### 2.2. Dirty Read

| T1 | T2 |
|----|----|
| SELECT age FROM users WHERE id = 1; | |
| | UPDATE users SET age = 21 WHERE id = 1; |
| SELECT age FROM users WHERE id = 1; | |
| | ROLLBACK; |

Dirty Read는 Commit 되지 않은 변경 내용이 다른 Transaction의 Read에 영향을 미치는 현상이다. 위의 예제의 경우 T1는 T2의 Rollback되어 사라진 21값을 가지고 있게된다.

#### 2.3. Non-repeatable Read

| T1 | T2 |
|----|----|
| SELECT age FROM users WHERE id = 1; | |
| | UPDATE users SET age = 21 WHERE id = 1; <br> COMMIT;|
| SELECT age FROM users WHERE id = 1; <br> COMMIT;| |

Non-repeatable Read는 Transaction에서 하나의 Row를 반복해서 읽을때 외부 Transaction의 Commit에 따라서 값이 변경되는 현상이다.

#### 2.4. Phantom Read

| T1 | T2 |
|----|----|
| SELECT * FROM users WHERE age BETWEEN 10 AND 30;| |
| | INSERT INTO users(id,name,age) VALUES ( 3, 'Bob', 27 ); <br> COMMIT;|
| SELECT * FROM users WHERE age BETWEEN 10 AND 30; <br> COMMIT;| |

Phantom Reae는 외부 Transaction에 의해서 새롭게 추가된 Row가 결과에 반영되는 현상이다. 위의 예제에서 T1은 첫번째 SELECT Query에서 Bob의 정보를 읽어오지 못하지만, 두번째 SELECT Query에서는 T2 Transaction에 의해서 Bob의 정보를 읽어오게 된다.

### 3. RDBMS

#### 3.1. SQL Server

Default Isolation Level로 Read Committed를 이용한다. 또한 Serializable Level과 Repeatable-Level 사이에 Snapshot이라는 Isolation Level을 제공한다. Snapshot Isolation Level은 각  Transaction마다 Table Snapshot을 만들고 이용하기 때문에 Phantom Read 현상을 막을 수 있다.

#### 3.2. MySQL

Default Isolation Level로 Repeatable-Level을 이용한다. Repeatable-Level이지만 Row Lock + Snapshot을 이용하는 독특한 구조 때문에 Phantom Read현상이 발생하지 않는다. 하지만 Transaction에서 보이지 않는 Row를 Update 할 수 있는 **Phatom Write** 현상이 발생한다.

### 4. 참조

* [http://whiteship.tistory.com/1554](http://whiteship.tistory.com/1554)
* [http://hundredin.net/2012/07/26/isolation-level/](http://hundredin.net/2012/07/26/isolation-level/)
* [https://blog.pythian.com/understanding-mysql-isolation-levels-repeatable-read/](https://blog.pythian.com/understanding-mysql-isolation-levels-repeatable-read/)
* [https://vladmihalcea.com/a-beginners-guide-to-database-locking-and-the-lost-update-phenomena/](https://vladmihalcea.com/a-beginners-guide-to-database-locking-and-the-lost-update-phenomena/)
* [https://docs.microsoft.com/ko-kr/sql/t-sql/statements/set-transaction-isolation-level-transact-sql?view=sql-server-2017](https://docs.microsoft.com/ko-kr/sql/t-sql/statements/set-transaction-isolation-level-transact-sql?view=sql-server-2017)
* [https://en.wikipedia.org/wiki/Isolation_(database_systems)](https://en.wikipedia.org/wiki/Isolation_(database_systems))
