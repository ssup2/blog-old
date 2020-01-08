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

![[그림 1] Ceph Architecture]({{site.baseurl}}/images/theory_analysis/Ceph/Ceph_Architecture.PNG)

Ceph는 Ojbect Storage 기반 분산 Storage이다. Object Storage이지만 File Storage, Block Storage 기능도 제공하고 있다. 따라서 다양한 환경에서 Ceph가 이용되고 있다. Ceph의 가장 큰 특징은 **Single Point of Failure** 문제를 고려한 Achitecture를 채택하고 있다는 점이다. 즉 Ceph는 중앙처리 방식이 아닌 분산처리 방식을 이용하고 있고, 특정 Node에 문제가 발생하더라도 Ceph 동작에는 문제가 없도록 설계되어 있다.

#### 1.1. Storage Type

Ceph는 Object Storage, Block Storage, File Storage 3가지 Type의 Storage를 제공한다.

##### 1.1.1. Object Storage

Ceph가 Object Storage로 동작할때는 RADOS Gateway가 RADOS Cluster의 Client 역할 및 Object Storage의 Proxy 역할을 수행한다. RADOS Gateway는 RADOS Cluster 제어를 도와주는 Librados를 이용하여 Object를 저장하고 제어한다. App은 RADOS Gateway의 REST API를 이용하여 Data를 저장한다. REST API는 Account 관련 기능과 File System의 폴더 역할을 수행하는 Bucket을 관리하는 기능을 제공하며, AWS S3와 OpenStack의 Swift와 호환되는 특징을 갖는다.

RADOS Gateway는 동시에 여러대가 운영될 수 있으며 Single Point of Failure를 막기 위해서 다수의 RADOS Gateway를 운영하는 것이 좋다. RADOS Gateway간의 Load Balancing은 Ceph에서 제공하지 않고, 별도의 Load Balancer를 이용해야 한다.

##### 1.1.2. Block Storage

Ceph가 Block Storage로 동작할때는 Linux Kernel의 RDB Module이나, Librados를 기반으로하는 Librbd이 RADOS Cluster의 Client가 된다. Kernel은 RBD Module을 통해 RADOS Cluster로부터 Block Storage를 할당받고 이용 할 수 있다. QEMU는 Librbd를 통해서 VM에게 줄 Block Storage를 할당 받을 수 있다.

##### 1.1.3. File Storage

Ceph가 File Storage로 동작할때는 Linux Kernel의 Ceph File System이나 Ceph Fuse Daemon이 RADOS Cluster의 Client가 된다. Ceph Filesystem이나 Ceph Fuse를 통해서 Linux Kernel은 Ceph File Storage를 Mount 할 수 있다.

#### 1.2. RADOS Cluster

RADOS Cluster는 OSD(Object Storage Daemon), Monitor, MDS(Meta Data Server) 3가지로 구성되어 있다.

##### 1.2.1. OSD (Object Storage Daemon)

![[그림 2] Ceph Object]({{site.baseurl}}/images/theory_analysis/Ceph/Ceph_Object.PNG){: width="700px"}

OSD는 Disk에 **Object 형태**로 Data를 저장하는 Daemon이다. Object 형태로 저장한다는 의미는 Data를 **Key/Value/Metadata**로 저장한다는 의미이다. [그림 2]는 OSD가 Data를 저장하는 모습을 나타내고 있다. Data는 File System의 폴더역할을 수행하는 Namespace라는 곳에 저장된다. 위의 Object Stroage 설명에서 나오는 Bucket이 OSD의 Namespace와 동일한 개념이다. Namespace는 Files System의 폴더처럼 Tree 계층을 구성하지는 않는다. Metadata는 다시 Key/Value로 구성되어 있다.

Node의 각 Disk마다 별도의 OSD Daemon이 동작한다. Disk는 주로 XFS Filesystem으로 Format된 Disk를 이용한다. 하지만 ZFS, EXT4 Filesystem도 이용이 가능하고, 최신 버전 Ceph의 OSD는 BlueStore Backend를 이용해 별도의 Filesystem을 이용하지 않고 Disk를 직접 이용하기도 한다.

##### 1.2.2. Monitor

