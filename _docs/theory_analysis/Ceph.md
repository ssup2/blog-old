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

* Ceph Object Storage - Ceph가 Object Storage로 동작할때는 RADOS Gateway가 RADOS Cluster의 Client 역활 및 Object Storage의 Proxy 역활을 수행한다. RADOS Gateway는 RADOS Cluster 제어를 도와주는 Librados를 이용하여 Object를 저장하고 제어한다. App은 RADOS Gateway의 REST API를 이용하여 Data를 저장한다. RADOS Gateway는 동시에 여러대가 운영될 수 있으며 Single Point of Failure를 막기 위해서 다수의 RADOS Gateway를 운영하는 것이 좋다. RADOS Gateway간의 Load Balancing은 Ceph에서 제공하지 않고, 별도의 Load Balancer를 이용해야 한다. 

* Block Storage - Ceph가 Block Storage로 동작할때는 Linux Kernel의 RDB Module이나, Librados 기반의 Librbd이 RADOS Cluster의 Client가 된다. Kernel은 RBD Module을 통해 RADOS Cluster로부터 Block Storage를 할당받고 이용 할 수 있다. QEMU는 Librbd를 통해서 VM에게 줄 Block Storage를 할당 받을 수 있다.

* File Storage - Ceph가 File Storage로 동작할때는 Linux Kernel의 Ceph Filesystem이나 Ceph Fuse Daemon이 RADOS Cluster의 Client가 된다. Ceph Filesystem이나 Ceph Fuse를 통해서 Linux Kernel은 Ceph File Storage를 Mount 할 수 있다.

#### 1.2. RADOS Cluster

##### 1.2.1. OSD

##### 1.2.2. Monitor

##### 1.2.3. MDS

#### 1.3. CRUSH MAP

### 2. 참조

* [http://docs.ceph.com/docs/master/architecture/](http://docs.ceph.com/docs/master/architecture/)
* [https://www.slideshare.net/sageweil1/20150222-scale-sdc-tiering-and-ec](https://www.slideshare.net/sageweil1/20150222-scale-sdc-tiering-and-ec)
