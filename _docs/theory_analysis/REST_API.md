---
title: REST API
category: Theory, Analysis
date: 2017-03-29T12:00:00Z
lastmod: 2017-03-29T12:00:00Z
comment: true
adsense: true
---

REST(Representational State Transfer) API를 분석한다.

### 1. REST API

REST는 Representational State Transfer의 약자로 **분산 System** 환경에 최적화된 **Architectural Style**이다. REST는 Server와 Client 사이의 표준을 정의하고 있지는 않지만, **Stateless, Uniform Interface** 같은 몇가지 특징을 정의하고 있다. 이러한 REST의 특징에 가장 잘 부합하고 있는 Protocol이 **HTTP**이기 때문에 대부분의 REST API는 HTTP를 이용하고 있다.

#### 1.1. 특징

위에서 언급한 REST의 특징이 REST API에도 그대로 반영되어 나타난다.

##### 1.1.1. Stateless

REST API는 Server와 Client의 State(Context)에 관계 없이 언제나 일관된 동작을 수행한다. 따라서 Server와 Client는 계속 Session을 유지할 필요가 없고 REST API를 이용할 경우에만 잠깐 동안 Session을 유지하면 된다. 또한 Server의 LB(Load Balancing)를 위해서 Server가 여러대 있는 경우, Client는 REST API를 이용 할 때마다 각각 다른 Server와 Session을 맺어도 문제가 없다. Stateless 특징 때문에 Server와 Client의 관계는 유연해진다.

단 Stateless 특징 때문에 Client는 REST API를 호출할때 마다 이전에 Server에게 보냈던 정보도 반복해서 보내야 한다. 이렇게 반복되는 정보는 Encoding 되거나 암호화 되어 **Token**형태로 주고 받는다. 현재 Client의 인증/인가시 Token이 많이 이용되고 있다. Client는 인증/인가 Server로부터 받은 Token을 저장한다. 그 후 Client는 REST API를 호출 할때 마다 해당 Token도 같이 Server에게 보내어 매번 인증/인가 절차를 수행한다. 이처럼 **Client가 Context를 유지하고 관리하는 방식**을 이용하는 것 또한 REST API의 특징이다.

##### 1.1.2. Uniform Interface

REST API는 **URI**를 통해서 **Resource**를 나타내고, **HTTP Method**를 통해 해당 Resource를 대상으로 어떤 **동작**을 수행할지를 결정하는 단순하고도 제한된 Interface를 제공한다. 따라서 REST API는 REST API의 형태만으로도 어떤 동작을 수행하는 API인지 쉽게 파악 할 수 있다는 장점을 갖는다.

#### 1.2. API

REST API의 핵심 요소는 Resource를 나타내는 URI와, Resource를 대상으로 어떤 동작을 할지를 나타내는 HTTP Method이다.

##### 1.2.1. Resource Model

![]({{site.baseurl}}/images/theory_analysis/REST_API/Resource_Model.PNG){: width="600px"}

위의 그림은 REST API의 Resource Model을 나타내고 있다. Resource는 하나의 자원을 타나내고 있고, **Collection**은 Resource의 집합을 의미한다. Resource 하위에 또 다른 Collection(Sub-collection)이 존재 할 수 있다. 각각의 Resource는 JSON, YAML, XML등 다양한 형태로 표현될 수 있다. 일반적으로는 **JSON** 형태를 가장 많이 이용하고 있다.

##### 1.2.2. URI

{: .newline }
> http://restapi.example.com/house/apartments/101

REST API의 URI는 Resource Model에 맞게 Directory 구조의 형태를 갖는다. 하나의 URI는 하나의 Resource를 나타내거나 Resource의 모음을 나타내는 하나의 Collection을 나타낸다. Resource는 **단수**로 표현하고 Collection은 **복수**로 표현한다. 위의 URI는 house Resource가 있고 그 아래 apartments라는 Collection이 존재하고 있고 다시 그 아래 101이란 Resource를 나타내고 있다.

##### 1.2.3. HTTP Method

REST API에서는 다음과 같은 HTTP Method들이 이용된다. 같은 Method라고 해도 대상이 Resource인지 Collection인지에 따라서 동작이 약간씩 달라진다.

* GET Resource - Resource Data를 가져 온다.
* GET Collection - Collection 하위의 모든 Resource Data를 가지고 온다.
* HEAD Resource - Resource의 Meta Data(HTTP Header)만 가져온다.
* HEAD Collection - Collection 하위의 모든 Resource의 Meta Data(HTTP Header)만 가져온다.
* POST Collection - 새로운 Resource를 생성한다.
* PUT Resource - Resource 전체를 Update한다.
* PATCH Resource - Resource 일부를 Update한다.
* DELETE Resource - Resource를 삭제한다.
* OPTION Resource, Collection - 이용가능한 모든 HTTP Method와 Option 정보를 가져온다.

### 2. 참조

* [https://www.redhat.com/archives/rest-practices/2011-August/pdfa1nfEjPMmT.pdf](https://www.redhat.com/archives/rest-practices/2011-August/pdfa1nfEjPMmT.pdf)
* [http://meetup.toast.com/posts/92](http://meetup.toast.com/posts/92)
* [https://spring.io/understanding/REST](https://spring.io/understanding/REST)
* [http://restful-api-design.readthedocs.io/en/latest/methods.html](http://restful-api-design.readthedocs.io/en/latest/methods.html)
* [https://restfulapi.net/resource-naming/](https://restfulapi.net/resource-naming/)
* [https://lornajane.net/posts/2013/are-subqueries-restful](https://lornajane.net/posts/2013/are-subqueries-restful)
