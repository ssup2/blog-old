---
title: Ubuntu Auto root Login
category: Record
date: 2017-01-20T16:10:00Z
lastmod: 2017-01-22T16:10:00Z
comment: true
adsense: true
---

### 1. Ubuntu 12.04 / Ubuntu 14.04 / Ubuntu 16.04

#### 1.1. root 계정의 Password 설정

* passwd tool을 이용한다.

~~~
# sudo passwd root
Enter new UNIX password:
Retype new UNIX password:
~~~

#### 1.2. Auto Login 설정

##### 1.2.1. Ubuntu 12.04 / Ubuntu 14.04

* /etc/lightdm/lightdm.conf 파일을 만들고 아래 내용을 작성한다. (이미 파일이 있으면 수정한다.)
~~~
[SeatDefaults]
autologin-user=root
autologin-user-timeout=0
user-session=ubuntu
greeter-session=unity-greeter
~~~

##### 1.2.2. Ubuntu 16.04

* /etc/lightdm/lightdm.conf 파일을 만들고 아래 내용을 작성한다. (이미 파일이 있으면 수정한다.)
~~~
[Seat:*]
autologin-guest=false
autologin-user=root
autologin-user-timeout=0
~~~

#### 1.3 Error 제거

##### 1.3.1 Ubuntu 14.04 / ubuntu 16.04

* /root/.profile 파일에 내용을 아래처럼 변경 한다.
~~~
mesg n
->
tty -s && mesg n
~~~
