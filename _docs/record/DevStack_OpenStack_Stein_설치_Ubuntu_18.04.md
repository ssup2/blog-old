---
title: DevStack을 이용하여 OpenStack Stein 설치 / Ubuntu 18.04
category: Record
date: 2019-07-01T12:00:00Z
lastmod: 2019-07-01T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

![[그림 1] DevStack 설치 환경 (ODROID-H2 Cluster)]({{site.baseurl}}/images/record/DevStack_OpenStack_Stein_Install_Ubuntu_18.04/Environment.PNG)

[그림 1]은 DevStack 설치 환경인 ODROID-H2 Cluster를 나타내고 있다. 상세한 환경 정보는 아래와 같다.

* DevStack, OpenStack : Stein Version
* Node : Ubuntu 18.04
  * Node 01 : Controller Node, Network Node
  * Node 02 : Compute Node 01
  * Node 03 : Compute Node 02
* Network
  * NAT Network : External Network (Provider Network), 192.168.0.0/24
      * Floating IP Range : 192.168.0.200 ~ 224
  * Private Network : Guest Network (Tanant Network), Management Network 10.0.0.0/24
* Ceph

### 2. DevStack 설정 및 설치

#### 2.1. Controller, Network Node

#### 2.2. Compute Node 01

#### 2.3. Compute Node 02

### 3. 참조

* [https://docs.openstack.org/devstack/stein/](https://docs.openstack.org/devstack/stein/)
* [https://docs.openstack.org/devstack/stein/configuration.html](https://docs.openstack.org/devstack/stein/configuration.html)
* [https://docs.openstack.org/devstack/stein/guides/neutron.html](https://docs.openstack.org/devstack/stein/guides/neutron.html)