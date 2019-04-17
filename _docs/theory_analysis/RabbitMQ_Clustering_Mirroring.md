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

![[그림 1] RabbitMQ Cluster]({{site.baseurl}}/images/theory_analysis/RabbitMQ_Clustering_Mirroring/Cluster.PNG)

RabbitMQ Clustering은 다수의 RabbitMQ를 하나의 RabbitMQ처럼 묶어서 사용하는 기법이다. [그림 1]은 RabbitMQ Cluster를 나타내고 있다. **RabbitMQ Cluster를 구성하는 RabbitMQ는 Queue를 제외한 모든 정보를 공유한다는 특징을 갖는다.** 따라서 동일 Cluster안에 있는 모든 RabbitMQ는 동일한 Exchange를 갖고 있다. [그림 1]에서 모든 RabbitMQ는 Exchange A를 갖고 있는것을 확인 할 수 있다. 또한 **RabbitMQ Cluster에서 기본적으로 Queue는 한개만 존재한다는 특징도 갖는다.** [그림 1]에서 Queue A와 Queue B는 Cluster에서 하나만 존재하는 것을 확인 할 수 있다. 동일 Cluster안의 있는 모든 RabbitMQ는 **Erlang Cookie**라고 불리는 비밀키를 공유한다. Erlang Cookie를 통해서 RabbitMQ는 상대방 RabbitMQ가 동일한 Cluster에 있는 RabbitMQ인지 확인한다. 또한 Cluster를 제어하는 CLI Tool 또한 Cluster의 Erlang Cookie를 갖고 있어야 해당 Cluster를 제어 할 수 있다.

Client는 일반적으로 Cluster의 모든 RabbitMQ와 Connection을 맺지않고 오직 하나의 RabbitMQ와 Connection을 맺는다. 즉 각 Producer/Consumer는 Cluster의 RabbitMQ 중에서 하나의 RabbitMQ와 Connection을 맺는다. Cluster안의 모든 RabbitMQ는 동일한 Exchange를 갖고 있기 때문에 Producer는 어떠한 RabbitMQ와 Connection을 맺어도 상관없다. Exchange는 Producer 모르게 Message를 전달해야할 Queue가 있는 RabbitMQ에게 Message 다시 전달하기 때문이다. 이와 비슷하게 Subsciber 또한 반드시 이용할 Queue가 있는 RabbitMQ와 직접 Connection을 맺을 필요없다. Consumer와 Connection을 맺은 RabbitMQ는 Queue가 있는 RabbitMQ으로부터 Message를 얻어 Subsriber에게 전달하기 때문이다.

Client는 Cluster의 RabbitMQ중에서 하나의 RabbitMQ와 Connection을 맺지만, HA를 위해서 Client는 Cluster의 모든 RabbitMQ와 Connection을 맺을 수 있는 환경이어야 한다. 그래야 Cluster의 특정 RabbitMQ가 죽을경우 Client는 다른 RabbitMQ와 Connection을 맺어 계속 RabbitMQ를 이용 할 수 있기 때문이다. 일반적으로 Client와 RabbitMQ Cluster 사이에 Load Balancer를 두어, Client에게 Cluster의 모든 RabbitMQ에 접속할 수 있는 환경 제공 및 Connection Load Balancing을 수행한다. 또는 Client가 Cluster의 모든 RabbitMQ의 IP(Domain), Port 접속 정보 갖고 있어, Client 스스로 RabbitMQ 장애 감지 및 Connection Load Balancing을 수행하는 방법을 이용한다.

