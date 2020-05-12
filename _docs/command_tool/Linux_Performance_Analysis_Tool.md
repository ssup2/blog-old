---
title: Linux Performance Analysis Tool
category: Command, Tool
date: 2019-09-22T12:00:00Z
lastmod: 2019-09-22T12:00:00Z
comment: true
adsense: true
---

Linux에서 성능 측정시 이용되는 Tool들을 정리한다.

### 1. Linux Performance Analysis Tool

#### 1.1. uptime

{% highlight console %}
# uptime
10:00:00 up  8:04,  1 user,  load average: 3.37, 3.37, 3.45
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] uptime</figcaption>
</figure>

uptime은 Linux의 구동 시간 및 평균 CPU 부하를 보여주는 Tool이다. [Shell 1]은 uptime Tool을 통해서 확인할 수 있는 Shell의 모습을 나타내고 있다. 현재 시각 / Linux 구동 시간 / 현재 Login 상태의 User 수 / 1분, 5분, 15분 동안의 평균 Load를 나타낸다. Load는 대기 상태로 존재하는 Process의 개수를 의미한다.

#### 1.2. free

{% highlight console %}
# free -m
              total        used        free      shared  buff/cache   available
Mem:           7977        1185        2710           1        4081        6490
Swap:          4095           0        4095
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] free</figcaption>
</figure>

free는 Memory 및 Swap 사용량을 출력하는 Tool이다. [Shell 2]는 Memory 사용량 및 Swap 사용량을 MB 단위로 출력하는 Shell의 모습을 나타내고 있다.

#### 1.3. vmstat

{% highlight console %}
# vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 2  1      0 2659952 815660 3469920    0    0    40  5839  197  477 17  3 32 48  0
 0  1      0 2675016 815676 3454768    0    0    20  4180  390 2881  7  3 55 36  0
 2  0      0 2684728 815716 3445176    0    0    32 12040  367 3019 21  2 33 44  0
 0  1      0 2675900 815740 3455176    0    0    28 10324  521 2906 13  3 66 19  0
 2  3      0 2661392 815768 3469476    0    0    28 13628  347 3175 14  2 44 40  0
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] vmstat</figcaption>
</figure>

vmstat은 CPU, Memory, Disk등 System의 전반적인 사용량을 출력하는 Tool이다. [Shell 3]은 vmstat을 이용하여 1초 간격으로 System의 전반적인 사용량를 출력하는 Shell의 모습을 나타내고 있다.

#### 1.4. pidstat

{% highlight console %}
# pidstat 1
Linux 4.15.0-60-generic (node09)        09/22/19        _x86_64_        (2 CPU)

Average:      UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
Average:    42472      2912   23.76    0.99    0.00    0.00   24.75     -  prometheus
Average:        0      3335    0.99    0.99    0.00    0.00    1.98     -  cadvisor
Average:    42472      3361    0.00    0.99    0.00    0.00    0.99     -  alertmanager
Average:        0      3968    0.00    0.99    0.00    0.00    0.99     -  kworker/1:2
Average:        0      7361    0.00    0.99    0.00    0.00    0.99     -  pidstat
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] pidstat</figcaption>
</figure>

pidstat은 process별 Resource 사용량을 출력하는 Tool이다. [Shell 4]는 pidstat을 이용하여 1초 간격으로 각 Process의 CPU 사용량을 출력하는 Shell의 모습을 나타내고 있다. pidstat은 CPU 사용량뿐만 아니라 Memory, Stack, Block I/O, Kernel 사용량 정보도 출력할 수 있다.

#### 1.5. mpstat

{% highlight console %}
# mpstat -P ALL 1
Linux 4.15.0-60-generic (node09)        09/22/19        _x86_64_        (2 CPU)

11:25:06     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
11:25:07     all    5.05    0.00    2.53   39.39    0.00    0.00    0.00    0.00    0.00   53.03
11:25:07       0    7.00    0.00    3.00   29.00    0.00    0.00    0.00    0.00    0.00   61.00
11:25:07       1    3.06    0.00    2.04   48.98    0.00    0.00    0.00    0.00    0.00   45.92
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 5] mpstat</figcaption>
</figure>

