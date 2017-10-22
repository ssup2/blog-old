---
title: KVM, QEMU 설치,실행
category: Record
date: 2017-10-22T12:00:00Z
lastmod: 2017-10-22T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경
* Host
  * Hardware - Intel i5-6500, DDR4 8GB
  * OS - Ubuntu 14.04.03 LTS 64bit, root user

### 2. Ubuntu Package 설치
~~~
# apt-get install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils uml-utilities qemu-system qemu-user-static virt-manager libncurses-dev targetcli
~~~

### 3. VM Kernel Build

* Kernel Directory 생성
~~~
# mkdir kernel
# cd kernel
~~~

* Kernel Download, Kernel Build Package 설치
~~~
# apt-get source linux-image-$(uname -r)
# apt-get build-dep linux-image-$(uname -r)
~~~

* Kernel Configuration
~~~
# cd linux-lts-vivid-3.19.0
# cp /boot/config-3.19.0-25-generic .config
# make ARCH=x86_64 menuconfig
[Device Driver -> SCSI device support -> SCSI low-level drivers -> <*> virtio-scsi support]
~~~

* Build Kernel
~~~
# cd linux-lts-vivid-3.19.0/ubuntu/vbox/vboxguest
# ln -s ../include/
# ln -s ../r0drv/
# cd linux-lts-vivid-3.19.0/ubuntu/vbox/vboxsf
# ln -s ../include/
# cd linux-lts-vivid-3.19.0/ubuntu/vbox/vboxvideo
# ln -s ../include/
# cd kernel/linux-lts-vivid-3.19.0
# make ARCH=x86_64
~~~

### 4. VM Rootfs 생성
~~~


{: .newline }
> a = G * x, b = G * y
> ---> L = G * x * y = (a * b) / G

![]({{site.baseurl}}/images/theory_analysis/Linux_LSM/Linux_LSM_Framework.PNG){: width="300px"}
![]({{site.baseurl}}/images/theory_analysis/KVM_QEMU/QEMU_non-iothread.PNG)

* QEMU - [http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html](http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html)
