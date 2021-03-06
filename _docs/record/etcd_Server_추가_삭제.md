---
title: etcd Server 추가/삭제
category: Record
date: 2021-03-04T12:00:00Z
lastmod: 2021-03-04T12:00:00Z
comment: true
adsense: true
---

### 1. 실행 환경

실행 환경은 다음과 같다.
* etcd v3.4.0
* Node
    * Ubuntu 18.04
    * Node01 : 192.168.0.61
    * Node02 : 192.168.0.62

### 2. 단일 etcd Server 구성

Node01에 단일 etcd Server를 구성한다.

~~~
(Node01)# export NODE01=192.168.0.61
(Node01)# export REGISTRY=gcr.io/etcd-development/etcd

(Node01)# docker run -d \
  --net=host \
  --name etcd ${REGISTRY}:v3.4.0 \
  /usr/local/bin/etcd \
  --data-dir=/etcd-data --name node01 \
  --initial-advertise-peer-urls http://${NODE01}:2380 --listen-peer-urls http://0.0.0.0:2380 \
  --advertise-client-urls http://${NODE01}:2379 --listen-client-urls http://0.0.0.0:2379 \
  --initial-cluster node01=http://${NODE01}:2380
~~~

단일 etcd Server를 Docker를 이용하여 구동한다.

### 3. Server 추가

Node02에 etcd Server 한대를 더 구동하고, Node01의 etcd Server와 Clustering을 맺는다.

~~~
(Node01)# docker exec -it etcd sh
(etcd Container)# etcdctl member add node02 --peer-urls=http://192.168.0.62:2380
Member 4c0878749a891a5f added to cluster 35d99f7f50aa4509

ETCD_NAME="node02"
ETCD_INITIAL_CLUSTER="node02=http://192.168.0.62:2380,node01=http://192.168.0.61:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.0.62:2380"
ETCD_INITIAL_CLUSTER_STATE="existing"
~~~

Node01의 etcd Server에 Node02의 etcd Member를 추가한다.

~~~
(Node02)# export NODE01=192.168.0.61
(Node02)# export NODE02=192.168.0.62
(Node02)# export REGISTRY=gcr.io/etcd-development/etcd

(Node02)# docker run -d \
  --net=host \
  --name etcd ${REGISTRY}:v3.4.0 \
  /usr/local/bin/etcd \
  --data-dir=/etcd-data --name node02 \
  --initial-advertise-peer-urls http://${NODE02}:2380 --listen-peer-urls http://0.0.0.0:2380 \
  --advertise-client-urls http://${NODE02}:2379 --listen-client-urls http://0.0.0.0:2379 \
  --initial-cluster node01=http://${NODE01}:2380,node02=http://${NODE02}:2380 \
  --initial-cluster-state existing
~~~

Node01의 etcd Server와 Clustering을 맺는다.

