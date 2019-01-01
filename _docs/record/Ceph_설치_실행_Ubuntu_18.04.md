---
title: Ceph 설치,실행 - Ubuntu 18.04
category: Record
date: 2019-01-10T12:00:00Z
lastmod: 2019-01-10T12:00:00Z
comment: true
adsense: true
---

### 1. 설정 환경

* Ubuntu 18.04 LTS 64bit, root user

### 2. Node 설정

![]({{site.baseurl}}/images/record/Ceph_Install_Ubuntu_18.04/Node_Setting.PNG)

* VirtualBox를 이용하여 위의 그림과 같이 가상의 Node (VM)을 생성한다.
* NAT - Virtual Box에서 제공하는 "NAT 네트워크" 이용하여 10.0.0.0/24 Network를 구축한다.
* HDD - 각 Node에 Ceph가 이용할 추가 HDD (/dev/sdb)를 생성하고 붙인다.
* Router - 공유기를 이용하여 192.168.0.0/24 Network를 구축한다. (NAT)

#### 2.1. Deploy Node

#### 2.2. Ceph Node

### 3. Ceph 설치

### 4. 참조

* [http://docs.ceph.com/docs/master/start/](http://docs.ceph.com/docs/master/start/)
