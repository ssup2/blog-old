---
title: sysdig
category: Command, Tool
date: 2019-10-19T12:00:00Z
lastmod: 2019-10-19T12:00:00Z
comment: true
adsense: true
---

Linux Kernel의 다양한 동작들을 출력하고, 성능 측정도 할 수 있는 sysdig의 사용법을 정리한다.

***

* TOC
{:toc}

***

### 1. lsof

#### 1.1. # sysdig

{% highlight console %}
8464 01:23:53.859656137 1 sshd (30637) < read res=2 data=..
8465 01:23:53.859656937 1 sshd (30637) > getpid
8466 01:23:53.859657037 1 sshd (30637) < getpid
8467 01:23:53.859658137 1 sshd (30637) > clock_gettime
8468 01:23:53.859658337 1 sshd (30637) < clock_gettime
8469 01:23:53.859658837 1 sshd (30637) > select
8470 01:23:53.859659637 1 sshd (30637) < select res=1
8471 01:23:53.859660037 1 sshd (30637) > clock_gettime
8472 01:23:53.859660237 1 sshd (30637) < clock_gettime
8473 01:23:53.859660737 1 sshd (30637) > rt_sigprocmask
8474 01:23:53.859660937 1 sshd (30637) < rt_sigprocmask
8475 01:23:53.859661337 1 sshd (30637) > rt_sigprocmask
8476 01:23:53.859661537 1 sshd (30637) < rt_sigprocmask
8477 01:23:53.859662037 1 sshd (30637) > clock_gettime
8478 01:23:53.859662237 1 sshd (30637) < clock_gettime
8479 01:23:53.859662737 1 sshd (30637) > write fd=3(<4t>10.0.0.10:12403->10.0.0.19:22) size=36
8480 01:23:53.859663337 1 sshd (30637) < write res=36 data=.)r...GId....mG.e..._.~..h}....K.{..
8481 01:23:53.859663937 1 sshd (30637) > clock_gettime
8482 01:23:53.859664137 1 sshd (30637) < clock_gettime
8483 01:23:53.859664737 1 sshd (30637) > select
8484 01:23:53.859665937 1 sshd (30637) > switch next=3591(sysdig) pgft_maj=3 pgft_min=452 vm_size=72356 vm_rss=6396 vm_swap=0
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] sysdig</figcaption>
</figure>

sysdig가 감지할 수 있는 Kernel의 모든 동작을 출력한다. [Shell 1]은 "sysdig"를 이용하여 Kernel의 동작을 출력하는 Shell의 모습을 나타내고 있다.

#### 1.2. # sysdig -c topprocs_cpu

{% highlight console %}
CPU%                Process             PID
--------------------------------------------------------------------------------
5.03%               cadvisor            2521
2.01%               prometheus          2397
1.01%               sysdig              4327
0.00%               dbus-daemon         920
0.00%               grafana-server      2398
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] sysdig -c topprocs_cpu</figcaption>
</figure>

CPU 사용률 높은 Process들을 순서대로 출력한다. [Shell 2]는 "sysdig -c topprocs_cpu"를 이용하여 CPU 사용률이 높은 Process들을 출력하는 Shell의 모습을 나타내고 있다.

#### 1.3. # sysdig -c topprocs_net

{% highlight console %}
Bytes               Process             PID
--------------------------------------------------------------------------------
1.70KB              openstack-expor     3228
314B                prometheus          2258
236B                sshd                3026      
212B                dbus-daemon         920
124%                grafana-server      2398                       
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] sysdig -c topprocs_net</figcaption>
</figure>

Network Bandwidth 사용률 높은 Process들을 순서대로 출력한다. [Shell 3]는 "sysdig -c topprocs_net"를 이용하여 Network Bandwidth 사용률이 높은 Process들을 출력하는 Shell의 모습을 나타내고 있다.

#### 1.4. # sysdig -c topprocs_file

{% highlight console %}
Bytes               Process             PID
--------------------------------------------------------------------------------
38.40M              prometheus          2574
32.55KB             cadvisor            2643
292B                sshd                2135
254B                chronyd             2540
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] sysdig -c topprocs_file</figcaption>
</figure>

Disk Bandwidth 사용률 높은 Process들을 순서대로 출력한다. [Shell 4]는 "sysdig -c topprocs_net"를 이용하여 Disk Bandwidth 사용률이 높은 Process들을 출력하는 Shell의 모습을 나타내고 있다.

#### 1.5. # sysdig -c topfiles_bytes

{% highlight console %}
Bytes               Filename
--------------------------------------------------------------------------------
1.12KB              /proc/stat
1.05KB              /dev/ptmx
832B                /lib/x86_64-linux-gnu/libnsl.so.1
832B                /lib/x86_64-linux-gnu/libnss_compat.so.2
832B                /lib/x86_64-linux-gnu/libnss_nis.so.2
832B                /lib/x86_64-linux-gnu/libnss_files.so.2
832B                /lib/x86_64-linux-gnu/libm.so.6
832B                /lib/x86_64-linux-gnu/libc.so.6
497B                /etc/nsswitch.conf
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 5] sysdig -c topfiles_bytes</figcaption>
</figure>

Disk Bandwidth 사용률 높은 File들을 순서대로 출력한다. [Shell 4]는 "sysdig -c topfiles_bytes"를 이용하여 Disk Bandwidth 사용률이 높은 File들을 출력하는 Shell의 모습을 나타내고 있다.

### 2. 참조

* [https://github.com/draios/sysdig/wiki/Sysdig-Examples#containers](https://github.com/draios/sysdig/wiki/Sysdig-Examples#containers)
