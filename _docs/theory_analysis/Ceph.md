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

Monitor는 OSD의 상태를 관리하는 Daemon이다. Monitor는 OSD 상태를 주기적으로 감시하면서 **Cluster Map**을 생성하고 관리한다. OSD Client는 Monitor가 가지고 있는 Cluster Map 정보를 바탕으로 CRUSH MAP 알고리즘을 이용하여 원하는 Object가 어느 OSD에 있는지 파악하게 된다.

Monitor는 동시에 여러대가 운영될 수 있으며 Single Point of Failure를 막기 위해서 다수의 Monitor를 운영하는것이 좋다. Monitor는 **Paxos** 알고리즘을 이용하여 다수의 Monitor가 운영될 시 Monitor간의 Consensus를 맞춘다.

##### 1.2.3. MDS (Meta Data Server)

![]({{site.baseurl}}/images/theory_analysis/Ceph/Ceph_MDS_Namespace.PNG){: width="600px"}

MDS는 POSIX 호환 File System를 제공하기 위해 필요한 Meta Data를 저장하는 Daemon으로, Ceph가 File Storage로 동작할때만 필요하다. Directory 계층 구조, Owner, Timestamp같은 File의 Meta 정보들을 저장하고 있다.

#### 1.3. CRUSH MAP

![]({{site.baseurl}}/images/theory_analysis/Ceph/Ceph_PG_CRUSH.PNG){: width="600px"}

![]({{site.baseurl}}/images/theory_analysis/Ceph/Ceph_CRUSH_Map.PNG){: width="700px"}

#### 1.4. Read/Write

![]({{site.baseurl}}/images/theory_analysis/Ceph/Ceph_Read_Write.PNG){: width="600px"}

### 2. 참조

* [http://docs.ceph.com/docs/master/architecture/](http://docs.ceph.com/docs/master/architecture/)
* [http://docs.ceph.com/docs/jewel/rados/configuration/mon-config-ref/](http://docs.ceph.com/docs/jewel/rados/configuration/mon-config-ref/)
* [https://www.slideshare.net/sageweil1/20150222-scale-sdc-tiering-and-ec](https://www.slideshare.net/sageweil1/20150222-scale-sdc-tiering-and-ec)
* [http://140.120.7.21/LinuxRef/CephAndVirtualStorage/VirtualStorageAndUsbHdd.html](http://140.120.7.21/LinuxRef/CephAndVirtualStorage/VirtualStorageAndUsbHdd.html)
* [https://ceph.com/wp-content/uploads/2016/08/weil-crush-sc06.pdf](https://ceph.com/wp-content/uploads/2016/08/weil-crush-sc06.pdf)

* [https://www.slideshare.net/LarryCover/ceph-open-source-storage-software-optimizations-on-intel-architecture-for-cloud-workloads](https://www.slideshare.net/LarryCover/ceph-open-source-storage-software-optimizations-on-intel-architecture-for-cloud-workloads)
