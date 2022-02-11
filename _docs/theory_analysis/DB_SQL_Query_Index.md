---
title: DB SQL Query with Index
category: Theory, Analysis
date: 2022-02-07T12:00:00Z
lastmod: 2022-02-07T12:00:00Z
comment: true
adsense: true
---

Index를 활용하는 SQL Query를 정리한다.

### 1. Where

{% highlight sql %}
WHERE state = 'NC'
WHERE state >= 'NC'
WHERE state < 'NC'
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 1] Where 단일 조건문</figcaption>
</figure>

Index를 이용하면 WHERE 조건문을 이용하는 SQL Query의 성능을 향상 시킬 수 있다. [Query 1]은 WHERE 조건문의 예제를 나타내고 있다. 동일한 값을 찾을때 뿐만 아니라, 크거나 작은 값을 찾을때도 Index를 이용한다.

{% highlight sql %}
WHERE state = 'NC' AND fruit >= 'Apple' AND fruit < 'Lemon'
WHERE state > 'NC' AND fruit >= 'Apple' AND fruit < 'Lemon'
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 2] Where 복수 조건문</figcaption>
</figure>

WHERE 조건문에 AND로 여러가지 조건이 추가되는 경우 조건의 범위가 가장 작은 Index를 참조해서 Query를 수행한다. Fruit Field의 Index와 State Field의 Index가 각각 존재할때 [Query 2]의 첫번째 Query는 State Field의 Index를 참조한다. State Field의 범위가 'NC'로 정해져 있기 때문이다. 두번째 Query는 Fruit Field의 Index를 참조한다. State Field의 범위는 최소값만 정해져 있지만 Fruit Field의 범위는 최소값, 최대값 둘다 정해져 있기 때문이다.

### 2. Concatenated Index (결합인덱스)

![[그림 1] DB Table]({{site.baseurl}}/images/theory_analysis/DB_SQL_Query_Index/DB_Table.PNG){: width="300px"}

[그림 1]은 설명을 위한 가상의 Table을 나타내고 있다. 현재 대부분의 DB에서는 하나의 Field가 아니라 여러개의 Field를 결합하여 Index를 생성하는 기능을 지원하고 있다. 이러한 Index를 **Concatenated Index(결합인덱스)**라고 한다. Concatenated Index 생성시 Field 결합 순서는 매우 중요하다. Field의 결합 순서대로 Record의 값을 붙여 Index를 생성하기 때문이다. [그림 1]에서 Fruit, State Field 순으로 Index를 생성하면 Index에는 OrangeFL값이 들어가고, State, Fruit 순으로 Index를 생성하면 Index에는 FLOrange값이 들어가게 된다.

{% highlight sql %}
SELECT * FROM fruit_info WHERE fruit = 'Lemon' AND state = 'NC'
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 3] Select, Where 복수 조건문</figcaption>
</figure>

[Query 3]을 Fruit, State Field 순으로 생성한 Index를 이용하는 경우 Index를 완전히 활용하여 Record를 빠르게 찾을 수 있다. 하지만 State, Fruit Field 순으로 생성한 Index를 이용하는 경우 Index의 앞부분인 State Field부분은 이용할 수 있지만 Index의 뒷부분인 Fruit 부분은 이용하지 못한다. 이와 같이 Concatenated Index의 Field 순서와 WHERE 조건문에 따라서 순서에 따라 SQL 성능이 달라진다. 또한 Concatenated Index의 첫번째 Field는 다양한 WHERE 조건문에서 이용 가능하다.

### 3. Join

{% highlight sql %}
SELECT * FROM dept, emp WHERE dept.id = emp.dept_id
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 4] Join</figcaption>
</figure>

Index를 이용하면 Join Query의 성능을 향상 시킬 수 있다. DB는 [Query 4]의 Query를 실행 할 때 dept Table의 record를 하나 선택한 다음 dept.dept_id를 확인한다. 그 후 emp Table를 뒤져 dept.id와 값이 같은 emp.dept_id를 갖는 record를 찾아 Join을 수행한다. 그리고 DB는 dept Table의 다음 record를 선택한뒤 동일 과정을 반복한다.

DB는 [Query 4]의 수행 과정에서 dept.id 값을 emp Table의 dept_ip Field안에서 찾기 위해 emp Table을 모두 뒤져보는 동작을 반복 수행하게 된다. emp.dept_id에 대한 Index를 생성해 놓으면 DB는 Index를 이용해 emp Table 전체를 뒤지지 않아도 되기 때문에 성능 향상으로 이어진다.

### 4. 참조

* [https://www.progress.com/tutorials/odbc/using-indexes](https://www.progress.com/tutorials/odbc/using-indexes)