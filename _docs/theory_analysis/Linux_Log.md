---
title: Linux Log
category: Theory, Analysis
date: 2017-01-14T12:00:00Z
lastmod: 2017-01-15T12:00:00Z
comment: true
adsense: true
---

Linux Log 관련 구성 요소와 역할을 분석한다.

### 1. Linux Log

![[그림 1] Linux Log 구성요소]({{site.baseurl}}/images/theory_analysis/Linux_Log/Linux_Log_Component.PNG)

[그림 1]은 Linux Log 관련 구성요소를 나타내고 있다. Log는 Kernel Log와 User Log로 분류 할 수 있다.

#### 1.1. Kernel Log

Kernel Log는 의미 그대로 Kernel이 남기는 Log를 의미한다. Ring Buffer는 Kernel Log를 임시로 저장하는 Kernel Memory 공간이다. Memory이기 때문에 재부팅을 하면 이전의 Kernel Log 내용은 사라진다. 또한 Ring Buffer이기 때문에 Kernel Log가 Ring Buffer 용량을 초과하는 경우 오래된 Kernel Log부터 덮어 씌우는 방식이다. Ring Buffer는 Kernel의 do_syslog() 함수를 통해 접근 및 제어를 할 수 있다. Kernel에서 Kernel Log를 남기기 위해서 이용되는 printk() 함수는 실제로 do_syslog() 함수를 통해서 Kernel Log를 Ring Buffer에 Write하는 동작을 수행한다.

User Level에서 Kernel Log를 얻기위해 이용되는 syslog(2) 함수(System Call)나 /proc/kmsg 파일은 do_syslog() 함수를 통해 Ring Buffer에 접근하여 Kernel Log를 얻는다. dmesg는 syslog(2) 함수를 통해 Kernel Log를 User가 볼 수 있도록 한다. 또한 rsyslogd나 systemd-journald는 syslog(2)나 /proc/kmsg를 통해서 Kernel Log를 /var/log 폴더에 파일로 기록하여 보관되도록 한다.

#### 1.2. User Log

User Log는 App이 남기는 Log를 의미한다. App은 syslog(3) 함수를 이용하여 App Log를 남길 수 있다. syslog(3) 함수는 /dev/log Domain Socket을 통해서 App Log를 rsyslogd나 systemd-journald에게 전달한다. rsyslogd나 systemd-journald는 전달받은 App Log를 /var/log 폴더에 파일로 남긴다.

### 2. 참조

* [https://www.ibm.com/developerworks/library/l-kernel-logging-apis/](https://www.ibm.com/developerworks/library/l-kernel-logging-apis/)
* [https://unix.stackexchange.com/questions/205883/understand-logging-in-linux/294206#294206](https://unix.stackexchange.com/questions/205883/understand-logging-in-linux/294206#294206)
* [https://unix.stackexchange.com/questions/35851/whats-the-difference-of-dmesg-output-and-var-log-messages](https://unix.stackexchange.com/questions/35851/whats-the-difference-of-dmesg-output-and-var-log-messages)
