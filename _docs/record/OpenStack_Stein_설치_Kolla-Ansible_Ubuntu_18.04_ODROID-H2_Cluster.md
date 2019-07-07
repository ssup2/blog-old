---
title: OpenStack Stein 설치 / Kolla-Ansible 이용 / Ubuntu 18.04, ODROID-H2 Cluster 환경
category: Record
date: 2019-07-06T12:00:00Z
lastmod: 2019-07-06T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

![[그림 1] OpenStack Stein 설치 환경 (ODROID-H2 Cluster)]({{site.baseurl}}/images/record/OpenStack_Stein_Install_Kolla-Ansible_Ubuntu_18.04_ODROID-H2_Cluster/Environment.PNG)

[그림 1]은 ODROID-H2 Cluster로 OpenStack 설치 환경을 나타내고 있다. 상세한 환경 정보는 아래와 같다.

* OpenStack : Stein Version
* Kolla-Ansible : 8.0.0.0rc2.dev124
* Node : Ubuntu 18.04
  * ODROID-H2
    * Node 1 : Controller Node, Network Node
    * Node 2,3 : Compute Node
  * VM
    * Node 4 : Deploy Node
* Network
  * NAT Network : External Network (Provider Network), 192.168.0.0/24
      * Floating IP Range : 192.168.0.200 ~ 224
  * Private Network : Guest Network (Tanant Network), Management Network 10.0.0.0/24
* Storage
  * /dev/mmcblk0 : Root Filesystem
  * /dev/nvme0n1 : Ceph

### 3. 참조

* [https://docs.openstack.org/kolla-ansible/stein/](https://docs.openstack.org/kolla-ansible/stein)