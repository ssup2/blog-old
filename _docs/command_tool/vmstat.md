---
title: vmstat
category: Command, Tool
date: 2019-09-16T12:00:00Z
lastmod: 2019-09-16T12:00:00Z
comment: true
adsense: true
---

Memory 통계 정보를 보여주는 vmstat 사용법을 정리한다.

***

* TOC
{:toc}

***

### 1. vmstat

#### 1.1. # vmstat

{% highlight console %}
# vmstat
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 1  1    268 782960 849224 3488324    0    0    14  1733   77   78  6  2 68 24  0
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] vmstat</figcaption>
</figure>

현재의 Memory 통계 정보를 출력한다. [Shell 1]은 "vmstat"을 이용하여 Memory 통계정보를 출력하는 Shell을 나타내고 있다. 각 열은 아래와 같은 의미를 나타낸다.

* procs
  * r :
  * b :
* memory
  * swpd :
  * free :
  * buff :
  * cache :
* swap :
  * si :
  * so :
* io
  * bi :
  * bo :
* system
  * in :
  * cs :
* cpu
  * us :
  * sy :
  * id :
  * wa :
  * st :

#### 1.2. # vmstat [Interval] [Count]

[Interval] 간격으로 [Count] 횟수만큼 System의 전반적인 정보를 출력한다.

#### 1.3. # vmstat -d

{% highlight console %}
# vmstat
disk- ------------reads------------ ------------writes----------- -----IO------
       total merged sectors      ms  total merged sectors      ms    cur    sec
loop0   8669      0   21324  109832      0      0       0       0      0      4
loop1     53      0    2152    1244      0      0       0       0      0      0
loop2  11152      0   25952     712      0      0       0       0      0      0
loop3      2      0      10       0      0      0       0       0      0      0
loop4      0      0       0       0      0      0       0       0      0      0
loop5      0      0       0       0      0      0       0       0      0      0
loop6      0      0       0       0      0      0       0       0      0      0
loop7      0      0       0       0      0      0       0       0      0      0
sr0        0      0       0       0      0      0       0       0      0      0
fd0       25      0     200    1164      0      0       0       0      0      1
sda   613771  66065 10319473 12671488 4981677 7462940 1628317680 348232712      0  94326
sdb      959      0   53207   20628      0      0       0       0      0     15
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] vmstat -d</figcaption>
</figure>

Disk 통계정보를 출력한다. [Shell 2]는 "vmstat -d"를 이용하여 Disk 통계량을 출력하는 Shell의 모습을 나타낸다. 각 열을 아래와 같은 의미를 나타낸다.

* reads
  * total :
  * merged :
  * sectors :
  * ms :
* writes
  * total :
  * merged :
  * sectors :
  * ms :
* IO
  * cur :
  * sec :

#### 1.4. # vmstat -p [Partition]

{% highlight console %}
# vmstat -p /dev/sda2
sda2          reads   read sectors  writes    requested writes
              612711   10283732    4783736 1628860584
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] vmstat -p</figcaption>
</figure>

[Shell 3]은 "vmstat"을 이용하여 Memory 통계정보를 출력하는 Shell을 나타내고 있다. 각 열은 아래와 같은 의미를 나타낸다.

* reads :
* read sectors :
* writes :
* requested writes :