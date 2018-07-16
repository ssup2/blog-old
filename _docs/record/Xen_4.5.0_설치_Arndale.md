---
title: Xen 4.5.0 설치 - Arndale Board
category: Record
date: 2015-07-16T12:00:00Z
lastmod: 2015-07-16T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

* PC - Ubuntu 14.04LTS 64bit, root user
* VM - Xen 4.5.0, Dom0 & DomU kernel 3.18.3 in linux upstream, Ubuntu 14.04LTS 32bit
* Network
  * Gateway : 192.168.0.1
  * HostOS(xenbr0) : 192.168.0.150
  * GeustOS_01 : 192.168.0.160, GeustOS_02 : 192.168.0.161
* Boot
  * PXE Boot or uSD Card Boot

### 2. Cross Compiler 설치

* Download - https://releases.linaro.org/15.02/components/toolchain/binaries/arm-linux-gnueabihf/gcc-linaro-4.9-2015.02-3-x86_64_arm-linux-gnueabihf.tar.xz

* /usr/local Directory에 압축을 풀고 ~/.bashrc 파일에 아래의 내용 추가

~~~
PATH=$PATH:/usr/local/gcc-linaro-arm-linux-gnueabihf-4.8/bin
~~~

### 3. uSD Card Partiton 구성

* 0 ~ 2M, 2M, No Filesystem: Bootloader (bl1, spl, U-boot)
* 2M ~ 18M, 16M, ext2, boot : xen-uImage, linux-zImage, exynos5250-arndale.dtb, load-xen-uSD.img
* 18M ~ rest, ext3, root : Dom0 Root-Filesystem

### 4. U-boot Fusing

* Download bl1 - http://releases.linaro.org/12.12/components/kernel/arndale-bl1/arndale-bl1.bin
* spl, u-boot Download 및 빌드 Build 

~~~
# git clone git://git.linaro.org/people/ronynandy/u-boot-arndale.git
# cd u-boot-arndale
# git checkout lue_arndale_13.1
# export CROSS_COMPILE=arm-linux-gnueabihf-
# export ARCH=arm
# make arndale5250
~~~

* bl1, spl, u-boot Fusing

~~~
# dd if=arndale-bl1.bin of=/dev/sdb bs=512 seek=1
# dd if=spl/smdk5250-spl.bin of=/dev/sdb bs=512 seek=17
# dd if=u-boot.bin of=/dev/sdb bs=512 seek=49
~~~

### 5. Xen Build

* Download

~~~
# git clone git://xenbits.xen.org/xen.git xen-4.5.0
# cd xen-4.5.0
# git checkout RELEASE-4.5.0
~~~

* Compile

~~~
# make dist-xen XEN_TARGET_ARCH=arm32 CROSS_COMPILE=arm-linux-gnueabihf-
# mkimage -A arm -T kernel -a 0x80200000 -e 0x80200000 -C none -d "./xen/xen" "./xen/xen-uImage"
~~~

### 6. Dom0 Kernel Build

* Download

~~~
# wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.18.3.tar.xz
# tar xvf linux-3.18.3.tar.xz
# mv linux-3.18.3_Dom0
~~~

* Configure

~~~
# make ARCH=arm exynos_defconfig
# make ARCH=arm menuconfig

Kernel Features -> Xen guest support on ARM <*>
* Save
Device Drivers -> Block device -> Xen block-device backend driver <*>
Device Drivers -> Network device support -> Xen backend network device <*>
Networking support -> Networking options -> 802.1d Ethernet Bridging <M>
~~~

* Compile

~~~
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- dtbs
~~~

### 7. DomU Kernel Build

* Download

~~~
# wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.18.3.tar.xz
# tar xvf linux-3.18.3.tar.xz
# mv linux-3.18.3_DomU
~~~

* Configure

~~~
# make ARCH=arm exynos_defconfig
# make ARCH=arm menuconfig

Kernel Features -> Xen guest support on ARM <*>
~~~

* Compile

~~~
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage
~~~

### 8. PXE Boot

#### 8.1. tftp Server 설치

* Ubuntu Package 설치

~~~
# apt-get install xinetd tftp tftpd
~~~

* /etc/xinetd.d/tftp 파일 설정

~~~
service tftp
{
    socket_type     = dgram
    protocol        = udp
    wait            = yes
    user            = root
    server          = /usr/sbin/in.tftpd
    server_args     = -s /tftpboot
    disable         = no
    per_source      = 11
    cps             = 100 2
    flags           = IPv4
}
~~~

* tftp server Directory 생성

~~~
# mkdir /tftpboot
# chmod 777 /tftpboot
# /etc/init.d/xinetd restart
~~~

#### 8.2. tftp Server에 Binary 복사

