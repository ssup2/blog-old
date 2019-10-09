---
title: mpstat
category: Command, Tool
date: 2019-09-16T12:00:00Z
lastmod: 2019-09-16T12:00:00Z
comment: true
adsense: true
---

CPU 사용량을 출력하는 mpstat의 사용법을 정리한다.

***

* TOC
{:toc}

***

### 1. mpstat

#### 1.1. # mpstat -P ALL

{% highlight console %}
# mpstat -P ALL
Linux 4.15.0-60-generic (node09)        10/09/19        _x86_64_        (2 CPU)

13:00:37     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
13:00:37     all    8.45    0.04    2.07   24.08    0.00    0.07    0.00    0.00    0.00   65.29
13:00:37       0    8.47    0.03    2.07   24.25    0.00    0.12    0.00    0.00    0.00   65.06
13:00:37       1    8.42    0.04    2.08   23.92    0.00    0.03    0.00    0.00    0.00   65.51
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] mpstat -P ALL</figcaption>
</figure>

CPU Core의 평균 사용률과 CPU Core별 사용률을 출력한다. [Shell 1]은 "mpstat -P ALL"을 이용하여 CPU Core의 평균 사용률과 CPU Core별 사용률을 출력하는 Shell의 모습을 나타내고 있다. 각 열의 의미는 아래와 같다.

* %usr : nice값이 적용되지 않은 Process들의 User Code를 구동하는데 이용한 CPU 사용률을 나타낸다. 대부분의 User Process들의 사용률을 의미한다.
* %nice : nice값이 적용된 Process들의 User Code들을 구동하는데 이용한 CPU 사용률을 나타낸다.
* %sys : Kernel Code를 구동하는데 이용한 CPU 사용률 중에서 id, wa, hi, si의 사용률/대기율 제외한 사용률을 의미한다.
* %iowait : I/O Wait로 인한 CPU 대기율을 나타낸다.
* %irq : 순수 Hardware Interrupt 처리를 위해 사용된 CPU 사용률을 나타낸다. Kernel의 Interrupt Flag를 Set만 하는 Top Havles 부분을 처리를 위한 CPU 사용률을 의미한다.
* %soft : Top Halves에서 Set한 Interrupt Flag에 따라서 실제 Interrupt를 처리하는 Bottom Havles의 CPU 사용률을 나타낸다.
* %steal : Kernel이 Hypervisor가 제어하는 가상 머신 안에서 동작할 때, Hypervisor나 다른 가상 머신에 의해서 사용을 뺏긴 CPU 사용률을 나타낸다.
* %guest : Hypervisor를 통해서 가상 머신을 구동하는 경우, nice값이 적용되지 않은 가상 머신의 vCPU를 구동하는데 이용한 CPU 사용률을 의미한다.
* %gnice : Hypervisor를 통해서 가상 머신을 구동하는 경우, nice값이 적용된 가상 머신의 vCPU를 구동하는데 이용한 CPU 사용률을 의미한다.
* %idle : I/O Wait를 제외한 CPU의 대기율를 나타낸다.

#### 1.2. # mpstat -P ALL [Interval] [Count]

[Interval] 간격으로 [Count] 횟수만큼 CPU 사용률을 출력한다.

### 2. 참조

* [https://linux.die.net/man/1/free](https://linux.die.net/man/1/free)
* [https://serverfault.com/questions/23433/in-linux-what-is-the-difference-between-buffers-and-cache-reported-by-the-f](https://serverfault.com/questions/23433/in-linux-what-is-the-difference-between-buffers-and-cache-reported-by-the-f)


