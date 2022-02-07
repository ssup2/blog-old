---
title: DB Indexing
category: Theory, Analysis
date: 2018-01-02T12:00:00Z
lastmod: 2017-01-02T12:00:00Z
comment: true
adsense: true
---

DB의 Indexing 기법을 분석한다.

### 1. DB Indexing

![[그림 1] DB Indexing]({{site.baseurl}}/images/theory_analysis/DB_Indexing/DB_Indexing.PNG){: width="500px"}

DB Indexing 기법은 단어 그대로 Index(색인)를 생성하여 DB의 성능을 높이는 기법이다. [그림 1]은 DB Indexing 기법을 간략하게 나타내고 있다. 오른쪽 표는 DB Table을 나타내고 있고, 왼쪽 표는 State Column을 기반으로 하는 Index를 나타내고 있다. Index는 State Column의 Record 값을 **정렬**한 후 해당 Record 값의 **ID**를 저장하고 있다.

{% highlight sql %}
SELECT * FROM Fruit_Info WHERE State = 'NC'
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 1] Select, Where 단일 조건문</figcaption>
</figure>

DB는 생성한 Index를 이용하여 특정 SQL Query의 성능을 높일 수 있다. [Query 1]을 수행한다고 할 경우 Index가 없으면 DB는 Fruit_Info Table의 모든 Record 값을 읽으면서 State Field 값이 'NC'인지 확인해야 한다. 즉 Table Full Scan이 발생한다. 하지만 Index가 있으면 Binary Search 같은 **탐색** 알고리즘을 이용할 수 있기 때문에 모든 Record 값을 읽을 필요없이 'NC' 값을 가지고 있는 Record를 빠르게 찾을 수 있다.

반대로 Index가 있으면 Record 삽입이나 변경시 Index도 변경되야 하기 때문에 **Overhead**가 발생한다. 따라서 Index를 무조건 많이 생성하는거시 아니라, Schema와 SQL Query에 따라 적절하게 적용해야 한다. 참고로 DB는 기본적으로 Primary Key Field에 대해서 Index를 생성하고 관리한다. 나머지 User가 정의한 Field의 Index는 DDL(Data Definition Language)를 통해서 생성, 삭제가 가능하다.

### 2. Index Type

![[그림 2] DB Indexing]({{site.baseurl}}/images/theory_analysis/DB_Indexing/Clustered_Non-clustered_Index.PNG){: width="800px"}

Index는 성격과 특징에 따라서 Clustered Index와 Non-clustered Index로 구분할 수 있다. 두 Index 모두 일반적으로 Disk의 물리적 특성을 고려하여 설계된 자료구조인 **B+ Tree**를 이용하여 Index를 관리하고 검색한다. [그림 2]는 [그림 1]을 기반으로 Cluster Index와 Non-clustred Index를 나타내고 있다. 아랫 부분은 Clustered Index를 나타내고 있고, 윗 부분은 Non-clustered Index를 나타내고 있다. [그림 2]에서 Clustred, Non-clustered Index 모두 Depth가 깊지 않지만, Index의 크기가 증가하면 B+ Tree 자료구조에 의해서 Index의 Depth도 깊어진다.

Clustered Index는 Diks에 저장되는 실제 Record를 기반으로 작성된 Index이다. 따라서 Clustred Index 이용하면 바로 Record에 접근할 수 있다는 장점을 가지고 있다. 반면 Record에서 Clustered Index를 생성한 Field가 변경될 경우 Clustered Index도 같이 변경되어야 하기 때문에 Record 변경에 큰 Overhead가 발생하는 단점도 가지고 있다. 실제 Record를 기반으로 작성되기 때문에 하나의 Table당 하나의 Clustered Index만 존재할 수 있다는 특징도 갖는다.

[그림 2]에서 빨간 화살표는 Clustred Index를 통해서 Record에 접근하는 과정을 나타내고 있다. 하나의 Index 조회를 통해서 바로 Record가 위치하고 있는 Page에 접근이 가능한 것을 확인할 수 있다. Record에 접근할때 가장 많이 이용되고, 거의 변경이 일어나지 않는 Primary Key의 Index를 일반적으로 Clustred Index로 생성한다. [그림 2]에서는 Fruit ID를 Primary Key라고 간주하고 있다. 따라서 Fruit ID를 이용하여 Clustred Index를 생성한 모습을 나타내고 있다.

### 3. 참조

* [https://www.progress.com/tutorials/odbc/using-indexes](https://www.progress.com/tutorials/odbc/using-indexes)
* [https://www.sqlshack.com/what-is-the-difference-between-clustered-and-non-clustered-indexes-in-sql-server/](https://www.sqlshack.com/what-is-the-difference-between-clustered-and-non-clustered-indexes-in-sql-server/)
* [https://velog.io/@gillog/SQL-Clustered-Index-Non-Clustered-Index](https://velog.io/@gillog/SQL-Clustered-Index-Non-Clustered-Index)
* [https://dev-navill.tistory.com/26](https://dev-navill.tistory.com/26)
