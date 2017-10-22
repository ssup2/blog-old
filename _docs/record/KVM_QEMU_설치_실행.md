---
title: KVM, QEMU 설치, 실행
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
* 설치
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
* Rootfs Directory 생성
~~~
# mkdir rootfs
# cd rootfs
~~~

* rootfs.img 파일 생성
~~~
# dd if=/dev/zero bs=1M count=8092 of=rootfs.img
# /sbin/mkfs.ext4 rootfs.img (Proceed anyway? (y,n) y)
~~~

* Ubuntu 설치
~~~
# mount -o loop rootfs.img /mnt
# cd /mnt
# qemu-debootstrap --arch=amd64 trusty .
~~~

* tty 설정
~~~
# vim /mnt/etc/init/ttyS0.conf
~~~
~~~
# ttyS0 - getty
#
# This service maintains a getty on ttyS0 from the point the system is
# started until it is shut down again.

start on stopped rc RUNLEVEL=[2345] and (
            not-container or
            container CONTAINER=lxc or
            container CONTAINER=lxc-libvirt)

stop on runlevel [!2345]

respawn
exec /sbin/getty -8 115200 ttyS0
~~~

* Network 설정

* LIO 설정

![]({{site.baseurl}}/images/record/KVM_QEMU_Install/LIO_targetcli.PNG)

### 9. 참조
* Kernel Compile - [https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1460768]( https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1460768)
* QEMU Option - [https://wiki.gentoo.org/wiki/QEMU/Options]( https://wiki.gentoo.org/wiki/QEMU/Options)
* fstab Problem - [ http://askubuntu.com/questions/392720/the-disk-drive-for-tmp-is-not-ready-yet-s-to-skip-mount-or-m-for-manual-recove]( http://askubuntu.com/questions/392720/the-disk-drive-for-tmp-is-not-ready-yet-s-to-skip-mount-or-m-for-manual-recove)
* LIO Targetcli - [http://linux-iscsi.org/wiki/Targetcli](http://linux-iscsi.org/wiki/Targetcli)
