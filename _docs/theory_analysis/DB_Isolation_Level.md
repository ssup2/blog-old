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

ACID 특성을 따르는 Transaction은 이론적으로는 서로 완전히 독립적으로 동작을 보장 받아야 한다. 하지만 Transaction의 완전한 ACID 특성을 보존하기 위해서는 Coarse-grained Lock을 이용해야하고 그만큼 DB의 성능 저하로 이어진다. 이러한 문제를 해결하기 위해 대부분의 DB는 Isolation Level을 지원한다.

DB User는 DB의 Isolation Level을 설정하여 DB의 성능과 Transaction의 ACID 특성의 보장 정도를 결정할 수 있다. Isolation Level이 높을수록 DB의 성능은 감소하지만 Transaction의 ACID 특성이 잘 보장된다. 반면에 Isolation Level이 낮을수록 DB의 성능은 증가하지만 Transaction의 ACID 특성이 잘 보장되지 않아, 각 Transaction이 서로에게 주는 영향도가 증가하게 된다.

DB Isolation Level에는 일반적으로 Serializable, Repeatable Read, Read Committed, Read UnCommitted 4가지가 존재한다. Isolation Level을 구현하기 위해서 DB는 Table 전체에 Lock을 설정하는 Table Lock과 하나의 Row에 Lock을 설정하는 Row Lock을 많이 이용한다. DB 종류에 따라서 각 Lock은 다시 Shared Lock (Read Lock), Exclusive Lock (Write Lock)으로 구분되는 경우가 이용되는 경우가 있다. DB에서 Shared, Exclusive Lock을 이용하는 경우 아래의 Isolation Level 설명에서 Table, Row Lock이라고 언급된 부분은 모두 **Exclusive Lock**으로 간주하면 된다.

#### 1.1. Serializable

가장 높은 Isolation Level이다. Transaction의 Query에 연관된 모든 Table에 Table Lock을 걸고 Query를 수행한다. 따라서 각 Transaction은 서로 완전히 독립되어 수행된다.

#### 1.2. Repeatable Read

두번째로 높은 Isolation Level이다. Transaction이 수행되는 동안 한번 읽었던 Row를 반복해서 읽을경우 언제나 동일한 Data가 나오는 것을 보장해주는 Level이다. DB는 Repeatable Read Level 구현을 위해서 Row Lock을 이용하여 방법과 Snapshot + Row Lock을 이용한 방법 2가지가 존재한다.

##### 1.2.1. Row Lock

DB가 Row Lock을 이용하여 Repeatable Read Level을 구현하는 경우 DB는 Transaction의 Query에 연관된 모든 Table의 Row에 Row Lock을 걸고 Query를 수행하고, Transaction이 종료될때 Row Lock을 푼다. 따라서 Transaction에서 Read를 수행한 Row를 외부 Transaction에서 변경하지 못하기 때문에 동일한 Transaction에서 여러번 Row를 읽어도 언제나 동일한 Data가 나타난다.

하지만 Row Lock만 이용하고 Table Lock을 이용하지 않기 때문에 외부 Transaction에서 해당 Table에 새로운 Row를 추가하는 경우, 추가된 Row가 원래 Transaction에서 같이 읽어질 수 있다. 이러한 현상은 **Phantom Read**라고  한다.

##### 1.2.2. Snapshot + Row Lock

Row Lock과 함께 Snapshot을 이용하면 읽기(SELECT) 동작의 병렬성 확보 및 Phantom Read 현상을 제거할 수 있다. Row Lock만을 이용하는 경우 동시에 Row Lock이 Transaction이 종료되어야 풀리기 때문에 동시에 여러 Transaction에서 하나의 Row를 동시에 읽을 수 없다.

Snapshot을 이용하는 경우 Transaction 내부에서 읽기 동작 수행시 Transaction 전용 Snapshot을 생성하고, 이후 Transaction 내부의 읽기 동작은 생성한 Transaction 전용 Snapshot을 대상으로 수행된다. 따라서 각 Transaction에서 하나의 Row를 동시에 읽더라도 실제로는 각 Transaction 전용 Snapshot을 읽기 때문에 동시에 읽기 동작이 가능하며, Phantom Read 현상도 발생하지 않는다.

