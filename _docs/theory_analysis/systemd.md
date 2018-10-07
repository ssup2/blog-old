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

systemd는 Linux Kernel과의 협력을 통해 OS를 전반적으로 관리하는 System 및 Service Manager이다. 처음에는 기존에 Init Process로 많이 이용되던 SysVinit의 빈약한 Service(Daemon) 관리 기능을 대체하기 위해서 개발되었다. 시간이 지나면서 System Log, User Session, Network, Device, Mount등 다양한 System Resource 관리 기능이 추가되었다.

#### 1.1. systemd Daemon

SysVinit을 대체하여 Init Process 역활을 수행하는 Daemon이다. 주로 Service(Daemon)들을 실행하고 관리하는 역활을 수행한다. SysVinit은 순차적으로 Service를 수행하는 방식이었지만 systemd는 병렬적으로 다수의 Service들을 실행하고 초기화한다. 따라서 systemd는 SysVinit에 비해서 빠른 Booting이 가능하다. 하휘 호환성을 위해서 SysVinit의 Init Script, LSB(Linux Standard Base) Script도 지원한다.

#### 1.2. journald Daemon

#### 1.3. logind Daemon

#### 1.4. networkd Daemon

#### 1.5. udevd Daemon

### 2. 참조

* [https://en.wikipedia.org/wiki/Systemd](https://en.wikipedia.org/wiki/Systemd)
*[https://www.maketecheasier.com/systemd-what-you-need-to-know-linux/](https://www.maketecheasier.com/systemd-what-you-need-to-know-linux/)

