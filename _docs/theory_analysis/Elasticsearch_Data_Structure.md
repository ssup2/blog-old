---
title: Elasticsearch Data Structure
category: Theory, Analysis
date: 2020-05-05T12:00:00Z
lastmod: 2020-05-05T12:00:00Z
comment: true
adsense: true
---

Elasticsearch의 Data Structure를 분석한다.

### 1. Elasticsearch Data Structure

![[그림 1] Data Structure]({{site.baseurl}}/images/theory_analysis/Elasticsearch_Data_Structure/Elasticsearch_Data_Structure.PNG){: width="600px"}

[그림 1]은 Elasticsearch의 Data Sturcture를 나타내고 있다. Elasticsearch의 Data는 **Index, Type, Document** 3단계로 구성되어 있다. Document는 Json 형태의 Tree 구조로 Data를 저장한다. Document의 집합을 Type이라고 명칭한다. Type의 집합을 Index라고 명칭한다. MySQL과 비교하면 Index는 Database, Type은 Table, Document는 Row/Column으로 Mapping된다.

{% highlight json %}
{
  "_index" : "index",
  "_type" : "type",
  "_id" : "id",
  "_version" : 1,
  "_seq_no" : 0,
  "_primary_term" : 1,
  "found" : true,
  "_source" : {
    "key1" : "value1",
    "key2" : {
      "key3" : "value2"
    }
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Data 1] Document Info</figcaption>
</figure>

[Data 1]은 Elasticsearch로 부터 얻은 Document의 정보를 나타내고 있다. _index, _type은 Document가 소속되어 있는 Index, Type을 나타낸다. _id는 Document의 ID를 나타낸다. _version은 Document의 Version을 나타내며 Document가 Update 될때마다 _version의 값은 증가한다. _source는 Document의 실제 Data를 나타낸다.

### 2. 참조

* [https://www.elastic.co/kr/blog/what-is-an-elasticsearch-index](https://www.elastic.co/kr/blog/what-is-an-elasticsearch-index)