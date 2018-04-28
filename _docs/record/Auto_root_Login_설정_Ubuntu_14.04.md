---
title: Auto root Login 설정 - Ubuntu 14.04
category: Record
date: 2017-01-20T16:10:00Z
lastmod: 2017-01-22T16:10:00Z
comment: true
adsense: true
---

### 1. 설정 환경

* Ubuntu 14.04 LTS 64bit, root user

### 2. root Password 설정

* passwd tool을 이용한다.

~~~
# sudo passwd root
Enter new UNIX password:
Retype new UNIX password:
~~~

### 3. Auto Login 설정

* /etc/lightdm/lightdm.conf 파일을 만들고 아래 내용을 작성한다. (이미 파일이 있으면 수정한다.)

~~~
[SeatDefaults]
autologin-user=root
autologin-user-timeout=0
user-session=ubuntu
greeter-session=unity-greeter
~~~

### 4. /root/.profile Error 제거

* 재부팅 후 /root/.profile 파일의 내용을 아래처럼 변경 한다.

~~~
mesg n
->
tty -s && mesg n
~~~
