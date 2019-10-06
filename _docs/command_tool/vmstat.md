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
  * r : Runnable Process (Running 상태 / Run Queue에서 대기 상태)의 개수를 나타낸다.
  * b : Uninterruptible Sleep 상태의 Process의 개수를 나타낸다.
* memory
  * swpd : Swap을 이용하여 제공되는 가상의 Memory 용량을 Byte로 나타낸다.
  * free : 사용되지 않는 Memory 용량을 Byte로 나타낸다.
  * buff : Kernel Buffer로 이용되는 Memory 용량을 Byte로 나타낸다.
  * cache : Kernel Cache로 이용되는 Memory 용량을 Byte로 나타낸다.
* swap :
  * si : 초당 Swap Disk에서 Memory로 옯겨간 Memory 용량을 Byte로 나타낸다.
  * so : 초당 Memory에서 Swap Disk로 옮겨간 Memory 용량을 Byte로 나타낸다.
* io
  * bi : 초당 Block Device에서 받은 Block의 개수를 나타낸다.
  * bo : 초당 Block Device로 보낸 Block의 개수를 나타낸다.
* system
  * in : 초당 Clock을 포함하여 받은 Interrupt의 개수를 나타낸다.
  * cs : 초당 발생한 Context Switch의 개수를 나타낸다.
* cpu
  * us : User Level CPU 사용률을 나타낸다.
  * sy : Kernel Level CPU 사용률을 나타낸다.
  * id : I/O Wait를 제외한 CPU의 대기율를 나타낸다.
  * wa : I/O Wait로 인한 CPU 대기율을 나타낸다.
  * st : Kernel이 Hypervisor가 제어하는 가상 머신 안에서 동작할 때, Hypervisor나 다른 가상 머신에 의해서 사용을 뺏긴 CPU 사용률을 의미한다.

#### 1.2. # vmstat [Interval] [Count]

[Interval] 간격으로 [Count] 횟수만큼 System의 전반적인 정보를 출력한다.

#### 1.3. # vmstat -d

{% highlight console %}
# vmstat -d
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
  * total : 성공한 총 Read 횟수를 나타낸다.
  * merged : I/O Scheduler에 의해서 Merge된 총 Read 횟수를 나타낸다.
  * sectors : Read에 성공한 총 Sector의 개수를 나타낸다.
  * ms : Read에 걸린 총 시간을 나타낸다.
* writes
  * total : 성공한 총 Write 횟수를 나타낸다.
  * merged : I/O Scheduler에 의해서 Merge된 총 Write 횟수를 나타낸다.
  * sectors : Write에 성공한 총 Sector의 개수를 나타낸다.
  * ms : Write에 걸린 총 시간을 나타낸다.
* IO
  * cur : 현재 처리중인 I/O의 개수를 나타낸다.
  * sec : I/O 처리에 걸린 총시간을 초단위로 나타낸다.

#### 1.4. # vmstat -p [Partition]

{% highlight console %}
# vmstat -p /dev/sda2
sda2          reads   read sectors  writes    requested writes
              612711   10283732    4783736 1628860584
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] vmstat -p</figcaption>
</figure>

[Shell 3]은 "vmstat"을 이용하여 Memory 통계정보를 출력하는 Shell을 나타내고 있다. 각 열은 아래와 같은 의미를 나타낸다.

* reads : 해당 Partition을 대상으로 발생한 Read 요청의 개수를 나타낸다.
* read sectors : 해당 Partition을 위해 Read한 Sector의 개수를 나타낸다.
* writes : 해당 Partition을 대상으로 발생한 Write 요청의 개수를 나타낸다.
* requested writes : 해당 Partition을 위해 Write한 Sector의 개수를 나타낸다.

#### 1.5. # vmstat -m

{% highlight console %}
# vmstat -m
Cache                       Num  Total   Size  Pages
SCTPv6                       22     22   1472     22
SCTP                          0      0   1344     12
au_finfo                      0      0    192     21
au_icntnr                     0      0    768     21
au_dinfo                      0      0    128     32
ovl_inode                 14122  14122    688     23
sw_flow                       0      0   1648     19
nf_conntrack                 94    168    320     12
ext4_groupinfo_4k          1624   1624    144     28
btrfs_delayed_ref_head        0      0    152     26
btrfs_delayed_node            0      0    296     13
btrfs_ordered_extent          0      0    416     19
btrfs_extent_map              0      0    144     28
btrfs_extent_buffer           0      0    280     14
btrfs_path                    0      0    112     36
btrfs_trans_handle            0      0    120     34
btrfs_inode                   0      0   1144     14 
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] vmstat -m</figcaption>
</figure>

[Shell 4]은 "vmstat -m"을 이용하여 slab 통계정보를 출력하는 Shell을 나타내고 있다. 각 열은 아래와 같은 의미를 나타낸다.

* Cache : Cache 이름을 나타낸다.
* Num : 현재 Active 상태의 Slab Object의 개수를 나타낸다.
* Total : 전체 Slab Object의 개수를 나타낸다.
* Size : Slab Object의 크기를 나타낸다.
* Pages : 한개 이상의 Active Slab Object가 있는 Page (Slab)의 개수를 나타낸다.

### 2. 참조

* [http://www.linfo.org/runnable_process.html](http://www.linfo.org/runnable_process.html)
* [https://hotpotato.tistory.com/280](https://hotpotato.tistory.com/280)
* [https://medium.com/@damianmyerscough/vmstat-explained-83b3e87493b3](https://medium.com/@damianmyerscough/vmstat-explained-83b3e87493b3)