mpstat은 CPU Core별 사용량을 출력하는 Tool이다. [Shell 5]는 mpstat을 이용하여 1초 간격으로 모든 CPU Core의 CPU 사용량을 출력하는 Shell의 모습을 나타내고 있다.

#### 1.6. iostat

{% highlight console %}
# iostat -x 1
Linux 4.15.0-60-generic (node09)        09/22/19        _x86_64_        (2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
          17.30    0.07    3.09   48.07    0.00   31.47

Device            r/s     w/s     rkB/s     wkB/s   rrqm/s   wrqm/s  %rrqm  %wrqm r_await w_await aqu-sz rareq-sz wareq-sz  svctm  %util
loop0            0.25    0.00      0.28      0.00     0.00     0.00   0.00   0.00   12.98    0.00   0.00     1.12     0.00   0.47   0.01
loop1            0.00    0.00      0.03      0.00     0.00     0.00   0.00   0.00   23.47    0.00   0.00    20.30     0.00   7.47   0.00
loop2            0.32    0.00      0.35      0.00     0.00     0.00   0.00   0.00    0.04    0.00   0.00     1.10     0.00   0.00   0.00
loop3            0.00    0.00      0.00      0.00     0.00     0.00   0.00   0.00    0.00    0.00   0.00     2.50     0.00   0.00   0.00
fd0              0.00    0.00      0.00      0.00     0.00     0.00   0.00   0.00   45.45    0.00   0.00     4.00     0.00  45.45   0.00
sda              8.65   53.40     80.75  15987.95     0.90   101.52   9.43  65.53   27.56   83.86   4.72     9.34   299.42  15.18  94.18
sdb              0.03    0.00      0.75      0.00     0.00     0.00   0.00   0.00   22.65    0.00   0.00    28.86     0.00  16.74   0.04
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 6] iostat</figcaption>
</figure>

iostat은 Block Device별 사용량을 출력하는 Tool이다. [Shell 6]는 iostat을 이용하여 1초 간격으로 모든 Block Device의 사용량을 출력하는 Shell의 모습을 나타내고 있다. iostat은 평균 CPU 사용률도 출력한다.

#### 1.7. netstat

{% highlight console %}
# netstat -i
Kernel Interface table
Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
docker0   1500        0      0      0 0            37      0      0      0 BMRU
eth0      1500    95498      0      0 0         76031      0      0      0 BMRU
eth1      1500  1017307      0      0 0        386209      0      0      0 BMRU
lo       65536   196363      0      0 0        196363      0      0      0 LRU
vetheeab  1500        0      0      0 0            74      0      0      0 BMRU
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 7] uptime</figcaption>
</figure>

netstat은 Linux Kernel이 갖고있는 대부분의 Network 정보를 출력하는 Tool이다. netstat은 Network 성능을 측정하는데도 이용할수 있다. [Shell 7]은 netstat을 이용하여 모든 Network Interface의 성능을 측정하는 Shell의 모습을 나타내고 있다.

#### 1.8. nicstat

{% highlight console %}
# nicstat 1
    Time      Int   rKB/s   wKB/s   rPk/s   wPk/s    rAvs    wAvs %Util    Sat
15:41:38  docker0    0.00    0.00    0.00    0.00    0.00   73.56  0.00   0.00
15:41:38     eth0    6.21    0.12    4.77    1.81  1332.9   69.11  0.01   0.00
15:41:38       lo    0.85    0.85    1.05    1.05   834.9   834.9  0.00   0.00
15:41:38 veth3673f81    0.00    0.00    0.00    0.00    0.00   73.62  0.00   0.00
15:41:38     eth1    7.32    0.55   12.19    5.00   614.8   111.7  0.01   0.00
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 8] nicstat</figcaption>
</figure>