~~~
# cd linux_Dom0
# cp ./arch/arm/boot/dts/exynos5250-arndale.dtb /tftpboot
# cp ./arch/arm/boot/zImage /tftpboot/linux-zImage
# cd xen-4.5.0
# cp xen-uImage /tftpboot
~~~

#### 8.3 img 파일 생성

~~~
# cd /tftpboot
# wget http://xenbits.xen.org/people/julieng/load-xen-tftp.scr.txt
# mkimage -T script -C none -d load-xen-tftp.scr.txt /tftpboot/load-xen-tftp.img
~~~

#### 8.4. Kernel Images, dtb, uSD Card Image 파일 복사 

* linux-zImage, exynos5250-arndale.dtb, load-xen-uSD.img 파일을 uSD Card의 ext2 Partition에 복사

#### 8.5. U-boot 설정

* board IP : 192.168.0.200
* tftp Server (Host PC) : 192.168.0.100

~~~
-> setenv ipaddr 192.168.0.200
-> setenv serverip 192.168.0.100
-> setenv xen_addr_r 0x50000000
-> setenv kernel_addr_r 0x60000000
-> setenv dtb_addr_r 0x42000000
-> setenv script_addr_r 0x40080000
-> setenv xen_path /xen-uImage
-> setenv kernel_path /linux-zImage
-> setenv dtb_path /exynos5250-arndale.dtb
-> setenv bootcmd 'tftpboot $script_addr_r /load-xen-tftp.img; source $script_addr_r'
-> setenv xen_bootargs 'sync_console console=dtuart dtuart=/serial@12C20000'
-> setenv dom0_bootargs 'console=hvc0 ignore_loglevel psci=enable clk_ignore_unused rw rootwait root=/dev/mmcblk1p2'
-> save
~~~

### 9. uSD Card Boot

#### 9.1. load-xen-uSD.scr.txt 파일 생성 및 img 파일 생성 

~~~
# wget http://xenbits.xen.org/people/julieng/load-xen-tftp.scr.txt
# mv load-xen-tftp.scr.txt load-xen-uSD.scr.txt
# vim load-xen-uSD.scr.txt
  - revise : tftpboot $kernel_addr_r $serverip:$kernel_path -> ext2load mmc 0:1 $kernel_addr_r /linux-zImage
  - revise : tftpboot $xen_addr_r $serverip:$xen_path -> ext2load mmc 0:1 $xen_addr_r /xen-uImage
  - revise : tftpboot $dtb_addr_r $serverip:$dtb_path -> ext2load mmc 0:1 $dtb_addr_r /exynos5250-arndale.dtb
# mkimage -T script -C none -d load-xen-uSD.scr.txt /tftpboot/load-xen-uSD.img
~~~

#### 9.2. Kernel Images, dtb, uSD Card Image 파일 복사

* linux-zImage, exynos5250-arndale.dtb, load-xen-uSD.img 파일을 uSD Card의 ext2 Partition에 복사

#### 9.3. U-boot 설정 

~~~
-> setenv xen_addr_r 0x50000000
-> setenv kernel_addr_r 0x60000000
-> setenv dtb_addr_r 0x42000000
-> setenv script_addr_r 0x40080000
-> setenv xen_path /xen-uImage
-> setenv kernel_path /linux-zImage
-> setenv dtb_path /exynos5250-arndale.dtb
-> setenv bootcmd 'ext2load mmc 0:1 $script_addr_r /load-xen-uSD.img; source $script_addr_r'
-> setenv xen_bootargs 'sync_console console=dtuart dtuart=/serial@12C20000'
-> setenv dom0_bootargs 'console=hvc0 ignore_loglevel psci=enable clk_ignore_unused rw rootwait root=/dev/mmcblk1p2'
-> save
~~~

### 10. Xen Tool Build

* sbuild, schroot 설치

~~~
# apt-get install sbuild
# sbuild-adduser $USER
~~~

* root 구성

~~~
# sbuild-createchroot --components=main,universe trusty /srv/chroots/trusty-armhf-cross http://archive.ubuntu.com/ubuntu/
# mv /etc/schroot/chroot.d/trusty-amd64-sbuild-*(random suffix) /etc/schroot/chroot.d/trusty-armhf-cross
# vi /etc/schroot/chroot.d/trusty-armhf-cross
  - 수정 : [trusty-amd64-sbuild] -> [trusty-armhf-cross]
  - 수정 : description=Debian trusty/amd64 autobuilder -> description=Debian trusty/armhf crossbuilder
~~~

* root 설정

~~~
# schroot -c trusty-armhf-cross
(schroot)# apt-get install vim-tiny wget sudo less pkgbinarymangler
(schroot)# vi /etc/apt/sources.list
  - add : 'deb http://ports.ubuntu.com/ trusty main universe'
(schroot)# vi /etc/apt/apt.conf.d/30norecommends
  - add : 'APT::Install-Recommends "0";'
  - add : 'APT::Install-Suggests "0";'
