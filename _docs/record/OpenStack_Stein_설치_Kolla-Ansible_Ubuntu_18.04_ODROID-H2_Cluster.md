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
* Node : Ubuntu 18.04, root user
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

### 2. OpenStack 구성

OpenStack의 구성요소 중에서 설치할 구성요소는 다음과 같다.

* Nova : VM을 관리한다.
* Neutron : Network를 관리한다.
* Keystone : Authentication, Authorization를 관리한다.
* Glance : VM Image를 관리한다.
* Cinder : VM Block Storage를 관리한다.
* Horizon : Web Dashboard를 제공한다.
* Ceilometer : Telemetry를 관리한다.

### 3. Package 설치

~~~
(Deploy)# apt-get install software-properties-common 
(Deploy)# apt-add-repository ppa:ansible/ansible
(Deploy)# apt-get update
(Deploy)# apt-get install python3-dev libffi-dev gcc libssl-dev python3-selinux python3-setuptools ansible
~~~

Deploy Node에 필요한 Ubuntu Package들을 설치한다.

### 4. Ansible 설정

Deploy Node에서 다른 Node에게 Password 없이 SSH로 접근할 수 있도록 설정한다.

~~~
-- Deploy Node --
(Deploy)# ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:Sp0SUDPNKxTIYVObstB0QQPoG/csF9qe/v5+S5e8hf4 root@kube02
The key's randomart image is:
+---[RSA 2048]----+
|   oBB@=         |
|  .+o+.*o        |
| .. o.+  .       |
|  o..ooo..       |
|   +.=ooS        |
|  . o.=o     . o |
|     +..    . = .|
|      o    ..o o |
|     ..oooo...o.E|
+----[SHA256]-----+
~~~

Deploy Node에서 ssh key를 생성한다. passphrase (Password)는 공백을 입력하여 설정하지 않는다. 설정하게 되면 Deploy Node에서 다른 Node로 SSH를 통해서 접근 할때마다 passphrase를 입력해야 한다.

~~~
-- Deploy Node --
(Deploy)# ssh-copy-id root@10.0.0.10
(Deploy)# ssh-copy-id root@10.0.0.11
(Deploy)# ssh-copy-id root@10.0.0.12
~~~

ssh-copy-id 명령어를 이용하여 생성한 ssh Public Key를 나머지 Node의 ~/.ssh/authorized_keys 파일에 복사한다.

### 5. Kolla-Ansible 설정

#### 5.1. Ansible Inventory 설정

#### 5.2. Kolla-Ansible Config 설정

### 6. 참조

* [https://docs.openstack.org/kolla-ansible/stein/](https://docs.openstack.org/kolla-ansible/stein)