nicstat은 Network Interface별 성능을 출력하는 Tool이다. [Shell 8]은 nicstat을 이용하여 1초 간격으로 모든 Network Interface의 성능을 출력하는 Shell의 모습을 나타내고 있다.

#### 1.9. top

{% highlight console %}
# top
top - 12:32:20 up  9:49,  1 user,  load average: 3.02, 2.97, 3.10
Tasks: 132 total,   1 running,  85 sleeping,   0 stopped,   0 zombie
%Cpu(s): 15.5 us,  3.5 sy,  0.0 ni, 24.3 id, 56.4 wa,  0.0 hi,  0.2 si,  0.0 st
KiB Mem :  8168940 total,  2694252 free,  1223500 used,  4251188 buff/cache
KiB Swap:  4194300 total,  4194300 free,        0 used.  6637292 avail Mem

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 2912 42472     20   0  861416 783804  21324 S  22.7  9.6 204:23.28 prometheus
26030 42472     20   0     212      4      0 S   5.7  0.0   0:00.17 dumb-init
 3335 root      20   0 1352800  91740  17476 S   3.0  1.1  19:55.28 cadvisor
 1529 root      20   0 1290564  82076  37524 S   1.0  1.0   1:55.27 dockerd
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 9] top</figcaption>
</figure>

top은 CPU 사용률 또는 Memory 사용률이 높은 순서대로 Process 또는 Thread를 보여주는 Tool이다. [Shell 9]는 top을 이용하여 Process의 CPU 사용률을 출력하는 Shell의 모습을 나타내고 있다.

#### 1.10. slabtop

{% highlight console %}
# slabtop
 Active / Total Objects (% used)    : 2581763 / 2731476 (94.5%)
 Active / Total Slabs (% used)      : 101112 / 101112 (100.0%)
 Active / Total Caches (% used)     : 85 / 122 (69.7%)
 Active / Total Size (% used)       : 577381.30K / 706488.91K (81.7%)
 Minimum / Average / Maximum Object : 0.01K / 0.26K / 8.00K

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
656136 651319   0%    0.10K  16824       39     67296K buffer_head
639009 623453   0%    0.19K  30429       21    121716K dentry
329460 328843   0%    0.13K  10982       30     43928K kernfs_node_cache
300870 188228   0%    1.06K  20058       15    320928K ext4_inode_cache
252246 252246 100%    0.04K   2473      102      9892K ext4_extent_status
123776 122174   0%    0.06K   1934       64      7736K kmalloc-64
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 10] slabtop</figcaption>
</figure>

slabtop은 Kernel이 이용하는 Slab Memory 사용량을 출력하는 Tool이다. [Shell 10]은 slabtop을 이용하여 Slab Memory 사용량을 출력하는 Shell의 모습을 나타내고 있다. 사용량 정렬 기준은 다양한 옵션을 통해서 변경이 가능하다.

#### 1.11. iotop

{% highlight console %}
# iotop
Total DISK READ :      46.79 K/s | Total DISK WRITE :       5.48 M/s
Actual DISK READ:      46.79 K/s | Actual DISK WRITE:       5.52 M/s
  TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND
  355 be/3 root        0.00 B/s   27.29 K/s  0.00 % 40.92 % [jbd2/sda2-8]
 3771 be/4 42472      35.09 K/s    0.00 B/s  0.00 %  8.91 % prometheus -config.file /etc/prometheus/prometheus.yml -web.liste~-log.format logger:stdout -storage.local.path /var/lib/prometheus
 3769 be/4 42472       3.90 K/s    0.00 B/s  0.00 %  4.53 % prometheus -config.file /etc/prometheus/prometheus.yml -web.liste~-log.format logger:stdout -storage.local.path /var/lib/prometheus
 5297 be/4 42472       3.90 K/s    2.30 M/s  0.00 %  4.37 % prometheus -config.file /etc/prometheus/prometheus.yml -web.liste~-log.format logger:stdout -storage.local.path /var/lib/prometheus
 3768 be/4 42472       3.90 K/s    3.15 M/s  0.00 %  2.68 % prometheus -config.file /etc/prometheus/prometheus.yml -web.liste~-log.format logger:stdout -storage.local.path /var/lib/prometheus
