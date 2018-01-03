---
title: Database Indexing
category: Thoery, Analysis
date: 2018-01-02T12:00:00Z
lastmod: 2017-01-02T12:00:00Z
comment: true
adsense: true
---

Database의 Indexing 기법을 분석한다.

### 1. Database Indexing

![]({{site.baseurl}}/images/theory_analysis/Database_Indexing/Database_Indexing.PNG){: width="600px"}

Database Indexing 기법은 단어 그대로 Index(색인)를 생성하여 Database의 성능을 높이는 기법이다. 위의 그림은 Database Indexing 기법을 간략하게 나타내고 있다. 오른쪽 표는 DB Table을 나타내고 있고, 왼쪽 표는 생성한 Index를 나타내고 있다. Index는 State Field의 Record값을 **정렬**한 후 해당 Record값의 **위치**를 저장하고 있다.

~~~
sql> select * from Fruit_Info where State = 'NC'
~~~

Database는 생성한 Index를 이용하여 특정 SQL Query의 성능을 높일 수 있다. 위의 Query를 수행한다고 할 경우 Index가 없으면 Database는 Fruit_Info Table의 모든 Record 값을 읽은 다음 State Field 값이 'NC'인지 확인해야 한다. 하지만 Index가 있으면 Binary Search 같은 **탐색** 알고리즘을 이용할 수 있기 때문에 모든 Record 값을 읽을 필요없이 'NC' 값을 가지고 있는 Record를 빠르게 찾을 수 있다.

반대로 Index가 있으면 Record 삽입시 Index도 변경되야 하기 때문에 **Overhead**가 발생한다. 따라서 Index는 Schema와 SQL Query에 따라 적절하게 적용해야 한다. 참고로 Database는 기본적으로 Primary Key Field에 대해서 Index를 생성하고 관리한다. 나머지 User가 정의한 Field의 Index는 DDL(Data Definition Language)를 통해서 생성,삭제가 가능하다.

실제 Database에서는 Harddisk의 물리적 특성을 고려하여 설계된 자료구조인 **B+ Tree**를 이용하여 Index를 생성, 탐색, 삽입 연산을 수행한다.

#### 1.1. Select

#### 1.2. Join

#### 1.3. Multi Field Index

### 2. 참조

* [https://www.progress.com/tutorials/odbc/using-indexes](https://www.progress.com/tutorials/odbc/using-indexes)
