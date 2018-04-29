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

![]({{site.baseurl}}/images/theory_analysis/DB_Indexing/DB_Indexing.PNG){: width="600px"}

DB Indexing 기법은 단어 그대로 Index(색인)를 생성하여 DB의 성능을 높이는 기법이다. 위의 그림은 DB Indexing 기법을 간략하게 나타내고 있다. 오른쪽 표는 DB Table을 나타내고 있고, 왼쪽 표는 생성한 Index를 나타내고 있다. Index는 State Field의 Record값을 **정렬**한 후 해당 Record값의 **위치**를 저장하고 있다.

{% highlight SQL %}
SELECT * FROM Fruit_Info WHERE State = 'NC'
{% endhighlight %}

DB는 생성한 Index를 이용하여 특정 SQL Query의 성능을 높일 수 있다. 위의 Query를 수행한다고 할 경우 Index가 없으면 DB는 Fruit_Info Table의 모든 Record 값을 읽은 다음 State Field 값이 'NC'인지 확인해야 한다. 하지만 Index가 있으면 Binary Search 같은 **탐색** 알고리즘을 이용할 수 있기 때문에 모든 Record 값을 읽을 필요없이 'NC' 값을 가지고 있는 Record를 빠르게 찾을 수 있다.

반대로 Index가 있으면 Record 삽입이나 변경시 Index도 변경되야 하기 때문에 **Overhead**가 발생한다. 따라서 Index는 Schema와 SQL Query에 따라 적절하게 적용해야 한다. 참고로 DB는 기본적으로 Primary Key Field에 대해서 Index를 생성하고 관리한다. 나머지 User가 정의한 Field의 Index는 DDL(Data Definition Language)를 통해서 생성,삭제가 가능하다.

실제 DB에서는 Harddisk의 물리적 특성을 고려하여 설계된 자료구조인 **B+ Tree**를 이용하여 Index를 생성, 탐색, 삽입 연산을 수행한다.

#### 1.1. Where

{% highlight SQL %}
WHERE State = 'NC'
WHERE State >= 'NC'
WHERE State < 'NC'
{% endhighlight %}

Index를 이용하여 WHERE 조건문을 이용하는 Query의 성능을 향상 시킬 수 있다. State Field의 Index가 존재 할 때 위의 Where 조건문 처럼 같은 값뿐만 아니라 크거나 작은 값을 찾을때에도 이용 가능하다.

{% highlight SQL %}
WHERE State = 'NC' AND Fruit >= 'Apple' AND Fruit < 'Lemon'
WHERE State > 'NC' AND Fruit >= 'Apple' AND Fruit < 'Lemon'
{% endhighlight %}

WHERE 조건문에 AND로 여러가지 조건이 추가되는 경우 조건의 범위가 가장 작은 Index를 참조해서 Query를 수행한다. State Field의 Index와 State Field의 Index가 각각 존재할때 위의 첫번째 Query는 State Field의 Index를 참조한다. State Field의 범위가 'NC'로 정해져 있기 때문이다.
두번째 Query는 Fruit Field의 Index를 참조한다. State Field의 범위는 최소값만 정해져 있지만 Fruit Field의 범위는 최소값, 최대값 둘다 정해져 있기 때문이다.

#### 1.2. Join

{% highlight SQL %}
SELECT * FROM dept, emp WHERE dept.dept_id = emp.dept
{% endhighlight %}

Index를 이용하여 Join Query의 성능을 향상 시킬 수 있다. DB는 위의 SQL를 실행 할 때 dept Table의 record를 하나 선택한 다음 dept.dept_id를 확인한다. 그 후 emp Table를 뒤져 dept.dept_id와 값이 같은 emp.dept를 갖는 record를 찾아 Join을 수행한다. 그리고 DB는 dept Table의 다음 record를 선택한뒤 동일 과정을 반복한다.

위의 과정에서 dept.dept_id 값을 emp Table안에서 찾기 위해 emp Table을 모두 뒤져보는 동작을 반복 수행하게 된다. emp.dept에 대한 Index를 생성해 놓으면 DB는 Index를 이용해 emp Table 전체를 뒤지지 않아도 되기 때문에 성능 향상으로 이어진다.

#### 1.3. Concatenated Index (결합인덱스)

현재 대부분의 DB에서는 하나의 Field가 아니라 여러개의 Field를 결합하여 Index를 생성하는 기능을 지원하고 있다. 이러한 Index를 **Concatenated Index(결합인덱스)**라고 한다.  Concatenated Index 생성시 Field 결합 순서는 매우 중요하다. Field의 결합 순서대로 Record의 값을 붙여 Index를 생성하기 때문이다. 위의 그림 예제에서 Fruit, State Field 순으로 Index를 생성하면 Index에는 OrangeFL값이 들어가고, State, Fruit 순으로 Index를 생성하면 Index에는 FLOrange값이 들어가게 된다.

{% highlight SQL %}
SELECT * FROM Fruit_Info WHERE Fruit = 'Lemon' AND State = 'NC'
{% endhighlight %}

위의 Query를 Fruit, State Field 순으로 생성한 Index를 이용하는 경우 Index를 완전히 활용하여 Record를 빠르게 찾을 수 있다. 하지만 State, Fruit Field 순으로 생성한 Index를 이용하는 경우 Index의 앞부분인 State Field부분은 이용할 수 있지만 Index의 뒷부분인 Fruit 부분은 이용하지 못한다. 이와 같이 Concatenated Index의 Field 순서와 WHERE 조건문에 따라서 순서에 따라 SQL 성능이 달라진다. 또한 Concatenated Index의 첫번째 Field는 다양한 WHERE 조건문에서 이용 가능하다.

### 2. 참조

* [https://www.progress.com/tutorials/odbc/using-indexes](https://www.progress.com/tutorials/odbc/using-indexes)
