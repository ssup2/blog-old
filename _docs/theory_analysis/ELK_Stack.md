---
title: ELK Stack
category: Theory, Analysis
date: 2019-05-10T12:00:00Z
lastmod: 2019-05-10T12:00:00Z
comment: true
adsense: true
---

ELK (Elasticsearch, Logstash, Kibana)를 분석한다.

### 1. ELK Stack

![[그림 1] ELK Stack]({{site.baseurl}}/images/theory_analysis/ELK_Stack/ELK_Stack.PNG)

ELK Stack은 Elasticsearch, Logstash, Kibana를 조합을 의미한다. ELK Stack을 이용하여 Data를 수집하고 분석하는 Platform을 쉽게 구축할 수 있다. [그림 1]은 ELK Stack을 나타내고 있다.

### 2. Elasticsearch

Elasticsearch는 Document DB로써 

#### 2.1. Master Node

{% highlight cpp linenos %}
node.master: true 
node.data: false 
node.ingest: false 
{% endhighlight %}
<figure>
<figcaption class="caption">[설정 1] Master Node 설정</figcaption>
</figure>

#### 2.2. Data Node

{% highlight cpp linenos %}
node.master: false 
node.data: true 
node.ingest: false 
{% endhighlight %}
<figure>
<figcaption class="caption">[설정 2] Data Node 설정</figcaption>
</figure>

#### 2.3. Ingest Node

{% highlight cpp linenos %}
node.master: false 
node.data: false
node.ingest: true 
{% endhighlight %}
<figure>
<figcaption class="caption">[설정 3] Ingest Node 설정</figcaption>
</figure>

#### 2.4. Coodinating (Client) Node

{% highlight cpp linenos %}
node.master: false
node.data: false
node.ingest: false
{% endhighlight %}
<figure>
<figcaption class="caption">[설정 4] Coodinating Node 설정</figcaption>
</figure>

### 3. Logstash

#### 3.1. Beats

### 4. Kibana

### 5. 참조

* [https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html)
* [https://blog.yeom.me/2018/03/24/get-started-elasticsearch/](https://blog.yeom.me/2018/03/24/get-started-elasticsearch/)
* [https://www.slideshare.net/AntonUdovychenko/search-and-analyze-your-data-with-elasticsearch-62204515](https://www.slideshare.net/AntonUdovychenko/search-and-analyze-your-data-with-elasticsearch-62204515)
* [https://m.blog.naver.com/PostView.nhn?blogId=indy9052&logNo=220942459559&proxyReferer=https%3A%2F%2Fwww.google.com%2F](https://m.blog.naver.com/PostView.nhn?blogId=indy9052&logNo=220942459559&proxyReferer=https%3A%2F%2Fwww.google.com%2F)
* [https://www.popit.kr/look-at-new-features-elasticsearch-5/](https://www.popit.kr/look-at-new-features-elasticsearch-5/)
* [https://subscription.packtpub.com/book/big_data_and_business_intelligence/9781784391010/9/ch09lvl1sec50/node-types-in-elasticsearch](https://subscription.packtpub.com/book/big_data_and_business_intelligence/9781784391010/9/ch09lvl1sec50/node-types-in-elasticsearch)
* [http://tech.javacafe.io/2017/12/12/logstash-persistent-queue/](http://tech.javacafe.io/2017/12/12/logstash-persistent-queue/)