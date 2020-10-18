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

OOM Killer는 Process를 죽일때 임의의 Process를 죽이지 않고, Badness Score라고 불리는 점수가 높은 Process부터 죽인다. Badness Score는 Process가 이용가능한 Memory에 비해서 실제 이용하고 있는 Memory 양이 높을수록 점수가 높아진다. 따라서 무조건 Memory 사용량이 높은 Process의 Badness Score가 높지는 않으며, 두 Process가 동일한 Memory를 이용하고 있더라도 각 Process에게 할당된 이용가능한 Memory 용량이 다르다면 Badness Score도 다르게 된다.

### 2. 참조

* [https://man7.org/linux/man-pages/man5/proc.5.html](https://man7.org/linux/man-pages/man5/proc.5.html)
* [https://lwn.net/Articles/761118/](https://lwn.net/Articles/761118/)
* [https://lwn.net/Articles/317814/](https://lwn.net/Articles/317814/)
* [https://dev.to/rrampage/surviving-the-linux-oom-killer-2ki9](https://dev.to/rrampage/surviving-the-linux-oom-killer-2ki9)