~~~
(Node01)# docker logs -f etcd
...
tcdserver/membership: set the initial cluster version to 3.4
2021-03-03 16:25:57.005589 I | embed: ready to serve client requests
2021-03-03 16:25:57.005633 I | etcdserver: published {Name:node01 ClientURLs:[http://192.168.0.61:2379]} to cluster 35d99f7f50aa4509
2021-03-03 16:25:57.005641 I | etcdserver/api: enabled capabilities for version 3.4
2021-03-03 16:25:57.006043 N | embed: serving insecure client requests on [::]:2379, this is strongly discouraged!
...
raft2021/03/03 16:27:23 INFO: 4eee438bb97e1153 switched to configuration voters=(5687557646807077203 7883063032017194716)
2021-03-03 16:27:23.856885 I | etcdserver/membership: added member 6d66440fb5660edc [http://192.168.0.62:2380] to cluster 35d99f7f50aa4509
2021-03-03 16:27:23.856932 I | rafthttp: starting peer 6d66440fb5660edc...
2021-03-03 16:27:23.856952 I | rafthttp: started HTTP pipelining with peer 6d66440fb5660edc
2021-03-03 16:27:23.857507 I | rafthttp: started streaming with peer 6d66440fb5660edc (writer)
2021-03-03 16:27:23.857752 I | rafthttp: started streaming with peer 6d66440fb5660edc (writer)
2021-03-03 16:27:23.859022 I | rafthttp: started peer 6d66440fb5660edc
2021-03-03 16:27:23.859053 I | rafthttp: added peer 6d66440fb5660edc
2021-03-03 16:27:23.859079 I | rafthttp: started streaming with peer 6d66440fb5660edc (stream MsgApp v2 reader)
2021-03-03 16:27:23.859114 I | rafthttp: started streaming with peer 6d66440fb5660edc (stream Message reader)
raft2021/03/03 16:27:25 WARN: 4eee438bb97e1153 stepped down to follower since quorum is not active
raft2021/03/03 16:27:25 INFO: 4eee438bb97e1153 became follower at term 2
raft2021/03/03 16:27:25 INFO: raft.node: 4eee438bb97e1153 lost leader 4eee438bb97e1153 at term 2
raft2021/03/03 16:27:26 INFO: 4eee438bb97e1153 is starting a new election at term 2
raft2021/03/03 16:27:26 INFO: 4eee438bb97e1153 became candidate at term 3
raft2021/03/03 16:27:26 INFO: 4eee438bb97e1153 received MsgVoteResp from 4eee438bb97e1153 at term 3
raft2021/03/03 16:27:26 INFO: 4eee438bb97e1153 [logterm: 2, index: 5] sent MsgVote request to 6d66440fb5660edc at term 3
raft2021/03/03 16:27:28 INFO: 4eee438bb97e1153 is starting a new election at term 3
raft2021/03/03 16:27:28 INFO: 4eee438bb97e1153 became candidate at term 4
raft2021/03/03 16:27:28 INFO: 4eee438bb97e1153 received MsgVoteResp from 4eee438bb97e1153 at term 4
raft2021/03/03 16:27:28 INFO: 4eee438bb97e1153 [logterm: 2, index: 5] sent MsgVote request to 6d66440fb5660edc at term 4
2021-03-03 16:27:28.859259 W | rafthttp: health check for peer 6d66440fb5660edc could not connect: dial tcp 192.168.0.62:2380: connect: connection refused
2021-03-03 16:27:28.859309 W | rafthttp: health check for peer 6d66440fb5660edc could not connect: dial tcp 192.168.0.62:2380: connect: connection refused
raft2021/03/03 16:27:29 INFO: 4eee438bb97e1153 is starting a new election at term 4
raft2021/03/03 16:27:29 INFO: 4eee438bb97e1153 became candidate at term 5
raft2021/03/03 16:27:29 INFO: 4eee438bb97e1153 received MsgVoteResp from 4eee438bb97e1153 at term 5
raft2021/03/03 16:27:29 INFO: 4eee438bb97e1153 [logterm: 2, index: 5] sent MsgVote request to 6d66440fb5660edc at term 5
raft2021/03/03 16:27:30 INFO: 4eee438bb97e1153 is starting a new election at term 5
raft2021/03/03 16:27:30 INFO: 4eee438bb97e1153 became candidate at term 6
raft2021/03/03 16:27:30 INFO: 4eee438bb97e1153 received MsgVoteResp from 4eee438bb97e1153 at term 6
raft2021/03/03 16:27:30 INFO: 4eee438bb97e1153 [logterm: 2, index: 5] sent MsgVote request to 6d66440fb5660edc at term 6
raft2021/03/03 16:27:32 INFO: 4eee438bb97e1153 is starting a new election at term 6
raft2021/03/03 16:27:32 INFO: 4eee438bb97e1153 became candidate at term 7
raft2021/03/03 16:27:32 INFO: 4eee438bb97e1153 received MsgVoteResp from 4eee438bb97e1153 at term 7
raft2021/03/03 16:27:32 INFO: 4eee438bb97e1153 [logterm: 2, index: 5] sent MsgVote request to 6d66440fb5660edc at term 7
raft2021/03/03 16:27:33 INFO: 4eee438bb97e1153 is starting a new election at term 7
raft2021/03/03 16:27:33 INFO: 4eee438bb97e1153 became candidate at term 8
raft2021/03/03 16:27:33 INFO: 4eee438bb97e1153 received MsgVoteResp from 4eee438bb97e1153 at term 8
raft2021/03/03 16:27:33 INFO: 4eee438bb97e1153 [logterm: 2, index: 5] sent MsgVote request to 6d66440fb5660edc at term 8
2021-03-03 16:27:33.859469 W | rafthttp: health check for peer 6d66440fb5660edc could not connect: dial tcp 192.168.0.62:2380: connect: connection refused
2021-03-03 16:27:33.859602 W | rafthttp: health check for peer 6d66440fb5660edc could not connect: dial tcp 192.168.0.62:2380: connect: connection refuse
...
2021-03-03 16:28:50.446253 I | rafthttp: peer 6d66440fb5660edc became active
2021-03-03 16:28:50.446282 I | rafthttp: established a TCP streaming connection with peer 6d66440fb5660edc (stream Message writer)
2021-03-03 16:28:50.446748 I | rafthttp: established a TCP streaming connection with peer 6d66440fb5660edc (stream MsgApp v2 writer)
2021-03-03 16:28:50.460719 I | rafthttp: established a TCP streaming connection with peer 6d66440fb5660edc (stream MsgApp v2 reader)
2021-03-03 16:28:50.460880 I | rafthttp: established a TCP streaming connection with peer 6d66440fb5660edc (stream Message reader)
raft2021/03/03 16:28:52 INFO: 4eee438bb97e1153 is starting a new election at term 60
raft2021/03/03 16:28:52 INFO: 4eee438bb97e1153 became candidate at term 61
raft2021/03/03 16:28:52 INFO: 4eee438bb97e1153 received MsgVoteResp from 4eee438bb97e1153 at term 61
raft2021/03/03 16:28:52 INFO: 4eee438bb97e1153 [logterm: 2, index: 5] sent MsgVote request to 6d66440fb5660edc at term 61
raft2021/03/03 16:28:52 INFO: 4eee438bb97e1153 received MsgVoteResp from 6d66440fb5660edc at term 61
raft2021/03/03 16:28:52 INFO: 4eee438bb97e1153 has received 2 MsgVoteResp votes and 0 vote rejections
raft2021/03/03 16:28:52 INFO: 4eee438bb97e1153 became leader at term 61
raft2021/03/03 16:28:52 INFO: raft.node: 4eee438bb97e1153 elected leader 4eee438bb97e1153 at term 6
~~~

Node02의 etcd Server가 추가될때 Node01의 etcd Server는 위와 같은 Log를 남긴다. Node01의 etcd Server는 Node02의 etcd Server가 추가된 이후에 Node02의 etcd Server와 Connection이 될때까지 대기한다. 이후 Node01의 etcd Server는 Node02의 etcd Server와 Connection을 맺은 다음, Leader Election 과정을 통해서 이후에 Leader가 된것을 알 수 있다.

### 4. Server 삭제

#### 4.1. Leader Server 삭제

Leader로 동작하는 Node01의 etcd Server를 제거해본다.

~~~
(Node02)# docker exec -it etcd sh
(etcd Container)# etcdctl endpoint status --cluster -w table
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT         |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://192.168.0.61:2379 | 4eee438bb97e1153 |   3.4.0 |   20 kB |      true |      false |        61 |          7 |                  7 |        |
| http://192.168.0.62:2379 | 6c9f385ab14331a2 |   3.4.0 |   20 kB |     false |      false |        61 |          7 |                  7 |        |
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

(etcd Container)# etcdctl member remove 4eee438bb97e1153
~~~

Leader etcd Server를 etcd Cluster로부터 제거한다.

~~~
(Node02)# docker logs -f etcd
...
raft2021/03/03 16:46:41 INFO: 6c9f385ab14331a2 switched to configuration voters=(7827036639565394338)
2021-03-03 16:46:41.520426 I | etcdserver/membership: removed member 4eee438bb97e1153 from cluster 35d99f7f50aa4509
2021-03-03 16:46:41.520470 I | rafthttp: stopping peer 4eee438bb97e1153...
2021-03-03 16:46:41.521156 I | rafthttp: closed the TCP streaming connection with peer 4eee438bb97e1153 (stream MsgApp v2 writer)
2021-03-03 16:46:41.521191 I | rafthttp: stopped streaming with peer 4eee438bb97e1153 (writer)
2021-03-03 16:46:41.522150 W | rafthttp: rejected the stream from peer 4eee438bb97e1153 since it was removed
2021-03-03 16:46:41.523061 I | rafthttp: closed the TCP streaming connection with peer 4eee438bb97e1153 (stream Message writer)
2021-03-03 16:46:41.523166 I | rafthttp: stopped streaming with peer 4eee438bb97e1153 (writer)
2021-03-03 16:46:41.523369 I | rafthttp: stopped HTTP pipelining with peer 4eee438bb97e1153
2021-03-03 16:46:41.523436 W | rafthttp: lost the TCP streaming connection with peer 4eee438bb97e1153 (stream MsgApp v2 reader)
2021-03-03 16:46:41.523458 E | rafthttp: failed to read 4eee438bb97e1153 on stream MsgApp v2 (context canceled)
2021-03-03 16:46:41.523462 I | rafthttp: peer 4eee438bb97e1153 became inactive (message send to peer failed)
2021-03-03 16:46:41.523485 I | rafthttp: stopped streaming with peer 4eee438bb97e1153 (stream MsgApp v2 reader)
2021-03-03 16:46:41.523525 W | rafthttp: lost the TCP streaming connection with peer 4eee438bb97e1153 (stream Message reader)
2021-03-03 16:46:41.523534 I | rafthttp: stopped streaming with peer 4eee438bb97e1153 (stream Message reader)
2021-03-03 16:46:41.523538 I | rafthttp: stopped peer 4eee438bb97e1153
2021-03-03 16:46:41.523548 I | rafthttp: removed peer 4eee438bb97e1153
2021-03-03 16:46:41.524312 W | rafthttp: rejected the stream from peer 4eee438bb97e1153 since it was removed
raft2021/03/03 16:46:43 INFO: 6c9f385ab14331a2 is starting a new election at term 5
raft2021/03/03 16:46:43 INFO: 6c9f385ab14331a2 became candidate at term 6
raft2021/03/03 16:46:43 INFO: 6c9f385ab14331a2 received MsgVoteResp from 6c9f385ab14331a2 at term 6
raft2021/03/03 16:46:43 INFO: 6c9f385ab14331a2 became leader at term 6
raft2021/03/03 16:46:43 INFO: raft.node: 6c9f385ab14331a2 changed leader from 4eee438bb97e1153 to 6c9f385ab14331a2 at term 6
~~~

Node01의 etcd Server가 제거 될때 Node02의 etcd Server는 위와 같은 Log를 남긴다. Leader Server가 제거되었기 때문에, Node02의 etcd Server가 Leader Election 과정을 통해서 Leader가 되는것을 확인할 수 있다.

#### 4.2. Follower Server 삭제

Follower로 동작하는 Node02의 etcd Server를 제거해본다.

~~~
(Node01)# docker exec -it etcd sh
(etcd Container)# etcdctl endpoint status --cluster -w table
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT         |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://192.168.0.61:2379 | 4eee438bb97e1153 |   3.4.0 |   20 kB |      true |      false |        11 |          7 |                  7 |        |
| http://192.168.0.62:2379 | 9035c191246d362c |   3.4.0 |   20 kB |     false |      false |        11 |          7 |                  7 |        |
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

(etcd Container)# etcdctl member remove 9035c191246d362c
~~~

Follower etcd Server를 etcd Cluster로부터 제거한다.

~~~
(Node01)# docker logs -f etcd
...
raft2021/03/03 17:04:23 INFO: 4eee438bb97e1153 switched to configuration voters=(5687557646807077203)
2021-03-03 17:04:23.420808 I | etcdserver/membership: removed member 9035c191246d362c from cluster 35d99f7f50aa4509
2021-03-03 17:04:23.420843 I | rafthttp: stopping peer 9035c191246d362c...
2021-03-03 17:04:23.421311 I | rafthttp: closed the TCP streaming connection with peer 9035c191246d362c (stream MsgApp v2 writer)
2021-03-03 17:04:23.421346 I | rafthttp: stopped streaming with peer 9035c191246d362c (writer)
2021-03-03 17:04:23.421918 I | rafthttp: closed the TCP streaming connection with peer 9035c191246d362c (stream Message writer)
2021-03-03 17:04:23.421951 I | rafthttp: stopped streaming with peer 9035c191246d362c (writer)
2021-03-03 17:04:23.422194 W | rafthttp: rejected the stream from peer 9035c191246d362c since it was removed
2021-03-03 17:04:23.422338 I | rafthttp: stopped HTTP pipelining with peer 9035c191246d362c
2021-03-03 17:04:23.422612 W | rafthttp: lost the TCP streaming connection with peer 9035c191246d362c (stream MsgApp v2 reader)
2021-03-03 17:04:23.422620 W | rafthttp: rejected the stream from peer 9035c191246d362c since it was removed
2021-03-03 17:04:23.422657 E | rafthttp: failed to read 9035c191246d362c on stream MsgApp v2 (context canceled)
2021-03-03 17:04:23.422667 I | rafthttp: peer 9035c191246d362c became inactive (message send to peer failed)
2021-03-03 17:04:23.422679 I | rafthttp: stopped streaming with peer 9035c191246d362c (stream MsgApp v2 reader)
2021-03-03 17:04:23.422729 W | rafthttp: lost the TCP streaming connection with peer 9035c191246d362c (stream Message reader)
2021-03-03 17:04:23.422739 I | rafthttp: stopped streaming with peer 9035c191246d362c (stream Message reader)
2021-03-03 17:04:23.422747 I | rafthttp: stopped peer 9035c191246d362c
2021-03-03 17:04:23.422757 I | rafthttp: removed peer 9035c191246d362c
~~~

Node02의 etcd Server가 제거 될때 Node01의 etcd Server는 위와 같은 Log를 남긴다. Follower Server가 제거된거라 Leader Election을 수행하지 않는것을 알 수 있다.

### 5. Learner 기능을 이용하여 Server 추가

Node03에 etcd Server 한대를 더 구동하고, Learner 기능을 이용하여 Node01, Node02의 etcd Server와 Clustering을 맺는다.

~~~
(Node01)# docker exec -it etcd sh
(etcd Container)# etcdctl member add node03 --learner --peer-urls=http://192.168.0.63:2380
Member aa9ac53bcb1de8c6 added to cluster 35d99f7f50aa4509

ETCD_NAME="node03"
ETCD_INITIAL_CLUSTER="node02=http://192.168.0.62:2380,node01=http://192.168.0.61:2380,node03=http://192.168.0.63:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.0.63:2380"
ETCD_INITIAL_CLUSTER_STATE="existing"
~~~

Node01의 etcd Server에 Node03의 etcd Member를 Learner로 추가한다.

~~~
(Node03)# export NODE01=192.168.0.61
(Node03)# export NODE02=192.168.0.62
(Node03)# export NODE03=192.168.0.63
(Node03)# export REGISTRY=gcr.io/etcd-development/etcd

(Node03)# docker run -d \
  --net=host \
  --name etcd ${REGISTRY}:v3.4.0 \
  /usr/local/bin/etcd \
  --data-dir=/etcd-data --name node03 \
  --initial-advertise-peer-urls http://${NODE03}:2380 --listen-peer-urls http://0.0.0.0:2380 \
  --advertise-client-urls http://${NODE03}:2379 --listen-client-urls http://0.0.0.0:2379 \
  --initial-cluster node01=http://${NODE01}:2380,node02=http://${NODE02}:2380,node03=http://${NODE03}:2380 \
  --initial-cluster-state existing
~~~

Node01의 etcd Server와 Clustering을 맺는다.

~~~
(Node01)# docker exec -it etcd sh
(etcd Container)# etcdctl endpoint status --cluster -w table
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT         |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://192.168.0.63:2379 | aa9ac53bcb1de8c6 |   3.4.0 |   20 kB |     false |       true |        36 |         10 |                 10 |        |
| http://192.168.0.62:2379 | 341224f3422176dd |   3.4.0 |   20 kB |     false |      false |        36 |         10 |                 10 |        |
| http://192.168.0.61:2379 | 4eee438bb97e1153 |   3.4.0 |   20 kB |      true |      false |        36 |         10 |                 10 |        |
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

(etcd Container)# etcdctl member promote aa9ac53bcb1de8c6
Member aa9ac53bcb1de8c6 promoted in cluster 35d99f7f50aa450
(etcd Container)# etcdctl endpoint status --cluster -w table
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|         ENDPOINT         |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| http://192.168.0.63:2379 | aa9ac53bcb1de8c6 |   3.4.0 |   20 kB |     false |      false |        36 |         12 |                 12 |        |
| http://192.168.0.62:2379 | 341224f3422176dd |   3.4.0 |   20 kB |     false |      false |        36 |         12 |                 12 |        |
| http://192.168.0.61:2379 | 4eee438bb97e1153 |   3.4.0 |   20 kB |      true |      false |        36 |         12 |                 12 |        |
+--------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
~~~

Node03의 etcd Server가 Learner 상태였다가 promote 명령어를 통해서 Follower가 된것을 확인할 수 있다.

~~~
(Node01)# docker logs -f etcd
...
2021-03-06 13:41:09.130322 W | rafthttp: health check for peer aa9ac53bcb1de8c6 could not connect: dial tcp 192.168.0.63:2380: connect: connection refused
2021-03-06 13:41:09.130381 W | rafthttp: health check for peer aa9ac53bcb1de8c6 could not connect: dial tcp 192.168.0.63:2380: connect: connection refused
2021-03-06 13:41:09.786452 W | etcdserver: failed to reach the peerURL(http://192.168.0.63:2380) of member aa9ac53bcb1de8c6 (Get http://192.168.0.63:2380/version: dial tcp 192.168.0.63:2380: connect: connection refused)
2021-03-06 13:41:09.786492 W | etcdserver: cannot get the version of member aa9ac53bcb1de8c6 (Get http://192.168.0.63:2380/version: dial tcp 192.168.0.63:2380: connect: connection refused)
2021-03-06 13:41:13.787721 W | etcdserver: failed to reach the peerURL(http://192.168.0.63:2380) of member aa9ac53bcb1de8c6 (Get http://192.168.0.63:2380/version: dial tcp 192.168.0.63:2380: connect: connection refused)
2021-03-06 13:41:13.787755 W | etcdserver: cannot get the version of member aa9ac53bcb1de8c6 (Get http://192.168.0.63:2380/version: dial tcp 192.168.0.63:2380: connect: connection refused)
2021-03-06 13:41:14.130602 W | rafthttp: health check for peer aa9ac53bcb1de8c6 could not connect: dial tcp 192.168.0.63:2380: connect: connection refused
2021-03-06 13:41:14.130679 W | rafthttp: health check for peer aa9ac53bcb1de8c6 could not connect: dial tcp 192.168.0.63:2380: connect: connection refused
...
2021-03-06 13:41:25.492675 I | rafthttp: peer aa9ac53bcb1de8c6 became active
2021-03-06 13:41:25.492718 I | rafthttp: established a TCP streaming connection with peer aa9ac53bcb1de8c6 (stream Message writer)
2021-03-06 13:41:25.492901 I | rafthttp: established a TCP streaming connection with peer aa9ac53bcb1de8c6 (stream MsgApp v2 writer)
2021-03-06 13:41:25.493739 I | rafthttp: established a TCP streaming connection with peer aa9ac53bcb1de8c6 (stream Message reader)
2021-03-06 13:41:25.493797 I | rafthttp: established a TCP streaming connection with peer aa9ac53bcb1de8c6 (stream MsgApp v2 reader)
raft2021/03/06 13:42:07 INFO: 4eee438bb97e1153 switched to configuration voters=(3752102066758186717 5687557646807077203) learners=(12293354993462667462)
raft2021/03/06 13:42:15 INFO: 4eee438bb97e1153 switched to configuration voters=(3752102066758186717 5687557646807077203 12293354993462667462)
...
2021-03-06 13:42:15.610651 N | etcdserver/membership: promote member aa9ac53bcb1de8c6 in cluster 35d99f7f50aa4509
~~~

Node03의 etcd Server가 Learner로 추가되고 Follower로 Promte될때 Node01의 etcd Server는 위와 같은 Log를 남긴다.

### 6. 참조

* [https://etcd.io/docs/v3.4.0/op-guide/container/](https://etcd.io/docs/v3.4.0/op-guide/container/)
* [https://etcd.io/docs/v3.4.0/op-guide/runtime-configuration/](https://etcd.io/docs/v3.4.0/op-guide/runtime-configuration/)
* [https://etcd.io/docs/v3.4.0/learning/design-learner/](https://etcd.io/docs/v3.4.0/learning/design-learner/)