---
title: Xen 4.5.0 설치,실행 / Arndale 환경
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

설치 환경은 다음과 같다.
* PC : Ubuntu 14.04LTS 64bit, root user
* VM on Xen : Xen 4.5.0, Dom0 & DomU kernel 3.18.3 in linux upstream, Ubuntu 14.04LTS 32bit
* Network
  * Gateway : 192.168.0.1
  * HostOS(xenbr0) : 192.168.0.150
  * GeustOS_01 : 192.168.0.160, GeustOS_02 : 192.168.0.161
* Boot
  * PXE Boot or uSD Card Boot

### 2. Cross Compiler 설치

Cross Compiler를 설치한다.
* Download : https://releases.linaro.org/15.02/components/toolchain/binaries/arm-linux-gnueabihf/gcc-linaro-4.9-2015.02-3-x86_64_arm-linux-gnueabihf.tar.xz

{% highlight text %}
...
PATH=$PATH:/usr/local/gcc-linaro-arm-linux-gnueabihf-4.8/bin
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] ~/.bashrc</figcaption>
</figure>

/usr/local Directory에 압축을 풀고 ~/.bashrc 파일에 [파일 1]의 내용을 추가하여 어떤 Directory에서라도 Compiler를 실행 할 수 있도록 만든다.

### 3. uSD Card Partiton 구성

* 0 ~ 2M, 2M, No Filesystem : Bootloader (bl1, spl, U-boot)
* 2M ~ 18M, 16M, ext2, boot : xen-uImage, linux-zImage, exynos5250-arndale.dtb, load-xen-uSD.img
* 18M ~ rest, ext3, root : Dom0 Root-Filesystem

### 4. U-boot Fusing

~~~
# git clone git://git.linaro.org/people/ronynandy/u-boot-arndale.git
# cd u-boot-arndale
# git checkout lue_arndale_13.1
# export CROSS_COMPILE=arm-linux-gnueabihf-
# export ARCH=arm
# make arndale5250
~~~

spl, u-boot Download 및 Build 한다.
* Download bl1 : http://releases.linaro.org/12.12/components/kernel/arndale-bl1/arndale-bl1.bin

~~~
# dd if=arndale-bl1.bin of=/dev/sdb bs=512 seek=1
# dd if=spl/smdk5250-spl.bin of=/dev/sdb bs=512 seek=17
# dd if=u-boot.bin of=/dev/sdb bs=512 seek=49
~~~

bl1, spl, u-boot를 Fusing 한다.

### 5. Xen Build

~~~
# git clone git://xenbits.xen.org/xen.git xen-4.5.0
# cd xen-4.5.0
# git checkout RELEASE-4.5.0
~~~

Xen을 Download 한다.

~~~
# make dist-xen XEN_TARGET_ARCH=arm32 CROSS_COMPILE=arm-linux-gnueabihf-
# mkimage -A arm -T kernel -a 0x80200000 -e 0x80200000 -C none -d "./xen/xen" "./xen/xen-uImage"
~~~

Xen을 Compile 한다.

### 6. Dom0 Kernel Build

~~~
# wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.18.3.tar.xz
# tar xvf linux-3.18.3.tar.xz
# mv linux-3.18.3_Dom0
~~~

Dom0용 Kernel을 Download 한다.

~~~
# make ARCH=arm exynos_defconfig
# make ARCH=arm menuconfig

Kernel Features -> Xen guest support on ARM <*>
* Save
Device Drivers -> Block device -> Xen block-device backend driver <*>
Device Drivers -> Network device support -> Xen backend network device <*>
Networking support -> Networking options -> 802.1d Ethernet Bridging <M>
~~~

Dom0용 Kernel을 Configuration 한다.

~~~
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- dtbs
~~~

Dom0용 Kernel을 Compile 한다.

### 7. DomU Kernel Build

~~~
# wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.18.3.tar.xz
# tar xvf linux-3.18.3.tar.xz
# mv linux-3.18.3_DomU
~~~

DomU용 Kernel을 Download 한다.

~~~
# make ARCH=arm exynos_defconfig
# make ARCH=arm menuconfig

Kernel Features -> Xen guest support on ARM <*>
~~~

DomU용 Kernel을 Configuration 한다.

~~~
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage
~~~

DomU용 Kernel을 Compile 한다.

### 8. Boot

PXE Boot 또는 uSD Card Boot 둘중에 하나를 선택하여 수행한다.

#### 8.1. PXE Boot

##### 8.1.1. tftp Server 설치

~~~
# apt-get install xinetd tftp tftpd
~~~

tftp Ubuntu Package 설치한다.

{% highlight text %}
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
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] /etc/xinetd.d/tftp</figcaption>
</figure>

