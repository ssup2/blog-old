---
title: Linux Log Command, Tool
category: Command, Tool
date: 2019-09-23T12:00:00Z
lastmod: 2019-09-23T12:00:00Z
comment: true
adsense: true
---

Linux Log 관련 Command, Tool들을 정리한다.

### 1. Linux Log Command, Tool

#### 1.1. dmesg

{% highlight console %}
# dmesg -H
[Sep23 00:14] Linux version 4.15.0-60-generic (buildd@lgw01-amd64-030) (gcc version 7.4.0 (Ubuntu 7.4.0-1ubuntu1~18.04.1)) #67-Ubuntu SMP Thu Aug 22 16:55:30 UTC 2019 (Ubuntu 4.15.0-60.67-generic 4.15.18)
[  +0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.15.0-60-generic root=UUID=c30770af-2d12-43ce-8bf2-1480721d056e ro
[  +0.000000] KERNEL supported cpus:
[  +0.000000]   Intel GenuineIntel
[  +0.000000]   AMD AuthenticAMD
[  +0.000000]   Centaur CentaurHauls
[  +0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
[  +0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
[  +0.000000] x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
[  +0.000000] x86/fpu: Supporting XSAVE feature 0x008: 'MPX bounds registers'
[  +0.000000] x86/fpu: Supporting XSAVE feature 0x010: 'MPX CSR'
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] dmesg</figcaption>
</figure>

dmesg는 Linux Kernel의 Log Ring Buffer에 저장되어 있는 Kernel Log의 내용을 보여주는 Tool이다. [Shell 1]은 dmesg를 이용하여 Kernel Log를 출력하는 Shell의 모습을 나타내고 있다. Linux Kernel에서 printk() 함수로 출력한 내용은 Log Ring Buffer에 저장된다. Log Ring Buffer는 Kernel Memory공간에 위치하고 있기 때문에, 재부팅이 된다면 사라지게 된다. 또한 Log Ring Buffer의 크기보다 많은양의 Log가 저장되면 이전의 Log 내용은 덮어 씌워지면서 사라지게 된다.

#### 1.2. /var/log/kern.log

{% highlight console %}
# cat /var/log/kern.log
Sep 20 14:33:10 vm kernel: [    0.000000] Linux version 4.15.0-60-generic (buildd@lgw01-amd64-030) (gcc version 7.4.0 (Ubuntu 7.4.0-1ubuntu1~18.04.1)) #67-Ubuntu SMP Thu Aug 22 16:55:30 UTC 2019 (Ubuntu 4.15.0-60.67-generic 4.15.18)
Sep 20 14:33:10 vm kernel: [    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.15.0-60-generic root=UUID=c30770af-2d12-43ce-8bf2-1480721d056e ro
Sep 20 14:33:10 vm kernel: [    0.000000] KERNEL supported cpus:
Sep 20 14:33:10 vm kernel: [    0.000000]   Intel GenuineIntel
Sep 20 14:33:10 vm kernel: [    0.000000]   AMD AuthenticAMD
Sep 20 14:33:10 vm kernel: [    0.000000]   Centaur CentaurHauls
Sep 20 14:33:10 vm kernel: [    0.000000] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
Sep 20 14:33:10 vm kernel: [    0.000000] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
Sep 20 14:33:10 vm kernel: [    0.000000] x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
Sep 20 14:33:10 vm kernel: [    0.000000] x86/fpu: Supporting XSAVE feature 0x008: 'MPX bounds registers'
Sep 20 14:33:10 vm kernel: [    0.000000] x86/fpu: Supporting XSAVE feature 0x010: 'MPX CSR' 
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] /var/log/kern.log</figcaption>
</figure>

rsyslogd 또는 systemd-journald는 Linux Kernel의 Log Ring Buffer에 저장되어 있는 Kernel Log를 /var/log/kern.log에 복사하여 저장한다. [Shell 2]는 /var/log/kern.log의 내용을 출력하는 Shell의 모습을 나타내고 있다. /var/log/kern.log은 파일이기 때문에 재부팅 이후에도 /var/log/kern.log에는 Kernel Log 내용이 남게 되고, 이전의 Log 내용은 덮어 씌워지지 않는다.

#### 1.3. /var/log/syslog

{% highlight console %}
# cat /var/log/syslog
Aug  1 06:25:59 node09 dockerd[1772]: time="2019-08-01T06:25:59.815896062Z" level=info msg="shim reaped" id=5c16c868b50c0a938a2ac2ae4c1aeb9924114b8a278d8d30f9527ca36f1d00cb
Aug  1 06:25:59 node09 dockerd[1772]: time="2019-08-01T06:25:59.825852795Z" level=info msg="ignoring event" module=libcontainerd namespace=moby topic=/tasks/delete type="*events.TaskDelete"
Aug  1 06:26:03 node09 dockerd[1772]: time="2019-08-01T06:26:03.088304486Z" level=info msg="shim containerd-shim started" address="/containerd-shim/moby/
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] /var/log/syslog</figcaption>
</figure>

rsyslogd 또는 systemd-journald는 Service (Daemon) Log를 /var/log/syslog에 저장한다. [Shell 3]은 /var/log/syslog에 저장되어 있는 Service Log를 출력하는 Shell의 모습을 나타내고 있다.

#### 1.4. journalctl

{% highlight console %}
# journalctl -xu ssh
-- Logs begin at Sat 2019-07-13 18:32:30 UTC, end at Wed 2019-09-25 14:27:04 UTC. --
Jul 13 19:06:29 node09 systemd[1]: Starting OpenBSD Secure Shell server...
-- Subject: Unit ssh.service has begun start-up
-- Defined-By: systemd
-- Support: http://www.ubuntu.com/support
--
-- Unit ssh.service has begun starting up.
Jul 13 19:06:29 node09 sshd[2675]: Server listening on 0.0.0.0 port 22.
Jul 13 19:06:29 node09 sshd[2675]: Server listening on :: port 22.
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] /var/log/kern.log</figcaption>
</figure>

journalctl은 systemd-journald가 기록한 각종 Log들의 내용을 출력하는 Tool이다. Log는 Kernel Log, Service (Daemon) Log, App Log등이 존재하며, /var/log/journal에 저장된다. [Shell 4]는 journalctl을 이용하여 ssh Service의 Log 내용을 출력하는 Shell의 모습을 나타내고 있다.

### 2. 참조

* [https://github.com/nicolaka/netshoot](https://github.com/nicolaka/netshoot)

