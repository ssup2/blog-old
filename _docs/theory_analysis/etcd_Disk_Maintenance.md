---
title: etcd Disk Maintenance
category: Theory, Analysis
date: 2021-03-08T12:00:00Z
lastmod: 2021-03-08T12:00:00Z
comment: true
adsense: true
---

etcd의 Disk Maintenance를 분석한다.

### 1. etcd Compaction

etcd의 Compaction은 Log Compaction과 Revision (History) Compaction으로 구분할 수 있다.

#### 1.1. Log Compaction

etcd는 Server Cluster 구성시 Raft Consensus Algorithm을 이용하여 Server 사이의 Key-Value Data의 정합성을 맞추고 있다. Raft Consensus Algorithm은 기본적으로 각 Server의 Log를 복제하고 Log를 통해서 Key-Value Data의 정합성을 맞춘다. 따라서 etcd Server Cluster는 Data Write를 수행할 수록 Log가 계속 쌓이게 된다. 즉 etcd가 이용하는 Disk의 용량이 증가한다. 이러한 Log를 제거할 수 있는 방법은 **Snapshot**을 찍으면된다. Snapshot을 찍으면 SnapShot을 찍은 상태의 Key-Value Data가 Log로 남게되고, 이전의 Log들은 제거된다.

etcd는 Log가 특정 횟수만큼 쌓이면 스스로 Snapshot을 찍어 Log Compaction을 수행한다. etcd Server의 `--snapshot-count` Option을 통해서 Log가 몇번 쌓이게 되면 Snapshot을 찍을지 설정할 수 있다. v3.3.0 이후 Version에서는 100,000이 기본값이다. etcd는 Server 사이의 빠른 Log 복제를 위해서 Log를 Memory에도 Caching하는데, Snapshot을 찍으면 Memory에 Caching한 Log도 같이 제거가된다. 따라서 `--snapshot-count` 값에 따라서 Memory 사용량과 Server Log 복제 속도가 Trade Off 관계에 있게 된다.

#### 1.2. Revision (History) Compaction

{% highlight console %}
# revision 12 
$ etcdctl put key1 1
OK
# revision 13
$ etcdctl put key2 2
OK
# revision 14
$ etcdctl put key1 10
OK
# revision 15
$ etcdctl put key2 20
OK

# revision 15
$ etcdctl get --prefix key
key1
10
key2
20
$ etcdctl get --prefix key --rev 15
key1
10
key2
20
# revision 14
$ etcdctl get --prefix key --rev 14
key1
10
key2
2
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] etcd Revision</figcaption>
</figure>

Log와 별개로 etcd는 Key-Value Data의 Revision (History)를 관리한다. [Shell 1]은 etcd Revision의 예제를 나타내고 있다. key가 하나씩 설정될때 마다 Revision도 증가한다. `--rev` Option을 통해서 특정 Revision의 Key-Value Data를 가져올 수 있다. 이러한 Revision이 쌓일수록 etcd가 이용하는 Disk의 용량도 증가한다. Snapshot을 수행해도 Revision은 Log가 아닌 별도의 영역에서 관리되는 Data이기 때문에 Revision은 제거되지 않는다.

`etcdctl compact` 명령어를 통해서 Revision을 강제로 제거할 수 있다. 또한 etcd Server의 `--auto-compaction` 명령어를 통해서 revsion 기반 또는 특정 주기를 기반으로 Revision을 제거할 수 있다. 기본적으로 한시간마다 Revision을 제거하도록 설정된다.

### 2. etcd Defragmentation

Log Compaction과 Revision Compaction을 수행하더라도 Key-Value Data가 Read/Write를 반복하게 된다면 Fragmentation 현상이 발생하여 실제 etcd의 Disk 사용량이 조금씩 증가하게 된다. etcd는 이러한 Fragmenation 현상을 제거하기 위해서 Defragmentation을 제공한다. `etcdctl defrag` 명령어를 통해서 Defragmentation을 수행할 수 있다.

etcd가 Defragmentation을 수행하는 동안에는 기능이 중지된다. 기능 중지에 따른 장애를 막기 위해서는 etcd를 Server Cluster로 구성한 다음, 각 Server별로 Defragmentation을 수행해야 한다. Defragmentation 동작은 Server 사이에 복제되어 다른 Server에게 전달되지 않는다. 따라서 etcd 관리자는 Server Cluster의 각 Server에게 하나씩 `etcdctl defrag` 명령어를 통해서 Defragmentation을 수행 해야한다.

### 3. 참조

* [https://etcd.io/docs/v3.4.0/op-guide/maintenance/](https://etcd.io/docs/v3.4.0/op-guide/maintenance/)
* [https://www.compose.com/articles/how-to-keep-your-etcd-lean-and-mean/](https://www.compose.com/articles/how-to-keep-your-etcd-lean-and-mean/)
* [https://blog.gojekengineering.com/a-few-notes-on-etcd-maintenance-c06440011cbe](https://blog.gojekengineering.com/a-few-notes-on-etcd-maintenance-c06440011cbe)
* [https://github.com/etcd-io/etcd/commit/c5a9d548358f64483b9fc1726f1a64722c4cdf6f](https://github.com/etcd-io/etcd/commit/c5a9d548358f64483b9fc1726f1a64722c4cdf6f)
