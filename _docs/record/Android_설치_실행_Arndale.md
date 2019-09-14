---
title: Android 설치, 실행 / Arndale 환경
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

### 1. 설치, 실행 환경

설치, 실행 환경은 다음과 같다.
* PC : Windows 7 64bit
* VM on PC : Ubuntu 12.04LTS 64bit
* Android JB mr1 provided from Insignal

### 2. Windows에 USB Driver 설치

![[그림 1] Arndale Board의 Hardware ID 확인]({{site.baseurl}}/images/record/Android_Install_Arndale/Arndale_USB_Hardware_Info.PNG){: width="400px"}

Arndale Board의 USB OTG 단자를 통해 PC와 연결한 다음 Hardware ID 확인한다.
* Computer -> Properties -> Device Manager -> Full -> Properties > Details >Hardware ID

{% highlight text %}
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
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] adt-bundle-windows-x86_64-20xxxxxx\sdk\extras\google\usb_driver\android_winusb.inf</figcaption>
</figure>

android_winusb.inf 파일 아래에 [파일 1]의 내용을 추가한 다음 Windows의 Device Manager를 통해 ADB USB Driver 설치한다.

### 3. Ubuntu Package 설치

~~~sh-session
# apt-get install git gnupg flex bison gperf build-essential zip curl libc6-dev libncurses5-dev:i386 x11proto-core-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc zlib1g-dev:i386
# ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
~~~

Android Build에 필요한 Ubuntu Package 설치한다.

~~~console
# add-apt-repository ppa:webupd8team/java
# apt-get update
# apt-get install oracle-java6-installer
~~~

Android Build에 필요한 Java 6를 설치한다.

### 4. Ubuntu에 Repo 설치

~~~console
# mkdir ~/bin
# curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
# chmod a+x ~/bin/repo
~~~

Android Build시 이용하는 Repo를 설치한다.

{% highlight shell %}
...
PATH=~/bin:$PATH
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] ~/.bashrc</figcaption>
</figure>

~/.bashrc 파일에 [파일 2]의 내용을 추가하여 어느 Directory에서든 Repo를 이용할 수 있도록 만든다.

### 5. Ubuntu에 fastboot, adb 설치

~~~console
# unzip adb_fastboot_for_linux_host.zip
# mv adb ~/bin
# mv fastboot ~/bin
~~~

fastboot와 adb는 Build한 Android를 Device에 Flash할때 이용된다. fastboot와 adb를 설치한다.
* fastboot, adb Download : http://forum.insignal.co.kr/download/file.php?id=90

### 6. Ubuntu에 Cross Compiler 설치

~~~console
# mv ./arm-2009q3.tar /usr/local
# cd /usr/local
# tar xvf arm-2009q3.tar
~~~

Cross Compiler를 설치한다.
* Cross Compiler Download : http://www.arndaleboard.org/wiki/downloads/supports/arm-2009q3.tar

{% highlight shell %}
...
PATH=/usr/local/arm-2009q3/bin:$PATH
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] ~/.bashrc</figcaption>
</figure>

~/.bashrc 파일에 [파일 3]의 내용을 추가하여 어느 Directory에서든 Compiler를 이용할 수 있도록 만든다.

### 7. Source Code Download

~~~console
# repo init -u git://git.insignal.co.kr/samsung/exynos/android/manifest.git -b jb-mr1
# repo sync
~~~

u-boot, Linux Kernel, Android jb-mr1 Source를 받는다.

### 8. Download Proprietary

~~~console
# mv vendor_samsung_slsi_exynos5250_jb-mr1_20140526_14b314b.run [root of source tree]
# mv vendor_insignal_arndale_jb-mr1_20140526_0a0bc3f.run [root of source tree]
# cd [root of source tree]
# chmod chmod +x vendor_samsung_slsi_exynos5250_jb-mr1_20140526_14b314b.run
# chmod chmod +x vendor_insignal_arndale_jb-mr1_20140526_0a0bc3f.run
# ./vendor_samsung_slsi_exynos5250_jb-mr1_20140526_14b314b.run
# ./vendor_insignal_arndale_jb-mr1_20140526_0a0bc3f.run
~~~

Booting을 위한 Proprietary를 받고 설치한다.
* Exynos5250 Download : http://forum.insignal.co.kr/download/file.php?id=247	
* Arndale Download : http://forum.insignal.co.kr/download/file.php?id=246

### 9. ccache 설정

~~~console
# cd [root of source tree]
# export USE_CCACHE=1
# export CCACHE_DIR=/[path of your choice]/.ccache
# prebuilts/misc/linux-x86/ccache/ccache -M 20G
# watch -n1 -d prebuilts/misc/linux-x86/ccache/ccache -s
~~~

Build 성능 향상을 위해서 ccache를 설정한다.

### 10. Build

~~~console
# cd [root of source tree]/u-boot/
# make clobber
# make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- arndale_config
# make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi-
~~~

u-boot를 Build한다.

~~~console
# cd [root of source tree]/u-boot/
# kernel_make distclean
# kernel_make arndale_android_defconfig
# kernel_make -j16
~~~

Kernel을 Build한다.

~~~console
# cd [root of source tree]/u-boot/
# choosevariant
# choosetype
# make kernel-binaries
# make -j4
~~~

Android를 Build한다.

### 11. Bootable uSD Card 만들기

~~~console
# source ./arndale_envsetup.sh
# mksdboot /dev/sdb
~~~

uSD Card를 Ubuntu에 연결 및 Device Name (/dev/sdb) 확인한 다음 uSD Card Format한다.

### 12. uSD Card에 Partition 생성

~~~console
Arndale # fdisk -c 0 520 520 520
Arndale # fatformat mmc 0:1
Arndale # fatformat mmc 0:2
Arndale # fatformat mmc 0:3
Arndale # fatformat mmc 0:4
~~~

uSD Card를 Arndale에 넣은 뒤 Arndale의 u-boot에 접근한 다음 u-boot에서 Partition 생성한다.

### 13. Binary들을 uSD에 Flash

~~~console
Arndale # fastboot
~~~ 

Arndale Board의 USB OTG 단자를 통해 PC와 연결한 다음 u-boot에서 fastboot에 진입하여 Flash를 준비한다.

~~~console
# fastboot flash fwbl1 ./vendor/insignal/arndale/exynos5250/exynos5250.bl1.bin
# fastboot flash bl2 ./u-boot/bl2.bin
# fastboot flash bootloader ./u-boot/u-boot.bin
# fastboot flash tzsw ./vendor/insignal/arndale/exynos5250/exynos5250.tzsw.bin
# fastboot flash kernel ./kernel/arch/arm/boot/zImage
# fastboot flash ramdisk ./out/debug/target/product/arndale/ramdisk.img.ub
# fastboot flash system ./out/debug/target/product/arndale/system.img
# fastboot reboot
~~~

fastboot에서 Flash를 수행한다.

### 14. 참조

* [http://www.webupd8.org/2012/11/oracle-sun-java-6-installer-available.html](http://www.webupd8.org/2012/11/oracle-sun-java-6-installer-available.html)
* [https://source.android.com/setup/build/downloading#installing-repo](https://source.android.com/setup/build/downloading#installing-repo)
