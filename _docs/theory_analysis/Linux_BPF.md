---
title: Linux BPF
category: Theory, Analysis
date: 2018-12-30T12:00:00Z
lastmod: 2018-12-30T12:00:00Z
comment: true
adsense: true
---

Linux의 BPF (Berkeley Packet Filter)를 분석한다.

### 1. BPF (Berkeley Packet Filter)

BPF (Berkeley Packet Filter)는 **Unix-like Kernel 안**에서 Bytecode에 따라서 동작하는 경량화된 **VM (Virtual Machine)**이다. 현재 Linux에서 BPF를 지원하고 있다. BPF에서 동작하는 Program은 BPF ByteCode로 Compile 된 후에 **Userspace Process의 요청**에 의해서 BPF에 적재되는 형태로 구동된다. 따라서 Kernel을 이용하는 User들은 필요에 따라서 BPF Program을 개발하고, 개발한 BPF Program을 BPF에 적재하여 BPF를 이용 할 수 있다.

#### 1.1. cBPF (Classic BPF), eBPF (Extended BPF)

![]({{site.baseurl}}/images/theory_analysis/Linux_BPF/cBPF_eBPF.PNG)

BPF는 의미 그대로 처음에는 Network Packet을 Filtering하는 Program을 구동하는 용도의 VM이었다. 하지만 BPF에 다양한 용도의 Program이 구동 될 필요가 생기자 Linux에서는 기존의 BPF를 확장한 **eBPF** (Extend BPF)를 정의하였고 Linux Kernel안에 eBPF가 실행되는 **Hook**을 곳곳에서 만들어 eBPF를 구동 할 수 있도록 지원하고 있다. eBPF가 등장하면서 기존의 BPF는 **cBPF** (Classic BPF)라고 불린다. 위의 그림은 cBPF와 eBPF를 나타내고 있다.

cBPF에서는 2개의 32bit Register와 메모리 역활을 수행하는 16개의 32bit Scratch Pad만을 이용 할 수 있었다. 하지만 eBPF에서는 11개의 64bit Register, 512개의 8bit Stack, Key-Value를 저장할 수 있는 무제한의 Map을 이용 할 수 있다. Bytecode도 추가되어 eBPF에서는 Kernel이 eBPF 지원을 위해 제공하는 **Kernel Helper Function**을 호출하거나 다른 eBPF Program을 호촐 할 수도 있게 되었다. 이처럼 eBPF는 cBPF보다 많은 리소스 및 기능을 이용 할 수 있기 때문에 cBPF보다 다양한 기능의 Program을 구동 할 수 있다.

현재 Linux에서는 BPF가 실행되는 Hook에 따라서 cBPF, eBPF 지원여부가 달라진다. Linux Kernel에서 bpf() System Call이 추가되기 이전에 존재했던 BPF는 cBPF라고 할 수 있다. Socket() System Call의 SO_ATTACH_FILTER Option이나 Seccomp() System Call의 SECCOMP_SET_MODE_FILTER Option을 통해 이용하던 BPF는 cBPF이다.

현재 Linux Kernel에서 Socket() System Call의 경우 eBPF를 이용하는 SO_ATTACH_BPF Option이 추가되었다. 물론 하위 호환성을 위해서 SO_ATTACH_FILTER Option도 여전히 제공한다. 하지만 SO_ATTACH_FILTER Option을 이용하더라도 내부적으로는 bpf() System Call을 이용하여 cBPF Bytecode를 eBPF Bytecode를 변경한뒤 eBPF에 적재한다. Seccomp() System Call의 경우에는 cBPF만을 지원하지만, 현재 eBPF 지원을 위한 개발이 진행중이다.

bpf() System Call이 추가된 Linux 3.18 Version 이후에 추가된 BPF는 모두 eBPF라고 보면된다. 이러한 대부분의 eBPF는 eBPF Bytecode로 Compile된 eBPF Program만을 지원한다.

#### 1.2. BPF Compile, bpf() System Call

![]({{site.baseurl}}/images/theory_analysis/Linux_BPF/Compile_bpf_Syscall.PNG){: width="650px"}

