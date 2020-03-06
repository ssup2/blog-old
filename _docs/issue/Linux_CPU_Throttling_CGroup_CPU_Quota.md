---
title: Linux CPU Throttling with CGroup CPU Quota
category: Issue
date: 2020-01-21T12:00:00Z
lastmod: 2020-01-21T12:00:00Z
comment: true
adsense: true
---

### 1. Issue

Multi Core Machine에서 CGroup CPU Quota를 통해 CPU 사용량이 제한된 Process가 CPU 사용량이 Quota에 도달하지 않았는데도 Throttling되어 CPU를 제대로 이용하지 못하는 Issue가 존재한다. Container의 CPU 사용률을 제한하기 위해서 CGroup CPU Quota가 이용된다. 따라서 Container를 이용하는 모든 환경에서 해당 Issue가 적용될 수 있다.

### 2. 해결 방안

Linux Kernel의 Process Scheduler의 문제이기 때문에 다음의 3개의 Patch가 적용된 Linux Kernel을 이용해야 한다.

* [https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=512ac999](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=512ac999)
* [https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=de53fd7aedb](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=de53fd7aedb)
* [https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=763a9ec06c4](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=763a9ec06c4)

Patch가 적용된 Kernel Version은 다음과 같다.

* Linux Stable
  * 5.4+
* Linux Longterm
  * 4.14.154+, 4.19.84+, 5.4+
* Distro Linux Kernel
  * Ubuntu : 4.15.0-67+
  * Centos7 : 3.10.0-1062.8.1.el7+

Kernel Upgrade가 힘들다면 CPU Quota 값을 원하는 값보다 높게 설정하거나 CPU Quota 기능을 이용하지 않는 방식으로 CPU Throttling Issue를 우회할 수 있다.

### 3. 참조

* [https://sched.co/Uae1](https://sched.co/Uae1)
* [https://github.com/kubernetes/kubernetes/issues/70585](https://github.com/kubernetes/kubernetes/issues/70585)
