---
title: GraphQL
category: Theory, Analysis
date: 2022-08-12T12:00:00Z
lastmod: 2022-08-12T12:00:00Z
comment: true
adsense: true
---

GraphQL을 분석한다.

### 1. GraphQL

GraphQL은 API Server를 위한 Query 언어이다. **Query 언어**이기 때문에 원하는 Data만 선택하여 얻을수 있다는 장점을 갖으며, 한번에 요청으로 다양한 Data를 얻을수도 있다는 장점도 갖는다. DB의 SQL과 매우 유사한 특징을 갖는다. 일반적으로 REST API의 단점 극복을 위한 용도로 선택되어 이용된다.

#### 1.1. Operation Type

GraphQL은 Query, Mutation, Subscription 3가지 Operation Type을 제공한다.

#### 1.1.1. Query

{% highlight text %}
# Query
{
  hero {
    name
  }
}

# Result
{
  "data": {
    "hero": {
      "name": "R2-D2"
    }
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 1] hero name Query</figcaption>
</figure>

Query는 **Data 조회** Operation을 의미한다. [Query 1]은 간단한 GraphQL Query를 나타내고 있다. GraphQL Query는 JSON과 매우 유사한 형태를 갖고 있으며, 얻고 싶은 **Field 명시**를 통해서 Data를 얻을 수 있다. [Query 1]에서는 hero Field의 name Field를 명시하고 있기 때문에 관련 Data를 얻을 수 있다. Query의 결과는 **JSON 형태**로 출력된다.

{% highlight text %}
# Query
{
  hero {
    id
    name
  }
}

# Result
{
  "data": {
    "hero": {
      "id": "2001",
      "name": "R2-D2"
    }
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 2] hero id, name Query</figcaption>
</figure>

[Query 2]는 [Query 1]과 다르게 hero Field의 name Field 뿐만 아니라, id Field도 가져오는 GraphQL Query를 나타내고 있다. 따라서 Query 결과를 보면 name Field뿐만 아니라 id Field의 Data만 가져오는 것을 확인할 수 있다. 이처럼 SQL의 Select Query에서 원하는 Column Data만 가져올 수 있는것 처럼, GraphQL도 **원하는 Field만 명시**하여 Data를 얻을 수 있다는 장점을 가지고 있다.

{% highlight text %}
# Query
{
  hero {
    name
    friends {
      id
      name
    }
  }
}

# Result
{
  "data": {
    "hero": {
      "name": "R2-D2",
      "friends": [
        {
          "id": "1000",
          "name": "Luke Skywalker"
        },
        {
          "id": "1002",
          "name": "Han Solo"
        }
      ]
    }
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 3] hero id, name, friends Query</figcaption>
</figure>

[Query 3]은 hero Field의 friends Field도 명시하여 hero의 friends 정보도 한번에 가져오는 GraphQL Query를 나타내고 있다. SQL의 Join Query를 통해서 여러 DB Table에 존재하는 Data를 한번에 조회가 가능한것 처럼, GraphQL도 여러 DB Table에 존재하는 Data를 **한번에 조회**할 수 있다는 장점을 가지고 있다.

#### 1.1.2. Mutation

Mutation은 **Data 변경** Operation을 의미한다.

#### 1.1.3. Subscription

Subscription은 **Data 변경 Event 수신** Operation을 의미하며, GraphQL의 Pub/Sub Model 구현체이다. GraqhQL Client는 GraphQL API Server를 대상으로 Subscription Operation을 요청하면, GraphQL API Server는 관련 Data 변경시 변경 Data를 GraphQL Client에게 전송한다. Subscription Operation을 통해서 Client는 비효율적인 Polling 기반의 Data 변경 감지를 수행하지 않아도 된다. Subscription Operation은 **WebSocket** Protocol을 이용한다.

### 2. GraphQL Implementation

GraphQL 구현시 필요한 개념들을 정리한다.

#### 2.1. with HTTP

{: .newline }
>GET http://api.ssup2.com/graphql?query={hero{name}}
<figure>
<figcaption class="caption">[Request 1] GET Request with GraphQL</figcaption>
</figure>

GraphQL도 REST API와 동일하게 일반적으로 HTTP Protocol을 이용한다. [Request 1]은 HTTP Protocol을 활용하여 GraphQL Query를 전송하는 예제를 나타내고 있다. 일반적인 HTTP Protocol 기반 REST API의 경우에는 Resource당 별도의 URL (Endpoint)를 갖는 구조이지만, GraphQL을 이용하는 경우 **단일 URL**을 이용한다. [Request 1]의 경우에는 GraphQL URL로 "/graphql"을 이용하고 있다. GraphQL Query의 경우에는 **Query String**을 이용하여 API Server에게 전달한다.

{: .newline }
> POST http://api.ssup2.com/graphql
> {
>   "query": "...",
>   "operationName": "...",
>   "variables": { "myVariable": "someValue", ... }
> } <br>
<figure>
<figcaption class="caption">[Request 2] POST Request with GraphQL</figcaption>
</figure>

#### 2.2. Resolver

Resolver는 DB와 같은 **외부 Data 저장소로부터 Data를 얻어**와 GraphQL Query에 대한 응답을 구성하는 역할을 수행한다. GraphQL Query의 Parsing은 대부분 GraphQL Library에서 처리하지만, Data를 가져오는 Resolver의 경우에는 API Server 개발자가 직접 구현해야 한다. HTTP Protocol을 이용한다면 HTTP Request를 가장 먼저 받는 HTTP Handler에서 Resolver를 호출하는 구조가 된다.

#### 2.3. Introspection

{% highlight text %}

{% endhighlight %}
<figure>
<figcaption class="caption">[Query ] </figcaption>
</figure>

Introspection은 API Server가 지원하는 GraphQL의 Schema를 확인하는 기능이다.

### 3. vs REST API

### 4. 참조

* [https://tech.kakao.com/2019/08/01/graphql-basic/](https://tech.kakao.com/2019/08/01/graphql-basic/)
* [https://hwasurr.io/api/rest-graphql-differences/](https://hwasurr.io/api/rest-graphql-differences/)
* [https://k0102575.github.io/articles/2020-08/graphql](https://k0102575.github.io/articles/2020-08/graphql)
* [https://www.holaxprogramming.com/2018/01/20/graphql-vs-restful-api/](https://www.holaxprogramming.com/2018/01/20/graphql-vs-restful-api/)
* [https://fe-developers.kakaoent.com/2022/220113-designing-graphql-mutation/](https://fe-developers.kakaoent.com/2022/220113-designing-graphql-mutation/)
* [https://kotlinworld.com/331](https://kotlinworld.com/331)
* Query, Mutation : [https://graphql-kr.github.io/learn/queries/](https://graphql-kr.github.io/learn/queries/)
* Subscription : [https://www.daleseo.com/graphql-apollo-server-subscriptions/](https://www.daleseo.com/graphql-apollo-server-subscriptions/)
* with HTTP : [https://graphql-kr.github.io/learn/serving-over-http/](https://graphql-kr.github.io/learn/serving-over-http/)
* Introspection : [https://graphql-kr.github.io/learn/introspection/](https://graphql-kr.github.io/learn/introspection/)
* Introspection : [https://hasura.io/learn/graphql/intro-graphql/introspection/](https://hasura.io/learn/graphql/intro-graphql/introspection/)