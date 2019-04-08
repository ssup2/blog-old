---
title: NoSQL Key-value DB
category: Theory, Analysis
date: 2018-08-25T12:00:00Z
lastmod: 2018-08-25T12:00:00Z
comment: true
adsense: true
---

NoSQL DB중 하나인 Key-value DB를 분석한다.

### 1. Key-value DB

![[그림 1] NoSQL Key-value DB]({{site.baseurl}}/images/theory_analysis/NoSQL_Key-value_DB/NoSQL_Key-value.PNG){: width="300px"}

Key-value 의미 그대로 Key/Value 관계를 갖는 Data를 저장하는 관리하는 DB이다. Key 값은 Binary Sequence를 이용하기 때문에 정수, 문자열 같은 Primitive Type부터 Image File까지 다양한 Data들을 Key로 이용 할 수 있지만, 반드시 **Unique** 해야하는 특징을 갖고있다. Key-value DB는 Key가 Unique한 것을 보장해야 하기 때문에 Key/Value Data가 추가될 때마다 Key 비교 연산을 수행하게 된다. Key값이 길어 질수록 Key 비교 연산 Overhead가 커지기 때문에 Key-value DB 성능을 높이기 위해서는 가능한 짧은 Binary Sequence를 이용하는 것이 좋다.

Value 값은 기본적으로 정수나 문자열같은 Primitive Type을 지원하지만 DB에 따라서 List, Hash같은 자료구조 Type을 제공하기도 한다. Memcached는 String Type의 Value만을 제공하지만 Redis는 String Type뿐만 아니라 List, Set, Hash같은 자료구조 Type을 제공한다.

Key-value DB는 Key를 Unique한 Key를 기준으로 Key/Value Data의 CRUD 기능만 제공 할 뿐, Key 사이의 관계(Relation) 정보는 저장하지 않는다. 이러한 단순한 기능 때문에 Key-value DB는 가장 빠른 CRUD 성능을 보여준다. 또한 Key-value DB는 Schema를 정의할 필요없이 Key/Value Data를 넣기만 하면 되기 때문에 높은 유연성(Flexibility)을 갖고 있고, Key의 Unique 조건을 제외한 Key 사이의 Dependency가 없기 때문에 높은 확장성(Scalability)을 갖고 있다.

### 2. 참조

* [https://database.guide/what-is-a-key-value-database/](https://database.guide/what-is-a-key-value-database/)
