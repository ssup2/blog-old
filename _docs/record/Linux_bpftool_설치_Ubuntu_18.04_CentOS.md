---
title: Linux bpftool 설치 - Ubuntu 18.04
category: Record
date: 2018-12-29T12:00:00Z
lastmod: 2018-12-29T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

#### 1.1. Ubuntu

* Ubuntu 18.04.1 LTS
* Linux 4.15.0-45-generic

#### 1.2. CentOS

* CentOS 7
* Linux 4.19.4-1.el7.elrepo.x86_64

### 2. Package 설치

#### 2.1. Ubuntu

* bpftool Build시 필요한 Library 설치

~~~
# apt-get install binutils-dev
# apt-get install libelf-dev
~~~

#### 2.2. CentOS

* bpftool Build시 필요한 Library 설치

~~~
# yum install binutils-devel
# yum install elfutils-libelf-devel
~~~

### 3. bpftool Build & 설치

* 현재 Ubuntu Package로 제공되지 않고 있기 때문에 Kernel Code를 받아 직접 bpftool Build 수행.
* bfptool의 net, perf Opiton 이용을 위해서 **v4.20 이상의 Kernel Version** 필요

~~~
# git clone https://github.com/torvalds/linux.git
# cd linux
# git checkout v4.20
~~~

* bpftool Build

~~~
# make -C tools/bpf/bpftool/
# cp tools/bpf/bpftool/bpftool /usr/sbin
~~~

#### 3.1. Compile Error 해결

* linux/if.h와 net/if.h의 충돌로 인한 Compile Error 발생 시

~~~
# make -C tools/bpf/bpftool/
...
/usr/include/linux/if.h:76:2: error: redeclaration of enumerator [01mIFF_NOTRAILERS
  IFF_NOTRAILERS   = 1<<5,  /* sysfs */
  ^
/usr/include/net/if.h:54:5: note: previous definition of [01mIFF_NOTRAILERSwas here
     IFF_NOTRAILERS = 0x20, /* Avoid use of trailers.  */
     ^
/usr/include/linux/if.h:77:2: error: redeclaration of enumerator [01mIFF_RUNNING
  IFF_RUNNING   = 1<<6,  /* __volatile__ */
  ^
/usr/include/net/if.h:56:5: note: previous definition of [01mIFF_RUNNINGwas here
     IFF_RUNNING = 0x40,  /* Resources allocated.  */
...
~~~

* tools/bpf/bpftool/net.c 파일을 아래와 같이 수정

~~~
...
#include <libbpf.h>
//#include <net/if.h>
#include <linux/if.h>
...
~~~

### 4. 참조

* [https://github.com/Netronome/bpf-tool](https://github.com/Netronome/bpf-tool)
* [https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel](https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel)
* [https://lore.kernel.org/patchwork/patch/866970/](https://lore.kernel.org/patchwork/patch/866970/)