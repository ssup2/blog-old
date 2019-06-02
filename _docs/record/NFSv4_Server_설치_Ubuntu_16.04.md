---
title: Ubuntu NFSv4 Server/Client 설치 - Ubuntu 16.04
category: Record
date: 2017-02-14T17:27:00Z
lastmod: 2017-02-14T17:27:00Z
comment: true
adsense: true
---

### 1. 설치 환경

설치 환경은 다음과 같다.
* Ubuntu 16.04 LTS 64bit, root user
* NFS Root : NFSv4 Server의 Root Directory 절대 경로를 의미한다.
  * NFS Root로 /export/nfs_root를 이용한다.
* NFS share : NFSv4 Server를 통해 실제 공유할 Directory의 절대 경로를 의미한다.
  * NFS share로 /root/nfs_share를 이용한다.

### 2. NFSv4 Server 설정

#### 2.1. Ubuntu Package 설치

~~~
# sudo apt-get install nfs-kernel-server nfs-common rpcbind
~~~

NFSv4 Server Package를 설치한다.

#### 2.2. 공유 폴더 생성 및 Bind Mount 설정

~~~
# mkdir -p /export/nfs_root
# mkdir -p /root/nfs_share
# chmod 777 /root/nfs_share
# mount --bind /root/nfs_share /export/nfs_root
~~~

공유 폴더 생성 및 Bind Mount를 수행한다.

{% highlight text %}
...
/root/nfs_share /export/nfs_root none bind  0  0
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] /etc/fstab</figcaption>
</figure>

/etc/fstab에 다음 [파일 1]의 내용을 추가하여 재부팅 후에도 Bind Mount 되도록 설정한다.

#### 2.3. 설정

{% highlight text %}
/export               *(rw,fsid=0,insecure,no_subtree_check,async)
/export/nfs_root      *(rw,nohide,insecure,no_subtree_check,async)
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] /etc/exports</figcaption>
</figure>

/etc/exports 파일에 [파일 2]의 내용을 추가한다.

#### 2.4. Restart

~~~
# /etc/init.d/nfs-kernel-server restart
~~~

NFSv4 Server를 재시작한다.

### 3. NFSv4 Client 설정

~~~
# apt-get install nfs-common
~~~

NFSv4 Client Package를 설치한다.

~~~
# mount -t nfs4 localhost:/nfs_root /mnt
~~~

NFSv4 Mount를 수행한다.
