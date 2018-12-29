---
title: Linux bpftool 설치 - Ubuntu 18.04
category: Record
date: 2018-12-29T12:00:00Z
lastmod: 2018-12-29T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

* Ubuntu 18.04.1 LTS

### 2. Ubuntu Package 설치

* bpftool Build시 필요한 Library 설치

~~~
# apt-get install binutils-dev
# apt-get install libelf-dev
~~~

### 3. bpftool 설치

* 현재 Ubuntu Package로 제공되지 않고 있기 때문에 Kernel Code를 받아 직접 bpftool Build 수행.
* bfptool의 net, perf Opiton 이용을 위해서 최신 Version의 Kernel을 받아 Build 수행.

~~~
# git clone https://github.com/torvalds/linux.git
# cd ubuntu-bionic
~~~

* bpftool Build

~~~
# make -C tools/bpf/bpftool/
# cp tools/bpf/bpftool/bpftool /usr/sbin
~~~

### 4. 참조

* [https://github.com/Netronome/bpf-tool](https://github.com/Netronome/bpf-tool)
* [https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel](https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel)
* [https://lore.kernel.org/patchwork/patch/866970/](https://lore.kernel.org/patchwork/patch/866970/)