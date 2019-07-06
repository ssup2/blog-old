---
title: OpenStack Rocky 설치 / Ansible 이용 / Ubuntu 18.04, ODROID-H2 Cluster 환경
category: Record
date: 2019-07-06T12:00:00Z
lastmod: 2019-07-06T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

![[그림 1] OpenStack Rocky 설치 환경 (ODROID-H2 Cluster)]({{site.baseurl}}/images/record/OpenStack_Rocky_Install_Ansible_Ubuntu_18.04_ODROID-H2_Cluster/Environment.PNG)

[그림 1]은 ODROID-H2 Cluster로 OpenStack 설치 환경을 나타내고 있다. 상세한 환경 정보는 아래와 같다.

* Ansible, OpenStack : Rocky Version
* Node : Ubuntu 18.04
  * Node 01 : Controller Node, Network Node
  * Node 02 : Compute Node 01
  * Node 03 : Compute Node 02
  * Node 04 : Deploy Node
* Network
  * NAT Network : External Network (Provider Network), 192.168.0.0/24
      * Floating IP Range : 192.168.0.200 ~ 224
  * Private Network : Guest Network (Tanant Network), Management Network 10.0.0.0/24
* Ceph

### 2. 참조

* [https://docs.openstack.org/project-deploy-guide/openstack-ansible/rocky/index.html](https://docs.openstack.org/project-deploy-guide/openstack-ansible/rocky/index.html)