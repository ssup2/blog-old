---
title: Ceph 설치, 실행 - Ubuntu 18.04
category: Record
date: 2019-01-10T12:00:00Z
lastmod: 2019-01-10T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설정 환경

* Ubuntu 18.04 LTS 64bit, root user
* Ceph Luminous Version

### 2. Node 설정

![]({{site.baseurl}}/images/record/Ceph_Install_Ubuntu_18.04/Node_Setting.PNG)

* VirtualBox를 이용하여 위의 그림과 같이 가상의 Node (VM)을 생성한다.
* Hostname : Master Node - node1, Worker Node1 - node2, Worker Node2 - node3
* NAT : Virtual Box에서 제공하는 "NAT 네트워크" 이용하여 10.0.0.0/24 Network를 구축한다.
* HDD : 각 Node에 Ceph가 이용할 추가 HDD (/dev/sdb)를 생성하고 붙인다.
* Router : 공유기를 이용하여 192.168.0.0/24 Network를 구축한다. (NAT)

#### 2.1. Ceph Node

* Ceph Node 01의 /etc/netplan directory의 모든 파일을 삭제하고 /etc/netplan/01-network.yaml 파일을 작성한다.

~~~
network:
    version: 2
    ethernets:
        enp0s3:
            dhcp4: no
            addresses: [10.0.0.10/24]
            gateway4: 10.0.0.1
            nameservers:
                addresses: [8.8.8.8]
        enp0s8:
            dhcp4: no
            addresses: [192.168.0.150/24]
            nameservers:
                addresses: [8.8.8.8]
~~~

* Ceph Node 02의 /etc/netplan directory의 모든 파일을 삭제하고 /etc/netplan/01-network.yaml 파일을 작성한다.

~~~
network:
    version: 2
    ethernets:
        enp0s3:
            dhcp4: no
            addresses: [10.0.0.20/24]
            gateway4: 10.0.0.1
            nameservers:
                addresses: [8.8.8.8]
~~~

* Ceph Node 03의 /etc/netplan directory의 모든 파일을 삭제하고 /etc/netplan/01-network.yaml 파일을 작성한다.

~~~
network:
    version: 2
    ethernets:
        enp0s3:
            dhcp4: no
            addresses: [10.0.0.30/24]
            gateway4: 10.0.0.1
            nameservers:
                addresses: [8.8.8.8]
~~~

### 3. Package 설치

#### 3.1. Ceph Node

* ntp Package를 설치한다.

~~~
# sudo apt install ntp
# sudo apt install python
~~~

* cephnode User를 생성한다. 
  * Password : cephnode

~~~
# sudo useradd -d /home/cephnode -m cephnode
# sudo passwd cephnode
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully

# echo "cephnode ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephnode
# sudo chmod 0440 /etc/sudoers.d/cephnode
~~~

#### 3.2. Deploy Node

* /etc/host 파일에 아래의 내용을 추가한다.

~~~
10.0.0.10 node1
10.0.0.20 node2
10.0.0.30 node3
~~~

* ceph-deploy Package를 설치한다.

~~~
# wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
# echo deb https://download.ceph.com/debian-luminous/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
# sudo apt update
# sudo apt install ceph-deploy
~~~

* cephdeploy User를 생성한다. 
  * Password : cephdeploy

~~~
# sudo useradd -d /home/cephdeploy -m cephdeploy
# sudo passwd cephdeploy
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully

# echo "cephdeploy ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephdeploy
# sudo chmod 0440 /etc/sudoers.d/cecephdeployphnode
~~~

* SSH Key를 생성 및 복사한다.
  * passphrases는 Empty 상태로 유지한다.

~~~
# login cephdeploy
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
...

$ ssh-copy-id cephnode@node1
$ ssh-copy-id cephnode@node2
$ ssh-copy-id cephnode@node3
~~~

* /home/cephdeploy/.ssh/config 파일을 다음과 같이 수정한다.

~~~
Host node1
   Hostname node1
   User cephnode
Host node2
   Hostname node2
   User cephnode
Host node3
   Hostname node3
   User cephnode
~~~

### 4. Storage Cluster 구성

#### 4.1. Depoly Node

* Storage Cluster Config 폴더를 생성한다.

~~~
# login cephdeploy
$ mkdir my-cluster
~~~

* Storage Cluster를 초기화한다.

~~~
# login cephdeploy
$ cd ~/my-cluster
$ ceph-deploy purge node1 node2 node3
$ ceph-deploy purgedata node1 node2 node3
$ ceph-deploy forgetkeys
$ rm ceph.*
~~~

* Storage Cluster를 구축 및 확인한다.
  * MON (Monitor Daemon)은 Ceph Node 01에 설치한다.

