---
title: journalctl
category: Command, Tool
date: 2019-07-22T12:00:00Z
lastmod: 2019-07-22T12:00:00Z
comment: true
adsense: true
---

systemd-journald를 제어하는 journalctl의 사용법을 정리한다.

***

* TOC
{:toc}

***

### 1. journalctl

#### 1.1. # journalctl -xu [Service]

{% highlight console %}
journalctl -xu ssh

-- Logs begin at Sat 2019-07-13 18:32:30 UTC, end at Mon 2019-09-30 08:16:09 UTC. --
Jul 13 19:06:29 node09 systemd[1]: Starting OpenBSD Secure Shell server...
-- Subject: Unit ssh.service has begun start-up
-- Defined-By: systemd
-- Support: http://www.ubuntu.com/support
--
-- Unit ssh.service has begun starting up.
Jul 13 19:06:29 node09 sshd[2675]: Server listening on 0.0.0.0 port 22.
Jul 13 19:06:29 node09 sshd[2675]: Server listening on :: port 22.
Jul 13 19:06:29 node09 systemd[1]: Started OpenBSD Secure Shell server.
-- Subject: Unit ssh.service has finished start-up
-- Defined-By: systemd
-- Support: http://www.ubuntu.com/support
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] journalctl -xu</figcaption>
</figure>

[Service] Log의 첫번째 부분을 출력한다. 진입이후 vim 명령어로 Log를 이동한다. [Shell 1]은 "journalctl -xu"를 이용하여 ssh Service Log의 앞부분을 출력하는 Shell의 모습을 나타내고 있다.

#### 1.2. # journalctl -xeu [Service]

[Service] Log의 마지막 부분을 출력한다. 진입이후 vim 명령어로 Log를 이동한다.

#### 1.3. # journalctl -fu [Service]

{% highlight console %}
# journalctl -fu ssh
-- Logs begin at Sat 2019-07-13 18:32:30 UTC. --
Sep 23 15:27:55 node09 sshd[14092]: Accepted password for root from 10.0.0.10 port 9334 ssh2
Sep 25 15:08:49 node09 sshd[1440]: Accepted password for root from 10.0.0.10 port 11432 ssh2
Sep 26 18:17:40 node09 sshd[1440]: Received disconnect from 10.0.0.10 port 11432:11: disconnected by user
Sep 26 18:17:40 node09 sshd[1440]: Disconnected from user root 10.0.0.10 port 11432
Sep 28 13:51:49 node09 sshd[26037]: Accepted password for root from 10.0.0.10 port 3217 ssh2
Sep 29 00:54:14 node09 sshd[19102]: Accepted password for root from 10.0.0.10 port 1382 ssh2
Sep 29 05:41:25 node09 sshd[19102]: Received disconnect from 10.0.0.10 port 1382:11: disconnected by user
Sep 29 05:41:25 node09 sshd[19102]: Disconnected from user root 10.0.0.10 port 1382
Sep 29 05:46:37 node09 sshd[28810]: Accepted password for root from 10.0.0.10 port 8328 ssh2
Sep 30 05:48:50 node09 sshd[17667]: Accepted password for root from 10.0.0.10 port 2359 ssh2
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] journalctl -fu</figcaption>
</figure>

[Service] Log의 마지막 부분을 출력하고 추가되는 Log를 계속 출력한다. [Shell 2]는 "journalctl -fu"를 이용하여 ssh Service Log를 추적하는 모습을 나타내고 있다.

#### 1.4. # journalctl -t kernel

{% highlight console %}
 # journalctl -t kernel
-- Logs begin at Sat 2019-07-13 18:32:30 UTC, end at Mon 2019-09-30 08:24:09 UTC. --
Jul 13 18:32:30 localhost.localdomain kernel: Linux version 4.15.0-54-generic (buildd@lgw01-amd64-014) (gcc version 7.4.0 (Ubuntu 7.4.0-1ubuntu1~18.04.1)) #58-Ubuntu SMP Mon Jun
Jul 13 18:32:30 localhost.localdomain kernel: Command line: BOOT_IMAGE=/boot/vmlinuz-4.15.0-54-generic root=UUID=c30770af-2d12-43ce-8bf2-1480721d056e ro
Jul 13 18:32:30 localhost.localdomain kernel: KERNEL supported cpus:
Jul 13 18:32:30 localhost.localdomain kernel:   Intel GenuineIntel
Jul 13 18:32:30 localhost.localdomain kernel:   AMD AuthenticAMD
Jul 13 18:32:30 localhost.localdomain kernel:   Centaur CentaurHauls
Jul 13 18:32:30 localhost.localdomain kernel: x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
<figure>
<figcaption class="caption">[Shell 3] journalctl -t kernel </figcaption>
</figure>

Kernel Log를 출력한다. 진입이후 vim 명령어로 Log를 이동한다. [Shell 3]은 "journalctl -t kernel"를 이용하여 Kernel Log를 출력하는 Shell의 모습을 나타내고 있다.
