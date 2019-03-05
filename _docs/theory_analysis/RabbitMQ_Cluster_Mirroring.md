---
title: RabbitMQ Cluster, Mirroring
category: Theory, Analysis
date: 2019-02-28T12:00:00Z
lastmod: 2019-02-28T12:00:00Z
comment: true
adsense: true
---

RabbitMQ의 HA (High Availability)를 위한 RabbitMQ의 Cluster, Mirroring 기법을 분석한다.

### 1. RabbitMQ Cluster, Mirroring

![]({{site.baseurl}}/images/theory_analysis/RabbitMQ_Cluster_Mirroring/Cluster_Mirroring.PNG)

RabbitMQ Cluster는 다수의 RabbitMQ를 하나의 RabbitMQ처럼 묶어서 사용하는 기법이다. RabbitMQ Mirroring은 RabbitMQ Cluster 안에서 Meesage를 다수의 RabbitMQ에 복사하여 저장하는 기법이다. RabbitMQ Cluster 기법과 RabbitMQ Mirroring 기법을 이용하여 RabbitMQ HA (High Availability)를 구성할 수 있다. 위의 그림은 RabbitMQ Cluster과 RabbitMQ Mirroring을 나타내고 있다.



### 2. 참조

* [https://www.rabbitmq.com/clustering.html](https://www.rabbitmq.com/clustering.html)
* [https://www.rabbitmq.com/ha.html](https://www.rabbitmq.com/ha.html)
* [https://m.blog.naver.com/tmondev/221051503100](https://m.blog.naver.com/tmondev/221051503100)
* [https://www.slideshare.net/visualdensity/rabbit-fairlyindepth](https://www.slideshare.net/visualdensity/rabbit-fairlyindepth)
