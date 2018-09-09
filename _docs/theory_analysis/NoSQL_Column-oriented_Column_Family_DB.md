---
title: NoSQL Column-oriented, Column Family DB
category: Theory, Analysis
date: 2018-09-07T12:00:00Z
lastmod: 2018-09-07T12:00:00Z
comment: true
adsense: true
---

NoSQL DB인 Column-oriented DB와 Column Family DB를 분석한다.

### 1. Column-oriented DB

![]({{site.baseurl}}/images/theory_analysis/NoSQL_Column-oriented_Column_Family_DB/Column-oriented_DB.PNG)

Column-oriented는 Data Table을 Column 단위로 쪼개어 저장하는 DB를 의미한다. 위의 그림은 일반적인 RDBMS에서 이용하는 Row-oriented 기법과 Column-oriented 기법을 비교하는 그림이다. Row-oriented는 하나의 Row가 하나의 Disk Block안에 저장되지만, Column-oriented 방식은 하나의 Column이 하나의 Disk Block안에 저장된다.

위의 예제에서 Gender가 Male인 사람이 몇명인지 구하는 동작을 DB가 수행 할 경우, Row-oriented 방식은 4개의 Block을 읽고 안의 Gender값을 알아내어 Sum을 수행해야 한다. 반면 Column-oriented는 1개의 Block만 읽고 결과를 구할 수 있기 때문에 빠른 처리가 가능하다. 이처럼 Data를 분석하는 동작의 경우 Data Table에서 모든 Column이 필요한 것이 아니라 일부 Column이 필요한 경우가 대부분이다. 따라서 Column-oriented DB는 OLAP(Online Analytical Processing) 처리에 유리하다. 반대로 하나의 Row를 추가하거나 삭제하는 경우 Row-oriented DB는 1개의 Block만 이용하면 되지만 Column-oriented는 4개의 Block을 이용해야 하기 때문에, Column-oriented DB는 OTLP(Online transaction processing) 처리에 불리하다.

Column-oriented DB는 Data를 쉽게 Compression 할 수 있다. 위의 예제에서 Column-oriented 기법의 Gender가 저장되어 있는 Block의 Data는 Male또는 Female만 존재한다. Block에 저장된 Data가 중복되는 경우가 많기 때문에 쉽게 Data를 Compression 할 수 있다. 예를들어 Male과 Female을 특정 ID로 Mapping 하고, Mapping된 ID를 Block에 저장하면 적은 용량으로 Data를 저장 할 수 있다.

### 2. Column Family DB

![]({{site.baseurl}}/images/theory_analysis/NoSQL_Column-oriented_Column_Family_DB/Column-Family_DB.PNG)

Column Family DB는 Column을 나타내는 Column Key/Data/Timestamp Tuple을 Row를 나타내는 Row Key에 Mapping하여 Data Table을 표현하는 DB이다. RDBMS에서 NULL값도 Disk Block 공간을 차지하지만 Column Family DB에서는 Row별로 자유로운 Column 추가/삭제가 가능하기 때문에 NULL값을 위한 Column이 별도로 필요없다.

일반적으로 Column-oriented DB와 Column Family DB가 혼용되어 사용되어 Column Family DB가 Column-oriented DB라고 간주하는 경우가 많다. 하지만 Column Family DB가 Column-oriented DB라고 할 수는 없다. Column Family DB인 HBASE는 Column의 집합인 Column Family 단위로 Disk Block에 저장되기 때문에 Column-oriented DB로 분류된다. 하지만 또 하나의 Column Family DB인 Cassandra는 Row 단위로 Disk Block에 저장되기 때문에 Column-oriented DB라고 할 수 없다.

### 3. 참조

* [https://en.wikipedia.org/wiki/Column-oriented_DBMS](https://en.wikipedia.org/wiki/Column-oriented_DBMS)
* [https://en.wikipedia.org/wiki/Column_family](https://en.wikipedia.org/wiki/Column_family)
* [https://database.guide/what-is-a-column-store-database/](https://database.guide/what-is-a-column-store-database/)
* [https://stackoverflow.com/questions/13010225/why-many-refer-to-cassandra-as-a-column-oriented-database](https://stackoverflow.com/questions/13010225/why-many-refer-to-cassandra-as-a-column-oriented-database)
* [https://www.scnsoft.com/blog/cassandra-vs-hbase](https://www.scnsoft.com/blog/cassandra-vs-hbase)
