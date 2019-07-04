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

설치, 실행 환경은 다음과 같다.
* Ubuntu 18.04 LTS 64bit, root user
* Ceph Luminous Version

### 2. Node 설정

![[그림 1] Ceph 설치를 위한 Node 구성도]({{site.baseurl}}/images/record/Ceph_Install_Ubuntu_18.04/Node_Setting.PNG)

VirtualBox를 이용하여 [그림 1]과 같이 가상의 Node (VM)을 생성한다.
* Hostname : Master Node - node01, Worker node01 - node02, Worker node02 - node03
* NAT : Virtual Box에서 제공하는 "NAT 네트워크" 이용하여 10.0.0.0/24 Network를 구축한다.
* HDD : 각 Node에 Ceph가 이용할 추가 HDD (/dev/sdb)를 생성하고 붙인다.
* Router : 공유기를 이용하여 192.168.0.0/24 Network를 구축한다. (NAT)

#### 2.1. Ceph Node

{% highlight yaml %}
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
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Node 01의 /etc/netplan/50-cloud-init.yaml</figcaption>
</figure>

Ceph Node 01의 /etc/netplan/50-cloud-init.yaml 파일을 [파일 1]의 내용으로 생성한다.

{% highlight yaml %}
network:
    version: 2
    ethernets:
        enp0s3:
            dhcp4: no
            addresses: [10.0.0.20/24]
            gateway4: 10.0.0.1
            nameservers:
                addresses: [8.8.8.8]
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] Node 02의 /etc/netplan/50-cloud-init.yaml</figcaption>
</figure>

Ceph Node 02의 /etc/netplan/50-cloud-init.yaml 파일을 [파일 2]의 내용으로 생성한다.

{% highlight yaml %}
network:
    version: 2
    ethernets:
        enp0s3:
            dhcp4: no
            addresses: [10.0.0.30/24]
            gateway4: 10.0.0.1
            nameservers:
                addresses: [8.8.8.8]
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] Node 03의 /etc/netplan/50-cloud-init.yaml</figcaption>
</figure>

Ceph Node 03의 /etc/netplan/50-cloud-init.yaml 파일을 [파일 3]의 내용으로 생성한다.

### 3. Package 설치

#### 3.1. Ceph Node

~~~
# sudo apt install ntp
# sudo apt install python
~~~

ntp, python Package를 설치한다.

~~~
# sudo useradd -d /home/ceph -m ceph
# sudo passwd ceph
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully

# echo "ceph ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ceph
# sudo chmod 0440 /etc/sudoers.d/ceph
~~~

ceph User를 생성한다. 
* Password : ceph

#### 3.2. Deploy Node

~~~
10.0.0.10 node01
10.0.0.20 node02
10.0.0.30 node03
~~~
<figure>
<figcaption class="caption">[파일 4] Deploy Node의 /etc/hosts</figcaption>
</figure>

/etc/hosts 파일에 [파일 4]의 내용을 추가한다.

~~~
# wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
# echo deb https://download.ceph.com/debian-luminous/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
# sudo apt update
# sudo apt install ceph-deploy
~~~

ceph-deploy Package를 설치한다.

~~~
# sudo useradd -d /home/deploy -m deploy
# sudo passwd deploy
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully

# echo "deploy ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/deploy
# sudo chmod 0440 /etc/sudoers.d/deploy
~~~

deploy User를 생성한다. 
* Password : deploy

~~~
# login deploy
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
...

$ ssh-copy-id ceph@node01
$ ssh-copy-id ceph@node02
$ ssh-copy-id ceph@node03
~~~

SSH Key를 생성 및 복사한다.
* passphrases는 Empty 상태로 유지한다.

{% highlight text %}
Host node01
   Hostname node01
   User ceph
Host node02
   Hostname node02
   User ceph
Host node03
   Hostname node03
   User ceph
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 5] Deploy Node의 /home/deploy/.ssh/config</figcaption>
</figure>

/home/deploy/.ssh/config 파일을 [파일 5]와 같이 수정한다.

### 4. Storage Cluster 구성

#### 4.1. Deploy Node

~~~
# login deploy
$ mkdir my-cluster
~~~

Storage Cluster Config 폴더를 생성한다.

~~~
# login deploy
$ cd ~/my-cluster
$ ceph-deploy purge node01 node02 node03
$ ceph-deploy purgedata node01 node02 node03
$ ceph-deploy forgetkeys
$ rm ceph.*
~~~

Storage Cluster를 초기화한다.

