---
title: Linux OOM Killer
category: Theory, Analysis
date: 2020-10-20T12:00:00Z
lastmod: 2020-10-20T12:00:00Z
comment: true
adsense: true
---

Linux의 OOM (Out of Memory) Killer를 분석한다.

### 1. Linux OOM Killer

Linux는 실제 물리 Memory보다 많은 양의 가상 Memory 공간을 생성하고 Process에게 할당 한다. 이러한 Memory 관리 정책을 Memory Overcommit이라고 명칭한다. 따라서 다수의 Process가 동시에 많은양의 Memory를 이용할 경우, 물리 Memory 공간이 부족현상이 발생할 수 있다. Linux의 Swap 기법은 물리 Memory 공간 부족시 Disk의 일부 영역을 Memory 처럼 활용하는 기법이다. 하지만 Swap 기법에 이용되는 Disk 영역인 Swap Space도 가득 찬다면, Linux는 더이상 Memory를 할당할 수 없게된다. **이럴때 Linux는 OOM (Out of Memory) Killer를 이용하여 기존의 동작중인 Process를 강제로 죽여 Memory를 확보하게 된다.**

{% highlight console %}
(node)# stress --vm 1 --vm-bytes 512M --vm-hang 0 &
[1] 2447
stress: info: [2447] dispatching hogs: 0 cpu, 0 io, 1 vm, 0 hdd
(node)# ps -ef | grep 2447
root      2447  2009  0 15:46 pts/1    00:00:00 stress --vm 1 --vm-bytes 512M --vm-hang 0
root      2449  2447  0 15:46 pts/1    00:00:00 stress --vm 1 --vm-bytes 512M --vm-hang 0
(node)# stress --vm 1 --vm-bytes 1024M --vm-hang 0 &
[2] 2476
stress: info: [2476] dispatching hogs: 0 cpu, 0 io, 1 vm, 0 hdd
(node)# ps -ef | grep 2476
root      2476  2009  0 15:47 pts/1    00:00:00 stress --vm 1 --vm-bytes 1024M --vm-hang 0
root      2478  2476  0 15:47 pts/1    00:00:00 stress --vm 1 --vm-bytes 1024M --vm-hang 0

(node)# cat /proc/2449/oom_score
76
(node)# cat /proc/2478/oom_score
152
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Badness Score 확인</figcaption>
</figure>

OOM Killer는 Process를 죽일때 임의의 Process를 죽이지 않고, Badness Score라고 불리는 점수가 높은 Process부터 죽인다. Badness Score는 Memory 사용량이 높을수록 같이 높아진다.

{% highlight console %}
(node)# cat /proc/2449/oom_score
76
(node)# echo -50 > /proc/2449/oom_score_adj
(node)# cat /proc/2449/oom_score
26
(node)# echo -100 > /proc/2449/oom_score_adj
(node)# cat /proc/2449/oom_score
0

(node)# cat /proc/2478/oom_score
152
(node)# echo 500 > /proc/2478/oom_score_adj
(node)# cat /proc/2478/oom_score
652
(node)# echo 900 > /proc/2478/oom_score_adj
(node)# cat /proc/2478/oom_score
1052
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] Badness Score 조정</figcaption>
</figure>

### 2. 참조

* [https://man7.org/linux/man-pages/man5/proc.5.html](https://man7.org/linux/man-pages/man5/proc.5.html)
* [https://lwn.net/Articles/761118/](https://lwn.net/Articles/761118/)
* [https://lwn.net/Articles/317814/](https://lwn.net/Articles/317814/)
* [https://dev.to/rrampage/surviving-the-linux-oom-killer-2ki9](https://dev.to/rrampage/surviving-the-linux-oom-killer-2ki9)
