---
title: Ceph
category: Theory, Analysis
date: 2018-05-14T12:00:00Z
lastmod: 2018-05-15T12:00:00Z
comment: true
adsense: true
---

분산 Storage로 많이 이용되고 있는 Ceph를 분석한다.

### 1. Ceph

![]({{site.baseurl}}/images/theory_analysis/Ceph/Ceph_Architecture.PNG)

Ceph는 Ojbect Storage 기반 분산 Storage이다. Object Storage이지만 File Storage, Block Storage 기능도 제공하고 있다. 따라서 다양한 환경에서 Ceph가 이용되고 있다. Ceph의 가장 큰 특징은 **Single Point of Failure** 문제를 고려한 Achitecture를 채택하고 있다는 점이다. 즉 Ceph는 중앙처리 방식이 아닌 분산처리 방식을 이용하고 있고, 특정 Node에 문제가 발생하더라도 Ceph 동작에는 문제가 없도록 설계되어 있다.

#### 1.1. Storage Type

Ceph는 Object Storage, Block Storage, File Storage 3가지 Type의 Storage를 제공한다.

##### 1.1.1. Object Storage

Ceph가 Object Storage로 동작할때는 RADOS Gateway가 RADOS Cluster의 Client 역활 및 Object Storage의 Proxy 역활을 수행한다. RADOS Gateway는 RADOS Cluster 제어를 도와주는 Librados를 이용하여 Object를 저장하고 제어한다. App은 RADOS Gateway의 REST API를 이용하여 Data를 저장한다. REST API는 Account 관련 기능과 File System의 폴더 역활을 수행하는 Bucket을 관리하는 기능을 제공하며, AWS S3와 OpenStack의 Swift와 호환되는 특징을 갖는다.

RADOS Gateway는 동시에 여러대가 운영될 수 있으며 Single Point of Failure를 막기 위해서 다수의 RADOS Gateway를 운영하는 것이 좋다. RADOS Gateway간의 Load Balancing은 Ceph에서 제공하지 않고, 별도의 Load Balancer를 이용해야 한다.

##### 1.1.2. Block Storage

Ceph가 Block Storage로 동작할때는 Linux Kernel의 RDB Module이나, Librados 기반의 Librbd이 RADOS Cluster의 Client가 된다. Kernel은 RBD Module을 통해 RADOS Cluster로부터 Block Storage를 할당받고 이용 할 수 있다. QEMU는 Librbd를 통해서 VM에게 줄 Block Storage를 할당 받을 수 있다.

##### 1.1.3. File Storage

Ceph가 File Storage로 동작할때는 Linux Kernel의 Ceph File System이나 Ceph Fuse Daemon이 RADOS Cluster의 Client가 된다. Ceph Filesystem이나 Ceph Fuse를 통해서 Linux Kernel은 Ceph File Storage를 Mount 할 수 있다.

#### 1.2. RADOS Cluster

RADOS Cluster는 OSD(Object Storage Daemon), Monitor, MDS(Meta Data Server) 3가지로 구성되어 있다.

##### 1.2.1. OSD (Object Storage Daemon)

OSD는 Disk에 Object의 형태로 Data를 저장하는 Daemon이다. brctl, xfs, ext4 Filesystem으로 Format된 Disk마다 별도의 OSD가 동작한다. 최신 버전 Ceph의 OSD는 별도의 Filesystem을 이용하지 않고 Disk를 직접 제어하는 형태로도 동작이 가능하다.

##### 1.2.2. Monitor

Monitor는 OSD Map, MDS Map, CRUSH Map, Monitor Map 등과 같은 RADOS Cluster 상태 정보를 관리하고 유지하는 Daemon이다. 또한 Ceph의 보안을 관리하거나 Log를 남기는 기능도 담당한다. Monitor는 동시에 여러대가 운영될 수 있으며 Single Point of Failure를 막기 위해서 다수의 Monitor를 운영하는것이 좋다. Monitor는 **Paxos** 알고리즘을 이용하여 다수의 Monitor가 운영될 시 Monitor간의 Consensus를 맞춘다.

##### 1.2.3. MDS (Meta Data Server)

MDS는 POSIX 호환 File System를 제공하기 위해 필요한 Meta Data를 관리하는 Daemon으로, Ceph가 File Storage로 동작할때만 필요하다. Directory 계층 구조, Owner, Timestamp같은 File의 Meta 정보들을 Object 형태로 RADOS Cluster에 저장하고 관리한다.

![]({{site.baseurl}}/images/theory_analysis/Ceph/Ceph_MDS_Namespace.PNG){: width="600px"}

