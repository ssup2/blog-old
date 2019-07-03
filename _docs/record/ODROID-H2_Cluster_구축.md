---
title: ODROID-H2 Cluster 구축
category: Record
date: 2019-07-01T12:00:00Z
lastmod: 2019-07-01T12:00:00Z
comment: true
adsense: true
---

Ceph, Openstack 설치를 위한 ODROID-H2 Cluster를 구축한다.

### 1. ODROID-H2 Cluster

![[그림 1] ODROID-H2 Cluster 구성]({{site.baseurl}}/images/record/ODROID-H2_Cluster_Build/Cluster.PNG)

[사진 1]은 ODROID-H2 Cluster의 실제 모습을 보여주고 있다. [그림 1]은 ODROID Cluster를 나타내고 있다. 모든 ODROID-H2의 Spec은 동일하다. ODROID-H2 Cluster의 주요사양은 아래와 같다.

* Node : ODROID-H2 * 3
* CPU : Intel Celeron J4105 Processor
* Memory : SAMSUNG DDR4 8G PC4-19200 * 2
* Network : 1Gbps NIC * 2
  * NAT Network : 192.168.0.0/24
  * Private Network : 10.0.0.0/24
* Storage
  * Root : eMMC 64GB
  * Ceph : SAMSUNG PM981 M.2 2280 256GB

#### 1.1. Ceph

![[그림 2] Ceph 구성 on ODROID-H2 Cluster]({{site.baseurl}}/images/record/ODROID-H2_Cluster_Build/Ceph.PNG)

#### 1.2. OpenStack

![[그림 3] OpenStack 구성 on ODROID-H2 Cluster]({{site.baseurl}}/images/record/ODROID-H2_Cluster_Build/OpenStack.PNG)

### 2. 참조

* [https://docs.openstack.org/devstack/stein/guides/neutron.html](https://docs.openstack.org/devstack/stein/guides/neutron.html)