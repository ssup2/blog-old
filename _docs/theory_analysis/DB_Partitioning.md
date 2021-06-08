---
title: DB Partitioning
category: Theory, Analysis
date: 2021-06-06T12:00:00Z
lastmod: 2021-06-06T12:00:00Z
comment: true
adsense: true
---

DB의 Partitioning, Sharding을 분석한다.

### 1. DB Partitioning

![[그림 1] DB Partitioning]({{site.baseurl}}/images/theory_analysis/DB_Partitioning/DB_Partitioning.PNG)

Partitioning은 성능, 가용성, 유지 보수의 용이성을 위해서 하나의 Table을 여러개의 Table로 분리하는 기법이다. Table이 분리 되는 만큼 Table의 Data도 별도의 Disk 공간으로 분리가 된다. Partitioning은 **Vertical Partitioning**과 **Horizontal Paritioning**이 존재한다. [그림 1]은 Vertical Partitioning과 Horizontal Paritioning을 나타내고 있다.

#### 1.1. Vertical Partitioning

Vertical Partitioning은 Table을 수직으로 분리하는 기법이다. Data Read가 일부 Column에서만 자주 발생한다면, 자주 Read가 발생하는 Column만 별도의 Table로 분류하여 Read 성능을 높일 수 있다. DB를 다수의 Instance로 구성하여도 Vertical Partitioning을 통해서는 다수의 DB Instance를 제대로 활용하지 못한다.

#### 1.2. Horizontal Paritioning

Horizontal Paritioning은 Table을 수평으로 분리하는 기법이다. 단일 DB Instance에서 수행하는 Horizontal Paritioning은 적용하여도 큰 성능적 이점을 얻기 힘들다. 하지만 다수의 DB Instance에게 수평으로 분리한 Table을 분산하면 다수의 DB Instance의 성능을 많이 활용할 수 있는 장점을 갖고 있다. Query를 다수의 DB Instance로 분리하여 처리할 수 있기 때문이다.

일반적으로 **DB Sharding**은 Horizontal Paritioning을 통해서 Table을 수평으로 분리하고, 분리한 Table을 다수의 DB Instance에 분리하여 저장하는 기법을 의미한다. Horizontal Paritioning은 Table을 수평으로 분리하는 Algorithm에 따라서 **Hash**, **Range**, **List** 방법이 존재한다.

##### 1.2.1. Hash

![[그림 2] Horizontal Partitioning Hash]({{site.baseurl}}/images/theory_analysis/DB_Partitioning/DB_Partitioning_Hash.PNG){: width="500px"}

[그림 2]는 Modular 연산 기반의 Hash Algorithm을 이용하는 Horizontal Partitioning을 나타내고 있다. [그림 2]에서는 Fruit ID를 Hash Key로 이용하고 있지만 다른 Column을 Hash Key로 이용할 수도 있다. Hash Algorithm의 균일한 Data 분배가 가능하다는 장점이 있다. 반면에 Table을 저장하는 DB Instance가 추가/제거시 대부분의 Data를 재정렬 해야하는 단점을 가지고 있다.

##### 1.2.2. Range

![[그림 3] Horizontal Partitioning Range]({{site.baseurl}}/images/theory_analysis/DB_Partitioning/DB_Partitioning_List.PNG){: width="500px"}

[그림 3]은 Range Algorithm을 이용하는 Horizontal Partitioning을 나타내고 있다. 각 DB Instance에 들어갈 수 있는 Fruit ID의 범위가 지정되어 있는것을 확인할 수 있다. [그림 3]에서는 Fruit ID를 이용하여 범위를 지정하고 있지만 다른 Column을 이용하여 범위를 지정할 수도 있다. Table을 저장하는 DB Instance가 추가/제거시 Range의 설정에 따라서 Data의 재정렬을 최소화 할 수 있는 장점을 가지고 있지만, Data에 따라서 Data가 제대로 분배되지 않을 수 있는 단점을 가지고 있다.

##### 1.2.3. List

![[그림 4] Horizontal Partitioning List]({{site.baseurl}}/images/theory_analysis/DB_Partitioning/DB_Partitioning_Range.PNG){: width="500px"}

[그림 4]는 List Algorithm을 이용하는 Horizontal Partitioning을 나타내고 있다. 각 DB Instance에 들어갈 수 있는 Fruit ID가 나열되어 있는것을 확인할 수 있다. [그림 4]에서는 Fruit ID를 나열하고 있지만 다른 Column의 값을 나열할 수도 있다. Range Algorithm와 동일한 장단점을 가지고 있다.

### 2. 참조

* [https://www.digitalocean.com/community/tutorials/understanding-database-sharding](https://www.digitalocean.com/community/tutorials/understanding-database-sharding)
* [https://blog.yugabyte.com/how-data-sharding-works-in-a-distributed-sql-database/](https://blog.yugabyte.com/how-data-sharding-works-in-a-distributed-sql-database/)
* [https://hazelcast.com/glossary/sharding/](https://hazelcast.com/glossary/sharding/)
* [https://hevodata.com/learn/understanding-mysql-sharding-simplified/](https://hevodata.com/learn/understanding-mysql-sharding-simplified/)
* [https://devopedia.org/database-sharding](https://devopedia.org/database-sharding)
* [https://woowabros.github.io/experience/2020/07/06/db-sharding.html](https://woowabros.github.io/experience/2020/07/06/db-sharding.html)
* [https://soye0n.tistory.com/267](https://soye0n.tistory.com/267)
* [http://theeye.pe.kr/archives/1917](http://theeye.pe.kr/archives/1917)