갱신(Update) 동작을 수행하는 경우에는 Snapshot이 아닌 실제 Row를 대상으로 Row Lock을 걸고 갱신 동작을 수행한다. 따라서 동시에 여러 Transaction에서 하나의 Row를 갱신하려고 하면 한번의 하나의 Transaction만 갱신이 가능하다. 

#### 1.3. Read Committed

세번째로 높은 Isolation Level이다. Transaction이 수행되는 동안 발생한 외부 Transaction의 Commit이 현재 Transaction에 영향을 미치는 Level이다. 즉 Transaction 수행 중 읽었던 Row를 외부 Transaction에서 Update & Commit를 통해 변경하면, 변경 내용이 현재 Transaction에 반영된다. 이렇게 Transaction에서 하나의 Row를 반복해서 읽을때 외부 Transaction의 Commit에 따라서 값이 변경되는 현상을 **Non-repeatable Read**라고 한다.

Read Committed Level에서 DB는 Query에 연관된 Row에 Row Lock을 건뒤 Query를 수행하고, Query 수행이 마치면 해당 Row Lock을 푼다. Transaction 단위가 아닌 Query 단위로 Lock 동작을 수행하기 때문에 Transaction 수행 중에도 외부 Transaction Commit 내용이 반영된다.

#### 1.4. Read Uncommitted

가장 낮은 Isolation Level이다. Transaction이 수행되는 동안 발생한 외부 Transaction의 Row 변경이 현재 Transaction에 영향을 미치는 Level이다. 즉 Transaction 수행 중 읽었던 Row를 외부의 Transaction에서 Commit없이 변경만 하더라도 변경 내용이 현재 Transaction에 반영된다. 이렇게 Commit 되지 않은 변경 내용이 다른 Transaction의 Read에 영향을 미치는 현상을 **Dirty Read**라고 한다.

Read Uncommitted Level에서 DB는 Lock을 걸지 않고 Query를 수행하기 때문에 Transaction 처리 과정이 외부 Transaction에 그대로 노출된다.

### 2. Isolation Level & Issue

| | Read Uncommitted | Read Committed | Repeatable Read | Serializable |
|----|----|----|----|----|
| Lost Update | O | O | X | X |
| Dirty Read | O | X | X | X |
| Non-repeatable Read | O | O | X | X |
| Phantom Read | O | O | O | X |

<figure>
<figcaption class="caption">[표 1] DB Isolation Level에 따른 Issue</figcaption>
</figure>

Isolation Level에 따라서 [표 1]과 같은 Issue가 발생한다.

#### 2.1. Lost Update

| T1 | T2 |
|----|----|
| SELECT age FROM users WHERE id = 1; | |
| | SELECT age FROM users WHERE id = 1; |
| UPDATE users SET age = 21 WHERE id = 1; <br> COMMIT; | |
| | UPDATE users SET age = 31 WHERE id = 1; <br> COMMIT;|

<figure>
<figcaption class="caption">[표 2] Lost Update 예제</figcaption>
</figure>

Lost Update는 2개 이상의 Transaction이 하나의 Row를 동시에 변경하는 경우 변경 내용이 사라지는 현상이다. Transaction 단위로 Lock을 걸지 않는 Read Uncommitted, Read Committed Level에서 발생한다. [표 2]의 경우 Read UnCommitted, Read Committed Level에서 T1의 21값은 사라진다. 하지만 Repeatable Read, Serializable Level에서는 T2의 Commit 수행시 Exception이 발생하면서 31값으로 변경되지 않는다.

#### 2.2. Dirty Read

| T1 | T2 |
|----|----|
| SELECT age FROM users WHERE id = 1; | |
| | UPDATE users SET age = 21 WHERE id = 1; |
| SELECT age FROM users WHERE id = 1; | |
| | ROLLBACK; |

<figure>
<figcaption class="caption">[표 3] Dirty Read 예제</figcaption>
</figure>

