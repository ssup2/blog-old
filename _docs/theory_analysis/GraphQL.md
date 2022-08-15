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

* Query : Data를 조회한다.
* Mutation : Data를 생성(Create), 갱신(Update), 삭제(Delete)하고 변경된 Data를 조회한다.
* Subscription : Data의 변경을 구독하여 Data 변경시 변경된 Data를 수신한다.

#### 1.1.1. Query

{% highlight text %}
# Query
query {
  countries {
    name
  }
}

# Result
{
  "data": {
    "countries": [
      {
        "name": "Andorra"
      },
      {
        "name": "United Arab Emirates"
      },
      {
        "name": "Afghanistan"
      },
...
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 1] countries name Query</figcaption>
</figure>

Query는 **Data 조회** Operation을 의미한다. [Query 1]은 countries를 조회하는 간단한 Query를 나타내고 있다. 가장 앞에는 **query 문자열**을 명시하여 Query Operation을 나타낸다. Query는 JSON과 매우 유사한 형태를 갖고 있으며, 얻고 싶은 **Field를 명시**하여 Data를 조회할 수 있다. Query의 결과는 **JSON 형태**로 출력되며, **data Key**에 실제 Data가 적재된다. [Query 1]에서는 countries Field의 name Field만 명시하고 있기 때문에 조회된 Data에도 name Field만 존재하는 것을 확인할 수 있다.

{% highlight text %}
# Query
query {
  countries {
    name
    capital
  }
}

# Result
{
  "data": {
    "countries": [
      {
        "name": "Andorra",
        "capital": "Andorra la Vella"
      },
      {
        "name": "United Arab Emirates",
        "capital": "Abu Dhabi"
      },
      {
        "name": "Afghanistan",
        "capital": "Kabul"
      },
...
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 2] countries name, capital Query</figcaption>
</figure>

[Query 2]는 [Query 1]과 다르게 countries Field의 name Field 뿐만 아니라, capital Field도 가져오는 GraphQL Query를 나타내고 있다. 따라서 Query 결과를 보면 name Field뿐만 아니라 capital Field의 Data도 가져오는 것을 확인할 수 있다. 이처럼 SQL의 Select Query에서 원하는 Column Data만 가져올 수 있는것 처럼, GraphQL도 **원하는 Field만 명시**하여 Data를 얻을 수 있다는 장점을 가지고 있다.

{% highlight text %}
# Query
query {
  countries {
    name
    languages {
      name
    }
  }
}

# Result
{
  "data": {
    "countries": [
      {
        "name": "Andorra",
        "languages": [
          {
            "name": "Catalan"
          }
        ]
      },
      {
        "name": "United Arab Emirates",
        "languages": [
          {
            "name": "Arabic"
          }
        ]
      },
      {
        "name": "Afghanistan",
        "languages": [
          {
            "name": "Pashto"
          },
          {
            "name": "Uzbek"
          },
          {
            "name": "Turkmen"
          }
        ]
      },
      {
        "name": "Antigua and Barbuda",
        "languages": [
          {
            "name": "English"
          }
        ]
      },
...
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 3] countries name, languages Query</figcaption>
</figure>

[Query 3]은 countries Field의 languages Field도 명시하여 countries의 languages 정보도 한번에 가져오는 GraphQL Query를 나타내고 있다. countries와 languages는 1:N 관계를 갖는것을 확인할 수 있다. SQL의 Join Query를 통해서 여러 DB Table에 존재하는 Data를 한번에 조회가 가능한것 처럼, GraphQL도 여러 DB Table에 존재하는 Data를 **한번에 조회**할 수 있다는 장점을 가지고 있다.

#### 1.1.2. Mutation

Mutation은 생성(Create), 갱신(Update), 삭제(Delete)와 같은 **Data 변경 및 변경된 Data 조회** Operation을 의미한다.

#### 1.1.3. Subscription

Subscription은 **Data 변경 Event 수신** Operation을 의미하며, GraphQL의 Pub/Sub Model 구현체이다. GraqhQL Client는 GraphQL API Server를 대상으로 Subscription Operation을 요청하면, GraphQL API Server는 관련 Data 변경시 변경 Data를 GraphQL Client에게 전송한다. Subscription Operation을 통해서 Client는 비효율적인 Polling 기반의 Data 변경 감지를 수행하지 않아도 된다. Subscription Operation은 **WebSocket** Protocol을 이용한다.

#### 1.2. Introspection

{% highlight text %}
# Query
query {
  __schema {
    queryType {
      fields {
        name
        description
      }
    }
    mutationType {
      fields {
        name
        description
      }
    }
    subscriptionType {
      fields {
        name
        description
      }
    }
  }
}

# Result
{
  "data": {
    "__schema": {
      "queryType": {
        "fields": [
          {
            "name": "_entities",
            "description": null
          },
          {
            "name": "_service",
            "description": null
          },
          {
            "name": "countries",
            "description": null
          },
          {
            "name": "country",
            "description": null
          },
          {
            "name": "continents",
            "description": null
          },
          {
            "name": "continent",
            "description": null
          },
          {
            "name": "languages",
            "description": null
          },
          {
            "name": "language",
            "description": null
          }
        ]
      },
      "mutationType": null,
      "subscriptionType": null
    }
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 4] Field List Query</figcaption>
</figure>

Introspection은 GraphQL API Server가 지원하는 Schema를 확인하는 기능이다. **__schema* Field를 대상으로 Query를 통해서 Schema 확인이 가능하다. [graphiql](https://lucasconstantino.github.io/graphiql-online)과 같은 GraphQL Client가 GraphQL API Server제 제공하는 Schema를 확인할 수 있는 이유는 Instrospection 기능을 활용하여 Schema 정보를 얻어오기 때문이다. [Query 4]는 각 Operation Type에 따른 질의 가능한 Field를 나타내고 있다. Query Operation을 제외한 나머지 Mutation, Subscription Operation은 질의 가능한 Field가 없는것을 확인할 수 있다.

{% highlight text %}
# Query
query {
  __schema {
    types {
      name
      description
    }
  }
}

# Result
{
  "data": {
    "__schema": {
      "types": [
        {
          "name": "Boolean",
          "description": "The `Boolean` scalar type represents `true` or `false`."
        },
        {
          "name": "String",
          "description": "The `String` scalar type represents textual data, represented as UTF-8 character sequences. The String type is most often used by GraphQL to represent free-form human-readable text."
        },
        {
          "name": "Country",
          "description": null
        },
        {
          "name": "ID",
          "description": "The `ID` scalar type represents a unique identifier, often used to refetch an object or as key for a cache. The ID type appears in a JSON response as a String; however, it is not intended to be human-readable. When expected as an input type, any string (such as `\"4\"`) or integer (such as `4`) input value will be accepted as an ID."
        },
        {
          "name": "Continent",
          "description": null
        },
...
      }
    }
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 5] Type Query</figcaption>
</figure>

[Query 5]는 Schema에서 이용되는 Type을 조회하는 Query를 나타내고 있다.

### 2. GraphQL Implementation

GraphQL 구현을 위해서는 GraphQL이 HTTP과 같이 동작하는 방식과 Resolver 개념을 이해하고 있어야 한다.

#### 2.1. with HTTP

{: .newline }
>GET http://api.ssup2.com/graphql?query={hero{name}}
<figure>
<figcaption class="caption">[Request 1] GET Request with GraphQL</figcaption>
</figure>

GraphQL도 REST API와 동일하게 일반적으로 HTTP를  이용한다. [Request 1]은 HTTP Protocol을 활용하여 GraphQL Query를 전송하는 예제를 나타내고 있다. 일반적인 HTTP Protocol 기반 REST API의 경우에는 Resource당 별도의 URL (Endpoint)를 갖는 구조이지만, GraphQL을 이용하는 경우 **단일 URL**을 이용한다. [Request 1]의 경우에는 GraphQL URL로 "/graphql"을 이용하고 있다. GraphQL Query의 경우에는 **Query String**을 이용하여 API Server에게 전달한다.

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

### 3. vs REST API

GraphQL은 REST API와 대비 Data 조회에 특화된 기술이다. REST API의 경우에는 Resource 관련 모든 Data를 조회한 이후에 필요한 Data 추출하여 이용하지만, GraphQL의 경우에는 필요한 Field만 명시하여 조회하고 이용할 수 있기 때문이다. 또한 REST API의 경우에는 여러 URL에 여러번 요청하여 Data를 조회하고 Data를 가공하여 이용하는 경우도 자주 발생하는데, GraphQL은 한번의 요청에 필요한 Data를 모두 조회할 수 있기 때문이다.

Data 조회에 특화되었만 때문에 GraphSQL API Server는 Data Store 또는 Repository와 같은 Data 저장소 역할만을 수행하는 경우가 대부분이고, Business Logic은 GraphSQL API Server가 아니라 GraphSQL Client에서 수행된다. 따라서 Client의 Business Logic이 중요한 Service의 경우에는 GraphQL을 이용하는것이 유리하며, Server에서 Business Logic을 수행하는 경우에는 REST API를 이용하는것이 유리하다.

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
* Online Demo : [https://lucasconstantino.github.io/graphiql-online/](https://lucasconstantino.github.io/graphiql-online/)
* Online Demo : [https://docs.github.com/en/graphql/overview/explorer](https://docs.github.com/en/graphql/overview/explorer)