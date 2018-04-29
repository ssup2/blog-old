---
title: LXC Compile, 설치 - Ubuntu 18.04
category: Record
date: 2017-01-14T12:00:00Z
lastmod: 2017-01-15T12:00:00Z
comment: true
adsense: true
---

### 1. Package 설치
~~~
# apt-get install libtool m4 automake
# apt-get install libcap-dev
# apt-get install pkgconf
# apt-get install docbook
~~~

### 2. Compile, 설치
~~~
# git clone https://github.com/lxc/lxc.git
# cd lxc
# ./autogen.sh
# ./configure
# make
# make install
# ldconfig
~~~

* [https://github.com/lxc/lxc/blob/master/INSTALL](https://github.com/lxc/lxc/blob/master/INSTALL)
