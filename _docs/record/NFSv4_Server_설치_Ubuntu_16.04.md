---
title: Ubuntu NFSv4 Server/Client 설치 - Ubuntu 16.04
category: Record
date: 2017-02-14T17:27:00Z
lastmod: 2017-02-14T17:27:00Z
comment: true
adsense: true
---

### 1. 설치 환경

* Ubuntu 16.04 LTS 64bit, root user

### 2. NFSv4 Server 설정

* [NFS root] - NFSv4 Server의 Root 폴더 이름을 의미한다.
* [NFS share] - NFSv4 Server를 통해 실제 공유할 폴더의 절대 경로를 의미한다.

#### 2.1. Ubuntu Package 설치

~~~
# sudo apt-get install nfs-kernel-server nfs-common rpcbind
~~~

#### 2.2. 공유 폴더 생성 및 Bind Mount 설정

* 공유 폴더 생성 및 Bind Mount 수행

~~~
# mkdir -p /export/[NFS root]
# chmod 777 [NFS share]
# mount --bind [NFS share] /export/[NFS root]
~~~

~~~
# mkdir -p /export/nfs_root
# mkdir -p /root/nfs_share
# chmod 777 /root/nfs_share
# mount --bind /root/nfs_share /export/nfs_root
~~~

*  /etc/fstab에 다음 내용을 추가하여 재부팅 후에도 Bind Mount 되도록 설정

~~~
[NFS share] /export/[NFS root] none bind  0  0
~~~

~~~
/root/nfs_share /export/nfs_root none bind  0  0
~~~

#### 2.3. 설정

* /etc/exports 파일에 다음의 내용을 추가한다.

~~~
/export               *(rw,fsid=0,insecure,no_subtree_check,async)
/export/[NFS dir]     *(rw,nohide,insecure,no_subtree_check,async)
~~~

~~~
/export               *(rw,fsid=0,insecure,no_subtree_check,async)
/export/nfs_root      *(rw,nohide,insecure,no_subtree_check,async)
~~~

#### 2.4. Restart

~~~
# /etc/init.d/nfs-kernel-server restart
~~~

### 3. NFSv4 Client 설정

* 3.1. Ubuntu Package 설치

~~~
# apt-get install nfs-common
~~~

* 3.2. NFSv4 Mount

~~~
# mount -t nfs4 [NFS Server IP]:/[NFS Server Path] [Mount dir]
~~~

~~~
# mount -t nfs4 localhost:/nfs_root /mnt
~~~
