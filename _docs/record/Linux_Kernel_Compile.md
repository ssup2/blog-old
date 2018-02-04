---
title: Linux Kernel Compile
category: Record
date: 2017-02-04T12:00:00Z
lastmod: 2017-02-04T12:00:00Z
comment: true
adsense: true
---

### 1. Compile
#### 1.1. Clean

* make clean - .config 파일을 제외한 Build시 생성된 대부분의 파일들을 지운다. .config 파일은 이전 Kernel Compile시 이용한 config 파일이다.
* make mrproper - .config 파일을 포함하여 Build시 생성된 파일과 Config 관련 Backup 파일들을 모두 지운다.
* make distclean - mrproper을 수행하고 추가로 Editor Backup 파일, patch 파일들을 지운다.

#### 1.2. Configuration

* make config - 질의응답 방식으로 Config를 설정한다.
* make menuconfig - Ncurses(Text)기반의 GUI를 이용하여 Config를 설정한다. 이전 Kernel Version에서 이용하던 config 파일을 이용하여 추가의 설정이 필요한경우 Default값으로 설정된다.
* make xconfig - QT(X-Window)기반의 GUI를 이용하여 Config를 설정한다. 이전 Kernel Version에서 이용하던 config 파일을 이용하여 추가의 설정이 필요한경우 Default값으로 설정된다.
* make oldconfig - 기존의 .config 파일을 이용한다. 이전 Kernel Version에서 이용하던 config 파일을 이용하여 추가의 설정이 필요한경우 질의응답 방식으로 User에 설정 방법을 묻는다.

#### 1.3. Build

* make zImage - Kernel을 컴파일하고 압축된 zImage 파일까지 생성한다.
* make uImage - zImage 파일까지 생성 후 u-boot에서 사용하는 uImage 파일까지 생성한다. mkimage Tool이 설치되어 있어야 한다. Ubuntu에서는 uboot-mkimage Package를 설치하면 된다.
* make modules - module들을 컴파일 한다.

#### 1.4. Install

* make install - initrd 이미지를 생성해주고, vmlinuz, System.map 파일을 /boot에 복사하고 심볼릭 링크를 생성한다. 그리고 grub.conf를 알맞게 수정하여 새로운 Kernel 이미지로 부팅할 수 있게 한다.
* make modules_install - Compile한 Module들을 $INSTALL_MOD_PATH/lib/modules/[kernel version] 폴더에 저장한다. Shell에서 $INSTALL_MOD_PATH를 변수를 설정하여 복사 위치를 변경 할 수 있다. $INSTALL_MOD_PATH를 설정하지 않으면 /(root)의 lib 폴더 아래에 복사된다.

#### 1.5. E.T.C

* make tags - ctags 파일을 생성한다.
* make cscope - cscope 파일을 생성한다.
* make help - make Target들과 설명을 보여준다.

### 2. Example
#### 2.1. ARM

~~~
# ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- make menuconfig
# ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- make zImage
# ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- make uImage
# ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- make modules
# ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- INSTALL_MOD_PATH=tmp make modules_install
~~~