**Cluster Map**은 RADOS Cluster를 운영 및 유지에 필요한 정보로써 Monitor Map, OSD Map, PG Map, CRUSH Map, MDS Map으로 구성되어 있다. Monitor는 이러한 Cluster Map을 관리하고 유지하는 Daemon이다. 또한  Monitor는 Ceph의 보안을 관리하거나 Log를 남기는 기능도 담당한다. Monitor는 동시에 여러대가 운영될 수 있으며 Single Point of Failure를 막기 위해서 다수의 Monitor를 운영하는것이 좋다. Monitor는 다수의 Monitor가 운영될시 **Paxos** 알고리즘을 이용하여 각 Monitor가 저장하고 있는 Cluster Map의 Consensus를 맞춘다.

##### 1.2.3. MDS (Meta Data Server)

MDS는 POSIX 호환 File System를 제공하기 위해 필요한 Meta Data를 관리하는 Daemon으로, Ceph가 File Storage로 동작할때만 필요하다. Directory 계층 구조, Owner, Timestamp같은 File의 Meta 정보들을 Object 형태로 RADOS Cluster에 저장하고 관리한다.

![[그림 3] Ceph MDS Namespace]({{site.baseurl}}/images/theory_analysis/Ceph/Ceph_MDS_Namespace.PNG){: width="600px"}

[그림 3]은 Ceph File System의 Namespace를 나타내고 있다. Tree 모양은 File System의 Directory 구조를 나타낸다. Ceph에서는 전체 Tree 또는 Sub Tree를 Namespace라고 표현한다. 각 MDS는 하나의 Namespace만 관리하고, 관리하는 Namespace와 연관된 Meta Data만 관리한다. Namespace는 Tree의 부하상태 및 Replica 상태에 따라 동적으로 바뀐다.

##### 1.2.4. Client (Librados, RBD Module, Ceph File System)

위에서 언급한 것처럼 Librados, Kernel의 RBD Module, Kernel의 Ceph File System은 RADOS Cluster의 Client 역할을 수행한다. Client는 Ceph 관리자가 Config 파일에 써놓은 **Monitor IP List**를 통해서 Monitor에 직접 연결하여 Monitor가 관리하는 Cluster Map 정보를 얻어온다. 그 후 Client는 Cluster Map에 있는 OSD Map, MDS Map등의 정보를 이용하여 OSD, MDS에 직접 접속하여 필요한 동작을 수행한다. 각 Client와 Monitor가 저장하고 있는 Cluster Map들의 Consensus도 paxos 알고리즘을 이용하여 맞춘다.

#### 1.3. CRUSH, CRUSH Map

![[그림 4] Ceph PG, CRUSH]({{site.baseurl}}/images/theory_analysis/Ceph/Ceph_PG_CRUSH.PNG){: width="600px"}

**CRUSH**는 Object를 어느 OSD에 배치할지 결정하는 알고리즘이다. Replica 설정시 Replica의 위치까지 CRUSH를 통해 결정된다. [그림 4]는 Object가 OSD에 할당되는 과정을 나타내고 있다. Object는 Object ID의 Hashing을 통해 특정 PG (Placement Group)에 할당된다. 그리고 PG는 다시 PG ID와 CRUSH를 통해서 특정 OSD에 할당된다. [그림 4]는 Replica가 3으로 설정되어 있다고 가정하고 있다. 따라서 CRUSH는 Object 하나당 3개의 OSD를 할당한다.

![[그림 5] Ceph CRUSH Map]({{site.baseurl}}/images/theory_analysis/Ceph/Ceph_CRUSH_Map.PNG){: width="700px"}

CRUSH는 **CRUSH Map**이라는 Storage Topology를 이용한다. [그림 5]는 CRUSH Map 나타내고 있다. CRUSH Map은 **Bucket**이라는 논리적 단위의 계층으로 구성된다. Bucket은 root, region, datacentor, room, pod, pdu, row, rack, chassis, host, osd 11가지 type으로 구성되어 있다. CRUSH Map의 Leaf는 반드시 osd bucket이어야 한다.

각 Bucket은 **Weight**값을 가지고 있는데 Weight는 각 Bucket이 갖고있는 Object의 비율을 나타낸다. 만약 Bucket A의 Weight가 100이고 Bucket B의 Weight가 200이라면 Bucket B가 Bucket A보다 2배많은 Object를 갖는다는걸 의미한다. 따라서 일반적으로 osd Bucket Type의 Weight값은 OSD가 관리하는 Disk의 용량에 비례하여 설정한다. 나머지 Bucket Type의 weight는 모든 하위 Bucket의 Weight의 합이다. [그림 5]의 Bucket안에 있는 숫자는 Weight를 나타내고 있다.

