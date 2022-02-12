---
title: DB Primary Key
category: Theory, Analysis
date: 2022-02-11T12:00:00Z
lastmod: 2022-02-11T12:00:00Z
comment: true
adsense: true
---

DB의 Primary Key를 분석한다.

### 1. Primary Key

Primary Key는 Table에 존재하는 각 Record들의 식별자 역활을 수행한다. 따라서 하나의 Table 내부에서 Primary Key 값은 반드시 유일해야 한다. 일반적으로 DB는 Transaction 처리중 Primary Key가 중복되는 경우 해당 Transaction을 취소하여 Primary Key의 유일성을 보장해준다. Record는 Primary Key를 기준으로 정렬되며 Disk에 저장된다. 정렬은 **B+ Tree**를 이용한다. 이러한 B+ Tree는 Record가 저장되는 Disk의 위치를 결정하기 때문에 **Clustered Index**라고 명칭된다.

#### 1.1. Auto Increment vs Random

Primary Key는 일반적으로 Record가 생성될때 마다 하나씩 증가시켜 저장하는 **Auto Increment** 방식과 중복이 거의 발생하지 않는 Random 값을 이용하는 방식 두가지를 이용한다. Random 값으로는 일반적으로 UUID를 이용한다.

Record Insert 과정은 Primary Key가 일정하게 증가하는 Auto Increment 방식이 Random 방식에 비해서 더 좋은 **성능**을 보여준다. 이유는 Record 정렬이 B+ Tree 기반이라는 점과 DB가 Disk의 Cache로 이용하는 Memory Buffer 때문이다. Primary Key가 Auto Increment 방식을 통해서 하나씩 증가하면서 저장될 경우 B+ Tree에 의해서 Record는 Disk의 동일한 Page에 반복해서 추가될 확률이 높다. 즉 DB가 이용하는 Memory Buffer에 추가되는 Record들을 저장했다가 한번에 Disk에 반영이 가능하다.

반면 Primary Key가 Random 방식의 경우에는 B+ Tree에 의해서 추가되는 Record가 Disk의 동일한 Page가 아닌 각각 다른 Page에 저장될 확률이 높다. 이 경우 DB의 Memory Buffer 활용성이 떨어지고 자주 Memory Buffer Flush가 발생하여 Insert 성능이 떨어진다.

Read 성능의 경우에도 Auto Increment 방식이 Random 방식에 비해서 Primary Key의 크기가 작기 때문에 더 좋은 성능을 보여준다. Auto Increment 방식은 Primary Key로 대부분 Integer Type을 이용한다. 즉 4Byte만을 이용하여 Primary Key를 저장할 수 있다. 반면에 Random 값은 Primary Key의 크기가 커야 충돌 발생을 방지할수 있기 때문에 Integer Type을 이용하지 못한다. Random 값으로 가장 많이 이용되는 UUID의 경우에도 최소 16Byte의 용량이 필요하다.

반면 Random 방식은 Auto Increment 방식에 비해서 높은 **유연성**이 가장 큰 장점이다. Random 방식의 경우 각 Record의 Primary Key의 고유성이 특정 Table 내부에 한정되지 않고 Global 범위에서도 유효하다는 특정이 있다. 이러한 특징 때문에  Record를 다른 DB/Table에 Migration을 수행할때 Primary Key를 변경할 필요없이 그대로 Migration을 수행할 수 있다.

### 2. 참조

* [https://www.percona.com/blog/2019/11/22/uuids-are-popular-but-bad-for-performance-lets-discuss/](https://www.percona.com/blog/2019/11/22/uuids-are-popular-but-bad-for-performance-lets-discuss/)
