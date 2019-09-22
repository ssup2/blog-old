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
<figcaption class="caption">[Shell 1] uptime Shell</figcaption>
</figure>

uptime은 Linux의 구동 시간 및 평균 CPU 부하를 보여주는 Tool이다. [Shell 1]은 uptime Tool을 통해서 확인할 수 있는 Shell의 모습을 나타내고 있다. 현재 시각 / Linux 구동 시간 / 현재 Login 상태의 User 수 / 1분, 5분, 15분 동안의 평균 CPU 부하(%)를 나타낸다.

#### 1.2. free

{% highlight console %}
# free -m
              total        used        free      shared  buff/cache   available
Mem:           7977        1185        2710           1        4081        6490
Swap:          4095           0        4095
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] free Shell</figcaption>
</figure>

free는 Memory 및 Swap 사용량을 출력하는 Tool이다. [Shell 2]는 Memory 사용량 및 Swap 사용량을 MB 단위로 출력하는 Shell의 모습을 나타내고 있다.

#### 1.3. pidstat

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
<figcaption class="caption">[Shell 3] pidstat Shell</figcaption>
</figure>

pidstat은 process별 Resource 사용량을 출력하는 Tool이다. [Shell 3]은 pidstat을 이용하여 1초 간격으로 각 Process의 CPU 사용량을 출력하는 Shell의 모습을 나타내고 있다. pidstat은 CPU 사용량뿐만 아니라 Memory, Stack, Block I/O, Kernel 사용량 정보도 출력할 수 있다.

#### 1.4. mpstat

{% highlight console %}
# mpstat -P ALL 1
Linux 4.15.0-60-generic (node09)        09/22/19        _x86_64_        (2 CPU)

11:25:06     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
11:25:07     all    5.05    0.00    2.53   39.39    0.00    0.00    0.00    0.00    0.00   53.03
11:25:07       0    7.00    0.00    3.00   29.00    0.00    0.00    0.00    0.00    0.00   61.00
11:25:07       1    3.06    0.00    2.04   48.98    0.00    0.00    0.00    0.00    0.00   45.92
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] mpstat Shell</figcaption>
</figure>

mpstat은 CPU Core별 사용량을 출력하는 Tool이다. [Shell 4]는 mpstat을 이용하여 1초 간격으로 모든 CPU Core의 CPU 사용량을 출력하는 Shell의 모습을 나타내고 있다.

#### 1.5. iostat

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
<figcaption class="caption">[Shell 5] iostat Shell</figcaption>
</figure>

iostat은 Block Device별 사용량을 출력하는 Tool이다. [Shell 5]는 iostat을 이용하여 1초 간격으로 모든 Block Device의 사용량을 출력하는 Shell의 모습을 나타내고 있다. iostat은 평균 CPU 사용률도 출력한다.

### 2. 참조

* [https://medium.com/netflix-techblog/linux-performance-analysis-in-60-000-milliseconds-accc10403c55](https://medium.com/netflix-techblog/linux-performance-analysis-in-60-000-milliseconds-accc10403c55)
* [https://github.com/nicolaka/netshoot](https://github.com/nicolaka/netshoot)

