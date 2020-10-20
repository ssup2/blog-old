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

{% highlight sh %}
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

{% highlight sh %}
# Badness Score 감소
(node)# cat /proc/2449/oom_score
76
(node)# echo -50 > /proc/2449/oom_score_adj
(node)# cat /proc/2449/oom_score
26
(node)# echo -100 > /proc/2449/oom_score_adj
(node)# cat /proc/2449/oom_score
0

# Badness Score 증가
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

Process의 Badness Score는 System 관리자가 조정할 수 있다. Process의 Badness Score를 조정하기 위해서는 **"/proc/[PID]/oom_score_adj"** 파일에 조정값을 적으면 된다. [Shell 2]는 Badness Score를 조정하는 과정을 나타내고 있다. Badness Score를 감소시키기 위해서는 "/proc/[PID]/oom_score_adj" 파일에 감소시키고 싶은 만큼 음수를 쓰면 된다. [Shell 2]의 Badness Score 감소 예제에서 처음에는 Badness Score가 76이었지만, "/proc/[PID]/oom_score_adj" 파일에 쓴 음수만큼 감소하는 것을 확인할 수 있다. Badness Score의 최소값은 0이기 때문에 0이하로는 내려가지 않는것도 확인할 수 있다.

반대로 Badness Score를 증가시키기 위해서는 "/proc/[PID]/oom_score_adj" 파일에 증가시키고 싶은 만큼 양수를 쓰면 된다. [Shell 2]의 Badness Score 증가 예제에서 처음에는 Bandness Score가 152이었지만, /proc/[PID]/oom_score_adj" 파일에 쓴 양수만큼 증가하는 것을 확인할 수 있다.

{: .newline }
> Final Badness Score = Original Badness Score + Adjust Score
> Original Badness Score : 0 <= Value <= 1000
> Adjust Score : 0 <= Value <= 1000
> Final Badness Score : 0 <= Value <= 2000 <br/>
<figure>
<figcaption class="caption">[공식 1] Badness Score 공식</figcaption>
</figure>

[공식 1]은 Badness Score를 구하는 과정을 나타내고 있다. 조정전 Badness Score는 최소 0부터 최대 1000의 값을 가질 수 있다. 조정값은 -1000에서 1000의 값을 가질 수 있다. 따라서 최종 Badness Score는 최대 2000까지 갖을수 있으며, 최소값은 정책상 0의 값을 가질 수 있다. **최종 Badness Score가 0이면 OOM Killer의 제거 대상에서 제외된다. 조정값을 -1000으로 설정하면 최종 Bandess Score는 반드시 0이기 때문에, OOM Killer의 제거 대상에서 제외된다. 최종 조정값이 1000이상인 경우, OOM 발생시 반드시 OOM Killer에 의해서 제거된다.**

{% highlight sh %}
# System Out of Memory
[ 2826.282883] Out of memory: Kill process 4070 (stress) score 972 or sacrifice child
[ 2826.289059] Killed process 4070 (stress) total-vm:8192780kB, anon-rss:7231748kB, file-rss:0kB, shmem-rss:0kB
[ 2826.635944] oom_reaper: reaped process 4070 (stress), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] OOM Killer Log</figcaption>
</figure>

OOM Killer가 Process를 죽일경우, 죽인 Process의 정보는 Kernel Log에 기록된다. Kernel Log는 "dmesg" 명령어 또는 "/var/log/syslog" 파일에서 확인할 수있다. [Shell 3]은 OOM Killer의 Log를 나타내고 있다.

#### 1.1. with Cgroup

Cgroup은 다수의 Process가 소속되어 있는 Process Group의 Resource 사용량을 제한하고 Monitoring하는 Linux의 기능이다. 주로 Container Process들의 Resource 사용량을 제한하기 위한 용도로 많이 이용되고 있다. Cgroup을 통해서 Process Group의 Memory 사용량을 제한할 수 있다. Cgroup에 소속되어 있는 Process Group의 총 Memory 사용량이 Cgroup의 허용된 Memory 용량보다 높은 경우, OOM Killer는 해당 Process Group에서 가장 많은 Memory 용량을 이용하고 있는 (Badness Score가 높은) Process부터 죽여서 Memory를 확보한다.

{% highlight sh %}
# Cgroup Out of Memory
[ 1869.151779] Memory cgroup out of memory: Kill process 27881 (stress) score 1100 or sacrifice child
[ 1869.155654] Killed process 27881 (stress) total-vm:8192780kB, anon-rss:7152284kB, file-rss:4kB, shmem-rss:0kB
[ 1869.434078] oom_reaper: reaped process 27881 (stress), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] OOM Killer Log</figcaption>
</figure>

[Shell 4]는 Cgroup에 소속되어 있는 Process가 Cgroup의 허용된 Memory 사용량보다 많은 Memory를 이용하여 OOM Killer가 Process를 죽일 경우 발생하는 Kernel Log를 나타내고 있다. Kernel Log에서 OOM Killer가 Cgroup의 Memory 제한 설정 때문에 Process를 죽였다는걸 확인할 수 있다. Cgroup 단위로 OOM Killer를 적용하지 않도록 설정할 수도 있다. Cgroup v2를 이용할 수 있는 Linux Kernel Version부터는 Cgroup을 인지하는 OOM Killer를 이용할 수 있다. Cgroup을 인지하는 OOM Killer는 총 Memory 사용량이 가장 높은 Process Group 찾아내고, Process Group의 모든 Process를 죽일수 있다.

### 2. 참조

* [https://man7.org/linux/man-pages/man5/proc.5.html](https://man7.org/linux/man-pages/man5/proc.5.html)
* [https://www.kernel.org/doc/Documentation/cgroup-v1/memory.txt](https://www.kernel.org/doc/Documentation/cgroup-v1/memory.txt)
* [https://lwn.net/Articles/761118/](https://lwn.net/Articles/761118/)
* [https://lwn.net/Articles/317814/](https://lwn.net/Articles/317814/)
* [https://dev.to/rrampage/surviving-the-linux-oom-killer-2ki9](https://dev.to/rrampage/surviving-the-linux-oom-killer-2ki9)
* [https://www.scrivano.org/posts/2020-08-14-oom-group/](https://www.scrivano.org/posts/2020-08-14-oom-group/)