Cluster를 구성하는 각 RabbitMQ는 Disk, RAM 2가지 Mode를 이용할 수 있다. Disk Mode는 Default Mode이다. RAM Mode는 Message, Message Index, Queue Index, 다른 RebbitMQ의 상태 정보를 제외한 나머지 모든 정보를 Memory (RAM)에만 저장하고 구동하는 Mode이다. RAM Mode에서도 Message와 관련된 정보는 여전히 Disk에 저장되기 때문에 RAM Mode를 이용해도 Message 처리량은 증가하지 않는다. 하지만 Exchange, Queue, Binding 등의 정보가 굉장히 많고 설정이 자주 변경되는 환경에서는 RAM Mode를 이용하여 빠르게 설정을 변경 할 수 있다. Cluster 구성시 반드시 하나 이상의 RabbitMQ는 반드시 Disk Mode로 동작시켜야 한다. RAM Mode의 RabbitMQ는 재시작시 Disk Mode가 갖고 있는 RabbitMQ의 정보를 받아서 초기화하기 때문이다.

Client가 Cluster의 모든 RabbitMQ와 Connection을 맺을 수 있어 Client는 언제나 RabbitMQ를 이용 할 수 있다고 하더라도, Queue는 Cluster에 하나만 존재하기 때문에 장애가 발생한 RabbitMQ의 Queue에 있는 Message의 손실 까지는 막을수 없다. 이러한 Message 손실을 방지하기 위해 적용하는 기법이 Mirroring이다.

### 2. RabbitMQ Mirroring

![[그림 2] RabbitMQ Mirroring]({{site.baseurl}}/images/theory_analysis/RabbitMQ_Clustering_Mirroring/Cluster_Mirroring.PNG)

RabbitMQ Mirroring은 RabbitMQ Cluster 안에서 Meesage를 다수의 RabbitMQ에 복사하여 저장하는 기법이다. RabbitMQ Cluster 기법과 RabbitMQ Mirroring 기법을 이용하여 RabbitMQ HA (High Availability)를 구성할 수 있다. [그림 2]는 RabbitMQ Cluster와 Mirroring이 같이 적용된 상태를 나타내고 있다. Mirroring 구성시 Queue는 Master Queue와 Slave Queue로 구성되며, 1:N 관계를 갖는다. Master Queue는 원본 Queue를 의미하며 Slave Queue는 Master Queue를 복제한 Queue를 의미한다. 각 Master Queue마다 다른 개수의 Slave Queue를 설정 할 수 있다. Master Queue는 RabbitMQ 문서에서는 Queue Master라고 불린다.

Master Queue와 Slave Queue 사이의 Mirroring은 기본적으로 **Sync** 방식이다. 즉 Producer가 Mirroring된 Queue에게 Message를 전송하면 RabbitMQ는 받은 Message를 Master Queue에만 넣고 Producer에게 ACK를 보내는 것이 아니라, 모든 Slave Queue와 Mirroring이 완료된 후에야 Producer에게 ACK를 보낸다. 따라서 Slave Queue의 개수가 많아질 수록 오히려 Message 처리량이 떨어진다. RabbitMQ에서는 Slave Queue의 개수를 정족수를 만큼만 구성하는 것을 추천한다. 예를들어 Cluster가 5개의 RabbitMQ로 구성되어 있다면 정족수인 3을 맞추어 1 Master Queue, 2 Slave Queue를 구성하면 된다.

**Mirroring을 통한 Slave Queue는 HA를 위한 기법이지 Message 처리량 향상을 위한 기법이 아니다.** Slave Queue가 있어도 Producer의 모든 Message는 오직 Master Queue로만 전달되고, Consumer에게 전달되는 Message는 오직 Master Queue로부터 전송되는 Message이다. Slave Queue는 오직 Master Queue와 Mirroring하는 동작만을 수행한다. 따라서 Slave Queue의 개수를 늘려도 Message 처리량은 분산되지 않는다. 언제나 Master Queue가 기준이 되기 때문에 Producer가 보낸 Message 순서대로 Consumer에게 전달되는 것을 알 수 있다.

