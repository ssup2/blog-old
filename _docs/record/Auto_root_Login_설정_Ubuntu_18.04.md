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

<figure>
{% highlight text %}
#%PAM-1.0
auth    requisite       pam_nologin.so
#auth   required        pam_succeed_if.so user != root quiet_success
...
<figcaption class="caption">[파일 1] /etc/pam.d/gdm-password</figcaption>
</figure>

* /etc/pam.d/gdm-autologin 파일을 아래와 같이 변경한다.

<figure>
{% highlight text %}
#%PAM-1.0
auth    requisite       pam_nologin.so
#auth   required        pam_succeed_if.so user != root quiet_success
...
{% endhighlight %}
<figcaption class="caption">[파일 2] /etc/pam.d/gdm-autologin</figcaption>
</figure>

* /etc/gdm3/custom.conf 파일을 아래와 같이 변경한다.

<figure>
{% highlight text %}
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=root
...
[security]
AllowRoot=true
{% endhighlight %}
<figcaption class="caption">[파일 3] /etc/gdm3/custom.conf</figcaption>
</figure>

### 4. /root/.profile Error 제거

<figure>
{% highlight text %}
...

tty -s && mesg n
{% endhighlight %}
<figcaption class="caption">[파일 4] /root/.profile</figcaption>
</figure>