CRUSH는 CRUSH Map의 root Bucket부터 시작하여 하위 Bucket을 Replica 개수 만큼 선택하고, 선택한 Bucket에서 동일한 작업을 반복하여 Leaf에 있는 osd Bucket을 찾는다. Object의 Replica 개수는 Bucket Type에 설정한 Replica에 따라 정해진다. Rack Bucket Type에는 3개의 Replica를 설정하고 Row Bucket Type에는 2개의 Replica를 설정하였다면, CRUSH는 3개의 Rack Bucket을 선택하고 선택한 Rack Bucket의 하위 Bucket인 Row Bucket을 각 Rack Bucket당 2개씩 선택하기 때문에 Object의 Replica는 6이 된다. 하위 Bucket을 선택하는 기준은 각 Bucket Type에 설정한 Bucket 알고리즘에 따라 결정된다.  Bucket 알고리즘에는 Uniform, List, Tree, Straw, Straw2가 있다.

#### 1.4. Read/Write

![[그림 6] Ceph Read/Write]({{site.baseurl}}/images/theory_analysis/Ceph/Ceph_Read_Write.PNG){: width="600px"}

Ceph의 특징 중 하나는 Ceph Client가 OSD에 바로 접근하여 Object를 관리한다는 점이다. [그림 6]은 Ceph의 Read/Write 과정을 나타내고 있다. Ceph Client는 Read/Write를 수행하기전에 **RADOS Cluster의 Monitor로부터 CRUSH Map 정보를 얻는다.** 그 후 Client는 별도의 외부 통신 없이 CRUSH Map과 CRUSH를 이용하여 접근하려는 Object가 있는 OSD의 위치를 파악할 수 있다.

CRUSH를 통해 결정된 OSD 중에서 첫번째 OSD를 **Primary OSD**라고 표현한다. Read 과정의 경우 Primary OSD만을 이용하여 Read 동작을 수행한다. Write 과정의 경우 Client는 Primary OSD에게 Object와 같이 Object의 Replica가 저장될 추가 OSD 정보도 같이 보낸다. Primary OSD는 Client로부터 Object를 다 받으면, 받은 Object를 나머지 OSD들에게 전송한다. 모든 전송이 완료된뒤 Primary OSD는 Client에게 Write Ack를 전송한다.

### 2. 참조

* [http://docs.ceph.com/docs/master/architecture/](http://docs.ceph.com/docs/master/architecture/)
* [http://yauuu.me/ride-around-ceph-crush-map.html](http://yauuu.me/ride-around-ceph-crush-map.html)
* [http://docs.ceph.com/docs/jewel/rados/configuration/mon-config-ref/](http://docs.ceph.com/docs/jewel/rados/configuration/mon-config-ref/)
* [https://www.slideshare.net/sageweil1/20150222-scale-sdc-tiering-and-ec](https://www.slideshare.net/sageweil1/20150222-scale-sdc-tiering-and-ec)
* [http://140.120.7.21/LinuxRef/CephAndVirtualStorage/VirtualStorageAndUsbHdd.html](http://140.120.7.21/LinuxRef/CephAndVirtualStorage/VirtualStorageAndUsbHdd.html)
* [https://ceph.com/wp-content/uploads/2016/08/weil-crush-sc06.pdf](https://ceph.com/wp-content/uploads/2016/08/weil-crush-sc06.pdf)
* [https://www.slideshare.net/LarryCover/ceph-open-source-storage-software-optimizations-on-intel-architecture-for-cloud-workloads](https://www.slideshare.net/LarryCover/ceph-open-source-storage-software-optimizations-on-intel-architecture-for-cloud-workloads)
* [http://www.lamsade.dauphine.fr/~litwin/cours98/Doc-cours-clouds/ceph-2009-02%5B1%5D.pdf](http://www.lamsade.dauphine.fr/~litwin/cours98/Doc-cours-clouds/ceph-2009-02%5B1%5D.pdf)
* [https://thenewstack.io/software-defined-storage-ceph-way/](https://thenewstack.io/software-defined-storage-ceph-way/)