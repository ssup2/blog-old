---
title: OpenStack Newton 설치
category: Record
date: 2017-07-04T12:00:00Z
lastmod: 2017-07-04T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

* OpenStack Newton Version
* Ubuntu Server 16.04.2 (VM)

### 2. Node 설정

![]({{site.baseurl}}/images/record/OpenStack_Newton_Install/Node_Setting.PNG)

* Virtual Box를 이용하여 위의 그림과 같이 가상의 Controller, Compute, Storage Node를 생성한다.
* NAT - Virtual Box에서 제공하는 "NAT 네트워크" 이용한다.

#### 2.1. Controller Node

* /etc/network/interfaces 수정

~~~
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto enp0s3
iface enp0s3 inet static
address 10.0.0.11
netmask 255.255.255.0
gateway 10.0.0.1

auto enp0s8
iface enp0s8 inet static
address 192.168.77.170
netmask 255.255.255.0
gateway 192.168.77.1
dns-nameservers 8.8.8.8
~~~

#### 2.2. Compute Node

* /etc/network/interfaces 수정

~~~
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto enp0s3
iface enp0s3 inet static
address 10.0.0.31
netmask 255.255.255.0
gateway 10.0.0.1

auto enp0s8
iface enp0s8 inet static
address 192.168.77.180
netmask 255.255.255.0
gateway 192.168.77.1
dns-nameservers 8.8.8.8
~~~

#### 2.3. Storage Node

* /etc/network/interfaces 수정

~~~
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto enp0s3
iface enp0s3 inet static
address 10.0.0.41
netmask 255.255.255.0
gateway 10.0.0.1

auto enp0s8
iface enp0s8 inet static
address 192.168.77.190
netmask 255.255.255.0
gateway 192.168.77.1
dns-nameservers 8.8.8.8
~~~

### 2. KeyStone 설치

### 2.1. Controller Node

* Ubuntu Package 설치

> \#

### 3. Glance 설치

### 4. Neutron 설치

### 5. Horizon 설치

### 6. Cinder 설치

### 7. 참조

* [https://docs.openstack.org/newton/ko_KR/install-guide-ubuntu/](https://docs.openstack.org/newton/ko_KR/install-guide-ubuntu/)
