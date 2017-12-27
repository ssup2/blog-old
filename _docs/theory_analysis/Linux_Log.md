---
title: Linux Log
category: Theory, Analysis
date: 2017-01-14T12:00:00Z
lastmod: 2017-01-15T12:00:00Z
comment: true
adsense: true
---

Linux Log 관련 구성 요소와 역활을 분석한다.

### 1. Linux Log

![]({{site.baseurl}}/images/theory_analysis/Linux_Log/Linux_Log_Component.PNG){: width="600px"}

위의 그림은 Linux Log 관련 구성요소를 나타내고 있다. Log의 내용을 Kernel Log와 User Log로 분류 할 수 있다.

### 2. Kernel Log

Linux Kernel이 남기는 Log를 의미한다. Kernel Log 관련 구성요소는 Kernel Level과 User Level로 분류 할 수 있다.

#### 2.1. Kernel Level

Kernel에는 Kernel Log를 저장하는 Log Ring Buffer가 있다. Log Ring Buffer를 접근하는 함수는 do_syslog()와 printk() 함수가 있다. do_syslog() 함수는 요청에 따라 Log Ring Buffer를 읽거나 Clear하는 동작을 수행한다. do_syslog() 함수는 User Level에서 syslog(2) System Call이나 /proc/kmsg를 통해 호출 된다. printk()는 Kernel Level에서 Log 기록을 위한 Kernel Level 전용 함수이다. User Level에서는 이용하지 못한다.

#### 2.2. User Level

glibc는 App 개발자가 Kernel Log를 쉽게 이용 할수 있도록 syslog(2) System Call을 Wrapping한 syslog(3) 함수를 제공한다. Application은 syslog(3) 함수나 /proc/kmsg를 통해 Kernel의 Log Ring Buffer에 접근 할 수 있다. dmesg는 glibc의 syslog(3)를 이용하여 Log Ring Buffer를 읽거나 제어하는 App이다. rsyslog는 Daemon으로 dmesg와 유사하게 syslog(3)를 이용하여 Kernel Log를 읽어와 /var/log 폴더 아래 저장한다.

시간이 지나 Kernel의 Log Ring Buffer에 없는 내용은 rsyslog가 저장한 /var/log 폴더 아래의 Log 파일에서 확인 가능하다. rsyslog가 동작하기 이전의 Kernel Booting Log는 dmesg를 통해 볼 수 있다.

### 3. User Log

Application이 남기는 Log를 의미한다. rsyslog는 Kernel Log 뿐만 아니라 Application의 Log도 기록한다. User Log도 Kernel Log와 동일하게 /var/log 폴더 아래 저장된다.

### 4. 참조

* [https://www.ibm.com/developerworks/library/l-kernel-logging-apis/](https://www.ibm.com/developerworks/library/l-kernel-logging-apis/)
* [https://unix.stackexchange.com/questions/35851/whats-the-difference-of-dmesg-output-and-var-log-messages](https://unix.stackexchange.com/questions/35851/whats-the-difference-of-dmesg-output-and-var-log-messages)