~~~
# login deploy
$ cd ~/my-cluster
$ ceph-deploy new node01
$ ceph-deploy install node01 node02 node03
$ ceph-deploy mon create-initial
$ ceph-deploy admin node01 node02 node03
$ ceph-deploy mgr create node01
$ ceph-deploy osd create --data /dev/sdb node01
$ ceph-deploy osd create --data /dev/sdb node02
$ ceph-deploy osd create --data /dev/sdb node03
$ sudo ceph -s
  cluster:
    id:     20261612-97fc-4a45-bd81-0d9c9b445e00
    health: HEALTH_OK

  services:
    mon: 1 daemons, quorum node01
    mgr: node01(active)
    osd: 3 osds: 3 up, 3 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0  objects, 0 B
    usage:   3.0 GiB used, 597 GiB / 600 GiB avail
    pgs:   
~~~

Storage Cluster를 구축 및 확인한다. MON (Monitor Daemon)은 Ceph Node 01에 설치한다.

~~~
# login deploy
$ cd ~/my-cluster
$ ceph-deploy mds create node01
$ sudo ceph -s
  cluster:
    id:     20261612-97fc-4a45-bd81-0d9c9b445e00
    health: HEALTH_OK

  services:
    mon: 1 daemons, quorum node01
    mgr: node01(active)
    osd: 3 osds: 3 up, 3 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0  objects, 0 B
    usage:   3.0 GiB used, 597 GiB / 600 GiB avail
    pgs:  
~~~

MDS (Meta Data Server)를 설치한다. MDS은 Ceph Node 01에 설치한다.

~~~
# login deploy
$ cd ~/my-cluster
$ ceph-deploy rgw create node01
$ sudo ceph -s 
  cluster:
    id:     20261612-97fc-4a45-bd81-0d9c9b445e00
    health: HEALTH_OK

  services:
    mon: 1 daemons, quorum node01
    mgr: node01(active)
    osd: 3 osds: 3 up, 3 in
    rgw: 1 daemon active

  data:
    pools:   4 pools, 32 pgs
    objects: 187  objects, 1.1 KiB
    usage:   3.0 GiB used, 597 GiB / 600 GiB avail
    pgs:     32 active+clean
~~~

RGW (Rados Gateway)를 설치한다. RGW는 Ceph Node 01에 설치한다.

### 5. Block Storage Test

#### 5.1. Ceph Node

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

### 6. File Storage Test

#### 6.1. Ceph Node

~~~
# ceph osd pool create cephfs_data 16
# ceph osd pool create cephfs_metadata 16
# ceph fs new filesystem cephfs_metadata cephfs_data
~~~

Pool 생성 및 File Storage를 생성한다.

~~~
# cat /home/deploy/my-cluster/ceph.client.admin.keyring
[client.admin]
        key = AQAk1SxcbTz/IBAAHCPTQ5x1SHFcA0fn2tTW7w==
        caps mds = "allow *"
        caps mgr = "allow *"
        caps mon = "allow *"
        caps osd = "allow *"
~~~

admin Key를 확인한다.

{% highlight text %}
AQAk1SxcbTz/IBAAHCPTQ5x1SHFcA0fn2tTW7w==
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 6] /root/admin.secret</figcaption>
</figure>

확인한 admin Key를 이용하여 [파일 6]의 내용으로 /root/admin.secret 파일을 생성한다.

~~~
# mkdir mnt
# mount -t ceph 10.0.0.10:6789:/ mnt/ -o name=admin,secretfile=/root/admin.secret
# mount
...
10.0.0.10:6789:/ on /root/test/ceph/mnt type ceph (rw,relatime,name=admin,secret=<hidden>,acl,wsize=16777216)
~~~

Ceph File Server를 Mount 한다.

### 7. Object Storage Test

#### 7.1. Ceph Node

~~~
# curl 127.0.0.1:7480
<?xml version="1.0" encoding="UTF-8"?><ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>anonymous</ID><DisplayName></DisplayName></Owner><Buckets></Buckets></ListAllMyBucketsResult>
~~~

RGW 동작을 확인한다.

### 8. 참조

* [http://docs.ceph.com/docs/master/start/](http://docs.ceph.com/docs/master/start/)
* [https://kubernetes.io/docs/concepts/storage/storage-classes/#ceph-rbd](https://kubernetes.io/docs/concepts/storage/storage-classes/#ceph-rbd)
* [https://github.com/kubernetes-incubator/external-storage/tree/master/ceph/rbd](https://github.com/kubernetes-incubator/external-storage/tree/master/ceph/rbd)
