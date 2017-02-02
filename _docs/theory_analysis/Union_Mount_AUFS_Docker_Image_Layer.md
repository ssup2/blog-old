---
title: Union Mount, AUFS, Docker Image Layer
category: Theory, Analysis
date: 2017-02-01T22:18:00Z
lastmod: 2017-02-01T22:18:00Z
comment: true
adsense: true
---

Union Mount를 간략하게 설명하고 리눅스에서 이용할 수 있는 Union Mount기법인 AUFS에 대해 알아본다. 마지막으로 AUFS의 내용을 바탕으로 Docker가 Image Layer를 어떻게 하나의 Image로 만들고 Snapshot을 생성하는지 알아본다.

### 1. Union Mount

<img src="{{site.baseurl}}/images/theory_analysis/Union_Mount_AUFS_Docker_Image_Layer/Union_Mount.PNG" width="600px">

* Union이란 이름에서도 알 수 있듯이, 여러개의 Directory를 동시에 특정 Directory에 Mount하는 동작을 Union Mount라고 한다. 리눅스 환경에서 Union Mount를 이용하기 위해서는 AUFS를 이용하면 된다.

### 2. AUFS

* AUFS (Advanced Multi Layered Unification Filesystem)은 리눅스 환경에서 Union Mount를 제공하는 기법이다. AUFS는 현재 Linux Kernel의 Main Stream에 포함되어 있지 않다. 하지만 Docker Image Layer의 기본 Filesystem으로 이용되고 있기 때문에 현재 많은 곳에서 AUFS를 이용하고 있다. 대부분의 리눅스 배포판에서는 별도의 Package 설치를 통해 AUFS를 쉽게 설치 할 수 있다.

> mount -t aufs -o br=/layer_rw=rw:/layer_01=ro+wh:/layer_02=ro+wh:/layer_03=ro+wh none /mnt

* 아래의 AUFS 설명들은 위와 같은 명령어와 Option을 통해 AUFS Mount를 했다고 가정하에 진행한다. AUFS는 **br(Branch)**에 Union Mount를 위한 Directory들을 나열한다. /layer_rw Directory는 rw로 Mount되고 나머지 Directory들은 ro로 Mount되는것을 확인 할 수 있다. 또한 /layer_rw가 br 옵션의 가장 앞에 있기 때문에 /layer_rw는 branch의 root가 된다. /mnt Directory에 Branch Directory들이 Union Mount 된다.

* AUFS에서는 파일의 삭제를 나타내기 위해 **whiteout** 파일을 이용한다. 기본적으로 AUFS는 Branch의 root Directory안에 있는 whiteout 파일만 참조하지만 +wh 옵션을 주면 +wh 옵션이 있는 Directory의 whiteout 파일도 참조한다.

#### 2.1. Read, Write

<img src="{{site.baseurl}}/images/theory_analysis/Union_Mount_AUFS_Docker_Image_Layer/AUFS_Read_Write.PNG" width="600px">

* Branch Directory들이 서로 다른 파일들을 갖고있는 경우 AUFS Mount를 통해 특정 Directory에 Brach Directory의 파일들이 모여도 문제가 없다는걸 예측 할 수 있다. 동일한 경로에 동일한 파일 이름이 있는 경우, 위의 그림처럼 AUFS Mount가된 Directory내에서는 오직 Branch의 가장 마지막에 있는 Directory의 파일만 볼 수 있다.

* Branch  

#### 2.2. Remove

<img src="{{site.baseurl}}/images/theory_analysis/Union_Mount_AUFS_Docker_Image_Layer/AUFS_Remove.PNG" width="600px">

<img src="{{site.baseurl}}/images/theory_analysis/Union_Mount_AUFS_Docker_Image_Layer/AUFS_Remove_opq.PNG" width="600px">

### 3. Docker Image Layer
 Docker Daemon에서 AUFS 이용시 위와 동일한 옵션을 이용한다.
<img src="{{site.baseurl}}/images/theory_analysis/Union_Mount_AUFS_Docker_Image_Layer/Docker_Image_Layer.PNG" width="600px">

### 4. 참조

<img src="{{site.baseurl}}/images/theory_analysis/Virtual_Machine_Linux_Container/Linux_Container.PNG" width="500px">

![]({{site.baseurl}}/images/theory_analysis/KVM_QEMU/QEMU_non-iothread.PNG)

* QEMU - [http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html](http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html)
