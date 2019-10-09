---
title: top
category: Command, Tool
date: 2017-02-12T18:48:00Z
lastmod: 2019-10-09T18:48:00Z
comment: true
adsense: true
---

Process들을 CPU 사용률 또는 Memory 사용률 순서대로 출력하는 top의 사용법을 정리한다.

***

* TOC
{:toc}

***

### 1. top

#### 1.1. # top

{% highlight console %}
# top
top - 10:27:27 up 36 min,  3 users,  load average: 0.00, 0.01, 0.05
Tasks: 238 total,   1 running, 237 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.2 us,  0.1 sy,  0.0 ni, 99.7 id,  0.1 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem:   8052812 total,  1053584 used,  6999228 free,    49428 buffers
KiB Swap:  8265724 total,        0 used,  8265724 free.   541164 cached Mem

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 1848 root      20   0 1175416 103756  61724 S   0.7  1.3   0:12.55 compiz
 1349 root      20   0  601840  69188  53208 S   0.3  0.9   0:05.81 Xorg
 2824 root      20   0   30372   3544   2976 R   0.3  0.0   0:00.06 top
    1 root      20   0   34024   4464   2616 S   0.0  0.1   0:00.80 init
    2 root      20   0       0      0      0 S   0.0  0.0   0:00.00 kthreadd
    3 root      20   0       0      0      0 S   0.0  0.0   0:00.52 ksoftirqd/0
    5 root       0 -20       0      0      0 S   0.0  0.0   0:00.00 kworker/0:+
    7 root      20   0       0      0      0 S   0.0  0.0   0:00.33 rcu_preempt
    8 root      20   0       0      0      0 S   0.0  0.0   0:00.00 rcu_sched
    9 root      20   0       0      0      0 S   0.0  0.0   0:00.00 rcu_bh
   10 root      rt   0       0      0      0 S   0.0  0.0   0:00.00 migration/0
   11 root      rt   0       0      0      0 S   0.0  0.0   0:00.01 watchdog/0
   12 root      rt   0       0      0      0 S   0.0  0.0   0:00.01 watchdog/1
   13 root      rt   0       0      0      0 S   0.0  0.0   0:00.00 migration/1
   14 root      20   0       0      0      0 S   0.0  0.0   0:00.44 ksoftirqd/1
   16 root       0 -20       0      0      0 S   0.0  0.0   0:00.00 kworker/1:+
   17 root      rt   0       0      0      0 S   0.0  0.0   0:00.00 watchdog/2
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] top</figcaption>
</figure>

[Shell 1]은 top 명령어를 통해서 확인할 수 있는 Shell의 모습을 나타내고 있다. 윗부분은 CPU와 Memory 정보를 출력하고, 아랫 부분은 CPU 사용률을 기준으로 내림차순으로 Process 정보를 출력한다.

##### 1.1.1. CPU 정보

[Shell 1]의 윗부분의 %Cpu(s) 부분은 모든 CPU Core의 평균 CPU 사용률을 타나내고 있다. 각 열은 다음과 같은 의미를 나타낸다.

* us (user) : nice값이 적용되지 않은 (un-niced, nice = 0) Process들의 User Code를 구동하는데 이용한 CPU 사용률을 나타낸다. 대부분의 User Process들의 사용률을 의미한다.
* sy (system) : Kernel Code를 구동하는데 이용한 CPU 사용률 중에서 id, wa, hi, si의 사용률/대기율 제외한 사용률을 의미한다.
* ni (nice) : nice값이 적용된 (niced) Process들의 User Code들을 구동하는데 이용한 CPU 사용률을 나타낸다.
* id (idle) : I/O Wait를 제외한 CPU의 대기율를 나타낸다.
* wa (wait) : I/O Wait로 인한 CPU 대기율을 나타낸다.
* hi (hardware interrupt) : 순수 Hardware Interrupt 처리를 위해 사용된 CPU 사용률을 나타낸다. Kernel의 Interrupt Flag를 Set만 하는 Top Havles 부분을 처리를 위한 CPU 사용률을 의미한다.
* si (sotware interrupt) : Top Halves에서 Set한 Interrupt Flag에 따라서 실제 Interrupt를 처리하는 Bottom Havles의 CPU 사용률을 나타낸다.
* st (steal) : Kernel이 Hypervisor가 제어하는 가상 머신 안에서 동작할 때, Hypervisor나 다른 가상 머신에 의해서 사용을 뺏긴 CPU 사용률을 나타낸다.

##### 1.1.2. Memory 정보

[Shell 1]의 CPU 정보와 Process 정보 사이에는 Memory 사용량을 나타내고 있다. 각 항목은 다음과 같은 의미를 나타낸다.

* Mem total : 전체 Memory 용량을 나타낸다.
* Mem used : 사용중인 Memory 용량을 나타낸다.
* Mem free : 사용중이지 않은 Memory 용량을 나타낸다.
* Swap total : 전체 Swap 용량을 나타낸다.
* Swap used : 사용중인 Swap 용량을 나타낸다.
* Swap free : 사용중이지 않은 Swap 용량을 나타낸다.
* buffers : Kernel Buffer로 이용되는 Memory 용량을 나타낸다.
* cached Mem : Kernel Cache로 이용되는 Memory 용량을 나타낸다.

##### 1.1.3. Process 정보

[Shell 1]의 아랫 부분에는 Process 정보를 출력한다. 각 열을 다음과 같은 의미를 나타낸다.

* PID : Process의 ID를 나타낸다.
* USER : Process Owner를 나타낸다.
* PR : Kernel Scheduling시 실제로 이용하는 Scheduling Priority를 나타낸다. "0 ~ 39, rt"의 값을 갖을수 있고, 숫자의 경우 낮은 값일수록 높은 Priority를 갖는다. rt는 Real Time Scheduling Priority를 의미하며 0 Priority 보다 높은 Priority를 갖는다.
* NI : nice 값을 나타낸다. "-20 ~ 19"의 값을 갖을수 있고, 숫자가 낮을수록 높은 Priority를 갖는다. "20 + NI" 값이 PR이 된다.
* VIRT : Virtual Memory 용량을 나타낸다. 현재 이용되지는 않더라도 Process를 위해서 할당된 모든 Memory 용량 및 Swap 용량의 합을 의미한다.
* RES : 현재 이용되고 있는 실제 Memory 용량을 나타낸다. VIRT의 일부분이다.
* SHR : 공유 Memory 용량을 나타낸다. RES의 일부분이다.
* S : Process의 상태를 나타낸다.
* %CPU : CPU 사용률을 나타낸다.
* %MEM : Memory 사용률을 나타낸다.
* TIME+ : Process 구동 시간을 나타낸다.
* COMMAND : Process Command를 나타낸다.

##### 1.1.4. 단축키

* 1 : 각 CPU Core별 사용률을 출력한다.
* SHIFT + M : Memory 사용률을 기준으로 정렬한다.
* SHIFT + P : CPU 사용률을 기준으로 정렬한다.
* SHIFT + T : 구동 시간을 기준으로 정렬한다.

### 2. 참조

* [https://kldp.org/node/65018](https://kldp.org/node/65018)
* [http://serverfault.com/questions/230495/what-does-st-mean-in-top](http://serverfault.com/questions/230495/what-does-st-mean-in-top)
* [https://www.tecmint.com/set-linux-process-priority-using-nice-and-renice-commands/](https://www.tecmint.com/set-linux-process-priority-using-nice-and-renice-commands/)
