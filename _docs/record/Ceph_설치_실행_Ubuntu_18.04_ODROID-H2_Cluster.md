---
title: Ceph 설치, 실행 - Ubuntu 18.04, ODROID-H2 Cluster
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

### 1. 설치  환경

![[그림 1] Ceph 설치를 위한 Node 구성도]({{site.baseurl}}/images/record/Ceph_Install_Ubuntu_18.04_ODROID-H2_Cluster/Environment.PNG)

[그림 1] ODROID-H2 Cluster로 Ceph 설치 환경을 나타내고 있다. 자세한 부분은 다음과 같다. ODROID-H2 Cluster의 주요 사양은 아래와 같다. Ceph를 File Storage와 Object Storage로는 이용하지 않을 예정이기 때문에 MDS (Meta Data Server)와 radosgw는 설치하지 않는다.

* Node : ODROID-H2 * 3
  * Node 1 : Deploy, Monitor, OSD
  * Node 2,3 : Monitor, OSD
* Network
  * NAT Network (External Network) : 192.168.0.0/24
  * Private Network (Ceph Network) : 10.0.0.0/24
* Storage
  * Root : eMMC 64GB
  * Ceph : SAMSUNG PM981 M.2 2280 256GB

### 2. Package 설치

#### 2.1. Ceph Node

~~~
# sudo apt install ntp
# sudo apt install python
~~~

ntp, python Package를 설치한다.

~~~
# sudo useradd -d /home/cephnode -m cephnode
# sudo passwd cephnode
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully

# echo "cephnode ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephnode
# sudo chmod 0440 /etc/sudoers.d/cephnode
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
<figcaption class="caption">[파일 1] Deploy Node의 /etc/hosts</figcaption>
</figure>

/etc/hosts 파일에 [파일 1]의 내용을 추가한다.

~~~
# wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
# echo deb https://download.ceph.com/debian-luminous/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
# sudo apt update
# sudo apt install ceph-deploy
~~~

ceph-deploy Package를 설치한다.

~~~
# sudo useradd -d /home/cephdeploy -m cephdeploy
# sudo passwd cephdeploy
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully

# echo "cephdeploy ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephdeploy
# sudo chmod 0440 /etc/sudoers.d/cephdeploy
~~~

cephdeploy User를 생성한다.
* Password : cephdeploy

~~~
# login cephdeploy
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
...

$ ssh-copy-id cephnode@node01
$ ssh-copy-id cephnode@node02
$ ssh-copy-id cephnode@node03
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
<figcaption class="caption">[파일 2] Deploy Node의 /home/cephdeploy/.ssh/config</figcaption>
</figure>

/home/cephdeploy/.ssh/config 파일을 [파일 2]와 같이 수정한다.

### 3. Ceph Cluster 구성

#### 3.1. Deploy Node

~~~
# login cephdeploy
$ mkdir my-cluster
~~~

Ceph Cluster Config 폴더를 생성한다.

~~~
# login cephdeploy
$ cd ~/my-cluster
$ ceph-deploy purge node01 node02 node03
$ ceph-deploy purgedata node01 node02 node03
$ ceph-deploy forgetkeys
$ rm ceph.*
~~~

Ceph Cluster를 초기화한다.

~~~
# login cephdeploy
$ cd ~/my-cluster
$ ceph-deploy new node01 node02 node03
$ ceph-deploy install node01 node02 node03
$ ceph-deploy mon create-initial
$ ceph-deploy admin node01 node02 node03
$ ceph-deploy mgr create node01 node02 node03
$ ceph-deploy osd create --data /dev/nvme0n1 node01
$ ceph-deploy osd create --data /dev/nvme0n1 node02
$ ceph-deploy osd create --data /dev/nvme0n1 node03
~~~

Ceph Cluster를 구축한다. MON (Monitor Daemon) 및 MGR (Manager Daemon)을 Ceph Node 01에 설치한다.

~~~
$ sudo ceph -s
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

### 4. Block Storage Test

#### 4.1. Ceph Node

~~~
# ceph osd pool create rbd 16
# rbd pool init rbd
~~~

Pool 생성 및 초기화를 진행한다.

~~~
# rbd create foo --size 4096 --image-feature layering
# rbd map foo --name client.admin
/dev/rbd0
~~~

Block Storage을 생성 및 Mapping 한다.

### 5. 참조

* [http://docs.ceph.com/docs/master/start/](http://docs.ceph.com/docs/master/start/)
* [https://kubernetes.io/docs/concepts/storage/storage-classes/#ceph-rbd](https://kubernetes.io/docs/concepts/storage/storage-classes/#ceph-rbd)