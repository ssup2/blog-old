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

![[사진 1] ODROID-H2 Cluster 구성 사진]({{site.baseurl}}/images/record/ODROID-H2_Cluster_Build/Cluster_Photo.PNG)

![[그림 1] ODROID-H2 Cluster 구성]({{site.baseurl}}/images/record/ODROID-H2_Cluster_Build/Cluster.PNG)

[사진 1]은 ODROID-H2 Cluster의 실제 모습을 보여주고 있다. [그림 1]은 ODROID Cluster를 나타내고 있다. 모든 ODROID-H2의 Spec은 동일하다. 모든 Node의 Default Gateway는 Inner NAT Network로 설정되어 있다. Node 04는 VM이며 Montoring 및 Deploy Node 용도로 이용한다. ODROID-H2 Cluster의 주요 사양은 아래와 같다.

* ODROID-H2 * 3
  * CPU : 4Core, Intel Celeron J4105 Processor
  * Memory : 8GB * 2, SAMSUNG DDR4 PC4-19200
  * Root Storage : 64GB, eMMC
  * Ceph Storage : 256GB, SAMSUNG PM981 M.2 2280 
* VM * 1
  * CPU : 2Core
  * Memory: 8GB
* Network
  * Outter NAT Network : 192.168.0.0/24
  * Inner NAT Network : 10.0.0.0/24


#### 1.1. Ceph

![[그림 2] Ceph 구성 on ODROID-H2 Cluster]({{site.baseurl}}/images/record/ODROID-H2_Cluster_Build/Ceph.PNG)

[그림 2]는 Ceph 구성시 필요한 구성 요소를 나타내고 있다. Node 01은 Ceph의 Monitor, Manager, OSD Node로 이용한다. Node 02, 03은 OSD Node로만 이용한다. 각 Node의 M.2 Storage를 OSD의 Block Storage로 이용한다. Ceph의 File Storage와 Object Storage는 이용하지 않을 예정이기 때문에 Ceph의 MDS (Meta Data Server)와 radosgw는 설치하지 않는다. Ceph Network로 Inner NAT Network를 이용한다.

#### 1.2. OpenStack

![[그림 3] OpenStack 구성 on ODROID-H2 Cluster]({{site.baseurl}}/images/record/ODROID-H2_Cluster_Build/OpenStack.PNG)

[그림 3]은 OpenStack 구성시 필요한 구성 요소를 나타내고 있다. Node 01은 OpenStack의 Controller Node와 Network Node로 이용하고, Node 02, 03은 OpenStack의 Compute Node로 이용한다. External Network (Provider Network)로 Outter NAT Network를 이용한다. OpenStack은 Network, Compute Node의 External Network와 연결되어 있는 Interface에는 IP를 할당하지 않는다. 따라서 enp0s2 Interface에는 IP를 할당하지 않는다. Guest (Tenant Network), Management Network는 Inner NAT Network를 이용한다.

### 2. 참조

* [https://docs.openstack.org/devstack/stein/guides/neutron.html](https://docs.openstack.org/devstack/stein/guides/neutron.html)