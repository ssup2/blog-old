---
title: Elasticsearch Data Management
category: Theory, Analysis
date: 2020-05-05T12:00:00Z
lastmod: 2020-05-05T12:00:00Z
comment: true
adsense: true
---

Elasticsearch의 Data Management 관련 내용을 분석한다.

### 1. Elasticsearch Data Managment

#### 1.1. Index, Type, Document

![[그림 1] Data Structure]({{site.baseurl}}/images/theory_analysis/Elasticsearch_Data_Management/Elasticsearch_Data_Structure.PNG){: width="600px"}

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

#### 1.2. Shard, Replica

[그림 2]는 Elastic Search에서 관리하는 Shard와 Replica를 나타낸다. 원본 Shard를 Primary Shard 라고 명칭하며 Primary Shard의 복제본을 Replica라고 명칭한다. Shard와 Replica는 모두 **Index 단위**로 설정이 가능하며, Shard의 개수는 Index가 생성 될때만 설정이 가능하고 Index가 생성된 이후에는 변경이 불가능하다. Replica의 개수는 자유롭게 변경이 가능하다.

![[그림 3] Shard, Replica Recovery]({{site.baseurl}}/images/theory_analysis/Elasticsearch_Data_Management/Elasticsearch_Shard_Replica.PNG){: width="600px"}

[그림 3]에서는 Data Node에 장애가 발생하였을때 Shard, Replica의 복구 과정을 나타내고 있다. [그림 3]에서는 Shard의 개수는 5개, Replica의 개수는 1개인 Index를 나타내고 있다. Data Node C에서 장애가 발생할 경우, Data Node C에는 1번 Primary Shard가 존재하고 있었기 때문에 Data Node D에 있던 1번 Replica는 Primary Shard가 된다. 그 후 Replica 개수 1개를 맞추기 위해서 Data Node D에 있는 1번 Primary Shard를 1번 Replica가 존재하지 않는 Data Node B에 복제되었다.

Data Node C에는 4번 Replica가 존재하고 있었기 때문에, Replica 개수 1개를 맞추기 위해서 Data Node B에 있는 4번 Primary Shard는 4번 Replica가 존재하지 않는 Data Node D에 복제되었다.

### 2. 참조

* [https://www.elastic.co/kr/blog/what-is-an-elasticsearch-index](https://www.elastic.co/kr/blog/what-is-an-elasticsearch-index)
* [https://esbook.kimjmin.net/03-cluster/3.2-index-and-shards](https://esbook.kimjmin.net/03-cluster/3.2-index-and-shards)
* [https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-replication.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-replication.html)
* [https://nesoy.github.io/articles/2019-01/ElasticSearch-Document](https://nesoy.github.io/articles/2019-01/ElasticSearch-Document)