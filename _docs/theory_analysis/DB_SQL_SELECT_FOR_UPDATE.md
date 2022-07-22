---
title: DB SQL SELECT FOR UPDATE
category: Theory, Analysis
date: 2022-07-20T12:00:00Z
lastmod: 2022-07-20T12:00:00Z
comment: true
adsense: true
---

SQL SELECT FOR UPDATE Query를 분석한다.

### 1. SELECT FOR UPDATE Query

SELECT FOR UPDATE Query는 SELECT 수행시 **Exclusive (Write) Row Lock** 획득 이후에 읽기 연산을 수행하는 Query이다. SELECT Query가 Shared (Read) Row Lock을 획득하거나 또는 Lock 자체를 획득하지 않는것과 대비된다. SELECT FOR UPDATE QUERY로 획득한 Exclusive Lock은 Transaction이 종료되어야 풀린다.

따라서 MySQL과 같이 SELECT Query시 Shared Lock을 획득하지 않는 DB 환경에서 다른 Transaction에서 Data 갱신을 위해서 Exclusive Lock을 획득하고 있는 경우, SELECT Query로는 Data 읽기가 가능하지만 SELECT FOR UPDATE Query의 경우에는 다른 Transaction에서 Exclusive Lock을 놓을때까지 대기하다가 읽기 동작을 수행한다. 

또한 SELECT FOR UPDATE Query가 수행되면 해당 Transaction이 종료되기 전까지 획득한 Exclusive Row Lock을 놓지 않기 때문에 다른 Transaction에서 해당 Row들을 갱신할 수 없다. 따라서 SELECT FOR UPDATE Query는 다수의 Transaction 수행 사이에서도 정합성이 보장된 Data를 얻어야 할 경우 이용한다.

DB의 종류 및 DB의 Isolation Level에 따라서 SELECT FOR UPDATE Query가 불필요하며 SELECT Query만 이용해도 되는 경우가 있다. 예를 들어 MySQL의 가장 높은 DB Isolation Level인 Serializable를 이용한다면 모든 SELECT Query에서도 Exclusive Table Lock을 잡고 읽기 동작을 수행하기 때문에 SELECT FOR UPDATE Query를 이용하지 않고 SELECT Query를 이용해도 정합성이 보장된 Data를 읽을 수 있다. 하지만 DB의 종류 및 DB의 Isolation Level에 의존성이 발생하기 때문에 어느 환경에서도 정합성이 보장된 Data를 얻어야할 경우에는 SELECT FOR UPDATE Query를 명시적으로 이용해야한다.

### 2. 참조

* [https://stackoverflow.com/questions/33784779/whats-the-use-of-select-for-update-when-using-repeatable-read-isolation](https://stackoverflow.com/questions/33784779/whats-the-use-of-select-for-update-when-using-repeatable-read-isolation)
* [https://stackoverflow.com/questions/33784779/whats-the-use-of-select-for-update-when-using-repeatable-read-isolation](https://stackoverflow.com/questions/33784779/whats-the-use-of-select-for-update-when-using-repeatable-read-isolation)