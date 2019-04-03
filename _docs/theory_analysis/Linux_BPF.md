---
title: Linux BPF (Berkeley Packet Filter)
category: Theory, Analysis
date: 2018-12-30T12:00:00Z
lastmod: 2018-12-30T12:00:00Z
comment: true
adsense: true
---

Linux의 BPF (Berkeley Packet Filter)를 분석한다.

### 1. BPF (Berkeley Packet Filter)

BPF (Berkeley Packet Filter)는 Unix-like OS의 **Kernel Level**에서 Bytecode에 따라 동작하는 경량화된 **VM (Virtual Machine)**이다. BPF는 의미 그대로 처음에는 Network Packet을 Filtering하는 Program을 구동하는 용도의 VM이었다. 하지만 사용자가 원하는 기능을 수행하는 Program을 언제든지 Kernel Level에서 구동 할 수 있다는 BPF의 장점 때문에 BPF는 꾸준히 발전하였고, 현재는 다양한 기능을 수행하는 VM이 되었다. 현재 Linux에서도 BPF를 지원하고 있다.

#### 1.1. cBPF (Classic BPF), eBPF (Extended BPF)

![[그림 1] cBPF, eBPF]({{site.baseurl}}/images/theory_analysis/Linux_BPF/cBPF_eBPF.PNG)

[그림 1]은 cBPF (Classic BPF)와 eBPF (Extended BPF)를 나타내고 있다. BPF가 다양한 기능을 수행하면서 BPF가 갖고있는 매우 제한된 Resource는 큰 걸림돌이 되었다. 이러한 BPF의 Resource 문제를 해결하기 위해서 Linux는 더 많은 Resource와 기능을 이용할 수 있는 **eBPF** (Extened BPF)를 정의하였다. eBPF를 정의하면서 기존의 BPF는 **cBPF** (Classic BPF)라고 불린다.

cBPF에서는 2개의 32bit Register와 메모리 역활을 수행하는 16개의 32bit Scratch Pad만을 이용 할 수 있었다. 하지만 eBPF에서는 11개의 64bit Register, 512개의 8bit Stack, Key-Value를 저장할 수 있는 무제한의 Map을 이용 할 수 있다. 또한 실행할 수 있는 Bytecode도 추가되어 eBPF에서는 Kernel이 eBPF 지원을 위해 제공하는 **Kernel Helper Function**을 호출하거나 다른 eBPF Program을 호촐할 수 있다. 이처럼 eBPF는 cBPF보다 많은 리소스 및 기능을 이용 할 수 있기 때문에 cBPF보다 다양한 기능의 Program을 구동 할 수 있다.

현재 Linux에서는 cBPF, eBPF 둘다 이용하고 있으며, BPF가 실행되는 지점인 **Hook**과 Kernel Version에 따라서 어떤 BPF가 이용될지 결정된다. bpf() System Call이 추가된 Kernel Version은 3.18인데, 3.18 이전 Version의 BPF는 모두 cBPF이다. 예를들어 Socket() System Call의 SO_ATTACH_FILTER Option이나 Seccomp() System Call의 SECCOMP_SET_MODE_FILTER Option을 통해 이용하던 BPF는 모두 cBPF였다. 3.18 이후 Version에 추가된 BPF는 모두 eBPF이다. eBPF가 도입되면서 cBPF는 현재 일부에서만 이용되고 있고 추후 eBPF가 cBPF를 완전히 대체하게될 예정이다.

현재 Linux에서 Socket() System Call의 경우 eBPF를 이용하는 SO_ATTACH_BPF Option이 추가되었다. 물론 하위 호환성을 위해서 SO_ATTACH_FILTER Option도 여전히 제공한다. 하지만 SO_ATTACH_FILTER Option을 이용하더라도 내부적으로는 bpf() System Call을 이용하여 cBPF Bytecode를 eBPF Bytecode를 변경한뒤 eBPF에 적재한다. Seccomp() System Call의 경우에는 아직도 cBPF만을 지원하지만, 현재 eBPF 지원을 위한 개발이 진행중이다.

#### 1.2. eBPF Program Compile, bpf() System Call

![[그림 2] eBPF Program Compile, bpf() System Call]({{site.baseurl}}/images/theory_analysis/Linux_BPF/Compile_bpf_Syscall.PNG){: width="650px"}

[그림 2]는 eBPF Program의 Compile 과정과 bpf() System Call의 동작을 나타내고 있다. LLVM/clang은 Backend로 eBPF를 지원한다. 개발자가 작성한 eBPF Source Code는 LLVM/clang을 통해서 eBPF Bytecode로 Compile된다. 그 후 eBPF Bytecode는 tc나 iproute2같은 eBPF 관리 App(Tool)을 이용해 Kernel의 eBPF에 적재된다. eBPF 관리 App은 내부적으로 bpf() System Call을 이용하여 eBPF에 eBPF Bytecode를 적재한다.

