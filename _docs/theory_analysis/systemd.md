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

journald는 Linux의 주요 Log를 저장하고 관리하는 Daemon이다. journald는 **/var/log/journal** 폴더 아래 다음과 같은 내용을 Log로 남긴다.

* /proc/kmsg를 통해 전달되는 Kernel Log를 기록한다.
* App이 syslog(3) 함수를 통해서 남기는 Log를 기록한다. Log는 /dev/log (/run/systemd/journal/dev-log) Domain Socket을 통해서 journald에게 전달된다.
* sd_journal_sendv() 함수같은 journald가 제공하는 API를 통해 전달된 Log를 기록한다. Log는 /run/systemd/journal/socket Domain Socket을 통해서 journald에게 전달된다.
* systemd Service들의 stdout, stderr를 Log로 기록한다. Log는 /run/systemd/journal/stdout을 통해서 journald에게 전달된다.
* Audit Log를 기록한다.

/dev/log Domain Socket은 journald가 나오기전 rsyslogd가 log를 받아 /var/log 폴더 아래 Log를 남길때 이용되던 Domain Socket이다. 따라서 rsyslogd는 journald와 같이 동작하는 경우 아래와 같은 2가지 방법으로 Log를 받을 수 있다

* /run/systemd/journal/syslog Domain Socket을 통해서 rsyslogd에게 Log를 전달 할 수 있다.
* imjournal Module은 journald가 기록한 Log를 rsyslogd에게 전달한다.

journald는 Log 기록시 rsyslogd처럼 Plain Text를 이용하지 않고 Structure를 이용하여 Log뿐만 아니라 Log의 Meta 정보를 같이 저장하는 방식이다. Structure를 통해서 journald는 Log를 빠르게 검색하거나 필터링 할 수 있다. journald는 Structure 구조이기 때문에 cat같은 Standard UNIX Tool로 Log 확인이 힘들다. journald에서 제공하는 **journalctl** 명령어로 Log를 확인 할 수 있다.

### 2. 참조

* [https://en.wikipedia.org/wiki/Systemd](https://en.wikipedia.org/wiki/Systemd)
*[https://www.maketecheasier.com/systemd-what-you-need-to-know-linux/](https://www.maketecheasier.com/systemd-what-you-need-to-know-linux/)
* journald - [https://unix.stackexchange.com/questions/205883/understand-logging-in-linux/](https://unix.stackexchange.com/questions/205883/understand-logging-in-linux/)
* journald - [https://askubuntu.com/questions/925440/relationship-of-rsyslog-and-journald-on-ubuntu-16-04](https://askubuntu.com/questions/925440/relationship-of-rsyslog-and-journald-on-ubuntu-16-04)
* jorunald - [https://www.loggly.com/blog/why-journald/](https://www.loggly.com/blog/why-journald/)