위의 그림은 eBPF Program의 Compile 과정과 bpf() System Call의 동작을 나타내고 있다. LLVM/clang은 Backend로 eBPF를 지원한다. 개발자가 작성한 eBPF Source Code는 LLVM/clang을 통해서 eBPF Bytecode로 Compile된다. 그 후 eBPF Bytecode는 tc나 iproute2같은 App(명령어)를 이용해 Kernel의 eBPF에 적재된다. eBPF Bytecode의 적재는 bpf() System Call을 통해 이루어진다.

eBPF Bytecode는 Kernel Level에서 동작하기 때문에 잘못 작성된 eBPF Bytecode은 System 전체에 큰영향을 줄 수 있다. 따라서 Kernel은 eBPF Bytecode를 적재전에 Verifier로 eBPF Bytecode에 이상이 없는지 검사한다. Verifier는 eBPF Bytecode가 허용되지 않은 Memory 영역을 참조하는지 검사하고, 무한 Loop가 발생하는지도 검사한다. 검사가 완료된 eBPF Bytecode의 일부는 필요에 따라 JIT (Just-in-time) Compiler를 통해서 Native Code로 변환되어 Kernel에서 동작한다.

bpf() System Call은 eBPF Bytecode 적재 뿐만 아니라 App이 eBPF가 이용하는 Map에 접근할 수 있게 만들어준다. 따라서 App과 eBPF는 Map을 이용하여 통신을 할 수 있다. eBPF와 App사이의 통신은 eBPF가 더욱 다양한 기능을 수행 할 수 있도록 만든다.

#### 1.3. BPF Type

![]({{site.baseurl}}/images/theory_analysis/Linux_BPF/BPF_Hook.PNG){: width="600px"}

BPF Hook은 Kernel에서 BPF가 실행되는 지점을 의미한다. Linux에서는 Hook에 따라서 eBPF를 **eBPF Type**으로 구분한다. 위의 그림은 eBPF Type들을 분류해서 나타낸 그림이다. Network 부분에는 Socket, tc(traffic control), XDP (eXpress Data Path) 관련 Type을 지원하고 있다. Tracing, Monitoring 부분에서는 Perf event, Tracepoint, Kprobe/Uprobe 관련 Type을 지원하고 있다. 또한 Cgroup 관련 Type도 지원하고 있다. 앞으로 더욱 많은 eBPF Type(Hook)이 추가될 예정이다.

eBPF Type은 Hook에 따라 정의되기 때문에 eBPF Type에 따라서 eBPF으로 들어오는 Input Type이 정해지게 된다. 또한 BPF Type은 eBPF가 호출 할 수 있는 Kernel Helper Function을 제한한다. 따라서 eBPF는 eBPF Type에 따라서 수행할 수 있는 기능이 제한된다. Linux Kernel의 Verifier는 eBPF Bytecode를 적재시 eBPF Type을 검사하고 해당 eBPF Bytecode가 허용된 Kernel Helper Function만을 호출하는지 검사한다. 만약 허용되지 않는 Kernel Helper Function을 호출할 경우 해당 eBPF Bytecode의 적재는 실패한다.

### 2. Network Type

![]({{site.baseurl}}/images/theory_analysis/Linux_BPF/BPF_Net_Type.PNG){: width="400px"}

위의 그림은 Linux에서 제공하는 eBPF의 주요 Network Type을 Network Stack과 함께 나타내고 있다.

#### 2.1. XDP (eXpress Data Path)

XDP Type BPF는 Network Device Driver에서 동작하는 eBPF이다. Network Device가 Packet을 수신한뒤, 수신한 Packet을 저장하는 Socket Buffer (sk_buff)를 할당하기전에 실행되는 BPF이다. 따라서 시간당 가장 많은양의 Packet을 처리 할 수 있는 eBPF이다. Socket Buffer를 할당하기 전에 수행되는 eBPF이기 때문에 Input Type은 들어온 Packet의 값만을 알 수 있는 xdp_md 구조체를 이용한다. 사용할 수 있는 Kernel Helper Function도 제한적이다. XDP Type BPF의 실행결과는 다음과 같은 4가지 결과만을 지원한다. XDP Type BPF는 Packet을 가공하거나 하는 동작보다는 Packet Drop, Routing이 주요 목적인 eBPF이다.

