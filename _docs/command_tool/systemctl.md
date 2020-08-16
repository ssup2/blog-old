---
title: systemctl
category: Command, Tool
date: 2020-08-16T12:00:00Z
lastmod: 2020-08-16T12:00:00Z
comment: true
adsense: true
---

systemd를 제어하는 systemctl의 사용법을 정리한다.

***

* TOC
{:toc}

***

### 1. systemctl

#### 1.1. # systemctl start [Service]

Service를 시작한다. 

#### 1.2. # systemctl stop [Service]

Service를 정지한다.

#### 1.3. # systemctl restart [Service]

Service를 재시작한다.

#### 1.4. # systemctl status [Service]

{% highlight console %}
# systemctl status sshd
● ssh.service - OpenBSD Secure Shell server
   Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2020-08-16 14:21:33 KST; 4min 44s ago
  Process: 23396 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
 Main PID: 23397 (sshd)
    Tasks: 7 (limit: 4915)
   CGroup: /system.slice/ssh.service
           ├─ 3613 tmux
           ├─ 3616 -zsh
           ├─23019 sshd: root@pts/0
           ├─23021 -zsh
           ├─23397 /usr/sbin/sshd -D
           ├─24163 systemctl status sshd
           └─24164 less

Aug 16 14:21:33 node09 systemd[1]: This usually indicates unclean termination of a previous run, or service implementation deficiencies.
Aug 16 14:21:33 node09 systemd[1]: ssh.service: Found left-over process 23021 (zsh) in control group while starting unit. Ignoring.
Aug 16 14:21:33 node09 systemd[1]: This usually indicates unclean termination of a previous run, or service implementation deficiencies.
Aug 16 14:21:33 node09 systemd[1]: ssh.service: Found left-over process 23394 (systemctl) in control group while starting unit. Ignoring.
Aug 16 14:21:33 node09 systemd[1]: This usually indicates unclean termination of a previous run, or service implementation deficiencies.
Aug 16 14:21:33 node09 systemd[1]: ssh.service: Found left-over process 23395 (systemd-tty-ask) in control group while starting unit. Ignorin
Aug 16 14:21:33 node09 systemd[1]: This usually indicates unclean termination of a previous run, or service implementation deficiencies.
Aug 16 14:21:33 node09 sshd[23397]: Server listening on 0.0.0.0 port 22.
Aug 16 14:21:33 node09 sshd[23397]: Server listening on :: port 22.
Aug 16 14:21:33 node09 systemd[1]: Started OpenBSD Secure Shell server.
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] systemctl status</figcaption>
</figure>

Service의 상태를 출력한다. [Shell 1]은 sshd Service의 상태를 출력하는 모습을 나타내고 있다.
