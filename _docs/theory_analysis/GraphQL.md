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

#### 1.1. Query

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
<figcaption class="caption">[Query 1] Hero Name Query</figcaption>
</figure>

[Query 1]은 간단한 GraphQL Query를 나타내고 있다. GraphQL Query는 JSON과 매우 유사한 형태를 갖고 있으며, 얻고 싶은 **Field 명시**를 통해서 Data를 얻을 수 있다. [Query 1]에서는 hero Field의 name Field를 명시하고 있기 때문에 관련 Data를 얻을 수 있다. Query의 결과는 **JSON 형태**로 출력된다.

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
<figcaption class="caption">[Query 2] Hero ID, Name Query</figcaption>
</figure>

[Query 2]는 [Query 1]과 다르게 Hero Field의 Name Field 뿐만 아니라, ID Field도 가져오는 Query이다. 따라서 Query 결과를 보면 Name Field뿐만 아니라 ID Field의 Data만 가져오는 것을 확인할 수 있다. 이처럼 GraphQL은 SQL의 Select Query에서 원하는 Column Data만 가져올 수 있는것 처럼, 원하는 Field만 명시하여 Data를 얻을 수 있다는 장점을 가지고 있다.

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
        },
        {
          "id": "1003",
          "name": "Leia Organa"
        }
      ]
    }
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 3] Hero ID, Name, Friends Query</figcaption>
</figure>

#### 1.2. Resolver

#### 1.3. Introspection

#### 1.4. with HTTP

#### 1.5. vs REST API

### 2. 참조

* [https://tech.kakao.com/2019/08/01/graphql-basic/](https://tech.kakao.com/2019/08/01/graphql-basic/)
* [https://hwasurr.io/api/rest-graphql-differences/](https://hwasurr.io/api/rest-graphql-differences/)
* [https://k0102575.github.io/articles/2020-08/graphql](https://k0102575.github.io/articles/2020-08/graphql)
* [https://www.holaxprogramming.com/2018/01/20/graphql-vs-restful-api/](https://www.holaxprogramming.com/2018/01/20/graphql-vs-restful-api/)
* Query : [https://graphql-kr.github.io/learn/queries/](https://graphql-kr.github.io/learn/queries/)