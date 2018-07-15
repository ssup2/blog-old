---
title: Android 설치 - Arndale Broad
category: Record
date: 2014-10-02T12:00:00Z
lastmod: 2014-10-02T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

* PC - Windows 7 64bit
* VM - Ubuntu 12.04LTS 64bit
* Android JB mr1 provided from Insignal

### 2. Windows에 USB Driver 설치

* Arndale Board의 USB OTG 단자를 통해 PC와 연결
* Hardware ID 확인 (Computer -> Properties -> Device Manager -> Full -> Properties > Details >Hardware ID)

![]({{site.baseurl}}/images/record/Android_Install_Arndale/Arndale_USB_Hardware_Info.PNG){: width="400px"}

* android_winusb.inf (adt-bundle-windows-x86_64-20xxxxxx\sdk\extras\google\usb_driver\android_winusb.inf) 파일을 아래에 아래의 내용 추가

~~~
...
[Google.NTx86]
;Insignal ARNDALE
%CompositeAdbInterface%     = USB_Install, USB\VID_18D1&PID_0002&REV_0100
%CompositeAdbInterface%     = USB_Install, USB\VID_18D1&PID_0002

...
[Google.NTamd64]
;Insignal ARNDALE
%CompositeAdbInterface%     = USB_Install, USB\VID_18D1&PID_0002&REV_0100
%CompositeAdbInterface%     = USB_Install, USB\VID_18D1&PID_0002
~~~

* Windows의 Device Manager를 통해 ADB USB Driver 설치

### 3. Ubuntu Package 설치 - VM

* Ubuntu Package 설치

~~~
# apt-get install git gnupg flex bison gperf build-essential zip curl libc6-dev libncurses5-dev:i386 x11proto-core-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc zlib1g-dev:i386
# ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
~~~

* Java 6 설치

~~~
# add-apt-repository ppa:webupd8team/java
# apt-get update
# apt-get install oracle-java6-installer
~~~

### 4. Ubuntu에 Repo 설치

* Download Repo

~~~
# mkdir ~/bin
# curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
# chmod a+x ~/bin/repo
~~~

* ~/.bashrc 파일에 아래의 내용 추가

~~~
PATH=~/bin:$PATH
~~~

### 5. Ubuntu에 fastboot, adb 설치

* Download - http://forum.insignal.co.kr/download/file.php?id=90
* 설치

~~~
# unzip adb_fastboot_for_linux_host.zip
# mv adb ~/bin
# mv fastboot ~/bin
~~~

### 6. Ubuntu에 Cross Compiler 설치

* Download - http://www.arndaleboard.org/wiki/downloads/supports/arm-2009q3.tar
* 설치

~~~
# mv ./arm-2009q3.tar /usr/local
# cd /usr/local
# tar xvf arm-2009q3.tar
~~~

* ~/.bashrc 파일에 아래의 내용 추가

~~~
PATH=/usr/local/arm-2009q3/bin:$PATH
~~~

### 7. Source Code Download

* u-boot, Linux Kernel, Android jb-mr1 Download

~~~
# repo init -u git://git.insignal.co.kr/samsung/exynos/android/manifest.git -b jb-mr1
# repo sync
~~~

### 8. Download Proprietary

* Download Exynos5250 - http://forum.insignal.co.kr/download/file.php?id=247
* Download Arndale - http://forum.insignal.co.kr/download/file.php?id=246
* 설정

~~~
# mv vendor_samsung_slsi_exynos5250_jb-mr1_20140526_14b314b.run [root of source tree]
# mv vendor_insignal_arndale_jb-mr1_20140526_0a0bc3f.run [root of source tree]
# cd [root of source tree]
# chmod chmod +x vendor_samsung_slsi_exynos5250_jb-mr1_20140526_14b314b.run
# chmod chmod +x vendor_insignal_arndale_jb-mr1_20140526_0a0bc3f.run
# ./vendor_samsung_slsi_exynos5250_jb-mr1_20140526_14b314b.run
# ./vendor_insignal_arndale_jb-mr1_20140526_0a0bc3f.run
~~~

### 9. ccache 설정

* 설정 

~~~
# cd [root of source tree]
# export USE_CCACHE=1
# export CCACHE_DIR=/[path of your choice]/.ccache
# prebuilts/misc/linux-x86/ccache/ccache -M 20G
# watch -n1 -d prebuilts/misc/linux-x86/ccache/ccache -s
~~~

### 10. Build

* u-boot Build

~~~
# cd [root of source tree]/u-boot/
# make clobber
# make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- arndale_config
# make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi-
~~~

* Kenrel Build

~~~
# cd [root of source tree]/u-boot/
# kernel_make distclean
# kernel_make arndale_android_defconfig
# kernel_make -j16
~~~

* Android Build

~~~
# cd [root of source tree]/u-boot/
# choosevariant
# choosetype
# make kernel-binaries
# make -j4
~~~

### 11. Bootable uSD Card 만들기

* uSD Card를 Ubuntu에 연결 및 Device Name 확인 (/dev/sdb) 
* uSD Card Format 

~~~
# source ./arndale_envsetup.sh
# mksdboot /dev/sdb
~~~

### 12. uSD Card에 Partition 생성

* uSD Card를 Arndale에 넣은 뒤 Arndale의 u-boot에 접근
* u-boot에서 Partition 생성

~~~
Arndale # fdisk -c 0 520 520 520
Arndale # fatformat mmc 0:1
Arndale # fatformat mmc 0:2
Arndale # fatformat mmc 0:3
Arndale # fatformat mmc 0:4
~~~   

### 13. Binary들을 uSD에 Flash

* Arndale Board의 USB OTG 단자를 통해 PC와 연결
* u-boot에서 Flash 준비

~~~
Arndale # fastboot
~~~ 

* Flash

~~~
# fastboot flash fwbl1 ./vendor/insignal/arndale/exynos5250/exynos5250.bl1.bin
# fastboot flash bl2 ./u-boot/bl2.bin
# fastboot flash bootloader ./u-boot/u-boot.bin
# fastboot flash tzsw ./vendor/insignal/arndale/exynos5250/exynos5250.tzsw.bin
# fastboot flash kernel ./kernel/arch/arm/boot/zImage
# fastboot flash ramdisk ./out/debug/target/product/arndale/ramdisk.img.ub
# fastboot flash system ./out/debug/target/product/arndale/system.img
# fastboot reboot
~~~

### 14. 참조

* [http://www.webupd8.org/2012/11/oracle-sun-java-6-installer-available.html](http://www.webupd8.org/2012/11/oracle-sun-java-6-installer-available.html)
* [https://source.android.com/setup/build/downloading#installing-repo](https://source.android.com/setup/build/downloading#installing-repo)