위의 그림은 Ceph File System의 Namespace를 나타내고 있다. Tree 모양은 File System의 Directory 구조를 나타낸다. Ceph에서는 전체 Tree 또는 Sub Tree를 Namespace라고 표현한다. 각 MDS는 하나의 Namespace만 관리하고, 관리하는 Namespace와 연관된 Meta Data만 관리한다. Namespace는 Tree의 부하상태 및 Replica 상태에 따라 동적으로 바뀐다.

#### 1.3. CRUSH, CRUSH Map

![]({{site.baseurl}}/images/theory_analysis/Ceph/Ceph_PG_CRUSH.PNG){: width="600px"}

**CRUSH**는 Object를 어느 OSD에 배치할지 결정하는 알고리즘이다. Replica 설정시 Replica의 위치까지 CRUSH를 통해 결정된다. 위의 그림은 Object가 OSD에 할당되는 과정을 나타내고 있다. Object는 Hashing을 통해 특정 PG(Placement Group)에 할당된다. 그리고 PG는 다시 CRUSH를 통해서 특정 OSD에 할당된다. 위의 그림은 Replica가 3으로 설정되어 있다고 가정하고 있다. 따라서 CRUSH은 3개의 OSD를 할당한다.

![]({{site.baseurl}}/images/theory_analysis/Ceph/Ceph_CRUSH_Map.PNG){: width="700px"}

CRUSH는 **CRUSH Map**이라는 Storage Topology를 용한다. 위의 그림은 CRUSH Map 나타내고 있다. CRUSH Map은 **Bucket**이라는 논리적 단위의 계층으로 구성된다. Bucket은 root, region, datacentor, room, pod, pdu, row, rack, chassis, host, osd 11가지 type으로 구성되어 있다. CRUSH Map의 Leaf는 반드시 osd bucket이어야 한다. Bucket은 **Weight**값을 가지고 있는데 일반적으로 osd Bucket의 Weight값은 OSD가 관리하는 Disk의 용량에 비례하여 설정한다. 나머지 Bucket type의 weight는 모든 하위 Bucket의 Weight의 합이다.

CRUSH는 CRUSH Map의 root Bucket부터 시작하여 하위 Bucket을 Replica 개수 만큼 선택하고, 선택한 Bucket에서 동일한 작업을 반복하여 Leaf에 있는 osd Bucket을 찾는 알고리즘이다. 따라서 Ceph의 Replica 개수, 위치는 CRUSH Map에 따라 정해진다. Rack Bucket에 3개의 Replica를 설정해 놓으면 3개의 Replica는 CRUSH에 의해 선택된 3개의 Rack에 하나씩 존재하게 된다.

각 Bucket은 자신의 하위 Bucket을 어떤 알고리즘을 이용하여 관리할지 설정 할 수 있다. 알고리즘은 Uniform, List, Tree, Straw 방식을 지원한다. 알고리즘 성능은 하위 Bucket을 찾는 속도와, CRUSH MAP이 변경에 따른 Object Rebalancing 소요 시간을 비교하여 분석한다.

##### 1.3.1. Uniform

Uniform 알고리즘은 하위 Bucket들을 **Consistency Hashing**을 이용하여 관리한다. Hashing 기반이기 때문에 O(1) 시간에 하위 Bucket을 찾을 수 있다. 하지만 Bucket이 추가되거나 제거될 경우 Hashing 결과가 달라지기 때문에 Rebalancing에 많은 시간이 소요된다. Uniform Bucket은 모든 Bucket의 Weight가 동일하다는 가정에 진행된다. Bucket 마다 다른 Weight를 주고 싶으면 다른 Bucket Type을 이용해야 한다.

##### 1.3.2. List

List 알고리즘은 하위 Bucket들을 **Linked List**를 이용하여 관리한다. 하위 Bucket을 찾는 경우 Linked List를 순회 해야하기 때문에 O(n) 시간이 걸린다. 따라서 하위 Bucket의 개수가 많아질 경우 탐색시간이 느린 단점을 갖고 있다.

Linked List에 Bucket이 추가되는 경우 Linked List의 가장 앞에 추가된다. Bucket이 추가되는 경우, 기존 Bucket들의 하위 Bucket 중 일부만 추가된 Bucket의 하위 Bucket으로 옮기기만 하면 되기 때문에 비교적 빠른 Rebalancing이 가능하다. 하지만 Linked List의 중간이나 마지막 Bucket 제거 또는 Bucket의 Weight 변경이 발생하는 경우 하위 Bucket들을 전반적으로 옮겨야 하기 때문에 Rebalancing에 많은 시간이 소요된다.

