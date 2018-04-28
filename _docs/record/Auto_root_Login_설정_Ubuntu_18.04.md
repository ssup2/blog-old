---
title: Auto root Login 설정 - Ubuntu 18.04
category: Record
date: 2018-04-28T16:10:00Z
lastmod: 2018-04-28T16:10:00Z
comment: true
adsense: true
---

### 1. 설정 환경

* Ubuntu 18.04 LTS 64bit, root user

### 2. root Password 설정

* passwd tool을 이용한다.

~~~
# sudo passwd root
Enter new UNIX password:
Retype new UNIX password:
~~~

### 3. Auto Login 설정

* /etc/pam.d/gdm-password 파일을 아래와 같이 변경한다.

~~~
#%PAM-1.0
auth    requisite       pam_nologin.so
#auth   required        pam_succeed_if.so user != root quiet_success
...
~~~

* /etc/pam.d/gdm-autologin 파일을 아래와 같이 변경한다.

~~~
#%PAM-1.0
auth    requisite       pam_nologin.so
#auth   required        pam_succeed_if.so user != root quiet_success
...
~~~

* /etc/gdm3/custom.conf 파일을 아래와 같이 변경한다.

~~~
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=root
...
[security]
AllowRoot=true
~~~

### 4. /root/.profile Error 제거

* 재부팅 후 /root/.profile 파일의 내용을 아래처럼 변경 한다.

~~~
mesg n || true
->
tty -s && mesg n || true
~~~