(schroot)# dpkg --add-architecture armhf
(schroot)# apt-get update
(schroot)# apt-get install wget
(schroot)# apt-get install crossbuild-essential-armhf
(schroot)# apt-get install libc6-dev:armhf libncurses-dev:armhf uuid-dev:armhf libglib2.0-dev:armhf libssl-dev:armhf libssl-dev:armhf libaio-dev:armhf libyajl-dev:armhf python gettext gcc git libpython2.7-dev:armhf libfdt-dev:armhf libpixman-1-dev:armhf
~~~

* Xen Tool Build

~~~
(schroot)# git clone -b RELEASE-4.5.0 git://xenbits.xen.org/xen.git xen-4.5.0
(schroot)# cd xen-4.5.0
(schroot)# CONFIG_SITE=/etc/dpkg-cross/cross-config.armhf ./configure --build=x86_64-unknown-linux-gnu --host=arm-linux-gnueabihf
(schroot)# make dist-tools CROSS_COMPILE=arm-linux-gnueabihf- XEN_TARGET_ARCH=arm32
  - Confirm 'dist/install' Directory
(schroot)# exit
~~~

### 11. Root Filesystem Image 생성

* Image 파일 생성 

~~~
# dd if=/dev/zero bs=1M count=1024 of=rootfs_ori.img
# mkfs.ext3 rootfs_ori.img (Proceed anyway? (y,n) y)
# mount -o loop rootfs_ori.img /mnt
~~~

* Root Filesystem 구성 

~~~
# apt-get install debootstrap qemu-user-static binfmt-support
# debootstrap --foreign --arch armhf trusty /mnt http://ports.ubuntu.com/
# cp /usr/bin/qemu-arm-static /mnt/usr/bin/
# sudo chroot /mnt
(chroot)# ./debootstrap/debootstrap --second-stage
~~~

* root password 설정 

~~~
(chroot)# passwd
~~~

* Network 설정

~~~
(chroot)# vi /etc/network/interfaces
  -> auto eth0
     iface eth0 inet dhcp
~~~

* Repository 설정 

~~~
(chroot)# vi /etc/apt/sources.list
  -> deb http://ports.ubuntu.com/ trusty main 
~~~

* getty 설정

~~~
(chroot)# cp /etc/init/tty1.conf /etc/init/xvc0.conf
(chroot)# vi /etc/init/xvc0.conf
  -> change 'exec /sbin/getty -8 38400 tty1' to 'exec /sbin/getty -8 115200 hvc0
~~~

* fstab 설정

~~~
(chroot)# vi /etc/fstab
  -> xenfs   /proc/xen    xenfs    defaults   0   0
(chroot) # exit
# umount /mnt
~~~

### 12. Dom0 Root Filesystem 설정

* img 파일 복사

~~~
# cp rootfs_ori.img rootfs_Dom0.img
# mount -o loop rootfs_Dom0.img /mnt
~~~

* Xen Tool 복사 

~~~
# rsync -avp /srv/chroots/trusty-armhf-cross/root/xen-4.5.0/dist/install/ /mnt/
~~~

* Kernel Module Compile 및 복사

~~~
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=/mnt modules_install
~~~

* insmod 설정

~~~
# sudo chroot /mnt
(chroot)# vi /etc/modules
  -> xen-gntalloc
     xen-gntdev
     bridge
~~~

* Hostname 설정 

~~~
(chroot)# vi /etc/hostname
  -> Dom0
(chroot) # exit
# umount /mnt
~~~

### 13. DomU_01 Root Filesystem 설정

* img 파일 복사

~~~
# cp rootfs_ori.img rootfs_DomU_01.img
# mount -o loop rootfs_DomU_01.img /mnt
# cd /mnt/dev
~~~

* xvdX Device Node 생성

~~~
# mknod xvda b 202 0
# mknod xvdb b 202 16 
# mknod xvdc b 202 32
# mknod xvdd b 202 48
# mknod xvde b 202 64
# mknod xvdf b 202 80
# mknod xvdg b 202 96
# mknod xvdh b 202 112
~~~

* Hostname 설정

~~~
(chroot)# vi /mnt/etc/hostname
  -> DomU01
~~~

* Network 설정

~~~
# vim  /mnt/etc/network/interfaces
  -> auto eth0
      iface eth0 inet static
      address 192.168.0.160
      netmask 255.255.255.0
      gateway 192.168.0.1
      dns-nameservers 8.8.8.8'
# umount /mnt
~~~

### 14. DomU_02 Root Filesystem 설정

* img 파일 복사

~~~
# cp rootfs_DomU_01.img rootfs_DomU_02.img
# mount -o loop rootfs_DomU_02.img /mnt
~~~

* Hostname 설정

~~~
(chroot)# vi /mnt/etc/hostname
  -> DomU02
