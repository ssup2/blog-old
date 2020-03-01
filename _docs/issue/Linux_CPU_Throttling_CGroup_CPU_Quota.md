---
title: Linux CPU Throttling with CGroup CPU Quota
category: Issue
date: 2020-01-21T12:00:00Z
lastmod: 2020-01-21T12:00:00Z
comment: true
adsense: true
---

### 1. Issue

Multi Core Machine에서 CGroup CPU Quota를 통해 CPU 사용량이 제한된 Process가 CPU 사용량이 Quota에 도달하지 않았는데도 Throttling되어 CPU를 제대로 이용하지 못하는 Issue가 존재한다.

### 2. 해결 방안

Linux Kernel의 Process Scheduler의 문제이기 때문에 Kernel Upgrade를 통해서 해결해야 한다. 다음과 같은 Linux Kernel Version을 이용하면 Issue를 해결할 수 있다. Kernel Upgrade가 힘들다면 CPU Quota 값을 원하는 값보다 높게 설정하거나 CPU Quota 기능을 이용하지 않는 방식으로 CPU Throttling Issue를 우회할 수 있다.

* Linux mainline
  * Apply to 5.4
* Linux stable
  * 4.14.154+, 4.19.84+, 5.3.9+
* Distro Linux Kernel
  * Ubuntu 16.04 : 4.15.0-67+
  * Ubuntu 18.04 : 5.3.0-24+
  * RHEL7 : 3.10.0-1062.8.1.el7
  * RHEL8.2 : WIP

### 3. 참조

* [https://sched.co/Uae1](https://sched.co/Uae1)
* [https://github.com/kubernetes/kubernetes/issues/70585](https://github.com/kubernetes/kubernetes/issues/70585)