Mirroring 정책이 변경되거나, Cluster에 새로운 RabbitMQ가 추가되면서 새로운 Slave Queue도 추가 될 수 있다. 새로운 Slave Queue는 처음에는 아무런 Message가 없는 빈 상태를 유지한다. 즉 Slave Queue는 Master Queue가 갖고 있던 기존의 Message를 복사하여 가져오지 않는다. 오직 Slave Queue가 생성된 이후 Master Queue가 받은 새로운 Message들만 복사하여 가져온다. 따라서 처음에 새로운 Slave Queue가 갖고 있는 Message는 Master Queue가 갖고있는 Message와 다르다. 이러한 상태를 RabbitMQ에서는 **Unsynchronised** 상태라고 표현한다. 시간이 지남에 따라서 Master가 기존의 Message들을 Consumer가 소비하기 때문에 Unsynchronised Slave Queue는 결국 Synchronised Slave Queue가 된다.

Master Queue가 있는 RabbitMQ가 죽으면 일반적으로 Slave Queue 중에서 가장 오래된 Slave Queue가 Master Queue로 승격된다. 이때 RabbitMQ는 기본적으로 Unsynchronised Slave Queue를 승격 대상에서 제외시킨다. 만약 모든 Slave Queue가 Unsynchronised 상태에서 Master Queue의 RabbitMQ가 죽는다면, Master Queue의 RabbitMQ가 복구될때까지 해당 Queue는 이용하지 못한다. 만약 Master Queue의 RabbitMQ를 복구하지 못한다면 Message 손실이 발생한다. 설정을 통해서 RabbitMQ가 Unsynchronised Slave Queue를 Master로 승격시키도록 만들 수 있지만 Message 손실을 피할 수는 없다.

### 3. RabbitMQ Cluster 확장

RabbitMQ Cluster는 동작중에 RabbitMQ를 추가할 수 있다. RabbitMQ는 **Peer Discovery Plugin**을 통해서 Cluster에 추가된 RabbitMQ를 자동으로 발견하고 Clustering까지 수행한다. Peer Discovery Plugin은 현재 4가지를 지원하고 있으며 각각 Consul, etcd, Kubernetes, AWS를 기반으로 하고 있다. RabbitMQ Cluster에 RabbitMQ를 추가하였어도 추가된 RabbitMQ에 Queue가 없다면, 추가된 RabbitMQ로는 부하가 제대로 분산되지 않는다. 따라서 Cluster에 RabbitMQ를 추가한 뒤에는 **Queue Rebalancing**을 통해서 Cluster 부하를 분산시켜야 한다. Queue Rebalancing 작업은 RabbitMQ에서 제공하는 Script 수행이나 Queue Rebalancing Third-party Plugin을 통해서 진행이 가능하다.

### 4. 참조

* [https://www.rabbitmq.com/clustering.html](https://www.rabbitmq.com/clustering.html)
* [https://www.rabbitmq.com/ha.html](https://www.rabbitmq.com/ha.html)
* [https://www.rabbitmq.com/cluster-formation.html](https://www.rabbitmq.com/cluster-formation.html)
* [https://www.rabbitmq.com/distributed.html](https://www.rabbitmq.com/distributed.html)
* [https://www.rabbitmq.com/reliability.html](https://www.rabbitmq.com/reliability.html)
* [https://www.rabbitmq.com/confirms.html](https://www.rabbitmq.com/confirms.html)
* [https://m.blog.naver.com/tmondev/221051503100](https://m.blog.naver.com/tmondev/221051503100)
* [https://www.slideshare.net/visualdensity/rabbit-fairlyindepth](https://www.slideshare.net/visualdensity/rabbit-fairlyindepth)
* [https://tech.labs.oliverwyman.com/blog/2015/12/18/the-end-to-end-principle-and-rabbitmq-queue-mirroring/](https://tech.labs.oliverwyman.com/blog/2015/12/18/the-end-to-end-principle-and-rabbitmq-queue-mirroring/)
* [https://github.com/Ayanda-D/rabbitmq-queue-master-balancer](https://github.com/Ayanda-D/rabbitmq-queue-master-balancer)