/etc/xinetd.d/tftp 파일을 [파일 2]의 내용으로 생성한다.

~~~
# mkdir /tftpboot
# chmod 777 /tftpboot
# /etc/init.d/xinetd restart
~~~

tftp server Directory 생성한다.

##### 8.1.2. tftp Server에 Binary 복사

~~~
# cd linux_Dom0
# cp ./arch/arm/boot/dts/exynos5250-arndale.dtb /tftpboot
# cp ./arch/arm/boot/zImage /tftpboot/linux-zImage
# cd xen-4.5.0
# cp xen-uImage /tftpboot
~~~

생성한 Binary들을 tfpt Server에 복사한다.

##### 8.1.3 tftp Image 파일 생성

~~~
# cd /tftpboot
# wget http://xenbits.xen.org/people/julieng/load-xen-tftp.scr.txt
# mkimage -T script -C none -d load-xen-tftp.scr.txt /tftpboot/load-xen-tftp.img
~~~

Booting을 위한 tfpt Image 파일을 생성한다.

##### 8.1.4. tfpt Image 파일 복사 

load-xen-tftp.img 파일을 uSD Card의 ext2 Partition에 복사한다.

##### 8.1.5. U-boot 설정

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

U-boot를 설정한다.
* board IP : 192.168.0.200
* tftp Server (Host PC) : 192.168.0.100

#### 8.2. uSD Card Boot

##### 8.2.1. load-xen-uSD.scr.txt 파일 생성 및 img 파일 생성 

~~~
# wget http://xenbits.xen.org/people/julieng/load-xen-tftp.scr.txt
# mv load-xen-tftp.scr.txt load-xen-uSD.scr.txt
~~~

{% highlight text %}
...
# Load Linux in memory
ext2load mmc 0:1 $kernel_addr_r /linux-zImage
# Load Xen in memory
ext2load mmc 0:1 $xen_addr_r /xen-uImage
# Load the device tree in memory
ext2load mmc 0:1 $dtb_addr_r /exynos5250-arndale.dtb
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] /etc/xinetd.d/tftp</figcaption>
</figure>

load-xen-tftp.scr.txt 파일을 통해서 load-xen-uSD.scr.txt 파일을 생성한다.

~~~
# mkimage -T script -C none -d load-xen-uSD.scr.txt /tftpboot/load-xen-uSD.img
~~~

Image 파일을 생성한다.

##### 8.2.2. Kernel Images, dtb, uSD Card Image 파일 복사

linux-zImage, exynos5250-arndale.dtb, load-xen-uSD.img 파일을 uSD Card의 ext2 Partition에 복사한다.

##### 8.2.3. U-boot 설정

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

U-boot를 설정한다.

### 9. Xen Tool Build

~~~
# apt-get install sbuild
# sbuild-adduser $USER
~~~

sbuild와 schroot를 설치한다.

~~~
# sbuild-createchroot --components=main,universe trusty /srv/chroots/trusty-armhf-cross http://archive.ubuntu.com/ubuntu/
# mv /etc/schroot/chroot.d/trusty-amd64-sbuild-*(random suffix) /etc/schroot/chroot.d/trusty-armhf-cross
~~~

root를 구성한다.

{% highlight text %}
...
[trusty-armhf-cross]
...
description=Debian trusty/armhf crossbuilder
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 4] /etc/schroot/chroot.d/trusty-armhf-cross</figcaption>
</figure>

/etc/schroot/chroot.d/trusty-armhf-cross 파일을 [파일 4]와 같이 수정한다.

~~~
# schroot -c trusty-armhf-cross
(schroot)# apt-get install vim-tiny wget sudo less pkgbinarymangler
(schroot)# echo deb http://ports.ubuntu.com/ trusty main universe >> /etc/apt/
(schroot)# echo 'APT::Install-Recommends "0"' >> /etc/apt/apt.conf.d/30norecommends
(schroot)# echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/30norecommends
(schroot)# dpkg --add-architecture armhf
(schroot)# apt-get update
(schroot)# apt-get install wget
(schroot)# apt-get install crossbuild-essential-armhf
(schroot)# apt-get install libc6-dev:armhf libncurses-dev:armhf uuid-dev:armhf libglib2.0-dev:armhf libssl-dev:armhf libssl-dev:armhf libaio-dev:armhf libyajl-dev:armhf python gettext gcc git libpython2.7-dev:armhf libfdt-dev:armhf libpixman-1-dev:armhf
~~~

root에 Package를 설치한다.