eBPF Bytecode는 Kernel Level에서 동작하기 때문에 잘못 작성된 eBPF Bytecode은 System 전체에 큰영향을 줄 수 있다. 따라서 Kernel은 eBPF Bytecode를 적재전에 Verifier로 eBPF Bytecode에 이상이 없는지 검사한다. Verifier는 eBPF Bytecode가 허용되지 않은 Memory 영역을 참조하는지 검사하고, 무한 Loop가 발생하는지도 검사한다. 또한 허용되지 않은 Kernel Helper Function을 호출했는지도 검사한다. 검사를 통과못한 eBPF Bytecode는 적재에 실패한다. 검사를 통과한 eBPF Bytecode는 eBPF에 적재되어 동작한다. 필요에 따라 eBPF Bytecode의 일부는 JIT (Just-in-time) Compiler를 통해서 Native Code로 변환되어 Kernel에서 동작한다.

bpf() System Call은 eBPF Bytecode 적재 뿐만 아니라 App이 eBPF가 이용하는 Map에 접근할 수 있게 만들어준다. 따라서 App과 eBPF는 Map을 이용하여 통신을 할 수 있다. eBPF와 App사이의 통신은 eBPF가 더욱 다양한 기능을 수행 할 수 있도록 만든다.

#### 1.3. BPF Program Type

![[그림 3] eBPF Program Type]({{site.baseurl}}/images/theory_analysis/Linux_BPF/eBPF_Program_Type.PNG){: width="600px"}

**BPF Program Type은 BPF Program이 어느 Hook에서 실행 될지를 결정한다.** 따라서 BPF Program Type은 BPF Program의 Input Type과 Input Data를 결정한다. 또한 BPF Program Type은 BPF Program이 호출할 수 있는 Kernel Helper Function을 결정한다. [그림 3]은 eBPF Program Type을 나타내고 있다. 앞으로 Kernel에 더욱 많은 Hook이 추가되는 만큼 eBPF Program Type도 추가될 예정이다.

### 2. Network Type

![[그림 4] Network BPF Program Type]({{site.baseurl}}/images/theory_analysis/Linux_BPF/BPF_Net_Type.PNG){: width="500px"}

[그림 4]는 Linux에서 제공하는 BPF Program Type 중에서 Network과 연관된 Type을 Kernel의 Network Stack과 함께 나타내고 있다. Network과 연관된 BPF Program Type에는 XDP, SCHED_CLS, SCHED_ACT, SOCKET_FILTER 4가지가 존재한다.

#### 2.1. XDP (eXpress Data Path)

XDP eBPF Program은 Network Device Driver 내부의 Hook에서 동작하는 eBPF에 적재되어 구동된다. XDP eBPF Program은 Software로 구성된 Network Stack에서 가장 낮은 Level에서 실행되는 eBPF Program이다. 따라서 시간당 가장 많은양의 Packet을 처리할 수 있는 eBPF Program이다.

XDP eBPF Program은 Socket Buffer를 할당하기 전에 수행되기 때문에, XDP eBPF Program의 Input Type은 들어온 Packet의 값만을 알 수 있는 xdp_md 구조체를 이용한다. 사용할 수 있는 Kernel Helper Function도 제한적이다. XDP eBPF Program의 실행결과는 다음과 같은 4가지 결과만을 지원한다. XDP eBPF Program은 Packet을 가공하는 동작보다는 Packet Drop, Routing이 주요 목적인 eBPF Program이다.

* XDP_DROP - 해당 Packet을 버린다.
* XDP_ABORTED - 해당 Packet을 버리고, trace_xdp_exception을 발생시킨다.
* XDP_PASS - 해당 Packet을 상위 Network Stack으로 넘긴다.
* XDP_TX - 해당 Packet을 들어온 Network Device로 반사한다.
* XDP_REDIRECT - 해당 Packet을 다른 Network Device로 넘긴다.

XDP eBPF Program은 Network Device Driver에서 동작하는 eBPF에 적재되어 구동되기 때문에, XDP를 지원하지 않는 Network Device Driver에서는 XDP eBPF Program을 구동할 수 없다. 제한적인 XDP eBPF Program의 구동환경은 XDP eBPF Program의 개발 및 Debugging을 힘들게 한다. 이러한 문제를 해결하기 위해 나온 XDP Type이 **Generic XDP**이다. Generic XDP eBPF Program는 Network Device Driver에서 구동되지 않고 Network Device Driver와 tc 사이에서 구동된다. 따라서 가상 Network Device를 포함한 어떠한 Network Device에서도 XDP eBPF Program을 구동 할 수 있다. Generic XDP가 나오면서 Network Device Driver안에서 구동되는 XDP Type은 **Native XDP**라고 불린다.

Generic XDP는 위에서 언급한 것 처럼 XDP 개발 및 Debugging을 위한 XDP Type이다. Generic XDP eBPF Program은 Native XDP eBPF Program에 비해서 높은 Network Stack에서 실행되는 만큼, Native XDP eBPF Program에 비해서 낮은 Packet 처리량을 갖는다. 또한 더 많은 Helper Function을 이용 할 수 있는 것도 아니다. 하지만 tc BPF Program 보다는 먼저 실행되기 때문에, Packet Drop같은 간단한 동작을 수행하는 경우 tc eBPF Program 보다는 Generic XDP eBPF Program을 이용하는 것이 좀더 유리하다.

