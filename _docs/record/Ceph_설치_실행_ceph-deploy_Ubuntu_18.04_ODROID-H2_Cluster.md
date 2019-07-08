---
title: Ceph 설치, 실행 / ceph-deploy 이용 / Ubuntu 18.04, ODROID-H2 Cluster 환경
category: Record
date: 2019-07-06T12:00:00Z
lastmod: 2019-07-06T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

![[그림 1] Ceph 설치 환경 (ODROID-H2 Cluster)]({{site.baseurl}}/images/record/Ceph_Install_ceph-deploy_Ubuntu_18.04_ODROID-H2_Cluster/Environment.PNG)

[그림 1]은 ODROID-H2 Cluster로 Ceph 설치 환경을 나타내고 있다. 자세한 부분은 다음과 같다. ODROID-H2 Cluster의 주요 사양은 아래와 같다. Ceph를 File Storage와 Object Storage로는 이용하지 않을 예정이기 때문에 MDS (Meta Data Server)와 radosgw는 설치하지 않는다.

* Node : Ubuntu 18.04
  * ODROID-H2
    * Node 1 : Monitor, OSD
    * Node 2,3 : Monitor, OSD
  * VM
    * Node 4 : Deploy
* Network
  * NAT Network (External Network) : 192.168.0.0/24
  * Private Network (Ceph Network) : 10.0.0.0/24
* Storage
  * /dev/mmcblk0 : Root Filesystem
  * /dev/nvme0n1 : Ceph

### 2. Package 설치

#### 2.1. Ceph Node

~~~
(Ceph)# sudo apt install ntp
(Ceph)# sudo apt install python
~~~

ntp, python Package를 설치한다.

~~~
(Ceph)# sudo useradd -d /home/cephnode -m cephnode
(Ceph)# sudo passwd cephnode
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully

(Ceph)# echo "cephnode ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephnode
(Ceph)# sudo chmod 0440 /etc/sudoers.d/cephnode
~~~

cephnode User를 생성한다. 
* Password : cephnode

#### 2.2. Deploy Node

~~~
10.0.0.10 node01
10.0.0.20 node02
10.0.0.30 node03
~~~
<figure>
<figcaption class="caption">[파일 1] Deploy Node - /etc/hosts</figcaption>
</figure>

/etc/hosts 파일에 [파일 1]의 내용을 추가한다.

~~~
(Deploy)# wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
(Deploy)# echo deb https://download.ceph.com/debian-luminous/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
(Deploy)# sudo apt update
(Deploy)# sudo apt install ceph-deploy
~~~

ceph-deploy Package를 설치한다.

~~~
(Deploy)# sudo useradd -d /home/cephdeploy -m cephdeploy
(Deploy)# sudo passwd cephdeploy
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully

(Deploy)# echo "cephdeploy ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephdeploy
(Deploy)# sudo chmod 0440 /etc/sudoers.d/cephdeploy
~~~

cephdeploy User를 생성한다.
* Password : cephdeploy

~~~
(Deploy)# login cephdeploy
(Deploy)$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
...

(Deploy)$ ssh-copy-id cephnode@node01
(Deploy)$ ssh-copy-id cephnode@node02
(Deploy)$ ssh-copy-id cephnode@node03
~~~

SSH Key를 생성 및 복사한다.
* passphrases는 Empty 상태로 유지한다.

{% highlight text %}
Host node01
   Hostname node01
   User cephnode
Host node02
   Hostname node02
   User cephnode
Host node03
   Hostname node03
   User cephnode
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] Deploy Node - /home/cephdeploy/.ssh/config</figcaption>
</figure>

/home/cephdeploy/.ssh/config 파일을 [파일 2]와 같이 수정한다.

### 3. Ceph Cluster 구성

#### 3.1. Deploy Node

~~~
(Deploy)# login cephdeploy
(Deploy)$ mkdir my-cluster
~~~

Ceph Cluster Config 폴더를 생성한다.

~~~
(Deploy)# login cephdeploy
(Deploy)$ cd ~/my-cluster
(Deploy)$ ceph-deploy purge node01 node02 node03
(Deploy)$ ceph-deploy purgedata node01 node02 node03
(Deploy)$ ceph-deploy forgetkeys
(Deploy)$ rm ceph.*
~~~

Ceph Cluster를 초기화한다.

~~~
(Deploy)# login cephdeploy
(Deploy)$ cd ~/my-cluster
(Deploy)$ ceph-deploy new node01 node02 node03
(Deploy)$ ceph-deploy install node01 node02 node03
(Deploy)$ ceph-deploy mon create-initial
(Deploy)$ ceph-deploy admin node01 node02 node03
(Deploy)$ ceph-deploy mgr create node01 node02 node03
(Deploy)$ ceph-deploy osd create --data /dev/nvme0n1 node01
(Deploy)$ ceph-deploy osd create --data /dev/nvme0n1 node02
(Deploy)$ ceph-deploy osd create --data /dev/nvme0n1 node03
~~~

Ceph Cluster를 구축한다. MON (Monitor Daemon) 및 MGR (Manager Daemon)을 Ceph Node 01에 설치한다.

### 4. 동작 확인

~~~
(Ceph)# ceph -s
  cluster:
    id:     f2aeccb9-dac1-4271-8b06-19141d26e4cb
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum node01,node02,node03
    mgr: node01(active), standbys: node02, node03
    osd: 3 osds: 3 up, 3 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0  objects, 0 B
    usage:   3.0 GiB used, 712 GiB / 715 GiB avail
    pgs:  
~~~

Ceph Cluster가 정상적으로 구축되었는지 확인한다.

#### 4.1. Block Storage

~~~
(Ceph)# ceph osd pool create rbd 16
(Ceph)# rbd pool init rbd
~~~

Pool 생성 및 초기화를 진행한다.

~~~
(Ceph)# rbd create foo --size 4096 --image-feature layering
(Ceph)# rbd map foo --name client.admin
/dev/rbd0
~~~

Block Storage을 생성 및 Mapping 한다.

### 5. 참조

* [http://docs.ceph.com/docs/master/start/](http://docs.ceph.com/docs/master/start/)
* [https://kubernetes.io/docs/concepts/storage/storage-classes/#ceph-rbd](https://kubernetes.io/docs/concepts/storage/storage-classes/#ceph-rbd)