Dirty Read는 Commit 되지 않은 변경 내용이 다른 Transaction의 Read에 영향을 미치는 현상이다. [표 3]의 경우 T1는 T2의 Rollback되어 사라진 21값을 가지고 있게된다.

#### 2.3. Non-repeatable Read

| T1 | T2 |
|----|----|
| SELECT age FROM users WHERE id = 1; | |
| | UPDATE users SET age = 21 WHERE id = 1; <br> COMMIT;|
| SELECT age FROM users WHERE id = 1; <br> COMMIT;| |

<figure>
<figcaption class="caption">[표 4] Non-repeatable Read 예제</figcaption>
</figure>

Non-repeatable Read는 Transaction에서 하나의 Row를 반복해서 읽을때 외부 Transaction의 Commit에 따라서 값이 변경되는 현상이다. [표 4]에서 T2의 의해서 T1은 첫번째 age의 Read 값과 두번째 age의 Read값이 달라진다.

#### 2.4. Phantom Read

| T1 | T2 |
|----|----|
| SELECT * FROM users WHERE age BETWEEN 10 AND 30;| |
| | INSERT INTO users(id,name,age) VALUES ( 3, 'Bob', 27 ); <br> COMMIT;|
| SELECT * FROM users WHERE age BETWEEN 10 AND 30; <br> COMMIT;| |

<figure>
<figcaption class="caption">[표 5] Phantom Read 예제</figcaption>
</figure>

Phantom Reae는 외부 Transaction에 의해서 새롭게 추가된 Row가 결과에 반영되는 현상이다. [표 5]에서 T1은 첫번째 SELECT Query에서 Bob의 정보를 읽어오지 못하지만, 두번째 SELECT Query에서는 T2 Transaction에 의해서 Bob의 정보를 읽어오게 된다.

### 3. RDBMS Isolation Level

* MySQL - Default Isolation Level로 Repeatable Read Level을 이용하며, Repeatable Level은 Snapshot + Row Lock 기반의 방식을 이용한다.
* SQL Server - Default Isolation Level로 Read Committed를 이용한다. 또한 Serializable Level과 Repeatable Read Level 사이에 Snapshot이라고 불리는 Snapshot 기반 Isolation Level을 제공한다.

### 4. 참조

* [http://whiteship.tistory.com/1554](http://whiteship.tistory.com/1554)
* [http://hundredin.net/2012/07/26/isolation-level/](http://hundredin.net/2012/07/26/isolation-level/)
* [https://blog.pythian.com/understanding-mysql-isolation-levels-Repeatable Read/](https://blog.pythian.com/understanding-mysql-isolation-levels-Repeatable Read/)
* [https://vladmihalcea.com/a-beginners-guide-to-database-locking-and-the-lost-update-phenomena/](https://vladmihalcea.com/a-beginners-guide-to-database-locking-and-the-lost-update-phenomena/)
* [https://docs.microsoft.com/ko-kr/sql/t-sql/statements/set-transaction-isolation-level-transact-sql?view=sql-server-2017](https://docs.microsoft.com/ko-kr/sql/t-sql/statements/set-transaction-isolation-level-transact-sql?view=sql-server-2017)
* [https://en.wikipedia.org/wiki/Isolation_(database_systems)](https://en.wikipedia.org/wiki/Isolation_(database_systems))
* [https://stackoverflow.com/questions/10935850/when-to-use-select-for-update](https://stackoverflow.com/questions/10935850/when-to-use-select-for-update)
* [https://stackoverflow.com/questions/33784779/whats-the-use-of-select-for-update-when-using-Repeatable Read-isolation](https://stackoverflow.com/questions/33784779/whats-the-use-of-select-for-update-when-using-Repeatable Read-isolation)
* [https://stackoverflow.com/questions/33784779/whats-the-use-of-select-for-update-when-using-repeatable-read-isolation](https://stackoverflow.com/questions/33784779/whats-the-use-of-select-for-update-when-using-repeatable-read-isolation)
* [https://jyeonth.tistory.com/32](https://jyeonth.tistory.com/32)
