---
title: Ubuntu NFSv4 Server/Client 설정
category: Record
date: 2017-02-14T17:27:00Z
lastmod: 2017-02-14T17:27:00Z
comment: true
adsense: true
---

### 1. 설치 환경

* Ubuntu 16.04 LTS 64bit, root user

### 2. NFSv4 Server 설정

* [NFS root] - NFSv4 Server Root 폴더의 상대 경로를 의미한다. (ex nfs_root)
* [NFS share] - NFSv4 Server를 통해 실제 공유할 폴더의 절대 경로를 의미한다. (ex /root/nfs_share)

#### 2.1. Ubuntu Package 설치

> \# sudo apt-get install nfs-kernel-server nfs-common rpcbind

#### 2.2. 공유 폴더 생성 및 Bind Mount 설정

* 공유 폴더 생성 및 Bind Mount 수행

> \# mkdir -p /export/[NFS root] <br>
> \# chmod 777 [NFS share] <br>
> \# mount \-\-bind [NFS share] /export/[NFS root]

*  /etc/fstab에 다음 내용을 추가하여 Bind Mount 설정

~~~
[NFS share] /export/[NFS root] none bind  0  0
~~~

#### 2.3. 설정

* /etc/exports 파일에 다음의 내용을 추가한다.

~~~
/export               *(rw,fsid=0,insecure,no_subtree_check,async)
/export/[NFS dir]     *(rw,nohide,insecure,no_subtree_check,async)
~~~

#### 2.4. Restart

> \# /etc/init.d/nfs-kernel-server restart

### 3. NFSv4 Client 설정

#### 3.1. Ubuntu Package 설치

> \# apt-get install nfs-common

#### 3.2. NFSv4 Mount

> \# mount -t nfs4 [NFS Server IP]:/[NFS Server Path] [Mount dir] <br>
> ex) \# mount -t nfs4 localhost:/nfs_root /mnt
