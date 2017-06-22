---
title: Linux LSM(Linux Security Module)
category:
date: 2017-01-14T12:00:00Z
lastmod: 2017-01-15T12:00:00Z
comment: true
adsense: true
---

Linux의 Security Framework인 LSM(Linux Security Module)을 분석한다.

### 1. LSM(Linux Security Module)

<img src="{{site.baseurl}}/images/theory_analysis/Linux_LSM/Linux_LSM_Framework.PNG" width="500px">

LSM은 Linux안에서 다양한 Security Module들의 구동 환경을 제공해주는 Security Framework이다. 현재 Linux의 Capability, SELinux, AppArmor, smack들의 기법들은 모두 LSM을 이용하고 있다.

Linux Document에는 LSM을 Framework라고 명시하지만, 실제로 LSM은 Linux Kernel Code 곳곳에 **Hook**을 넣어 Linux Kernel이 Security Module의 함수를 호출할 수 있게 만드는 **Interface** 역활만을 수행한다. 따라서 LSM은 Security 정책은 전적으로 Security Module에 의존하게 된다.

<img src="{{site.baseurl}}/images/theory_analysis/Linux_LSM/Linux_LSM_Query.PNG" width="500px">

위의 그림은 LSM의 실제 동작을 간략하게 나타내고 있다. Linux Kernel은 Application이나 Device의 여러 요청들을 처리하면서 중간중간 LSM의 Hook을 만나게 된다. Linux Kernel은 Hook을 거치면서 Security Module의 Hook Function을 수행한다. 수행 결과는 오직 YES/No로 받는다. Yes를 받계 되면 계속해서 요청을 처리하고, No를 받게 되면 요청 처리를 멈춘다.

LSM 위에 올라가는 Security Module은 lsmod 명령으로 조회가능한 Loadable Module이 아니이다. 따라서 Security Module은 반드시 Kernel Compile시 같이 Compile되어야 한다. 일부 Security Module은 같이 Compile 되었어도 Booting 설정을 통해 이용하지 않을 수 있다.

### 1.1. LSM Module Stack

### 2. 참조

<img src="{{site.baseurl}}/images/theory_analysis/Virtual_Machine_Linux_Container/Linux_Container.PNG" width="500px">

![]({{site.baseurl}}/images/theory_analysis/KVM_QEMU/QEMU_non-iothread.PNG)

* QEMU - [http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html](http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html)
