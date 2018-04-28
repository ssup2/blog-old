---
title: KVM, QEMU 설치, 실행 - Ubuntu 14.04
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

~~~
# vim /mnt/etc/network/interfaces
~~~

~~~
# interfaces(5) file used by ifup(8) and ifdown(8)
# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
~~~

* root Password 설정

~~~
# /mnt
# chroot .
(chroot) # passwd
(chroot) # exit
~~~

* Kernel module 설치

~~~
# cd kernel/linux-lts-vivid-3.19.0
# make ARCH=x86_64 INSTALL_MOD_PATH=/mnt modules_install
~~~

* Unmount /mnt

~~~
# umount /mnt
~~~

### 5. Bridge 설정

* Script 파일 작성

~~~
# mkdir VM
# cd VM
# vim set_bridge.sh
~~~

~~~
brctl addbr br0
brctl addif br0 eth0
ifconfig br0 192.168.77.100 up
ifconfig eth0 0.0.0.0 up
route add default gw 192.168.77.1
~~~

~~~
# chmod +x set_bridge.sh
~~~

### 6. LIO 설정

* LIO Package 설치 설정

~~~
# apt-get install targetcli
# vim /var/target/fabric/vhost.spec
~~~

~~~
# The fabric module feature set
features = nexus, tpgts

# Use naa WWNs.
wwn_type = naa

# Non-standard module naming scheme
#kernel_module = tcm_vhost
kernel_module = vhost_scsi

# The configfs group
configfs_group = vhost
~~~

* LIO CLI를 이용하여 LIO 설정

~~~
# reboot now
# targetcli
~~~

~~~
(targetcli) /> cd backstores/fileio
(targetcli) /> create name=file_backend file_or_dev=[Absolute Path of rootfs.img] size=8G
(targetcli) /> cd /vhost
(targetcli) /> create wwn=naa.60014052cc816bf4
(targetcli) /> cd naa.60014052cc816bf4/tpgt1/luns
(targetcli) /> create /backstores/fileio/file_backend
(targetcli) /> cd /
(targetcli) /> saveconfig
(targetcli) /> exit
~~~

* LIO 설정 결과

![]({{site.baseurl}}/images/record/KVM_QEMU_Install/LIO_targetcli.PNG)

### 7. VM 실행

* rootfs.img, bzImage 복사

~~~
# cd VM
# cp ../../kernel/linux-lts-vivid-3.19.0/arch/x86_64/boot/bzImage
# cp ../../rootfs/rootfs.img
~~~

#### 7.1. KVM + QEMU

* User Networking (SLIRP)

~~~
# qemu-system-x86_64 -enable-kvm -kernel bzImage -m 1024 -nographic -hda rootfs.img -net nic -net user -append "earlyprintk root=/dev/sda console=ttyS0"
~~~

#### 7.2. KVM + QEMU + VirtIO

* User Networking (SLIRP), virtio-net, virtio-blk

~~~
# qemu-system-x86_64 -enable-kvm -kernel bzImage -m 1024 -nographic -device virtio-blk-pci,scsi=off,drive=blk0 -device virtio-net-pci,netdev=net0 -drive file=rootfs.img,if=none,id=blk0 -netdev user,id=net0 -append "earlyprintk root=/dev/vda console=ttyS0"
~~~

* TAP, virtio-net, virtio-blk

~~~
# ./set_bridge.sh
# qemu-system-x86_64 -enable-kvm -kernel bzImage -m 1024 -nographic -device virtio-blk-pci,scsi=off,drive=blk0 -device virtio-net-pci,netdev=net0 -drive file=rootfs.img,if=none,id=blk0 -netdev tap,id=net0,ifname=tap0 -append "earlyprintk root=/dev/vda console=ttyS0"
~~~

* User Networking (SLIRP), virtio-net, virtio-scsi

~~~
# qemu-system-x86_64 -enable-kvm -kernel bzImage -m 1024 -nographic -device virtio-scsi-pci -device scsi-hd,drive=root -device virtio-net-pci,netdev=net0 -drive file=rootfs.img,if=none,format=raw,id=root -netdev user,id=net0 -append "earlyprintk root=/dev/sda console=ttyS0"
~~~

* TAP, virtio-net, virtio-scsi

~~~
# ./set_bridge.sh
# qemu-system-x86_64 -enable-kvm -kernel bzImage -m 1024 -nographic -device virtio-scsi-pci -device scsi-hd,drive=root -device virtio-net-pci,netdev=net0 -drive file=rootfs.img,if=none,format=raw,id=root -netdev tap,id=net0,ifname=tap0 -append "earlyprintk root=/dev/sda console=ttyS0"
~~~

#### 7.3. KVM + QEMU + VirtIO + vhost

* TAP, virtio-net+vhost, virtio-scsi+vhost-scsi

~~~
# ./set_bridge.sh
# qemu-system-x86_64 -enable-kvm -kernel bzImage -m 1024 -nographic -device vhost-scsi-pci,wwpn=naa.60014052cc816bf4 -device virtio-net-pci,netdev=net0 -netdev tap,id=net0,vhost=on,ifname=tap0 -append "earlyprintk root=/dev/sda console=ttyS0"
~~~

### 8. fstab 설정

* Shell 접근

~~~
* Stopping log initial device creation                                  [ OK ]
The disk drive for / is not ready yet or not present.
keys:Continue to wait, or Press S to skip mounting or M for manual recovery (Push M)
~~~

* blkid 확인, fstab 설정

~~~
(VM) # mount -o remount,rw /
(VM) # blkid
(VM) /dev/sda: UUID="(UUID of blk)" TYPE="ext4"
(VM) # vi /etc/fstab
~~~

~~~
UUID=(UUID of blk) / ext4 errors=remount-ro 0 1
~~~

### 9. 참조

* Kernel Compile - [https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1460768]( https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1460768)
* QEMU Option - [https://wiki.gentoo.org/wiki/QEMU/Options]( https://wiki.gentoo.org/wiki/QEMU/Options)
* fstab Problem - [ http://askubuntu.com/questions/392720/the-disk-drive-for-tmp-is-not-ready-yet-s-to-skip-mount-or-m-for-manual-recove]( http://askubuntu.com/questions/392720/the-disk-drive-for-tmp-is-not-ready-yet-s-to-skip-mount-or-m-for-manual-recove)
* LIO Targetcli - [http://linux-iscsi.org/wiki/Targetcli](http://linux-iscsi.org/wiki/Targetcli)
