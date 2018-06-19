---
title: mutt Gmail 설치, 사용 - Ubuntu
category: Record
date: 2018-05-28T00:00:00Z
lastmod: 2018-05-28T00:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

* Ubuntu 18.04 LTS 64bit, root user

### 2. mutt 설치

~~~
# sudo apt-get install mutt
~~~

### 3. Gmail Access 권한 설정

* Guide - [https://support.google.com/accounts/answer/6010255?hl=en](https://support.google.com/accounts/answer/6010255?hl=en)
* Secure Apps - [https://myaccount.google.com/lesssecureapps](https://myaccount.google.com/lesssecureapps)

### 4. mutt 설정

* mutt 관련 폴더, 파일 생성

~~~
# mkdir -p ~/Mail
# touch /var/mail/root
# chmod 660 /var/mail/root
# chown root:mail /var/mail/root
~~~

* ~/.muttrc 파일 설정

~~~
set realname = "<first and last name>"
set from = "<gmail username>@gmail.com"
set use_from = yes
set envelope_from = yes

set smtp_url = "smtps://<gmail username>@gmail.com@smtp.gmail.com:465/"
set smtp_pass = "<gmail password>"
set imap_user = "<gmail username>@gmail.com"
set imap_pass = "<gmail password>"
set folder = "imaps://imap.gmail.com:993"
set spoolfile = "+INBOX"
set ssl_force_tls = yes

# G to get mail
bind index G imap-fetch-mail
set editor = "vim"
set charset = "utf-8"
set record = ''
~~~

### 5. 사용법

* mutt 실행

~~~
# mutt
~~~

* 단축키
  * m - Compose a new mail message.
  * G - Fetch new messages.

### 6. 참조
* [http://nickdesaulniers.github.io/blog/2016/06/18/mutt-gmail-ubuntu/](http://nickdesaulniers.github.io/blog/2016/06/18/mutt-gmail-ubuntu/)
