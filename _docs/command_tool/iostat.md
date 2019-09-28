---
title: iostat
category: Command, Tool
date: 2019-09-16T12:00:00Z
lastmod: 2019-09-16T12:00:00Z
comment: true
adsense: true
---

I/O 통계 정보를 보여주는 iostat 사용법을 정리한다.

***

* TOC
{:toc}

***

### 1. iostat

#### 1.1. # iostat

{% highlight console %}
# iostat
Linux 4.15.0-60-generic (node09)        09/28/19        _x86_64_        (2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           9.34    0.05    2.41   32.10    0.00   56.10

Device             tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
loop0             0.09         0.11         0.00       9424          0
loop1             0.00         0.01         0.00       1076          0
sda              40.71        43.81      7572.20    3903569  674772928
sdb               0.01         0.29         0.00      25400          0
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] iostat</figcaption>
</figure>

현재의 I/O 통계 정보를 출력한다.

#### 1.2. # iostat -x

{% highlight console %}
# iostat -x
Linux 4.15.0-60-generic (node09)        09/28/19        _x86_64_        (2 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           9.34    0.05    2.41   32.09    0.00   56.11

Device            r/s     w/s     rkB/s     wkB/s   rrqm/s   wrqm/s  %rrqm  %wrqm r_await w_await aqu-sz rareq-sz wareq-sz  svctm  %util
loop0            0.09    0.00      0.11      0.00     0.00     0.00   0.00   0.00   12.98    0.00   0.00     1.12     0.00   0.47   0.00
loop1            0.00    0.00      0.01      0.00     0.00     0.00   0.00   0.00   23.47    0.00   0.00    20.30     0.00   7.47   0.00
loop2            0.12    0.00      0.13      0.00     0.00     0.00   0.00   0.00    0.04    0.00   0.00     1.10     0.00   0.00   0.00
sda              4.83   35.87     43.79   7568.11     0.49    64.44   9.14  64.24   24.46   72.31   2.71     9.06   211.00  16.16  65.76
sdb              0.01    0.00      0.28      0.00     0.00     0.00   0.00   0.00   22.65    0.00   0.00    28.86     0.00  16.74   0.02
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] iostat -x</figcaption>
</figure>

현재의 확장된 I/O 통계 정보를 출력한다.

#### 1.2. # iostat [Interval] [Count]

[Interval] 간격으로 [Count] 횟수만큼 I/O 통계 정보를 출력한다.

#### 1.3. # iostat -c

CPU 통계 정보만 출력한다.

#### 1.4. # iostat -d 

Disk 장치 정보만 출력한다.

#### 1.5. # iostat -k

초당 블록 수 대신 초당 kb로 출력한다.

#### 1.6. # iostat -m

초당 블록 수 대신 초당 Mb로 출력한다.