~~~
(schroot)# git clone -b RELEASE-4.5.0 git://xenbits.xen.org/xen.git xen-4.5.0
(schroot)# cd xen-4.5.0
(schroot)# CONFIG_SITE=/etc/dpkg-cross/cross-config.armhf ./configure --build=x86_64-unknown-linux-gnu --host=arm-linux-gnueabihf
(schroot)# make dist-tools CROSS_COMPILE=arm-linux-gnueabihf- XEN_TARGET_ARCH=arm32
  - Confirm 'dist/install' Directory
(schroot)# exit
~~~

Xen Tool을 Build한다.

### 10. 기본 Root Filesystem Image 생성

~~~
# dd if=/dev/zero bs=1M count=1024 of=rootfs_ori.img
# mkfs.ext3 rootfs_ori.img (Proceed anyway? (y,n) y)
# mount -o loop rootfs_ori.img /mnt
~~~

Image 파일을 생성한다. 

~~~
# apt-get install debootstrap qemu-user-static binfmt-support
# debootstrap --foreign --arch armhf trusty /mnt http://ports.ubuntu.com/
# cp /usr/bin/qemu-arm-static /mnt/usr/bin/
# sudo chroot /mnt
(chroot)# ./debootstrap/debootstrap --second-stage
~~~

Root Filesystem을 구성한다. 

~~~
(chroot)# passwd
~~~

root password를 설정한다. 

{% highlight text %}
auto eth0
iface eth0 inet dhcp
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 5] 기본 Root Filesystem Image의 /etc/network/interfaces</figcaption>
</figure>

/etc/network/interfaces를 [파일 5]의 내용으로 설정한다.

~~~
(chroot)# echo deb http://ports.ubuntu.com/ trusty main >> /etc/apt/sources.list
~~~

Repository를 설정한다. 

~~~
(chroot)# cp /etc/init/tty1.conf /etc/init/xvc0.conf
~~~

{% highlight text %}
...
respawn
exec exec /sbin/getty -8 115200 hvc0
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 6] 기본 Root Filesystem Image의 /etc/init/xvc0.conf</figcaption>
</figure>

/etc/init/xvc0.conf 파일을 [파일 6]의 내용으로 생성하여 getty를 설정한다.

~~~
(chroot) # echo 'xenfs   /proc/xen    xenfs    defaults   0   0' >> /etc/fstab
(chroot) # exit
# umount /mnt
~~~

fstab을 설정한다.

### 11. Dom0 Root Filesystem 설정

~~~
# cp rootfs_ori.img rootfs_Dom0.img
# mount -o loop rootfs_Dom0.img /mnt
~~~

Root Img 파일을 복사한다.

~~~
# rsync -avp /srv/chroots/trusty-armhf-cross/root/xen-4.5.0/dist/install/ /mnt/
~~~

Xen Tool을 복사한다. 

~~~
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=/mnt modules_install
~~~

Kernel Module Compile 및 복사를 수행한다.

~~~
# sudo chroot /mnt
(chroot)# cat << EOF > /etc/modules
xen-gntalloc
xen-gntdev
bridge
EOF
~~~

Default Kernel Module을 설정한다.

~~~
(chroot) # echo Dom0 > /etc/hostname
(chroot) # exit
# umount /mnt
~~~

Hostname을 설정한다. 

### 12. DomU_01 Root Filesystem 설정

~~~
# cp rootfs_ori.img rootfs_DomU_01.img
# mount -o loop rootfs_DomU_01.img /mnt
~~~

img 파일을 복사한다.

~~~
# cd /mnt/dev
# mknod xvda b 202 0
# mknod xvdb b 202 16 
# mknod xvdc b 202 32
# mknod xvdd b 202 48
# mknod xvde b 202 64
# mknod xvdf b 202 80
# mknod xvdg b 202 96
# mknod xvdh b 202 112
~~~

xvdX Device Node를 생성한다.

~~~
# echo DomU01 > /mnt/etc/hostname
~~~

Hostname을 설정한다.

~~~
# cat << EOF > /mnt/etc/network/interfaces
auto eth0
iface eth0 inet static
address 192.168.0.160
netmask 255.255.255.0
gateway 192.168.0.1
dns-nameservers 8.8.8.8
EOF
# umount /mnt
~~~

Network를 설정한다.

### 13. DomU_02 Root Filesystem 설정

~~~
# cp rootfs_DomU_01.img rootfs_DomU_02.img
# mount -o loop rootfs_DomU_02.img /mnt
~~~

img 파일을 복사한다.

~~~
(chroot)# vi /mnt/etc/hostname
  -> DomU02
~~~

Hostname을 설정한다.

~~~
# cat << EOF > /mnt/etc/network/interfaces
auto eth0
iface eth0 inet static
address 192.168.0.161
netmask 255.255.255.0
gateway 192.168.0.1
dns-nameservers 8.8.8.8
EOF
# umount /mnt
~~~

Network를 설정한다.

