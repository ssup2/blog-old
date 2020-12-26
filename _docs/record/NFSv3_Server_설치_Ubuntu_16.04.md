---
title: Ubuntu NFSv3 Server, Client 설치 / Ubuntu 16.04 환경
category: Record
date: 2020-04-24T17:27:00Z
lastmod: 2020-04-24T17:27:00Z
comment: true
adsense: true
---

### 1. 설치 환경

설치 환경은 다음과 같다.
* Ubuntu 16.04 LTS 64bit, root user
* NFS Root : NFSv3 Server의 Root Directory 절대 경로를 의미한다.
  * NFS Root로 /nfs_root를 이용한다.
* NFS share : NFSv3 Server를 통해 실제 공유할 Directory의 절대 경로를 의미한다.
  * NFS share로 /root/nfs_share를 이용한다.

### 2. NFSv3 Server 설정

#### 2.1. Ubuntu Package 설치

~~~console
# sudo apt-get install nfs-kernel-server nfs-common rpcbind
~~~

NFSv3 Server Package를 설치한다.

#### 2.2. 공유 폴더 생성 및 Bind Mount 설정

~~~console
# mkdir -p /nfs_root
# mkdir -p /root/nfs_share
# chmod 777 /root/nfs_share
# mount --bind /root/nfs_share /nfs_root
~~~

공유 폴더 생성 및 Bind Mount를 수행한다.

{% highlight text %}
...
/root/nfs_share /nfs_root none bind  0  0
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] /etc/fstab</figcaption>
</figure>

/etc/fstab에 다음 [파일 1]의 내용을 추가하여 재부팅 후에도 Bind Mount 되도록 설정한다.

#### 2.3. 설정

{% highlight text %}
/nfs_root      *(rw,nohide,insecure,no_subtree_check,async,no_root_squash)
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] /etc/exports</figcaption>
</figure>

/etc/exports 파일에 [파일 2]의 내용을 추가한다.

#### 2.4. Restart

~~~console
# /etc/init.d/nfs-kernel-server restart
~~~

NFSv3 Server를 재시작한다.

### 3. NFSv3 Client 설정

~~~console
# apt-get install nfs-common
~~~

NFSv3 Client Package를 설치한다.

~~~console
# mount -t nfs localhost:/nfs_root /mnt
~~~

NFSv3 Mount를 수행한다.