#### 2.2. SCHED_CLS, SCHED_ACT

SCHED_CLS, SCHED_ACT BPF Program은 Packet이 Network Device에서 tc로 전달되는 Ingress, 또는 Packet이 tc에서 Network Device로 전달되는 Egress 경로의 Hook에서 동작하는 BPF에 적재되어 구동된다. cBFP, eBPF 둘다 지원한다. XDP eBPF Program보다는 상위 Layer에서 동작하기 때문에 시간당 Packet 처리량은 XDP eBPF Program 보다는 적지만, 좀더 다양한 Packet 처리가 가능하다. 

SCHED_CLS, SCHED_ACT BPF Program의 Input Type은 Socket Buffer (\_\_sk_buff)이다. Socket Buffer를 바탕으로 XDP eBPF Program보다 좀더 다양한 Kernel Helper Function을 이용 할 수 있다. SCHED_CLS BPF Program의 실행결과는 classid 반환하고, SCHED_ACT BPF Program의 실행결과는 'TC_ACT_'으로 시작하는 Linux Kernel에 정의된 값을 반환한다.

* TC_ACT_SHOT - Ingress를 통해오는 Packet을 버리고 Socket Buffer를 해지한다. 따라서 Packet은 상위 Network Stack으로 전달되지 못한다.
* TC_ACT_STOLEN - Ingress를 통해오는 Packet을 소모하거나 Queuing한다. 따라서 Packet은 상위 Network Stack으로는 전달되지 못한다.
* TC_ACT_OK - Ingress에서는 해당 Packet을 통과시켜 Network Stack으로 넘기고, Egress에서는 해당 Packet을 Network Device에게 넘긴다.
* TC_ACT_REDIRECT - 해당 Packet을 동일 또는 다른 Network Device의 Ingress나 Engress로 전달한다.

#### 2.3. SOCKET_FILTER

SOCKET_FILTER BPF Program은 Socket Layer Hook에서 실행되는 BPF에 적재되어 구동된다. SOCKET_FILTER BPF Program은 Socket으로 들어오는 Packet을 필터링, 분류, 파싱하는 역활을 수행한다. 위에서 언급했던것 처럼 cBPF (SO_ATTACH_FILTER), eBPF (SO_ATTACH_BPF) 둘다 지원한다. SOCKET_FILTER BPF Program의 Input Type은 Socket Buffer (__sk_buff)이다. SOCKET_FILTER BPF Program의 실행결과는 기존의 cBPF Program의 반환값을 그대로 이용한다.

### 3. 참조

* [https://www.netronome.com/blog/bpf-ebpf-xdp-and-bpfilter-what-are-these-things-and-what-do-they-mean-enterprise/](https://www.netronome.com/blog/bpf-ebpf-xdp-and-bpfilter-what-are-these-things-and-what-do-they-mean-enterprise/)
* [https://wariua.github.io/facility/extended-bpf.html](https://wariua.github.io/facility/extended-bpf.html)
* [https://cilium.readthedocs.io/en/v1.0/bpf/?fbclid=IwAR38RyvJXSsuzWk1jaTOGR7OhlgvQezoIHRLuiUA4rG2fc-AA70yyQTvxOg#bpf-guide](https://cilium.readthedocs.io/en/v1.0/bpf/?fbclid=IwAR38RyvJXSsuzWk1jaTOGR7OhlgvQezoIHRLuiUA4rG2fc-AA70yyQTvxOg#bpf-guide)
* [https://github.com/iovisor/bcc/blob/master/docs/kernel-versions.md](https://github.com/iovisor/bcc/blob/master/docs/kernel-versions.md)
* [https://www.slideshare.net/lcplcp1/xdp-and-ebpfmaps](https://www.slideshare.net/lcplcp1/xdp-and-ebpfmaps)
* [https://www.slideshare.net/lcplcp1/introduction-to-ebpf-and-xdp](https://www.slideshare.net/lcplcp1/introduction-to-ebpf-and-xdp)
* [https://prototype-kernel.readthedocs.io/en/latest/blogposts/xdp25_eval_generic_xdp_tx.html](https://prototype-kernel.readthedocs.io/en/latest/blogposts/xdp25_eval_generic_xdp_tx.html)
* [https://www.slideshare.net/TaeungSong/bpf-xdp-8-kosslab](https://www.slideshare.net/TaeungSong/bpf-xdp-8-kosslab)
* [http://media.frnog.org/FRnOG_28/FRnOG_28-3.pdf](http://media.frnog.org/FRnOG_28/FRnOG_28-3.pdf)
* [http://man7.org/linux/man-pages/man2/bpf.2.html](http://man7.org/linux/man-pages/man2/bpf.2.html)