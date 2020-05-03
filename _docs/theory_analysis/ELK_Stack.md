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

Elasticsearch는 분산형 Data 검색 및 분석 엔진 역할을 수행한다. Elasticsearch는 JSON 형태와 같은 **Document** 형태로 Data를 저장한다. Elasticsearch는 Full-text Search시 **Inverted Index**를 이용하고, 숫자 및 위치 Data 처리시에는 **BKD Tree**를 이용하여 빠른 Data 검색이 가능하도록 설계되어 있다. Elasticsearch는 Master-elibigle, Data, Ingest, Coodinating 4개의 Node Type으로 구성되어 있다. Node Type이 4개이지만 하나의 Node에 4개의 Node Type을 모두 적용할 수도 있다.

#### 2.1. Master-elibigle Node

{% highlight cpp linenos %}
node.master: true 
node.data: false
node.ingest: false
{% endhighlight %}
<figure>
<figcaption class="caption">[설정 1] Master Node 설정 Configuration</figcaption>
</figure>

Master-eligible Node는 Elasticsearch Cluster를 전반적으로 관리하는 Node이다. Cluster를 구성하는 Node들의 상태를 관리하고, Index를 관리하고, Data를 어느 Shard에 저장할지 결정한다. Cluster에서 다수의 Master-elibigle Node가 있는 경우 실제로 Master 역할을 수행하는 Node는 하나이며, 나머지 Master-elibigle Node는 Failover시 Master가 될 수 있는 예비 Node 역할을 수행한다. [설정 1]은 Master-elibigle Node를 설정하는 Configuration이다.

#### 2.2. Data Node

{% highlight cpp linenos %}
node.master: false 
node.data: true 
node.ingest: false 
{% endhighlight %}
<figure>
<figcaption class="caption">[설정 2] Data Node 설정</figcaption>
</figure>

Data Node는 Shard를 저장하고 관리하는 Node이다. [설정 2]는 Data Node를 설정하는 Configuration이다.

#### 2.3. Ingest Node

{% highlight cpp linenos %}
node.master: false 
node.data: false
node.ingest: true 
{% endhighlight %}
<figure>
<figcaption class="caption">[설정 3] Ingest Node 설정</figcaption>
</figure>

Ingest Node는 Data Pre-processing Pipeline을 수행하는 Node이다. 따라서 Logstash가 수행하는 Data 전처리를 Ingest Node에서도 수행할 수 있다. [설정 3]은 Ingest Node를 설정하는 Configuration이다.

#### 2.4. Coodinating (Client) Node

{% highlight cpp linenos %}
node.master: false
node.data: false
node.ingest: false
{% endhighlight %}
<figure>
<figcaption class="caption">[설정 4] Coodinating Node 설정</figcaption>
</figure>

Coodinating Node는 외부의 (Logstash, Kibana) 요청에 따라서 Master Node, Data Node, Coodinating Node에 적절한 요청을 보내고, 요청 결과를 받아 다시 외부로 전달하는 Load Balaner 또는 Proxy 역할을 수행한다. [설정 4]는 Coodinating Node를 설정하는 Configuration이다.

### 3. Logstash

Logstash는 다양한 Data Source로부터 Data를 수집하고 가공하여 Elasticsearch에게 전송하는 역할을 수행한다. Data Source에는 Log 파일, App의 Rest API 호출을 통해 전달되는 Data, Beats를 통해 전달되는 Data가 있다. Logstash는 기본적으로 Data Source로부터 받은 Data를 In-memory Queue에 넣기 때문에, Logstash 장애 발생시 Data 유실이 발생한다. 이러한 Data 유실을 방지하기 위해서 Logstash는 Persistent Queue를 제공한다. Persistent Queue는 Data를 Disk에 저장하여 Data 손실을 방지한다. Persistent Queue는 Kafka, RabbitMQ와 같은 Message Queue를 대신하여 Data Buffer의 역할로도 이용될 수 있다.

#### 3.1. Beats

beats는 Data 수집기이다. Beats는 다양한 Data 수집을 위하여 다양한 Plugin을 제공하고 있다.

### 4. Kibana

Kibana는 Elastic Search를 통해서 분석한 Data를 시각화하는 Tool이다.

### 5. 참조

* [https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html)
* [https://www.elastic.co/guide/en/elasticsearch/guide/2.x/important-configuration-changes.html#_minimum_master_nodes](https://www.elastic.co/guide/en/elasticsearch/guide/2.x/important-configuration-changes.html#_minimum_master_nodes)
* [https://www.elastic.co/kr/blog/writing-your-own-ingest-processor-for-elasticsearch](https://www.elastic.co/kr/blog/writing-your-own-ingest-processor-for-elasticsearch)
* [https://blog.yeom.me/2018/03/24/get-started-elasticsearch/](https://blog.yeom.me/2018/03/24/get-started-elasticsearch/)
* [https://www.slideshare.net/AntonUdovychenko/search-and-analyze-your-data-with-elasticsearch-62204515](https://www.slideshare.net/AntonUdovychenko/search-and-analyze-your-data-with-elasticsearch-62204515)
* [https://m.blog.naver.com/PostView.nhn?blogId=indy9052&logNo=220942459559&proxyReferer=https%3A%2F%2Fwww.google.com%2F](https://m.blog.naver.com/PostView.nhn?blogId=indy9052&logNo=220942459559&proxyReferer=https%3A%2F%2Fwww.google.com%2F)
* [https://www.popit.kr/look-at-new-features-elasticsearch-5/](https://www.popit.kr/look-at-new-features-elasticsearch-5/)
* [https://subscription.packtpub.com/book/big_data_and_business_intelligence/9781784391010/9/ch09lvl1sec50/node-types-in-elasticsearch](https://subscription.packtpub.com/book/big_data_and_business_intelligence/9781784391010/9/ch09lvl1sec50/node-types-in-elasticsearch)
* [http://tech.javacafe.io/2017/12/12/logstash-persistent-queue/](http://tech.javacafe.io/2017/12/12/logstash-persistent-queue/)