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
# stress 명령어를 이용하여 512MB, 1024MB를 이용하는 Child Process생성
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

# stress 명령어의 Child Process의 Badness Score 확인
(node)# cat /proc/2449/oom_score
76
(node)# cat /proc/2478/oom_score
152
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] Badness Score 확인</figcaption>
</figure>

OOM Killer는 Process를 죽일때 임의의 Process를 죽이지 않고, Badness Score라고 불리는 점수가 높은 Process부터 죽인다. Badness Score는 Memory 사용량이 높을수록 같이 높아진다. 각 Process의 Badness Score는 **"/proc/[PID]/oom_score"** 파일에서 확인 할 수 있다. [Shell 1]은 stress 명령어를 활용하여 Memory 사용량에 따른 Badness Score를 확인하는 과정을 나타내고 있다. 첫번째 stress 명령어는 512MB의 Memory를 이용하는 Child Process를 생성하고, 두번째 stress 명령어는 1024MB의 Memory를 이용하는 Child Process를 생성한다. 두번째 stress 명령어의 Child Process가 첫번째 stress 명령어의 Child Process보다 2배의 Memory를 더 많이 이용하는 만큼, Badness Score도 2배가 차이나는것을 확인할 수 있다.

Memory 사용량 뿐만 아니라 Badness Score에 영향을 주는 요소가 존재한다. 다음의 요소는 Badness Score를 줄이는 요소이다. 

* Privileged Process (root User Process)
* 오랜 시간동안 동작한 Process
* Hardware에 직접 접근하는 Process

다음의 요소들은 Badness Score를 올리는 요소이다.

* 많은 Child Process를 생성한 Process
* 낮은 nice 값을 갖는 Process

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

Process의 Badness Score는 System 관리자가 조정할 수 있다. Process의 Badness Score를 조정하기 위해서는 **"/proc/[PID]/oom_score_adj"** 파일에 조정값을 적으면 된다. [Shell 2]는 Badness Score를 조정하는 과정을 알 수 있다.

### 2. 참조

* [https://man7.org/linux/man-pages/man5/proc.5.html](https://man7.org/linux/man-pages/man5/proc.5.html)
* [https://lwn.net/Articles/761118/](https://lwn.net/Articles/761118/)
* [https://lwn.net/Articles/317814/](https://lwn.net/Articles/317814/)
* [https://dev.to/rrampage/surviving-the-linux-oom-killer-2ki9](https://dev.to/rrampage/surviving-the-linux-oom-killer-2ki9)
