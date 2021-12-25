---
title: WSL2 Samba 설치, 설정 / Windows 10 환경
category: Record
date: 2021-09-10T12:00:00Z
lastmod: 2021-09-10T12:00:00Z
comment: true
adsense: true
---

### 1. 설치, 설정 배경

WSL2 VM의 경우에는 Windows OS와 공유하는 /mnt 하위의 Directory의 I/O 성능이 나오지 않는 문제가 존재한다. 해당 문제를 우회하기 위해서 WSL2 VM 내부에 Samba Server를 설치하고 이용하는 방법을 정리한다.

### 2. 설치, 설정 환경

설치, 설정 환경은 다음과 같다.
* Windows 10 Pro 64bit
* WSL2 Ubuntu 20.04, root User

### 3. Ubuntu에 Samba Server 설치

~~~console
(WSL2 Ubuntu)# apt update
(WSL2 Ubuntu)# apt install samba
(WSL2 Ubuntu)# smbpasswd -a root
New SMB password:
Retype new SMB password:
Added user root.
~~~

WSL2 VM 내부에서 Samba Server를 설치하고, Samba Server를 위한 root User를 추가한다.

{% highlight text %}
[homes]
  comment = home directories
  valid users = %S
  browseable = no
  read only = no
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] /etc/samba/smb.conf</figcaption>
</figure>

/etc/samba/smb.conf 파일에 [파일 1]의 내용을 추가한다.

~~~console
(WSL2 Ubuntu)# service smbd restart
~~~

Samba Server를 재시작합니다.

### 4. WSL2 VM으로 Port Forwarding Rule 추가

WSL2 VM은 재부팅을 수행할때마다 IP가 변경된다. 따라서 Windows OS에 Port Forwarding Rule을 설정하여 Local Host로 Samba Connection 발생시 WSL2 VM으로 Connection이 전달되도록 설정한다.

{% highlight text %}
wsl -d ubuntu -u root service smbd restart
wsl -d ubuntu -u root ip addr add 192.168.10.100/24 broadcast 192.168.10.255 dev eth0 label eth0:1
netsh interface ip add address "vEthernet (WSL)" 192.168.10.50 255.255.255.0
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] C:\route_ssh_to_wsl.ps1</figcaption>
</figure>

[파일 1]의 Script를 작성한다. Script는 192.168.10.100으로 접속시 Samba Server로 접속하게 만든다.

### 5. Script를 시작 Script로 등록

{% highlight text %}
(Windows)# $trigger= New-JobTrigger -AtStartup -RandomDelay 00:00:15
(Windows)# Register-ScheduledJob -Trigger $trigger -FilePath C:\route_ssh_to_wsl.ps1 -Name RouteSSHtoWSL
{% endhighlight %}

### 6. Samba Server 접속

Windows OS를 재부팅한 다음에 File Browser에서 다음의 주소로 접속한다.
* \\\\192.168.10.100\root

### 7. 참고

* [https://embeddedaroma.tistory.com/64](https://embeddedaroma.tistory.com/64)
* [https://www.python2.net/questions-1217707.htm](https://www.python2.net/questions-1217707.htm)
