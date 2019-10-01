---
title: lsof
category: Command, Tool
date: 2019-09-14T12:00:00Z
lastmod: 2019-09-14T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

Open File List를 출력하는 lsof의 사용법을 정리한다.

### 1. lsof

#### 1.1. # lsof

{% highlight console %}
# lsof
COMMAND     PID   TID             USER   FD      TYPE             DEVICE SIZE/OFF       NODE NAME
systemd       1                   root  cwd       DIR                8,2     4096          2 /
systemd       1                   root  rtd       DIR                8,2     4096          2 /
systemd       1                   root  txt       REG                8,2  1595792   11535295 /lib/systemd/systemd
sshd       1618                   root    3u     IPv4              23680      0t0        TCP *:ssh (LISTEN) 
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] lsof</figcaption>
</figure>

모든 Open File List를 출력한다. [Shell 1]은 "lsof"를 이용하여 Open되어 있는 모든 File System을 출력하는 Shell의 모습을 나타내고 있다.

#### 1.2. # lsof -u [User]

[User]가 Open하고 있는 File List를 출력한다.

#### 1.3. # lsof +D [Dir]

[Director]의 하위에 있는 Open File List만 출력한다.

#### 1.4. # lsof [File]

[File]을 Open하고 있는 Process의 정보를 출력한다.

#### 1.5. # lsof -c [Binary, Tool]

[Binary, Tool]이 Open하고 있는 File List를 출력한다.

#### 1.6. # lsof -i TCP

TCP를 이용하고 있는 Process의 정보를 출력한다.

#### 1.7. # lsof -i TCP:[Port]

TCP, [Port]를 이용하고 있는 Process의 정보를 출력한다.

#### 1.8. # lsof -i TCP:[Port Start]-[Port End]

TCP, [Port Start] - [Port End] 사이의 Port를 이용하고 있는 Process의 정보를 출력한다.

#### 1.9 # lsof -i UDP

UDP를 이용하고 있는 Process의 정보를 출력한다.
