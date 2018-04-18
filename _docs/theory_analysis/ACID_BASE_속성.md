---
title: ACID, BASE 속성
category: Theory, Analysis
date: 2018-04-18T12:00:00Z
lastmod: 2018-04-18T12:00:00Z
comment: true
adsense: true
---

ACID, BASE 속성을 정리한다.

### 1. ACID

Database Transaction의 4가지 속성을 나타내는 용어이다.

* Atomicity - 외부에서 Transaction의 상태는 **성공/실패** 2가지의 상태만 확인 할 수 있는 특징을 의미한다. 즉 외부에서는 Transaction의 중간 과정을 볼 수 없는 없다.

* Consistency - Transaction 수행 전/후 DB의 상태는 일관성을 유지해야 하는 특징을 의미한다.

* Isolation - Transaction은 서로 완전히 독립적으로 실행되야 하는 특징을 의미한다. 즉 여러개의 Transaction이 동시에 실행될때 각 Transaction은 자신 혼자 Transaction을 수행 하는것 처럼 동작해야 된다.

* Durability - Transaction이 수행된 이후 변경 내용은 다음 Transaction이 수행되기 전까지 보장되어야 한다.

### 2. BASE

분산시스템에서는 성능과 가용성을 위해서 ACID대신 BASE 속성을 고려하여 설계된다.

* Basically Available - 가용성 보장을 의미한다. 즉 분산시스템은 언제나 요청에 응답 할 수 있어야 한다는 의미이다. 하지만 언제나 응답 성공을 보장해주지는 않는다.

* Soft-State - 분산시스템의 상태는 User가 별도로 유지하지 않으면 언제든지 변경 될 수 있는걸 의미한다. 즉 분산시스템의 상태는 외부의 요청이 없더라도 언제든지 바뀔 수 있다는 의미이다.

* Eventually Consistent - 일시적으로 일관성이 깨질수는 있지만 최종적으로는 일관성을 유지하는 특징을 의미한다. Update된 Data가 다른 Node들에게 전달되기 전까지 일시적으로 일관성이 깨지지만, 특정 시간이 지난후에 모든 Node들이 Update되면 다시 일관성을 유지 할 수 있게 된다.

### 3. 참조
* [https://en.wikipedia.org/wiki/ACID](https://en.wikipedia.org/wiki/ACID)
* [http://atin.tistory.com/624](http://atin.tistory.com/624)
* [https://stackoverflow.com/questions/4851242/what-does-soft-state-in-base-mean](https://stackoverflow.com/questions/4851242/what-does-soft-state-in-base-mean)