##### 1.3.3. Tree

Tree 알고리즘은 하위 Bucket을 **Weighted Binary Search Tree**를 이용한다. Tree의 끝에 하위 Bucket들이 달려있다. Tree 기반이기 때문에 하위 Bucket 탐색에 O(log n) 시간이 걸린다. Tree의 Left/Right Weight는 Left/Write Subtree에 속한 모든 Bucket들의 Weight의 합과 동일하다.

Tree에 Bucket 추가,제거 또는 Bucket의 Weight 변경이 발생하는 경우 Weighted Binary Search Tree의 일부 Weight에만 영향을 주기 때문에 일부 Bucket의 하위 Bucket들만 Rebalancing에 참여해도 된다. 따라서 비교적 빠른 Rebalancing이 가능하다.

##### 1.3.4. Straw

알고리즘 Straw Bucket은 하위 Bucket별로 Straw를 뽑아 **Straw의 길이가 가장 긴 Bucket을 선택**하는 방식이다. Straw의 길이는 **각 Bucket의 Weight에 영향을 받는 Hashing**을 이용한다. Bucket의 Weight가 클수록 긴 길이의 Straw를 할당 받을 확률이 높아진다. 모든 하위 Bucket을 대상으로 Hashing을 수행해야 하기 때문에 하위 Bucket 선택에 O(n)의 시간이 걸린다.

Straw에 Bucket 추가,제거 또는 Bucket의 Weight가 변경되더라도 각 Bucket별로 수행한 Hashing을 이용하는 방식이기 때문에 영향받은 Bucket에 속한 하위 Bucket들만 Rebalancing을 수행하면 된다. 따라서 빠른 Rebalancing이 가능하다.

#### 1.4. Read/Write

![]({{site.baseurl}}/images/theory_analysis/Ceph/Ceph_Read_Write.PNG){: width="600px"}

Ceph의 특징 중 하나는 Ceph Client가 OSD에 바로 접근하여 Object를 관리한다는 점이다. 위의 그림은 Ceph의 Read/Write 과정을 나타내고 있다. Ceph Client는 RADOS Cluster의 Monitor로부터 CRUSH Map 정보를 받는다. 그 후 Client는 별도의 외부 통신 없이 CRUSH Map과 CRUSH를 통해서 접근하려는 Object가 있는 OSD의 위치를 파악 할 수 있다.

CRUSH를 통해 결정된 OSD 중에서 첫번째 OSD를 **Primary OSD**라고 표현한다. Read 과정의 경우 Primary OSD만을 이용하여 Read 동작을 수행한다. Write 과정의 경우 Client는 Primary OSD에게 Object와 같이 Object의 Replica가 저장될 추가 OSD 정보도 같이 보낸다. Primary OSD는 Client로 부터 Object는 다 받으면 받은 Object를 모든 추가 OSD에게 전송한다. 모든 전송이 완료된뒤 Primary OSD는 Client에게 Write Ack를 전송한다.

### 2. 참조

* [http://docs.ceph.com/docs/master/architecture/](http://docs.ceph.com/docs/master/architecture/)
* [http://yauuu.me/ride-around-ceph-crush-map.html](http://yauuu.me/ride-around-ceph-crush-map.html)
* [http://docs.ceph.com/docs/jewel/rados/configuration/mon-config-ref/](http://docs.ceph.com/docs/jewel/rados/configuration/mon-config-ref/)
* [https://www.slideshare.net/sageweil1/20150222-scale-sdc-tiering-and-ec](https://www.slideshare.net/sageweil1/20150222-scale-sdc-tiering-and-ec)
* [http://140.120.7.21/LinuxRef/CephAndVirtualStorage/VirtualStorageAndUsbHdd.html](http://140.120.7.21/LinuxRef/CephAndVirtualStorage/VirtualStorageAndUsbHdd.html)
* [https://ceph.com/wp-content/uploads/2016/08/weil-crush-sc06.pdf](https://ceph.com/wp-content/uploads/2016/08/weil-crush-sc06.pdf)
* [https://www.slideshare.net/LarryCover/ceph-open-source-storage-software-optimizations-on-intel-architecture-for-cloud-workloads](https://www.slideshare.net/LarryCover/ceph-open-source-storage-software-optimizations-on-intel-architecture-for-cloud-workloads)
* [http://www.lamsade.dauphine.fr/~litwin/cours98/Doc-cours-clouds/ceph-2009-02%5B1%5D.pdf](http://www.lamsade.dauphine.fr/~litwin/cours98/Doc-cours-clouds/ceph-2009-02%5B1%5D.pdf)
