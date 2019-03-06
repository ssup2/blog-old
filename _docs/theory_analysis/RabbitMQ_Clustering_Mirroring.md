---
title: RabbitMQ Clustering, Mirroring
category: Theory, Analysis
date: 2019-02-28T12:00:00Z
lastmod: 2019-02-28T12:00:00Z
comment: true
adsense: true
---

RabbitMQ의 HA (High Availability)를 위한 RabbitMQ의 Clustering, Mirroring 기법을 분석한다. 

### 1. RabbitMQ Clustering

![]({{site.baseurl}}/images/theory_analysis/RabbitMQ_Clustering_Mirroring/Cluster.PNG)

RabbitMQ Clustering은 다수의 RabbitMQ를 하나의 RabbitMQ처럼 묶어서 사용하는 기법이다. 위의 그림은 RabbitMQ Cluster를 나타내고 있다. **RabbitMQ Cluster를 구성하는 RabbitMQ는 Queue를 제외한 모든 정보를 공유한다는 특징을 갖는다.** 따라서 동일 Cluster안에 있는 모든 RabbitMQ는 동일한 Exchange를 갖고 있다. 위의 그림에서 모든 RabbitMQ는 Exchange A를 갖고 있는것을 확인 할 수 있다. 또한 **RabbitMQ Cluster에서 기본적으로 Queue는 한개만 존재한다는 특징도 갖는다.** 위의 그림에서 Queue A와 Queue B는 Cluster에서 하나만 존재하는 것을 확인 할 수 있다.

RabbitMQ Cluster안의 모든 RabbitMQ는 동일한 Exchange를 갖고 있기 때문에 Publisher는 어떠한 RabbitMQ과 연결하여 Message를 전송해도 상관없다.

### 2. RabbitMQ Mirroring

![]({{site.baseurl}}/images/theory_analysis/RabbitMQ_Clustering_Mirroring/Cluster_Mirroring.PNG)

RabbitMQ Mirroring은 RabbitMQ Cluster 안에서 Meesage를 다수의 RabbitMQ에 복사하여 저장하는 기법이다. RabbitMQ Cluster 기법과 RabbitMQ Mirroring 기법을 이용하여 RabbitMQ HA (High Availability)를 구성할 수 있다. 위의 그림은 RabbitMQ Cluster와 Mirroring이 같이 적용된 상태를 나타내고 있다.

### 3. 참조

* [https://www.rabbitmq.com/clustering.html](https://www.rabbitmq.com/clustering.html)
* [https://www.rabbitmq.com/ha.html](https://www.rabbitmq.com/ha.html)
* [https://www.rabbitmq.com/distributed.html](https://www.rabbitmq.com/distributed.html)
* [https://m.blog.naver.com/tmondev/221051503100](https://m.blog.naver.com/tmondev/221051503100)
* [https://www.slideshare.net/visualdensity/rabbit-fairlyindepth](https://www.slideshare.net/visualdensity/rabbit-fairlyindepth)
