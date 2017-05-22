---
title: top
category: Command, Tool
date: 2017-02-12T18:48:00Z
lastmod: 2017-01-15T18:48:00Z
comment: true
adsense: true
---

top 명령어는 Linux에서 실시간으로 Process들을 보여주는 Tool이다. top은 proc Filesystem의 Process 관련 내용을 파싱 및 계산을 통해 Linux 사용자가 쉽게 Process들의 상태를 파악 할 수 있도록 도와준다.

### 1. top Display

~~~
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
~~~

### 2. CPU 사용률

top을 통해서 CPU 사용률을 알 수 있다. **%Cpu(s)** 부분은 모든 CPU Core의 평균 CPU 사용률을 타나내고 있다. 1번 키보드를 누르면 각 CPU Core의 사용률을 볼 수 있다.CPU의 사용률은 us, sy, ni, id, wa, hi, si, st 7개의 부분으로 나타낸다. 7개 부분의 사용률을 모두 더하면 100%가 된다.

* us (user) - nice값이 적용되지 않은 (un-niced, nice = 0) User Process들의 사용률을 나타낸다. 대부분의 User Process들의 사용률을 의미한다.  
* sy (system) - Kernel의 사용률 중 id, wa, hi, si의 사용률 제외한 사용률을 의미한다.
* ni (nice) - nice값이 적용된 (niced) User Process들의 사용률을 나타낸다.
* id (idle) - I/O Wait를 제외한 CPU의 대기율를 나타낸다.
* wa (wait) - I/O Wait로 인한 CPU 대기율을 나타낸다.
* hi (hardware interrupt) - 순수 Hardware Interrupt 처리를 위해 사용된 CPU 사용률을 의미한다. 좀더 정확히 설명하면 Kernel의 Interrupt Flag를 Set만 하는 Top Havles 부분을 처리를 위한 CPU 사용률을 의미한다.
* si (sotware interrupt) - Top Halves에서 Set한 Interrupt Flag에 따라서 실제 Interrupt를 처리하는 Bottom Havles의 CPU 사용률을 의미한다.
* st (steal) - Kernel이 Hypervisor가 제어하는 가상 머신 안에서 동작할 때, Hypervisor나 다른 가상 머신에 의해서 사용을 뺏긴(steal) CPU 사용률을 의미한다.

### 3. 참조

* [https://kldp.org/node/65018](https://kldp.org/node/65018)
* [http://serverfault.com/questions/230495/what-does-st-mean-in-top](http://serverfault.com/questions/230495/what-does-st-mean-in-top)
