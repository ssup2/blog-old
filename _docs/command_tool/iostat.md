---
title: iostat
category: Command, Tool
date: 2019-09-16T12:00:00Z
lastmod: 2019-09-16T12:00:00Z
comment: true
adsense: true
---

Block Device I/O 통계 정보와 CPU 통계 정보를 보여주는 iostat 사용법을 정리한다.

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

Block Device의 I/O 통계 정보와 CPU 통계 정보를 출력한다. [Shell 1]은 iostat을 이용하여 Block Device의 I/O 통계 정보와 CPU 통계 정보를 출력하는 Shell의 모습을 나타내고 있다. 윗부분에는 CPU 통계 정보가 출력된다. 출력 내용은 아래와 같다.

* user : nice 값이 적용되지 않은 Process들의 User Level 사용률을 나타낸다.
* nice : nice 값이 적용된 Process들의 User Level 사용률을 나타낸다.
* system : Process들의 Kernel Level 사용률을 나타낸다.
* iowait : I/O Wait로 인한 CPU 대기율을 나타낸다.
* steal : Kernel이 Hypervisor가 제어하는 가상 머신 안에서 동작할 때, Hypervisor나 다른 가상 머신에 의해서 사용을 뺏긴(steal) CPU 사용률을 의미한다.
* idle : I/O Wait를 제외한 CPU의 대기율을 나타낸다.

아랫부분에는 Block Device I/O 정보를 출력한다. 출력 내용을 아래와 같다.

* tps : 초당 I/O Request의 개수를 나타낸다.
* kB_read/s : 초당 읽은 Data의 양을 kB으로 나타낸다. 옵션을 통해서 단위 변경이 가능하다.
* kB_wrtn/s : 초당 쓴 Data의 양을 kB으로 나타낸다. 옵션을 통해서 단위 변경이 가능하다.
* kB_read : 초당 읽은 Block 개수를 나타낸다.
* kB_wrtn : 초당 쓴 Block 개수를 나타낸다.

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

확장된 Block Device의 I/O 통계 정보와 CPU 통계 정보를 출력한다. [Shell 2]는 "iostat -x"을 이용하여 확장된 Block Device의 I/O 통계 정보와 CPU 통계 정보를 출력하는 Shell의 모습을 나타내고 있다. CPU 통계 정보는 [Shell 1]과 동일하며 Block Device의 I/O 통계 정보는 아래와 같다.

* r/s : 초당 완료된 Read 요청 개수를 의미한다.
* w/s : 초당 완료된 Write 요청 개수를 의미한다.
* rkB/s : 초당 읽은 Data의 양을 kB으로 나타낸다. 옵션을 통해서 단위 변경이 가능하다.
* wkB/s : 초당 쓴 Data의 양을 kB으로 나타낸다. 옵션을 통해서 단위 변경이 가능하다.
* rrqm/s : 초당 Block Device의 Queue에서 Merge된 Read 요청 개수를 의미한다.
* wrqm/s : 초당 Block Device의 Queue에서 Merge된 Wrtie 요청 개수를 의미한다.
* %rrqm : Block Device에 전송하기 전에 Merge된 Read 요청의 비율
* %wrqm : Block Device에 전송하기 전에 Merge된 Write 요청의 비율
* r_await : Block Device에 Read 요청을 전송한후 실제 Data가 Block Device로부터 Read될때 까지의 평균 시간. 시간에는 요청이 Queue에서 대기한 시간까지 포함한다.
* w_await : Block Device에 Write 요청을 전송한후 실제 Data가 Block Device에 Write될때 까지의 평균 시간. 시간에는 요청이 Queue에서 대기한 시간까지 포함한다.
* aqu-sz : 평균 Queue의 길이를 의미한다.
* rareq-sz : Read 요청의 평균 크기를 의미한다.
* wareq-sz : Write 요청의 평균 크기를 의미한다.
* %util : Block Device의 Bandwidth 사용률을 의미한다.

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