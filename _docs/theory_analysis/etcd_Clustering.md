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

[Shell 1]은 3개의 Server를 이용하여 Cluster를 구축할때 Static하게 모든 Server의 IP/Port를 입력하여 Server Cluster를 구축하는 명령어를 보여주고 있다. 3개의 Server 중에서 첫번째 Server를 실행하는 명령어를 보여주고 있다. --initial-cluster Parameter에 첫번째 Server 뿐만 아니라 두번째, 세번째 Server의 IP/Port 정보가 포함되어 있는것을 확인할 수 있다. 두번째, 세번째 Server를 구동할 때도 [Shell 1]과 유사하게 나머지 Server의 IP/Port 정보가 포함되어 있어야 한다.

Server Cluster 내부의 통신은 TLS를 이용하여 암호화 될 수 있다.

#### 1.2. Client Load Balancer

{% highlight cpp linenos %}
# etcdctl --endpoints=http://10.0.1.10:2379,http://10.0.1.11:2379,http://10.0.1.12:2379 member list
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] etcdctl</figcaption>
</figure>

Server Cluster와 통신하기 위해서는 Client는 Cluster에 참여하는 일부 Server의 IP/Port 정보를 알고 있으면 된다. 이때 Client가 다수의 Server의 IP/Port 정보를 알고 있다면 Client는 Load Balancer를 활용하여 요청을 분배하고, Server 장애시 장애가 발생하지 않는 다른 Server에게 요청을 다시 전송하여 스스로 장애에 대응한다. etcdctl은 etcd의 CLI Client이다. [Shell 2]는 etcdctl의 endpoints Parameter를 통해서 다수의 Server의 IP/Port를 전달하는 모습을 보여주고 있다.

Client는 어느 Server가 Leader Server인지 알고있지 못한다. 따라서 Client가 Load Balancing을 수행할 때는 Server의 역활은 고려되지 않는다. Client는 처음에는 Cluster의 모든 Server와 동시에 TCP Connection을 맺는 방법을 이용하다가, 이후에 한번에 하나의 TCP Connection을 맺는 방법을 이용하다가 현재는 gRCP의 SubConnection을 통해서 모든 Server와 논리적 Connection을 맺는 방식을 이용하고 있다.

#### 1.3. Server 추가/삭제

{% highlight cpp linenos %}
# etcdctl member add infra2 --peer-urls=http://10.0.1.11:2380
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] Server 추가</figcaption>
</figure>

{% highlight cpp linenos %}
# etcdctl member remove [Server ID]
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] Server 삭제</figcaption>
</figure>

Server Cluster에는 동적으로 Server를 추가하거나 제거할 수 있다. [Shell 3]은 etcdctl을 통해서 Server를 추가하는 모습을 나타내고 있다. etcdctl 명령어를 통해서 Server Cluster에 Server를 추가한 다음, 실제 Server를 구동하면 된다. [Shell 4]는 etcdctl을 통해서 Server를 제거하는 모습을 나타내고 있다. etcdctl 명령어를 통해서 Server Cluster에서 Server를 제거한 다음, 실제 Server를 내리면된다.

**중요한 점은 Quorum은 실제 Server가 구동/제거 될때가 아니라, etcdctl 명령어를 통해서 Server가 추가/제가 될때 변경된다는 점이다.** 따라서 Server 추가 명령어는 매우 신중하게 실행되어야 한다. 만약 Server Cluster에 Server가 1대일 경우에는 Quorum은 1이기 때문에, Server Cluster에 etcdctl 명령어를 통해서 Server 한대를 추가할 경우 문제업이 추가가 된다. 이때 Server Cluster에는 Server가 2대이기 때문에 Quorum은 2가 된다.

{% highlight cpp linenos %}
# etcdctl member add infra2 --peer-urls=http://10.0.1.11:2380
Member 44e87d9a57243f90 added to cluster 35d99f7f50aa4509

ETCD_NAME="infra2"
ETCD_INITIAL_CLUSTER="infra2=http://10.0.1.11:2380,node01=http://192.168.0.61:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.0.1.11:2380"
ETCD_INITIAL_CLUSTER_STATE="existing"

# etcdctl member add infra3 --peer-urls=http://10.0.1.12:2380
{"level":"warn","ts":"2021-03-07T13:34:30.176Z","caller":"clientv3/retry_interceptor.go:61","msg":"retrying of unary invoker failed","target":"endpoint://client-28ab18bd-4710-44b1-a768-749b75f35c08/127.0.0.1:2379","attempt":0,"error":"rpc error: code = Unknown desc = etcdserver: re-configuration failed due to not enough started members"}

# etcdctl member remove 44e87d9a57243f90
{"level":"warn","ts":"2021-03-07T13:48:57.530Z","caller":"clientv3/retry_interceptor.go:61","msg":"retrying of unary invoker failed","target":"endpoint://client-abf6cede-ae3d-439d-aded-a700d5ee1838/127.0.0.1:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = context deadline exceeded"}
Error: context deadline exceeded
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 5] Server 추가/제거 불가능</figcaption>
</figure>

문제는 Server를 추가하고 실제 Server를 구동하지 않는다면 해당 Server Cluster는 앞으로 Read Only Mode로만 동작할 뿐, Server 추가/삭제 동작 뿐만 아니라 Data Write 동작도 수행할 수 없게 된다. Quorum이 2이기 때문에 추가된 Server가 동작하여 투표할 수 있는 상황이 되어야, Server 추가/삭제 또는 Data Write가 가능하기 때문이다. [Shell 5]는 이러한 상황을 나타내고 있다. infra2 Server를 추가한 다음에 infra2 Server를 실제로 구동하지 않은 상태에서 infra3 Server가 추가되지 않는것을 알 수 있다. 원래의 상태로 돌리기 위해서 infra2 Server를 제거하려고 해도 infra Server가 실제로 동작하고 있지는 않기 때문에 제거되지도 않는다.

이러한 상황을 막기 위해서 etcd에서는 가능하면 Server 추가는 한대씩 차례차례 동작을 시키면서 추가하는 방법을 권장하고 있다. 또한 Server Cluster의 Server 교체시, 새로운 Server를 먼저 Server Cluster에 추가하고 교체할 Server를 Server Cluster에서 제거하는 방법이 아니라, 먼저 Server Cluster에서 교체할 Server를 제거한 다음 새로운 Server를 Server Cluster에 추가시키도록 권장하고 있다. 새로운 Server를 Server Cluster에 먼저 추가하면 불필요하게 Quorum이 증가하여 위의 문제가 발생할 수 있기 때문이다.

#### 1.3.1. Learner

### 2. 참조

* [https://etcd.io/docs/v3.4.0/faq/](https://etcd.io/docs/v3.4.0/faq/)
* [https://etcd.io/docs/v3.4.0/op-guide/clustering/](https://etcd.io/docs/v3.4.0/op-guide/clustering/)
* [https://etcd.io/docs/v3.4.0/learning/design-client/](https://etcd.io/docs/v3.4.0/learning/8 design-client/)
* [https://etcd.io/docs/v3.4.0/learning/design-learner/](https://etcd.io/docs/v3.4.0/learning/design-learner/)
* [https://etcd.io/docs/v3.4.0/op-guide/runtime-configuration/](https://etcd.io/docs/v3.4.0/op-guide/runtime-configuration/)
* [https://github.com/etcd-io/etcd/blob/master/Documentation/faq.md](https://github.com/etcd-io/etcd/blob/master/Documentation/faq.md)