~~~
# login cephdeploy
$ cd ~/my-cluster
$ ceph-deploy new node1
$ ceph-deploy install node1 node2 node3
$ ceph-deploy mon create-initial
$ ceph-deploy admin node1 node2 node3
$ ceph-deploy mgr create node1
$ ceph-deploy osd create --data /dev/sdb node1
$ ceph-deploy osd create --data /dev/sdb node2
$ ceph-deploy osd create --data /dev/sdb node3
$ sudo ceph -s
  cluster:
    id:     20261612-97fc-4a45-bd81-0d9c9b445e00
    health: HEALTH_OK

  services:
    mon: 1 daemons, quorum node1
    mgr: node1(active)
    osd: 3 osds: 3 up, 3 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0  objects, 0 B
    usage:   3.0 GiB used, 597 GiB / 600 GiB avail
    pgs:   
~~~

* MDS (Meta Data Server)를 설치한다.
  * MDS은 Ceph Node 01에 설치한다.

~~~
# login cephdeploy
$ cd ~/my-cluster
$ ceph-deploy mds create node1
$ sudo ceph -s
  cluster:
    id:     20261612-97fc-4a45-bd81-0d9c9b445e00
    health: HEALTH_OK

  services:
    mon: 1 daemons, quorum node1
    mgr: node1(active)
    osd: 3 osds: 3 up, 3 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0  objects, 0 B
    usage:   3.0 GiB used, 597 GiB / 600 GiB avail
    pgs:  
~~~

* RGW (Rados Gateway)를 설치한다.
  * RGW는 Ceph Node 01에 설치한다.

~~~
# login cephdeploy
$ cd ~/my-cluster
$ ceph-deploy rgw create node1
$ sudo ceph -s 
  cluster:
    id:     20261612-97fc-4a45-bd81-0d9c9b445e00
    health: HEALTH_OK

  services:
    mon: 1 daemons, quorum node1
    mgr: node1(active)
    osd: 3 osds: 3 up, 3 in
    rgw: 1 daemon active

  data:
    pools:   4 pools, 32 pgs
    objects: 187  objects, 1.1 KiB
    usage:   3.0 GiB used, 597 GiB / 600 GiB avail
    pgs:     32 active+clean
~~~

### 5. Block Storage Test

#### 5.1. Ceph Node

* Pool 생성 및 초기화를 진행한다.

~~~
# ceph osd pool create rbd 16
# rbd pool init rbd
~~~

* Block Storage을 생성 및 Mapping 한다.

~~~
# rbd create foo --size 4096 --image-feature layering
# rbd map foo --name client.admin
/dev/rbd0
~~~

### 6. File Storage Test

#### 6.1. Ceph Node

* Pool 생성 및 File Storage를 생성한다.

~~~
# ceph osd pool create cephfs_data 16
# ceph osd pool create cephfs_metadata 16
# ceph fs new filesystem cephfs_metadata cephfs_data
~~~

* admin Key 확인 및 admin.secret 파일을 생성한다.

~~~
# cat /home/cephdeploy/my-cluster/ceph.client.admin.keyring
[client.admin]
        key = AQAk1SxcbTz/IBAAHCPTQ5x1SHFcA0fn2tTW7w==
        caps mds = "allow *"
        caps mgr = "allow *"
        caps mon = "allow *"
        caps osd = "allow *"

# vim admin.secret
AQAk1SxcbTz/IBAAHCPTQ5x1SHFcA0fn2tTW7w==
~~~

* Ceph File Server를 Mount 한다.

~~~
# mkdir mnt
# mount -t ceph 10.0.0.10:6789:/ mnt/ -o name=admin,secretfile=admin.secret
# mount
...
10.0.0.10:6789:/ on /root/test/ceph/mnt type ceph (rw,relatime,name=admin,secret=<hidden>,acl,wsize=16777216)
~~~

### 7. Object Storage Test

#### 7.1. Ceph Node

* RGW 동작을 확인한다.

~~~
# curl 127.0.0.1:7480
<?xml version="1.0" encoding="UTF-8"?><ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>anonymous</ID><DisplayName></DisplayName></Owner><Buckets></Buckets></ListAllMyBucketsResult>
~~~

### 8. 참조

* [http://docs.ceph.com/docs/master/start/](http://docs.ceph.com/docs/master/start/)
* [https://kubernetes.io/docs/concepts/storage/storage-classes/#ceph-rbd](https://kubernetes.io/docs/concepts/storage/storage-classes/#ceph-rbd)
* [https://github.com/kubernetes-incubator/external-storage/tree/master/ceph/rbd](https://github.com/kubernetes-incubator/external-storage/tree/master/ceph/rbd)