* XDP_DROP - 해당 Packet을 버린다.
* XDP_PASS - 해당 Packet을 상위 Network Stack으로 넘긴다.
* XDP_TX - 해당 Packet을 들어온 Network Device로 반사한다.
* XDP_REDIRECT - 해당 Packet을 다른 Network Device로 넘긴다.

#### 2.2. SCHED_CLS, SCHED_ACT

SCHED_CLS, SCHED_ACT Type의 BPF는 tc로 Packet이 들어오는 Ingress 또는 tc로 Packet이 나가는 Egress 경로에서 실행되는 BPF이다. cBFP, eBPF 둘다 지원한다. XDP Type보다는 상위 Layer의 BPF이기 때문에 시간당 Packet 처리량은 XDP Type의 BPF보다는 적지만 좀더 다양한 Packet 처리가 가능하다. SCHED_CLS, SCHED_ACT Type의 Input Type은 Socket Buffer (__sk_buff)이다. Socket Buffer를 바탕으로 XDP Type보다 좀더 다양한 Kernel Helper Function을 이용 할 수 있다. SCHED_CLS Type BPF의 실행결과는 classid 반환하고, SCHED_ACT Type BPF의 실행결과는 'TC_ACT_'으로 시작하는 Linux Kernel에 정의된 값을 반환한다.

* TC_ACT_SHOT - 해당 Packet을 버린다.
* TC_ACT_OK - 해당 Packet을 상위 Network Stack으로 넘긴다.
* TC_ACT_REDIRECT - 해당 Packet을 특정 Network Device로 넘긴다.

#### 2.3. SOCKET_FILTER

Socket Layer에 붙어서 Socket으로 들어오는 Packet을 필터링, 분류, 파싱하는 역활을 수행하는 BPF이다. 위에서 언급했던것 처럼 cBPF (SO_ATTACH_FILTER), eBPF (SO_ATTACH_BPF) 둘다 지원한다. SOCKET_FILTER Type의 Input Type은 Socket Buffer (__sk_buff)이다. SOCKET_FILTER Type의 실행결과는 기존의 cBPF의 반환값을 그대로 이용한다.

### 3. 참조

* [https://www.netronome.com/blog/bpf-ebpf-xdp-and-bpfilter-what-are-these-things-and-what-do-they-mean-enterprise/](https://www.netronome.com/blog/bpf-ebpf-xdp-and-bpfilter-what-are-these-things-and-what-do-they-mean-enterprise/)
* [https://wariua.github.io/facility/extended-bpf.html](https://wariua.github.io/facility/extended-bpf.html)
* [https://cilium.readthedocs.io/en/v1.0/bpf/?fbclid=IwAR38RyvJXSsuzWk1jaTOGR7OhlgvQezoIHRLuiUA4rG2fc-AA70yyQTvxOg#bpf-guide](https://cilium.readthedocs.io/en/v1.0/bpf/?fbclid=IwAR38RyvJXSsuzWk1jaTOGR7OhlgvQezoIHRLuiUA4rG2fc-AA70yyQTvxOg#bpf-guide)
* [https://github.com/iovisor/bcc/blob/master/docs/kernel-versions.md](https://github.com/iovisor/bcc/blob/master/docs/kernel-versions.md)
* [https://www.slideshare.net/lcplcp1/xdp-and-ebpfmaps](https://www.slideshare.net/lcplcp1/xdp-and-ebpfmaps)
* [http://media.frnog.org/FRnOG_28/FRnOG_28-3.pdf](http://media.frnog.org/FRnOG_28/FRnOG_28-3.pdf)
* [http://man7.org/linux/man-pages/man2/bpf.2.html](http://man7.org/linux/man-pages/man2/bpf.2.html)