10129 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.05 % [kworker/u4:4]
    1 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % systemd --system --deserialize 40
    2 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [kthreadd]            
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 11] iotop</figcaption>
</figure>

iotop은 Block I/O 사용률이 높은 순서대로 Process 또는 Thread를 출력하는 Tool이다. [Shell 11]은 iotop을 이용하여 Block I/O 사용률을 출력하는 Shell의 모습을 나타내고 있다.

#### 1.12. iftop

{% highlight console %}
# iftop
 Press H or ? for help            25.0Kb            37.5Kb           50.0Kb      62.5Kb
└─┴─┴─┴─┴──
node09                        => dns.google                      672b   1.11Kb  1.05Kb
                              <=                                 672b   1.00Kb  1.04Kb
node09                        => 192.168.0.40 cast.net             0b      0b    931b
                              <=                                   0b      0b   3.33Kb
_gateway                      => all-systems.mcast.net             0b      0b     34b
                              <=                                   0b      0b      0b
node09                        => 106.247.248.106                   0b      0b     15b
                              <=                                   0b      0b     15b
node09                        => dadns.cdnetworks.co.kr            0b      0b     15b
                              <=                                   0b      0b     15b
node09                        => ch-ntp01.10g.ch                   0b      0b     15b
                              <=                                   0b      0b     15b
node09                        => ec2-13-209-84-50.ap-northeas      0b      0b     15b
                              <=                                   0b      0b     15b

──
TX:             cum:   11.2KB   peak:   19.1Kb         rates:    672b   1.11Kb  2.02Kb
RX:                    23.8KB           67.5Kb                   672b   1.00Kb  4.46Kb
TOTAL:                 35.0KB           86.6Kb                  1.31Kb  2.11Kb  6.48Kb 
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 12] iftop</figcaption>
</figure>

iftop은 특정 Interface의 Network Bandwidth 사용량을 Src IP/Dst IP로 분류한 다음, 샤용량이 높은 순서에 따라서 출력하는 Tool이다. [Shell 12]는 iftop을 이용하여 Network Bandwidth 사용량을 출력하는 Shell의 모습을 나타내고 있다.

#### 1.13. nethogs

{% highlight console %}
# nethogs
NetHogs version 0.8.5-2

    PID USER     PROGRAM DEV SENT      RECEIVED
      ? root     10.0.0.19:3000-10.0.0.11:56170                0.058       0.109 KB/sec
      ? root     10.0.0.19:9093-10.0.0.11:39550                0.058       0.109 KB/sec
  31723 root     sshd: root@pts/0                  eth1        0.342       0.084 KB/sec
      ? root     10.0.0.19:9091-10.0.0.11:55972                0.029       0.055 KB/sec
  27860 42417    /usr/sbin/grafana-server          eth1        0.013       0.013 KB/sec
      ? root     10.0.0.19:36076-10.0.0.11:9150                0.000       0.000 KB/sec
   2912 42472    /opt/prometheus/prometheus        eth1        0.000       0.000 KB/sec
      ? root     unknown TCP                                   0.000       0.000 KB/sec

  TOTAL 0.000 0.000 KB/sec                                     0.500       0.371
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 13] nethogs</figcaption>
</figure>

nethogs는 Network Bandwidth 사용률이 높은 순서대로 Process를 출력하는 Tool이다. [Shell 13]은 nethogs를 이용하여 Network Bandwidth 사용량을 출력하는 Shell의 모습을 나타내고 있다.

### 2. 참조

* [https://medium.com/netflix-techblog/linux-performance-analysis-in-60-000-milliseconds-accc10403c55](https://medium.com/netflix-techblog/linux-performance-analysis-in-60-000-milliseconds-accc10403c55)
* [https://github.com/nicolaka/netshoot](https://github.com/nicolaka/netshoot)

