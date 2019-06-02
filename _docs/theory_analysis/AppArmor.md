---
title: AppArmor
category: Theory, Analysis
date: 2017-07-14T12:00:00Z
lastmod: 2017-07-14T12:00:00Z
comment: true
adsense: true
---

Linux LSM (Linux Security Module) Framework의 Security Module 중 하나인 AppArmor에 대해서 분석한다.

### 1. AppArmor

AppArmor는 Linux LSM Framework위에서 동작하는 MAC(Mandatory Access Control) 기반 Security Module이다. AppArmor는 **System Call** 제한을 통해 Program(Binary)의 동작을 제한한다. 각 프로그램의 동작 제한 사항은 **AppArmor Profile** 파일을 통해서 AppArmor에게 전달한다.

AppArmor는 Enforcement, Complain 2개의 Mode로 동작한다.
* Enforcement : Program의 허용되지 않은 동작을 제한하고 Log에 남긴다. 실제 Program을 운영하면서 동작을 제한 할 때 이용하는 Mode이다.
* Complain : Program의 허용되지 않은 동작을 제한하지는 않고 Log만 남긴다. 특정 Program의 AppArmor Profile을 작성할때 이용하는 Mode이다. Log를 통해서 AppArmor Profile 작성을 도움 받을 수 있다.

{% highlight text %}
# aa-status
apparmor module is loaded.
29 profiles are loaded.
29 profiles are in enforce mode.
   /sbin/dhclient
   /usr/bin/evince
   /usr/bin/evince-previewer
   /usr/bin/evince-previewer//sanitized_helper
   /usr/bin/evince-thumbnailer
   /usr/bin/evince-thumbnailer//sanitized_helper
   /usr/bin/evince//sanitized_helper
   /usr/bin/lxc-start
   /usr/bin/ubuntu-core-launcher
   /usr/lib/NetworkManager/nm-dhcp-client.action
   /usr/lib/NetworkManager/nm-dhcp-helper
   /usr/lib/connman/scripts/dhclient-script
   /usr/lib/cups/backend/cups-pdf
   /usr/lib/lightdm/lightdm-guest-session
   /usr/lib/lightdm/lightdm-guest-session//chromium
   /usr/lib/lxd/lxd-bridge-proxy
   /usr/sbin/cups-browsed
   /usr/sbin/cupsd
   /usr/sbin/cupsd//third_party
   /usr/sbin/ippusbxd
   /usr/sbin/mysqld
   /usr/sbin/tcpdump
   docker-default
   lxc-container-default
   lxc-container-default-cgns
   lxc-container-default-with-mounting
   lxc-container-default-with-nesting
   webbrowser-app
   webbrowser-app//oxide_helper
0 profiles are in complain mode.
14 processes have profiles defined.
14 processes are in enforce mode.
   /usr/bin/lxc-start (12311)
   /usr/sbin/cups-browsed (1944)
   docker-default (17235)
   docker-default (17259)
   docker-default (17270)
   docker-default (17350)
   docker-default (17351)
   lxc-container-default-cgns (12320)
   lxc-container-default-cgns (12462)
   lxc-container-default-cgns (12501)
   lxc-container-default-cgns (12502)
   lxc-container-default-cgns (12503)
   lxc-container-default-cgns (12504)
   lxc-container-default-cgns (12505)
0 processes are in complain mode.
0 processes are unconfined but have a profile defined.
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Apparmor 상태 확인</figcaption>
</figure>

[Shell 1]은 aa-status 명령어을 이용하여 AppArmor의 상태를 조회한 내용이다. AppArmor가 이용할 수 있는 Profile과 Profile이 적용된 Process를 확인 할 수 있다. AppArmor의 정보는 /sys/kernel/security/apparmor 폴더안에 위치하고 있는데, aa-status 명령어는 /sys/kernel/security/apparmor 폴더안의 내용을 정리해서 보여주는 역활을 수행한다.

#### 1.1. AppArmor Profile