~~~

* Network 설정

~~~
# vim  /mnt/etc/network/interfaces
  -> auto eth0
      iface eth0 inet static
      address 192.168.0.161
      netmask 255.255.255.0
      gateway 192.168.0.1
      dns-nameservers 8.8.8.8'
# umount /mnt
~~~

### 15. zImage, Root Filesystem 복사

~~~
# mount -o loop rootfs_Dom0.img /mnt
# rsync -avp /mnt/ /media/root/root (ext3 partition in uSD)
# cp rootfs_DomU_01.img /media/root/root/root (ext3 partition in uSD)
# cp rootfs_DomU_02.img /media/root/root/root (ext3 partition in uSD)
# cp DomU_zImage /media/root/root/root (ext3 partition in uSD)
# umount /mnt
~~~

### 16. Dom0에서 Ubuntu Package 설치

* uSD Card를 Arndale Board에 넣고 Booting하여 Dom0에 진입후 아래의 명령어 수행

~~~
(Dom0)# apt-get install libyajl-dev
(Dom0)# apt-get install libfdt-dev
(Dom0)# apt-get install libaio-dev 
(Dom0)# apt-get install libglib2.0-dev
(Dom0)# apt-get install libpixman-1-dev
(Dom0)# ldconfig
(Dom0)# apt-get install bridge-utils
~~~

### 17. DomU Config 파일 생성

* DomU_01 Config

~~~
(Dom0)# vim DomU_01.cfg
-> kernel = "/root/Xen_Guest/DomU_zImage"
   name = "DomU_01"
   memory = 128
   vcpus = 1
   disk = [ 'phy:/dev/loop0,xvda,w' ]
   vif = ['bridge=xenbr0']
   extra = "earlyprintk=xenboot console=hvc0 rw rootwait root=/dev/xvda"
~~~

* DomU_02 Config 

~~~
(Dom0)# vim DomU_02.cfg
-> kernel = "/root/Xen_Guest/DomU_zImage"
   name = "DomU_02"
   memory = 128
   vcpus = 1
   disk = [ 'phy:/dev/loop1,xvda,w' ]
   vif = ['bridge=xenbr0']
   extra = "earlyprintk=xenboot console=hvc0 rw rootwait root=/dev/xvda"
~~~

### 18. DomU 구동

* Xencommons 구동 및 Bridge 생성 

~~~
(Dom0)# /etc/init.d/xencommons start
(Dom0)# brctl addbr xenbr0
(Dom0)# brctl addif xenbr0 eth0
(Dom0)# ifconfig xenbr0 192.168.0.150 up
(Dom0)# ifconfig eth0 0.0.0.0 up
(Dom0)# route add default gw 192.168.0.1 xenbr0
~~~

* DomU 구동

~~~
(Dom0)# losetup /dev/loop0 rootfs_DomU_01.img                                           
(Dom0)# xl create DomU_01.cfg
(Dom0)# losetup /dev/loop1 rootfs_DomU_02.img                                           
(Dom0)# xl create DomU_02.cfg
~~~

### 19. 참조

* [http://wiki.xenproject.org/wiki/Xen_ARMv7_with_Virtualization_Extensions/Arndale](http://wiki.xenproject.org/wiki/Xen_ARMv7_with_Virtualization_Extensions/Arndale)
* [http://wiki.xenproject.org/wiki/Xen_ARMv7_with_Virtualization_Extensions#Building_Xen_on_ARM](http://wiki.xenproject.org/wiki/Xen_ARMv7_with_Virtualization_Extensions#Building_Xen_on_ARM)
* [http://wiki.xenproject.org/wiki/Xen_ARM_with_Virtualization_Extensions/CrossCompiling](http://wiki.xenproject.org/wiki/Xen_ARM_with_Virtualization_Extensions/CrossCompiling)
* [http://wiki.xenproject.org/wiki/Xen_ARM_with_Virtualization_Extensions/RootFilesystem](http://wiki.xenproject.org/wiki/Xen_ARM_with_Virtualization_Extensions/RootFilesystem)
* [https://wiki.linaro.org/Boards/Arndale/Setup/PXEBoot](https://wiki.linaro.org/Boards/Arndale/Setup/PXEBoot)
* [http://forum.falinux.com/zbxe/index.php?document_srl=518293&mid=lecture_tip](http://forum.falinux.com/zbxe/index.php?document_srl=518293&mid=lecture_tip)
* [http://badawave.tistory.com/entry/Xen-ARM-with-Virtualization-ExtensionsArndale](http://badawave.tistory.com/entry/Xen-ARM-with-Virtualization-ExtensionsArndale)
* [http://lists.xen.org/archives/html/xen-users/2012-03/msg00325.html](http://lists.xen.org/archives/html/xen-users/2012-03/msg00325.html)

