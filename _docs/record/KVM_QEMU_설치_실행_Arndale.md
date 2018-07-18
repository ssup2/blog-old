---
title: KVM, QEMU 설치, 실행 - Arndale Broad
category: Record
date: 2015-07-22T12:00:00Z
lastmod: 2015-07-22T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

* Arndale Board, 8GB uSD
* PC - Ubuntu 14.04LTS 32bit, root User
* VM on KVM - Ubuntu 14.04LTS 32bit, root User
* Cross compiler - arm-linux-gnueabihf-4.9.3
* Network 192.168.0.xxx (NAT)
  * HostOS - 192.168.0.150
  * br0 - 192.168.0.200
  * GeustOS_01 - 192.168.0.160, GeustOS_02 - 192.168.0.161
  * tap0 - 192.168.0.201, tap1 - 192.168.0.202

### 2. Cross Compiler 설치

* Download - https://releases.linaro.org/15.02/components/toolchain/binaries/arm-linux-gnueabihf/gcc-linaro-4.9-2015.02-3-x86_64_arm-linux-gnueabihf.tar.xz

* /usr/local Directory에 압축을 풀고 ~/.bashrc 파일에 아래의 내용 추가

~~~
PATH=$PATH:/usr/local/gcc-linaro-arm-linux-gnueabihf-4.8/bin
~~~

### 3. Ubuntu Package 설치

~~~
# apt-get install gcc-arm-linux-gnueabi
# apt-get install build-essential git u-boot-tools qemu-user-static libncurses5-dev
~~~

### 4. Kernel Config Download

* Login in - http://www.virtualopensystems.com/
* Guest Kernel Config - http://www.virtualopensystems.com/downloads/guides/kvm_virtualization_on_arndale/guest-config

### 5. Host Kernel, Host dtb Build

* Download

~~~
# wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.18.3.tar.xz
# tar xvf linux-3.18.3.tar.xz
# mv Kernel_Host
~~~ 

* Build

~~~
# cd Kernel_Host
# make ARCH=arm exynos_defconfig
# make ARCH=arm menuconfig

 -> Kernel hacking -> [*] Kernel low-level debugging functions (read help!) -> Use Samsung S3C UART 2 for low-level debug
                   -> [*] Early printk
 -> Device Driver -> Generic Driver Options 
                  -> [*] Maintain a devtmpfs filesystem to mount at /dev
                  -> [*]  Automount devtmpfs at /dev, after the kernel mounted to the rootfs
 -> System Type -> [*] Support for the Large Physical Address Extension [*] 
 -> [*] Virtualization -> [*] Kernel-based Virtual Machine (KVM) support
 -> Device Drivers -> Virtio Drivers -> <*> Platform bus driver for memory mapped virtio devices
                                     -> <*> Virtio ballon driver
                                     -> [*] Memory mapped virtio devices parameter parsing
                   -> Block Drivers -> <*> Virtio block driver
                   -> Network device support -> <*> Universal TUN/TAP device driver support
                                             -> <*> Virtio network driver
 -> Networking support -> Networking options-> [M] 802.1d Ethernet Bridging

# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- LOADADDR=0x40008000  uImage
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- dtbs
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=. modules_install
~~~

### 6. Guest Kernel, Guest dtb Build

* Download

~~~
# wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.18.3.tar.xz
# tar xvf linux-3.18.3.tar.xz
# mv Kernel_Guest
~~~

* Build

~~~
# cd Kernel_Guest
# cp ../guest-config .config
# make ARCH=arm menuconfig
 -> Device Driver -> Generic Driver Options -> [*] Maintain a devtmpfs filesystem to mount at /dev
                                            -> [*]  Automount devtmpfs at /dev, after the kernel mounted to the rootfs
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
# cp arch/arm/boot/dts/armvexpress-v2p-ca15-tc1.dtb arch/arm/boot/dts/guest-vexpress.dtb
~~~

### 7. u-boot Build

~~~
# git clone git://github.com/virtualopensystems/u-boot-arndale.git Arndale_u-boot
# cd Arndale_u-boot
# make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- arndale5250
~~~

### 8. Root Filesystem Image 생성

* img 파일 생성 

