---
title: Linux BPF
category: Theory, Analysis
date: 2018-12-27T12:00:00Z
lastmod: 2018-12-27T12:00:00Z
comment: true
adsense: true
---

### 1. BPF (Berkeley Packet Filter)

BPF (Berkeley Packet Filter)는 **Unix-like Kernel 안**에서 Bytecode에 따라서 동작하는 **VM (Virtual Machine)**이다. BPF에서 동작하는 Program은 BPF ByteCode로 Compile 된 후에 **Userspace Process의 요청**에 의해서 BPF에 적재되는 형태로 구동된다. 따라서 Kernel을 이용하는 User들은 필요에 따라서 BPF Program을 작성하여 BPF를 이용 할 수 있다.

#### 1.1. cBPF (Classic BPF), eBPF (Extended BPF)

![]({{site.baseurl}}/images/theory_analysis/Linux_BPF/cBPF_eBPF.PNG)

BPF는 의미 그대로 처음에는 Network Packet을 Filtering하는 Program을 구동하는 용도의 VM이었다. 하지만 BPF에 다양한 용도의 Program이 구동 될 필요가 생기자 Linux에서는 기존의 BPF를 확장한 eBPF (Extend BPF)를 정의하였고 Linux Kernel 곳곳에서 eBPF를 구동 할 수 있도록 지원하고 있다. eBPF가 등장하면서 기존의 BPF는 cBPF (Classic BPF)라고 불린다. 위의 그림은 cBPF와 eBPF를 나타내고 있다.

cBPF에서는 2개의 32bit Register와 메모리 역활을 수행하는 16개의 32bit Scratch Pad만을 이용 할 수 있었다. 하지만 eBPF에서는 11개의 64bit Register, 512개의 8bit Stack, Key-Value를 저장할 수 있는 무제한의 Map을 이용 할 수 있다. Bytecode도 추가되어 eBPF에서는 Kernel이 eBPF 지원을 위해 제공하는 Kernel Helper Function을 호출하거나 다른 eBPF Program을 호촐 할 수도 있게 되었다. 이처럼 eBPF는 cBPF보다 많은 리소스 및 기능을 이용 할 수 있기 때문에 cBPF보다 다양한 기능의 Program을 구동 할 수 있다.

Linux에서는 eBPF만을 제공할 뿐 cBPF를 제공하지 않는다. 그 대신 Linux에서는 cBPF Bytecode로 Compile된 cBPF Program을 eBPF에 적재시 eBPF Bytecode로 변환하여 cBPF Program을 구동한다.

#### 1.2. Compile, bpf()

![]({{site.baseurl}}/images/theory_analysis/Linux_BPF/Compile_bpf_Syscall.PNG){: width="650px"}

위의 그림은 eBPF Program의 Compile 과정과 bpf() System Call의 동작을 나타내고 있다. LLVM/clang은 Backend로 eBPF를 지원한다. 개발자가 작성한 eBPF Program은 LLVM/clang을 통해서 eBPF Bytecode로 Compile된다. 그후 Compile된 eBPF Program은 tc나 iproute2같은 App(명령어)를 이용해 Kernel의 eBPF에 적재된다.  eBPF Program의 적재는 bpf() System Call을 통해 이루어진다.

#### 1.3. Hooks

![]({{site.baseurl}}/images/theory_analysis/Linux_BPF/BPF_Hook.PNG){: width="600px"}

위의 그림은 eBPF가 실행될 수 있는 eBPF Hook들을 나타내고 있다. Network 부분에는 Socket, tc(traffic control) 및 아래서 설명할 XDP (eXpress Data Path) Hook을 지원하고 있다. Tracing, Monitoring 부분에서는 Perf event, Tracepoint, Kprobe/Uprobe에서도 eBPF Hook을 지원하고 있다. 또한 Container가 이용하는 Cgroup에서도 eBPF Hook을 지원하고 있다. 더욱 중요한 점은 계속해서 eBPF Hook이 추가될 예정이라는 점이다.

### 2. BPF Network Hook

### 3. 참조

* [https://www.netronome.com/blog/bpf-ebpf-xdp-and-bpfilter-what-are-these-things-and-what-do-they-mean-enterprise/](https://www.netronome.com/blog/bpf-ebpf-xdp-and-bpfilter-what-are-these-things-and-what-do-they-mean-enterprise/)
* [http://media.frnog.org/FRnOG_28/FRnOG_28-3.pdf](http://media.frnog.org/FRnOG_28/FRnOG_28-3.pdf)