### 14. zImage, Root Filesystem 복사

~~~
# mount -o loop rootfs_Dom0.img /mnt
# rsync -avp /mnt/ /media/root/root (ext3 partition in uSD)
# cp rootfs_DomU_01.img /media/root/root/root (ext3 partition in uSD)
# cp rootfs_DomU_02.img /media/root/root/root (ext3 partition in uSD)
# cp DomU_zImage /media/root/root/root (ext3 partition in uSD)
# umount /mnt
~~~

zImage, Root Filesystem들을 uSD에 복사한다.

### 15. Dom0에서 Ubuntu Package 설치

~~~
(Dom0)# apt-get install libyajl-dev
(Dom0)# apt-get install libfdt-dev
(Dom0)# apt-get install libaio-dev 
(Dom0)# apt-get install libglib2.0-dev
(Dom0)# apt-get install libpixman-1-dev
(Dom0)# ldconfig
(Dom0)# apt-get install bridge-utils
~~~

uSD Card를 Arndale Board에 넣고 Booting하여 Dom0에 진입후 아래의 명령어를 수행한다.

### 16. DomU Config 파일 생성

{% highlight text %}
kernel = "/root/Xen_Guest/DomU_zImage"
name = "DomU_01"
memory = 128
vcpus = 1
disk = [ 'phy:/dev/loop0,xvda,w' ]
vif = ['bridge=xenbr0']
extra = "earlyprintk=xenboot console=hvc0 rw rootwait root=/dev/xvda"
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 7] 기본 Root Filesystem Image의 DomU_01.cfg</figcaption>
</figure>

[파일 7]의 내용으로 DomU_01.cfg 파일을 생성한다.

{% highlight text %}
kernel = "/root/Xen_Guest/DomU_zImage"
name = "DomU_02"
memory = 128
vcpus = 1
disk = [ 'phy:/dev/loop1,xvda,w' ]
vif = ['bridge=xenbr0']
extra = "earlyprintk=xenboot console=hvc0 rw rootwait root=/dev/xvda"
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 8] 기본 Root Filesystem Image의 DomU_02.cfg</figcaption>
</figure>

[파일 8]의 내용으로 DomU_02.cfg 파일을 생성한다.

### 17. DomU 구동

~~~
(Dom0)# /etc/init.d/xencommons start
(Dom0)# brctl addbr xenbr0
(Dom0)# brctl addif xenbr0 eth0
(Dom0)# ifconfig xenbr0 192.168.0.150 up
(Dom0)# ifconfig eth0 0.0.0.0 up
(Dom0)# route add default gw 192.168.0.1 xenbr0
~~~

Xencommons 구동 및 Bridge 생성한다.

~~~
(Dom0)# losetup /dev/loop0 rootfs_DomU_01.img                                           
(Dom0)# xl create DomU_01.cfg
(Dom0)# losetup /dev/loop1 rootfs_DomU_02.img                                           
(Dom0)# xl create DomU_02.cfg
~~~

DomU를 구동한다.

### 18. 참조

* [http://wiki.xenproject.org/wiki/Xen_ARMv7_with_Virtualization_Extensions/Arndale](http://wiki.xenproject.org/wiki/Xen_ARMv7_with_Virtualization_Extensions/Arndale)
* [http://wiki.xenproject.org/wiki/Xen_ARMv7_with_Virtualization_Extensions#Building_Xen_on_ARM](http://wiki.xenproject.org/wiki/Xen_ARMv7_with_Virtualization_Extensions#Building_Xen_on_ARM)
* [http://wiki.xenproject.org/wiki/Xen_ARM_with_Virtualization_Extensions/CrossCompiling](http://wiki.xenproject.org/wiki/Xen_ARM_with_Virtualization_Extensions/CrossCompiling)
* [http://wiki.xenproject.org/wiki/Xen_ARM_with_Virtualization_Extensions/RootFilesystem](http://wiki.xenproject.org/wiki/Xen_ARM_with_Virtualization_Extensions/RootFilesystem)
* [https://wiki.linaro.org/Boards/Arndale/Setup/PXEBoot](https://wiki.linaro.org/Boards/Arndale/Setup/PXEBoot)
* [http://forum.falinux.com/zbxe/index.php?document_srl=518293&mid=lecture_tip](http://forum.falinux.com/zbxe/index.php?document_srl=518293&mid=lecture_tip)
* [http://badawave.tistory.com/entry/Xen-ARM-with-Virtualization-ExtensionsArndale](http://badawave.tistory.com/entry/Xen-ARM-with-Virtualization-ExtensionsArndale)
* [http://lists.xen.org/archives/html/xen-users/2012-03/msg00325.html](http://lists.xen.org/archives/html/xen-users/2012-03/msg00325.html)