AppArmor Profile의 이름은 /로 시작하는 이름과 /로 시작하지 않는 이름으로 구분할 수 있다. /으로 시작하는 Profile인 경우 Profile이 이름이 해당 Profile이 적용될 프로그램을 나타내고 있다. [Shell 1]에서 조회된 Profile 목록 중에서 /usr/sbin/tcpdump Profile을 확인할 수 있는데, /usr/sbin/tcpdump 프로그램이 실행되면 /usr/sbin/tcpdump Profile이 자동으로 적용되어 동작하게 된다. /으로 시작하지 않는 Profile은 특정 Program을 동작시킬때 aa-exec 명령을 통해 수동으로 Profile을 적용시켜야 한다. 물론 /으로 시작하는 Profile도 aa-exec 명령을 통해 특정 Program에 Profile을 적용시킬 수 있다. Profile들은 **/etc/AppArmor.d**에 위치하고 있다.

{% highlight text %}
#include <tunables/global>

profile apparmor-example {
  #include <abstractions/base>

  capability net_admin,
  capability setuid,
  capability setgid,

  mount fstype=proc -> /mnt/proc/**,

  /etc/hosts.allow rw,
  /root/test.sh rwix,

  network tcp,
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] apparmor-example Apparmor Profile</figcaption>
</figure>

[파일 1]은 apparmor-example이란 예제 AppArmor Profile을 나타내고 있다. 다음과 같은 의미를 나타내고 있다.

* net_admin, setuid, setgid Capability를 이용할 수 있다.
* proc File System을 /mnt/proc 아래의 경로에만 Mount 할 수 있다.
* /etc/hots.allow 파일을 읽고, 쓸 수 있다.
* /root/test.sh 파일을 읽고, 쓰고, 실행 할 수 있다.
* tcp Protocol만을 이용 할 수 있다.

{% highlight text %}
# apparmor_parser /etc/apparmor.d/test/apparmor-example
# aa-status
apparmor module is loaded.
30 profiles are loaded.
30 profiles are in enforce mode.
...
   /usr/sbin/tcpdump
   apparmor-example
   docker-default
   lxc-container-default
   lxc-container-default-cgns
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Apparmor Profile 등록 및 확인</figcaption>
</figure>

[Shell 2]는 작성한 Profile을 apparmor_parser 명령어를 이용하여 AppArmor에 등록하고, aa-status 명령어를 이용하여 Profile 등록을 확인하는 과정을 나타내고 있다. 등록이 완료되면 aa-status 명령어를 통해 apparmor_parser Profile을 확인 할 수 있다.

{% highlight shell %}
#!/bin/bash

sleep 10000 &
sleep 10000 &
ping 127.0.0.1 -c 10

while true; do sleep 1; done
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Apparmor Test Script</figcaption>
</figure>

[Code 1]은 AppArmor Test를 위한 간단한 Script를 나타내고 있다. sleep 명령어는 backgroud로 수행하고, ping 명령어도 수행한다. 그 후 test.sh가 종료되지 않도록 while문을 수행한다.

{% highlight text %}
# aa-exec -p apparmor-example ./test.sh
socket: Permission denied

# ps -efZ
apparmor-example (enforce)      root     20635 30300  0 13:38 pts/26   00:00:00 /bin/bash ./t
apparmor-example (enforce)      root     20636 20635  0 13:38 pts/26   00:00:00 sleep 10000
apparmor-example (enforce)      root     20637 20635  0 13:38 pts/26   00:00:00 sleep 10000
apparmor-example (enforce)      root     20640 20635  0 13:38 pts/26   00:00:00 sleep 1
unconfined                      root     20641 20611  0 13:38 pts/29   00:00:00 ps -efZ
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] Apparmor 적용</figcaption>
</figure>

[Shell 3]는 aa-exec 명령어로 apparmor_example Profile 적용시켜 test.sh를 실행한 결과를 나타내고 있다.  socket: Permission denied Message를 확인 할 수 있다. apparmor_exmaple Profile은 tcp만 이용할 수 있도록 설정되어 있기 때문에 icmp를 이용하는 ping을 이용 할 수 없기 때문이다. ps -efZ 명령을 통해 test.sh관련 Process들에 appArmor-example Profile이 적용된 것을 확인 할 수 있다.

### 2. 참조

* [http://wiki.apparmor.net](http://wiki.apparmor.net)
* [https://wiki.ubuntu.com/AppArmor](https://wiki.ubuntu.com/AppArmor)