~~~
# mkdir rootfs
# cd rootfs
# dd if=/dev/zero bs=1M count=700 of=rootfs.img
# /sbin/mkfs.ext3 rootfs.img (Proceed anyway? (y,n) y)
# mount -o loop rootfs.img /mnt
~~~

* debootstrap 

~~~
# cd /mnt
# qemu-debootstrap --arch=armhf trusty .
~~~

* Config

~~~
# vim etc/apt/sources.list
  -> deb http://ports.ubuntu.com/ trusty main restricted universe
  -> deb-src http://ports.ubuntu.com/ trusty main restricted universe
# cp etc/init/tty1.conf etc/init/ttySAC2.conf
# vim etc/init/ttySAC2.conf
  -> change all 'tty1' to 'ttySAC2'
  -> change '38400' to '115200'
# cp etc/init/tty1.conf etc/init/ttyAMA0.conf
# vim etc/init/ttyAMA0.conf
  -> change all 'tty1' to 'ttyAMA0'
# vim etc/securetty
  -> add 'ttySAC2'
# vim etc/network/interfaces
  -> 'auto eth0
      iface eth0 inet dhcp'
~~~

* root 설정

~~~
# chroot .
(chroot) # passwd
(chroot) # exit
# umount /mnt
~~~

### 9. Host Root Filesystem 설정 

~~~
# cp rootfs.img rootfs_host.img
# mount -o loop rootfs_host.img /mnt
# vi /mnt/etc/hostname
  -> host
# cp -R ../Kernel_Host/lib/modules /mnt/lib
# umount /mnt
~~~

### 10. Guest_01 Root Filesystem 설정 

~~~
# cp rootfs.img rootfs_guest_01.img
# mount -o loop rootfs_guest_01.img /mnt
# vi /mnt/etc/hostname
  -> guest01
# vim /mnt/etc/network/interfaces
  -> 'auto eth0
      iface eth0 inet static
      address 192.168.0.160
      netmask 255.255.255.0
      gateway 192.168.0.1
      dns-nameservers 8.8.8.8'
# umount /mnt
~~~

### 11. Guest_02 Root Filesystem 설정

~~~
# cp rootfs.img rootfs_guest_02.img
# mount -o loop rootfs_guest_02.img /mnt
# vi /mnt/etc/hostname
  -> guest02
# vim /mnt/etc/network/interfaces
  -> 'auto eth0
      iface eth0 inet static
      address 192.168.0.161
      netmask 255.255.255.0
      gateway 192.168.0.1
      dns-nameservers 8.8.8.8'
# umount /mnt
~~~

### 12. QEMU Build

~~~
# apt-get install xapt
# vim /etc/apt/sources.list.d/armel-precise.list
 -> add 'deb [arch=armel] http://ports.ubuntu.com/ubuntu-ports precise main restricted universe multiverse
         deb-src [arch=armel] http://ports.ubuntu.com/ubuntu-ports precise main restricted universe multiverse'
# xapt -a armel -m -b zlib1g-dev libglib2.0-dev libfdt-dev libpixman-1-dev
# dpkg -i /var/lib/xapt/output/*.deb
# apt-get install pkg-config-arm-linux-gnueabi

# git clone git://github.com/virtualopensystems/qemu.git
# cd qemu
# git checkout origin/kvm-arm-virtio-fb-hack -b virtio
# ./configure --cross-prefix=arm-linux-gnueabi- --target-list=arm-softmmu --audio-drv-list="" --enable-fdt --enable-kvm --static
# make
~~~

### 13. uSD Card Partiton 구성 

* 0 ~ 2M, 2M, No Filesystem: Bootloader (bl1, spl, U-boot)
* 2M ~ 18M, 16M, ext2, boot : uImage, exynos5250-arndale.dtb
* 18M ~ rest, ext3, root : Root-Filesystem

### 14. uSD Card에 u-boot Fusing

~~~
# cd Arndale-u-boot
# wget http://www.virtualopensystems.com/downloads/guides/kvm_virtualization_on_arndale/arndale-bl1.bin
# dd if=arndale-bl1.bin of=/dev/sdb bs=512 seek=1
# dd if=spl/smdk5250-spl.bin of=/dev/sdb bs=512 seek=17
# dd if=u-boot.bin of=/dev/sdb bs=512 seek=49
~~~

