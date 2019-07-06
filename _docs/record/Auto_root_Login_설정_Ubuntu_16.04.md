---
title: Auto root Login 설정 / Ubuntu 16.04 환경
category: Record
date: 2017-01-20T16:10:00Z
lastmod: 2017-01-22T16:10:00Z
comment: true
adsense: true
---

### 1. 설정 환경

설정 환경은 다음과 같다.
* Ubuntu 16.04 LTS 64bit, root user

### 2. root Password 설정

~~~
# sudo passwd root
Enter new UNIX password:
Retype new UNIX password:
~~~

passwd tool을 이용하여 root의 Password를 설정한다.

### 3. Auto Login 설정

{% highlight text %}
[Seat:*]
autologin-guest=false
autologin-user=root
autologin-user-timeout=0
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] /etc/lightdm/lightdm.conf</figcaption>
</figure>

/etc/lightdm/lightdm.conf 파일을 [파일 1]의 내용으로 생성한다. (이미 파일이 있으면 변경한다.)

### 4. /root/.profile Error 제거

{% highlight text %}
...

tty -s && mesg n
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] /root/.profile</figcaption>
</figure>

재부팅 후 /root/.profile 파일의 내용을 [파일 2]의 내용으로 변경한다.
