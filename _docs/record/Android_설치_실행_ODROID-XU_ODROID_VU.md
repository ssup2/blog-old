---
title: Android 설치, 실행 / ODROID-XU, ODROID-VU 환경
category: Record
date: 2014-10-24T12:00:00Z
lastmod: 2014-10-24T12:00:00Z
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
* ODROID-XU, 16GB emmc
* Android 4.2.2 Alpha 2.5 Release

### 2. Windows에 ADB Driver 설치

Windows의 Device Manager를 통해 ADB USB Driver를 설치한다.
* http://com.odroid.com/sigong/nf_file_board/nfile_board_view.php?bid=22

### 3. Ubuntu Package 설치

~~~
# apt-get install git gnupg flex bison gperf build-essential zip curl libc6-dev libncurses5-dev:i386 x11proto-core-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc zlib1g-dev:i386
# ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
~~~

Android Build를 위한 Ubuntu Package를 설치한다.

~~~
# add-apt-repository ppa:webupd8team/java
# apt-get update
# apt-get install oracle-java6-installer
~~~

Java 6를 설치한다.

### 5. Ubuntu에 Repo 설치

~~~
# mkdir ~/bin
# curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
# chmod a+x ~/bin/repo
~~~

Repo는 Android Build시 이용된다. Android Build시 이용하는 Repo를 설치한다.

{% highlight shell %}
...
PATH=~/bin:$PATH
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] ~/.bashrc</figcaption>
</figure>

~/.bashrc 파일에 [파일 1]의 내용을 추가하여 어느 Directory에서든 Repo를 이용할 수 있도록 만든다.

### 6. Ubuntu에 Cross Compiler 설치

~~~
# mv ./arm-eabi-4.6.tar.gz /usr/local
# cd /usr/local
# tar zxvf arm-eabi-4.6.tar.gz
~~~

Cross Compiler를 설치한다. 
* Download : http://dn.odroid.com/ODROID-XU/compiler/arm-eabi-4.6.tar.gz

{% highlight shell %}
...
PATH=/usr/local/arm-eabi-4.6/bin:$PATH
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] ~/.bashrc</figcaption>
</figure>

~/.bashrc 파일에 [파일 2]의 내용을 추가하여 어느 Directory에서든 Compiler를 이용할 수 있도록 만든다.

### 7. Prebuilt Images와 Sources Download

Prebuilt Image들을 아래의 URL을 통해서 Download 한다.
* Prebuilt Image
  * http://dn.odroid.com/ODROID-XU/Firmware/01-10-2014/emmc_self_installer.img.zip
* Android, Kernel
  * http://dn.odroid.com/ODROID-XU/Android_bsp/01-25-2014/android.tgz
* Kernel Patch
  * http://dn.odroid.com/ODROID-XU/Android_bsp/04-07-2014/kernel_Apr_07_2014.patch
* Android Patch
  * http://dn.odroid.com/ODROID-XU/Android_bsp/04-07-2014/android_patch.zip
  * http://dn.odroid.com/ODROID-XU/Android_bsp/04-07-2014/android_patch.sh

### 8. Prebuilt Image를 emmc에 Flash 및 Android Update

~~~
# unzip emmc_self_installer.img.zip
# pv -tpreb emmc_self_installer.img | dd of=/dev/sdb bs=1M
~~~

PreBuild Image를 emmc에 Flash 한다. Android 부팅 후 ODROID-XU Updater 실행 및 아래의 URL을 입력한다.
* http://dn.odroid.com/ODROID-XU/Firmware/04-07-2014/update.zip

### 10. Patch 수행

#### 10.1. kernel

~~~
# chmod +x kernel_Apr_07_2014.patch
# patch -p1 < kernel_Apr_07_2014.patch
~~~

Kernel Root 폴더에 kernel_Apr_07_2014.patch 파일 복사 및 위의 명령어를 수행한다.

#### 10.2. Android

~~~
# chmod +x android_patch.sh
# ./android_patch.sh
~~~

Android Root 폴더에 android_patch.sh, android_patch.zip 파일 복사 및 위의 명령어를 수행한다.

### 11. Build

~~~
# cd [Kernel root]
# ARCH=arm CROSS_COMPILE=arm-eabi- make odroidxu_android_defconfig
# ARCH=arm CROSS_COMPILE=arm-eabi- make zImage -j4
# ARCH=arm CROSS_COMPILE=arm-eabi- make modules
# mkdir modules
# ARCH=arm CROSS_COMPILE=arm-eabi- INSTALL_MOD_PATH=modules make modules_install
~~~

Kenrel을 Build 한다.

~~~
# cd [Android Root]
# cp ../kernel/modules/lib/modules/3.4.5/kernel/drivers/net/usb/ax88179_178a.ko device/hardkernel/proprietary/bin
# cp ../kernel/modules/lib/modules/3.4.5/kernel/drivers/net/usb/smsc95xx.ko device/hardkernel/proprietary/bin
# cp ../kernel/modules/lib/modules/3.4.5/kernel/drivers/net/wireless/rtl8191su/rtl8191su.ko device/hardkernel/proprietary/bin
# cp ../kernel/modules/lib/modules/3.4.5/kernel/drivers/net/wireless/rtl8192cu_v40/rtl8192cu.ko device/hardkernel/proprietary/bin
# cp ../kernel/modules/lib/modules/3.4.5/kernel/drivers/scsi/scsi_wait_scan.ko device/hardkernel/proprietary/bin
# cp ../kernel/modules/lib/modules/3.4.5/kernel/drivers/w1/wire.ko device/hardkernel/proprietary/bin
# cp ../kernel/arch/arm/boot/zImage device/hardkernel/odroidxu
# ./build.sh odroidxu platform
~~~

Android를 Build 한다.

### 12. Flash Image

~~~
Exynos5410 # fastboot
~~~

ODROID-XU의 OTG USB와 PC를 연결한 다음 u-boot에서 위의 명령어 수행한다.

~~~
# fastboot flash kernel kernel/arch/arm/boot/zImage
# fastboot flash system android/out/target/product/odroidxu/system.img
# fastboot reboot
~~~

Ubuntu에서 위의 명령어를 수행한다.

### 13. 참조

* [http://odroid.com/dokuwiki/doku.php?id=en:odroid-xu](http://odroid.com/dokuwiki/doku.php?id=en:odroid-xu)
* [http://com.odroid.com/sigong/nf_file_board/nfile_board_view.php?keyword=&tag=ODROID-XU&bid=212](http://com.odroid.com/sigong/nf_file_board/nfile_board_view.php?keyword=&tag=ODROID-XU&bid=212)
* [http://www.webupd8.org/2012/11/oracle-sun-java-6-installer-available.html](http://www.webupd8.org/2012/11/oracle-sun-java-6-installer-available.html)
