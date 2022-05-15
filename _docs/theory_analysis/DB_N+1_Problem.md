---
title: DB N+1 문제
category: Theory, Analysis
date: 2022-02-13T12:00:00Z
lastmod: 2022-02-13T12:00:00Z
comment: true
adsense: true
---

DB의 N+1 문제를 정리한다.

### 1. N+1 문제

{% highlight java linenos %}
@Entity
public class School {
    @Id
    private String id;

    private String name;

    @OneToMany(fetch = FetchType.EAGER)
    //@OneToMany(fetch = FetchType.LAZY)
    private List<Student> students;
}

@Entity
public class Student{
    @Id
    private String id;

    private String name;
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] N + 1 Problem Entity</figcaption>
</figure>

N+1 문제는 N개의 Record(Data) 조회시 App 개발자는 한번의 SQL Query가 발생할 것으로 예상하지만, 실제로는 N+1 Query가 발생하여 App 성능에 영향을 주는 문제를 의미한다. 일반적으로 App에서 직접 SQL을 이용하는 경우보다 App에서 ORM(Object Relational Mapping)과 같은 기법을 통해서 SQL Query을 추상화하여 이용하는 경우에 N+1 문제가 발생한다.

[Code 1]은 N+1 문제가 발생할 수 있는 Java Spring Framework (JPA)에서의 Entity 예제를 나타내고 있다. School Entity와 Student Entity가 1:N 관계를 갖고 있는것을 확인할 수 있다. 만약 School Record가 2000인 상태에서 School Entity를 대상으로 "findAll()"을 호출하는 경우 모든 School Record 조회를 위한 SELECT SQL Query 한번과 각 School에 소속되어 있는 Student 조회를 위한 2000번의 SELECT SQL Query가 수행된다. 총 N+1번의 SQL Query가 수행되는 것을 확인 할 수 있다. 이러한 N+1 문제를 해결하는 가장 대표적인 방법은 **Table Join**을 이용하는 방법이 있다. Java Spring Framework에서는 JPQL을 이용하여 Join을 명시할 수 있다.

N+1 문제를 해결하는 다른 방법은 Eager Loading 기법을 이용하는 방법이다. 하지만 Eager Loading 기법은 모든 환경에서 N+1 문제를 해결하는 기법이 아니다. Eager Loading은 특정 시점에 관련 Data를 모두 얻는 기법이지 한번의 Query를 강요하는 기법이 아니기 때문이다. 실제로 Java Spring Framework 환경에서는 Eager Loading 기법을 적용하더라도 다수의 SQL Query를 수행하는 방식이기 때문에 N+1 문제를 해결할 수 없다. 따라서 Eager Loading 기법을 활용하여 N+1 문제를 해결하기 위해서는 이용하는 Framework, ORM에서 SQL을 어떻게 수행하는지 파악하는 과정이 반드시 선행되어야 한다.

### 2. 참조

* [https://incheol-jung.gitbook.io/docs/q-and-a/spring/n+1](https://incheol-jung.gitbook.io/docs/q-and-a/spring/n+1)
* [https://wwlee94.github.io/category/blog/spring-jpa-n+1-query/](https://wwlee94.github.io/category/blog/spring-jpa-n+1-query/)
* [https://thecodingmachine.io/solving-n-plus-1-problem-in-orms](https://thecodingmachine.io/solving-n-plus-1-problem-in-orms)