### 15. Host Root Filesystem 복사 

~~~
# mount -o loop rootfs_host.img /mnt
# cd /mnt
# cp -a * (MicroSD root Partition)
# sync
~~~

### 16. binary, image, dtb 복사

* Host Kernel uImage, exynos5250-arndale.dtb 파일을 uSD Card boot Partition에 복사
* Host Guest zImage, qemu-system-arm, rootfs_host.img, rootfs_guest_01.img, rootfs_guest_02.img, guest-vexpress.dtb 파일을 root Partition에 복사 

### 17. u-boot 설정

~~~
(u-boot) # setenv kernel_addr_r 0x40007000
(u-boot) # setenv dtb_addr_r 0x42000000
(u-boot) # setenv bootcmd 'ext2load mmc 0:1 $kernel_addr_r /uImage; ext2load mmc 0:1 $dtb_addr_r /exynos5250-arndale.dtb; bootm $kernel_addr_r - $dtb_addr_r'
(u-boot) # setenv bootargs 'root=/dev/mmcblk1p2 rw rootwait earlyprintk console=ttySAC2,115200n8 --no-log'
(u-boot) # save
~~~

### 18. Host Package 설정

* Arndale Board에서 uSD Card를 넣고 Host Booting 후, Host에서 실행 

~~~
(Host) # apt-get update (Host) # apt-get install gcc make ssh xorg fluxbox tightvncserver (Host) # apt-get install libsdl-dev libfdt-dev bridge-utils uml-utilities
~~~

### 19. Host에 Bridge 설정

~~~
(Host) # brctl addbr br0
(Host) # brctl addif br0 eth0
(Host) # ifconfig br0 192.168.0.150 up
(Host) # ifconfig eth0 0.0.0.0 up
(Host) # route add default gw 192.168.0.1
~~~

### 20. Host에 VNC를 통해 접속

* Host에서 VNC Server 실행

~~~
(Host) # tightvncserver -nolisten tcp :1
~~~

* VNC Client를 통해서 192.168.0.150:1에 접속

### 21. Guest 실행

* VNC Shell에서 각 Guest 실행

~~~
(Host) # tunctl -u root
(Host) # ifconfig tap0 192.168.0.200 up
(Host) # brctl addif br0 tap0
(Host) # ./qemu-system-arm \
	-enable-kvm -kernel guest_zImage \
	-nographic -dtb ./guest-vexpress.dtb \
	-m 512 -M vexpress-a15 -cpu cortex-a15 \
	-netdev type=tap,id=net0,script=no,downscript=no,ifname="tap0" \
	-device virtio-net,transport=virtio-mmio.1,netdev=net0 \
	-device virtio-blk,drive=virtio-blk,transport=virtio-mmio.0 \
	-drive file=./rootfs_guest_01.img,id=virtio-blk,if=none \
	-append "earlyprintk console=ttyAMA0 mem=512M root=/dev/vda rw --no-log virtio_mmio.device=1M@0x4e000000:74:0 virtio_mmio.device=1M@0x4e100000:75:1"
~~~

~~~
 (Host) # tunctl -u root
 (Host) # ifconfig tap1 192.168.0.201 up
 (Host) # brctl addif br0 tap1
 (Host) # ./qemu-system-arm \
	-enable-kvm -kernel guest_zImage \
	-nographic -dtb ./guest-vexpress.dtb \
	-m 512 -M vexpress-a15 -cpu cortex-a15 \
	-netdev type=tap,id=net0,script=no,downscript=no,ifname="tap1" \
	-device virtio-net,transport=virtio-mmio.1,netdev=net0 \
	-device virtio-blk,drive=virtio-blk,transport=virtio-mmio.0 \
	-drive file=./rootfs_guest_02.img,id=virtio-blk,if=none \
	-append "earlyprintk console=ttyAMA0 mem=512M root=/dev/vda rw --no-log virtio_mmio.device=1M@0x4e000000:74:0 virtio_mmio.device=1M@0x4e100000:75:1"
~~~

### 22. 참조

* [http://www.virtualopensystems.com/en/solutions/guides/kvm-virtualization-on-arndale](http://www.virtualopensystems.com/en/solutions/guides/kvm-virtualization-on-arndale)