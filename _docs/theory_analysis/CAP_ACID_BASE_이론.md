---
title: CAP, ACID, BASE 이론
category: Theory, Analysis
date: 2018-04-18T12:00:00Z
lastmod: 2018-04-18T12:00:00Z
comment: true
adsense: true
---

CAP, ACID, BASE 이론을 정리한다.

### 1. CAP

CAP 이론은 분산 시스템이 Consistency, Availability, Partition-tolerance 3가지 속성을 모두 충족시킬 수 없다는 이론을 의미한다.

* Consistency - 분산 시스템을 이루는 다수의 Node로부터 동일한 응답을 얻을 수 있어야 하는 속성을 의미한다.

* Availability - 분산 시스템을 이루는 특정 Node에 장애가 발생하더라도 분산 시스템이 동작해야하는 속성을 의미한다.

* Partition-tolerance - Network 장애로 인하여 Node 사이의 통신이 불가능하여도 분산 시스템이 동작해야 한다는 속성을 의미한다.

Consistency와 Partition-tolerance를 고려하여 설계된 분산 시스템을 **CP 시스템**이라고 한다. CP 시스템에서는 Node의 장애로 인하여 Node 사이의 Consistency가 맞지 않으면, Consistency가 맞을때까지 동작이 멈추게 된다. 따라서 Availability 속성을 충족시키지 못하게 된다. Availability와 Partition-tolerance를 고려하여 설계된 분산 시스템을 **AP 시스템**이라고 한다. AP 시스템에서는 Node의 장애로 인하여 Node 사이의 Consistency가 맞지 않아도 동작한다. 따라서 Consistency 속성을 충족시키지 못한다.

Consistency와 Availability를 고려하여 설계된 분산 시스템을 CP 시스템이라고 한다. Network 장애를 고려하지 않은 분산 시스템을 의미하지만, 실제로 Network 장애가 발생하지 않는 분산 시스템은 없기 때문에 실제 존재하는 CP 시스템은 없다라고 보는것이 맞다. 단일 Node에서 동작하는 시스템은 Network 장애가 발생하지 않기 때문에 일반적으로 CP 시스템으로 분류한다.

### 2. ACID

Database Transaction의 4가지 속성을 나타내는 용어이다. CAP 이론의 CP 시스템 속성과 유사하다.

* Atomicity - 외부에서 Transaction의 상태는 **성공/실패** 2가지의 상태만 확인 할 수 있는 특징을 의미한다. 즉 외부에서는 Transaction의 중간 과정을 볼 수 없는 없다.

* Consistency - Transaction 수행 전/후 DB의 상태는 **모순** 없이 일관성을 유지해야 하는 특징을 의미한다. 여기서 일관성은 법칙 또는 규칙을 의미한다. A 계좌에서 B 계좌로 송금하는 경우 A 계좌와 B 계좌의 잔액 총합은 Transaction 전/후 동일해야 한다. Table의 Column으로 FK(Foreign Key)를 갖는 경우 Transaction 수행 전/후 FK 규칙은 유지되어야 한다.

* Isolation - Transaction은 서로 완전히 독립적으로 실행되야 하는 특징을 의미한다. 즉 여러개의 Transaction이 동시에 실행될때 각 Transaction은 자신 혼자 Transaction을 수행 하는것 처럼 동작해야 된다.

* Durability - Transaction이 수행된 이후 변경 내용은 다음 Transaction이 수행되기 전까지 보장되어야 한다.

### 3. BASE

분산시스템에서는 성능과 가용성을 위해서 ACID대신 BASE 속성을 고려하여 설계된다. CAP 이론의 AP 시스템 속성과 유사하다.

* Basically Available - 가용성 보장을 의미한다. 즉 분산시스템은 언제나 요청에 응답 할 수 있어야 한다는 의미이다. 하지만 언제나 올바른 응답을 보장해주지는 않는다.

* Soft-State - 분산시스템의 상태는 User가 별도로 유지하지 않으면 언제든지 변경 될 수 있는걸 의미한다. 즉 분산시스템의 상태는 외부의 요청이 없더라도 언제든지 바뀔 수 있다는 의미이다.

* Eventually Consistent - 일시적으로 일관성이 깨질수는 있지만 최종적으로는 일관성을 유지하는 특징을 의미한다. Update된 Data가 다른 Node들에게 전달되기 전까지 일시적으로 일관성이 깨지지만, 특정 시간이 지난후에 모든 Node들이 Update되면 다시 일관성을 유지 할 수 있게 된다.

### 4. 참조

* [http://blog.thislongrun.com/2015/04/the-unclear-cp-vs-ca-case-in-cap.html](http://blog.thislongrun.com/2015/04/the-unclear-cp-vs-ca-case-in-cap.html)
* [https://bravenewgeek.com/cap-and-the-illusion-of-choice/](https://bravenewgeek.com/cap-and-the-illusion-of-choice/)
* [https://dba.stackexchange.com/questions/18435/cap-theorem-vs-base-nosql](https://dba.stackexchange.com/questions/18435/cap-theorem-vs-base-nosql)
* [https://stackoverflow.com/questions/4851242/what-does-soft-state-in-base-mean](https://stackoverflow.com/questions/4851242/what-does-soft-state-in-base-mean)
