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

RabbitMQ Clustering은 다수의 RabbitMQ를 하나의 RabbitMQ처럼 묶어서 사용하는 기법이다. 위의 그림은 RabbitMQ Cluster를 나타내고 있다. **RabbitMQ Cluster를 구성하는 RabbitMQ는 Queue를 제외한 모든 정보를 공유한다는 특징을 갖는다.** 따라서 동일 Cluster안에 있는 모든 RabbitMQ는 동일한 Exchange를 갖고 있다. 위의 그림에서 모든 RabbitMQ는 Exchange A를 갖고 있는것을 확인 할 수 있다. 또한 **RabbitMQ Cluster에서 기본적으로 Queue는 한개만 존재한다는 특징도 갖는다.** 위의 그림에서 Queue A와 Queue B는 Cluster에서 하나만 존재하는 것을 확인 할 수 있다. 동일 Cluster안의 있는 모든 RabbitMQ는 **Erlang Cookie**라고 불리는 비밀키를 공유한다. Erlang Cookie를 통해서 RabbitMQ는 상대방 RabbitMQ가 동일한 Cluster에 있는 RabbitMQ인지 확인한다. 또한 Cluster를 제어하는 CLI Tool 또한 Cluster의 Erlang Cookie를 갖고 있어야 해당 Cluster를 제어 할 수 있다.

Client는 일반적으로 Cluster의 모든 RabbitMQ와 Connection을 맺지않고 오직 하나의 RabbitMQ와 Connection을 맺는다. 즉 각 Publisher/Subscriber는 Cluster의 RabbitMQ 중에서 하나의 RabbitMQ와 Connection을 맺는다. Cluster안의 모든 RabbitMQ는 동일한 Exchange를 갖고 있기 때문에 Publisher는 어떠한 RabbitMQ와 Connection을 맺어도 상관 없다. Exchange는 Publisher 모르게 Message를 전달해야할 Queue가 있는 RabbitMQ에게 Message 다시 전달하기 때문이다. 이와 비슷하게 Subsciber 또한 반드시 이용할 Queue가 있는 RabbitMQ와 직접 Connection을 맺을 필요없다. Subscriber와 Connection을 맺은 RabbitMQ는 Queue가 있는 RabbitMQ으로부터 Message를 얻어 Subsriber에게 전달하기 때문이다.

Client는 Cluster의 RabbitMQ중에서 하나의 RabbitMQ와 Connection을 맺지만, HA를 위해서 Client는 Cluster의 모든 RabbitMQ와 Connection을 맺을 수 있는 환경이어야 한다. 그래야 Cluster의 특정 RabbitMQ가 죽을경우 Client는 다른 RabbitMQ와 Connection을 맺어 계속 RabbitMQ를 이용 할 수 있기 때문이다. 일반적으로 Client와 RabbitMQ Cluster 사이에 **Load Balancer**를 두어, Client에게 Cluster의 모든 RabbitMQ에 접속할 수 있는 환경 제공 및 Connection Load Balancing을 수행한다. 또는 Client가 Cluster의 모든 RabbitMQ의 IP(Domain), Port 접속 정보 갖고 있어, Client 스스로 RabbitMQ 장애 감지 및 Connection Load Balancing을 수행할 수도 있다.

Cluster를 구성하는 각 RabbitMQ는 Disk, RAM 2가지 Mode를 이용할 수 있다. Disk Mode는 Default Mode이다. RAM Mode는 Message, Message Index, Queue Index, 다른 RebbitMQ의 상태 정보를 제외한 나머지 모든 정보를 Memory (RAM)에만 저장하고 구동하는 Mode이다. RAM Mode에서도 Message와 관련된 정보는 여전히 Disk에 저장되기 때문에 RAM Mode를 이용해도 Message 처리량은 증가하지 않는다. 하지만 Exchange, Queue, Binding 등의 정보가 굉장히 많고 설정이 자주 변경되는 환경에서는 RAM Mode를 이용하여 빠르게 설정을 변경 할 수 있다. Cluster 구성시 반드시 하나 이상의 RabbitMQ는 반드시 Disk Mode로 동작시켜야 한다. RAM Mode의 RabbitMQ는 재시작시 Disk Mode가 갖고 있는 RabbitMQ의 정보를 받아서 초기화 한다.

Client가 Cluster의 모든 RabbitMQ와 Connection을 맺을 수 있어 Client는 언제나 RabbitMQ를 이용 할 수 있다고 하더라도, Queue는 Cluster에 하나만 존재하기 때문에 장애가 발생한 RabbitMQ의 Queue에 있는 Message의 손실 까지는 막을수 없다. 이러한 Message 손실을 최소화 하기위해 적용하는 기법이 Mirroring이다.

### 2. RabbitMQ Mirroring

![]({{site.baseurl}}/images/theory_analysis/RabbitMQ_Clustering_Mirroring/Cluster_Mirroring.PNG)

RabbitMQ Mirroring은 RabbitMQ Cluster 안에서 Meesage를 다수의 RabbitMQ에 복사하여 저장하는 기법이다. RabbitMQ Cluster 기법과 RabbitMQ Mirroring 기법을 이용하여 RabbitMQ HA (High Availability)를 구성할 수 있다. 위의 그림은 RabbitMQ Cluster와 Mirroring이 같이 적용된 상태를 나타내고 있다.

### 3. 참조

* [https://www.rabbitmq.com/clustering.html](https://www.rabbitmq.com/clustering.html)
* [https://www.rabbitmq.com/ha.html](https://www.rabbitmq.com/ha.html)
* [https://www.rabbitmq.com/distributed.html](https://www.rabbitmq.com/distributed.html)
* [https://m.blog.naver.com/tmondev/221051503100](https://m.blog.naver.com/tmondev/221051503100)
* [https://www.slideshare.net/visualdensity/rabbit-fairlyindepth](https://www.slideshare.net/visualdensity/rabbit-fairlyindepth)
