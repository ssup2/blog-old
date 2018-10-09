---
title: systemd
category: Theory, Analysis
date: 2018-10-15T12:00:00Z
lastmod: 2018-10-15T12:00:00Z
comment: true
adsense: true
---

현재 대부분의 Linux OS에서 Init Process로 이용되는 systemd를 분석한다.

### 1. systemd

systemd는 Linux Kernel과의 협력을 통해 OS를 전반적으로 관리하는 System 및 Service Manager이다. 처음에는 기존에 Init Process로 많이 이용되던 SysVinit의 빈약한 Service(Daemon) 관리 기능을 대체하기 위해서 개발되었다. 시간이 지나면서 systemd에는 Service 관리 기능뿐만이 아니라 Log, User Session, Network, Device, Mount등의 System Resource를 관리하는 기능이 추가되었고, 현재는 전반적인 System을 관리하는 역활을 수행하고 있다.

SysVinit은 System 관리자가 작성한 Service Script를 실행하고, Service Process를 관리하는 정도의 제한된 Service 기능만을 제공하였다. systemd는 Service Config 파일을 통해서 Service를 세밀하게 제어할 수 있고, Service Log 관리기능도 제공한다. 또한 Process 사이의 Message BUS인 D-BUS 제공을 통해 Service 사이의 통신도 쉽게 구현 할 수 있는 환경을 제공한다.

SysVinit은 순차적으로 Service를 수행하는 방식이었지만 systemd는 병렬적으로 다수의 Service들을 실행하고 초기화한다. 따라서 systemd는 SysVinit에 비해서 빠른 Booting 및 System 초기화가 가능하다. 하휘 호환성을 위해서 SysVinit의 Init Script, LSB(Linux Standard Base) Script도 지원한다.

#### 1.1. journald

journald는 Service Log를 관리를 위해서 systemd Daemon이 실행하는 Daemon이다.

#### 1.2. logind

#### 1.3. networkd

#### 1.4. udevd

### 2. 참조

* [https://en.wikipedia.org/wiki/Systemd](https://en.wikipedia.org/wiki/Systemd)
*[https://www.maketecheasier.com/systemd-what-you-need-to-know-linux/](https://www.maketecheasier.com/systemd-what-you-need-to-know-linux/)

