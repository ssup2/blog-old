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
(Node01)# export DATA_DIR="etcd-data"

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
(Node02)# export DATA_DIR="etcd-data"

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

### 4. Member 삭제

#### 4.1. Leader etcd Server를 제거

#### 4.2. Follower etcd Server를 제거

### 5. Learner

### 6. 참조

* [https://etcd.io/docs/v3.4.0/op-guide/container/](https://etcd.io/docs/v3.4.0/op-guide/container/)
* [https://etcd.io/docs/v3.4.0/op-guide/runtime-configuration/](https://etcd.io/docs/v3.4.0/op-guide/runtime-configuration/)
* [https://etcd.io/docs/v3.4.0/learning/design-learner/](https://etcd.io/docs/v3.4.0/learning/design-learner/)