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
<figcaption class="caption">[Data 1] Document Structure</figcaption>
</figure>

#### 1.2. Shard, Replica

![[그림 1] Shard, Replica]({{site.baseurl}}/images/theory_analysis/Elasticsearch_Data_Management/Elasticsearch_Shard_Replica.PNG){: width="700px"}

### 2. 참조

* [https://www.elastic.co/kr/blog/what-is-an-elasticsearch-index](https://www.elastic.co/kr/blog/what-is-an-elasticsearch-index)
* [https://esbook.kimjmin.net/03-cluster/3.2-index-and-shards](https://esbook.kimjmin.net/03-cluster/3.2-index-and-shards)
* [https://nesoy.github.io/articles/2019-01/ElasticSearch-Document](https://nesoy.github.io/articles/2019-01/ElasticSearch-Document)