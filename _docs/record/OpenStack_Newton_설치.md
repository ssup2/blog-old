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

* Ubuntu Server 16.04.2 (VM)
* OpenStack Newton Version
  * Controller Node - 1대
  * Compute Node - 1대
  * Block Storage Node - 1대
  * Network - Self-service

### 2. Node 설정

![]({{site.baseurl}}/images/record/OpenStack_Newton_Install/Node_Setting.PNG)

* Virtual Box를 이용하여 위의 그림과 같이 가상의 Controller, Compute, Storage Node를 생성한다.
* NAT - Virtual Box에서 제공하는 "NAT 네트워크" 이용한다.

#### 2.1. 모든 Node

##### 2.1.1. Network 설정

* /etc/hosts에 다음의 내용 추가

~~~
# controller
10.0.0.11       controller

# compute1
10.0.0.31       compute1

# block1
10.0.0.41       block1
~~~

##### 2.1.1. OpenStack Package 설치

* OpenStack Package 저장소 추가

> \# apt install software-properties-common <br>
> \# add-apt-repository cloud-archive:newton

* OpenStack Package 설치

> \# apt update && apt dist-upgrade
> \# apt install python-openstackclient

#### 2.2. Controller Node

##### 2.2.1. Network 설정

* /etc/network/interfaces을 다음과 같이 수정

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

##### 2.2.2. NTP (Network Time Protocol) 설정

* chrony Package 설치

> \# apt install chrony

* /etc/chrony/chrony.conf에 다음의 내용 추가

~~~
server 0.asia.pool.ntp.org
server 1.asia.pool.ntp.org
server 2.asia.pool.ntp.org
server 3.asia.pool.ntp.org

allow 10.0.0.0/24
~~~

* chrony 재시작

> \# service chrony restart

##### 2.2.3. SQL Database 설치

* MariaDB Package 설치

> \# apt install mariadb-server python-pymysql

* /etc/mysql/mariadb.conf.d/99-openstack.cnf 생성 및 다음과 같이 수정

~~~
[mysqld]
bind-address = 10.0.0.11

default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
~~~

* MariaDB 재시작

> \# service mysql restart

##### 2.2.4. Message Queue 설치

* RabbitMQ Package 설치

> \# apt install rabbitmq-server

* RabbitMQ 설정

> \# rabbitmqctl add_user openstack root <br>
> \# rabbitmqctl set_permissions openstack ".\*" ".\*" ".\*"

##### 2.2.5. Memcached 설치

* Memcached Package 설치

> \# apt install memcached python-memcache

* /etc/memcached.conf에 다음의 내용 추가

~~~
-l 10.0.0.11
~~~

#### 2.3. Compute Node

##### 2.3.1. Network 설정

* /etc/network/interfaces을 다음과 같이 수정

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

##### 2.3.2. NTP (Network Time Protocol) 설정

* chrony Package 설치

> \# apt install chrony

* /etc/chrony/chrony.conf에 다음의 내용 추가

~~~
server controller iburst
~~~

* chrony 재시작

> \# service chrony restart

#### 2.4. Storage Node

##### 2.4.1, Network 설정

* /etc/network/interfaces을 다음과 같이 수정

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

##### 2.4.2. NTP (Network Time Protocol) 설정

* chrony Package 설치

> \# apt install chrony

* /etc/chrony/chrony.conf에 다음의 내용 추가

~~~
server controller iburst
~~~

* chrony 재시작

> \# service chrony restart

### 3. KeyStone 설치

### 3.1. Controller Node

* Ubuntu Package 설치

> \#

### 4. Glance 설치

### 5. Neutron 설치

### 6. Horizon 설치

### 7. Cinder 설치

### 8. 참조

* [https://docs.openstack.org/newton/ko_KR/install-guide-ubuntu/](https://docs.openstack.org/newton/ko_KR/install-guide-ubuntu/)
