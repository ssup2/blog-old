---
title: etcd Clustering
category: Theory, Analysis
date: 2021-02-01T12:00:00Z
lastmod: 2021-02-01T12:00:00Z
comment: true
adsense: true
---

etcd의 Clustering 기법을 분석한다.

### 1. etcd Server Clustering

![[그림 1] etcd Server Cluster]({{site.baseurl}}/images/theory_analysis/etcd_Clustering/etcd_Cluster_Architecture.PNG){: width="600px"}

etcd Server는 Clustering을 통해서 HA(High Availability)를 제공할 수 있다. [그림 1]은 etcd Server의 Cluster를 나타내고 있다.

#### 1.1. Server Clustering

Server는 Raft Algorithm에 따라서 **Leader**와 **Follower**로 동작한다. Raft Algorithm에 따라서 Client의 Request는 반드시 Leader Server에게로 전달되어야 한다. Follower 역할을 수행하는 Server는 Client의 요청을 받을 경우 Leader Server에게 전달하는 Proxy 역할을 수행한다.

Server들이 Clustering을 수행하기 위해서는 각 Server는 Cluster에 참여하는 모든 Server의 IP/Port를 알고 있어야한다. Cluster에 참여하는 모든 Server의 IP/Port 정보는 Server의 Parameter를 통해서 **Static**하게 설정될 수도 있고, **Discovery** 기능을 활용하여 각 Server가 스스로 얻어올 수 있도록 설정할 수도 있다. Discovery 기능은 etcd 자체적으로 제공하는 기법과 DNS를 활용한 기법 2가지를 제공하고 있다. 

{% highlight cpp linenos %}
# etcd --name infra0 --initial-advertise-peer-urls http://10.0.1.10:2380 \
--listen-peer-urls http://10.0.1.10:2380 \
--listen-client-urls http://10.0.1.10:2379,http://127.0.0.1:2379 \
--advertise-client-urls http://10.0.1.10:2379 \
--initial-cluster-token etcd-cluster-1 \
--initial-cluster infra0=http://10.0.1.10:2380,infra1=http://10.0.1.11:2380,infra2=http://10.0.1.12:2380 \
--initial-cluster-state new
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Server Cluster 생성</figcaption>
</figure>

[Shell 1]은 3개의 etcd Server를 이용하여 Cluster를 구축할때 Static하게 모든 Server의 IP/Port를 입력하여 Server Cluster를 구축하는 명령어를 나타내고 있다. 첫번째 etcd Server를 실행하는 명령어이다. --initial-cluster Parameter에 첫번째 etcd Server 뿐만 아니라 두번째, 세번째 etcd Server의 IP/Port 정보가 포함되어 있는것을 확인할 수 있다. 두번째, 세번째 etcd Server를 구동할때도 [Shell 1]과 유사하게 나머지 etcd Server의 IP/Port 정보가 포함되어 있어야 한다.

Server Cluster 내부의 통신은 TLS를 이용하여 암호화 될 수 있다.

#### 1.2. Client Load Balancer

{% highlight cpp linenos %}
# etcdctl --endpoints=http://10.0.1.10:2379,http://10.0.1.11:2379,http://10.0.1.12:2379 member list
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] etcdctl</figcaption>
</figure>

Server Cluster와 통신하기 위해서는 Client는 Cluster에 참여하는 일부 Server의 IP/Port 정보를 알고 있으면 된다. 이때 Client가 다수의 Server의 IP/Port 정보를 알고 있다면 Client는 Load Balancer를 활용하여 요청을 분배하고, Server 장애시 장애가 발생하지 않는 다른 Server에게 요청을 다시 전송하여 스스로 장애에 대응한다. etcdctl은 etcd의 CLI Client이다. [Shell 2]는 etcdctl의 endpoints Parameter를 통해서 다수의 etcd Server의 IP/Port를 Client에게 알려주는 명령어를 나타내고 있다.

Client는 어느 Server가 Leader Server인지 알고있지 못한다. 따라서 Client가 Load Balancing을 수행할 때는 Server의 역활은 고려되지 않는다. Client는 처음에는 Cluster의 모든 Server와 동시에 TCP Connection을 맺는 방법을 이용하다가, 이후에 한번에 하나의 TCP Connection을 맺는 방법을 이용하다가 현재는 gRCP의 SubConnection을 통해서 모든 Server와 논리적 Connection을 맺는 방식을 이용하고 있다.

#### 1.3. Server 추가/삭제

#### 1.3.1. Learner

### 2. 참조

* [https://etcd.io/docs/v3.4.0/faq/](https://etcd.io/docs/v3.4.0/faq/)
* [https://etcd.io/docs/v3.4.0/op-guide/clustering/](https://etcd.io/docs/v3.4.0/op-guide/clustering/)
* [https://etcd.io/docs/v3.4.0/learning/design-client/](https://etcd.io/docs/v3.4.0/learning/8 design-client/)
* [https://etcd.io/docs/v3.4.0/learning/design-learner/](https://etcd.io/docs/v3.4.0/learning/design-learner/)
* [https://etcd.io/docs/v3.4.0/op-guide/runtime-configuration/](https://etcd.io/docs/v3.4.0/op-guide/runtime-configuration/)
* [https://github.com/etcd-io/etcd/blob/master/Documentation/faq.md](https://github.com/etcd-io/etcd/blob/master/Documentation/faq.md)