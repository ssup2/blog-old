---
title: Linux BPF (Berkeley Packet Filter) Network
category: Theory, Analysis
date: 2018-12-30T12:00:00Z
lastmod: 2018-12-30T12:00:00Z
comment: true
adsense: true
---

Network Type의 BPF를 분석한다.

### 1. Network Type BPF

![[그림 1] Network BPF Program Type]({{site.baseurl}}/images/theory_analysis/Linux_BPF_Network/BPF_Net_Type.PNG){: width="450px"}

[그림 1]는 Linux에서 제공하는 BPF Program Type 중에서 Network과 연관된 Type을 Kernel의 Network Stack과 함께 나타내고 있다. Network과 연관된 BPF Program Type에는 XDP, SCHED_CLS, SCHED_ACT, SOCKET_FILTER 4가지가 존재한다.

#### 1.1. XDP (eXpress Data Path)

XDP eBPF Program은 Network Device Driver 내부의 Hook에서 동작하는 eBPF에 적재되어 구동된다. XDP eBPF Program은 Software로 구성된 Network Stack에서 가장 낮은 Level에서 실행되는 eBPF Program이다. 따라서 시간당 가장 많은양의 Packet을 처리할 수 있는 eBPF Program이다. XDP eBPF Program은 Socket Buffer를 할당하기 전에 수행되기 때문에, XDP eBPF Program의 Input Type은 들어온 Packet의 값만을 알 수 있는 xdp_md 구조체를 이용한다. 사용할 수 있는 Kernel Helper Function도 제한적이다. XDP eBPF Program은 Packet을 가공하는 동작보다는 Packet Drop, Routing이 주요 목적인 eBPF Program이다. XDP eBPF Program의 실행결과는 다음과 같은 4가지만을 지원한다.

* XDP_DROP : 해당 Packet을 버린다.
* XDP_ABORTED : 해당 Packet을 버리고, trace_xdp_exception을 발생시킨다.
* XDP_PASS : 해당 Packet을 상위 Network Stack으로 넘긴다.
* XDP_TX : 해당 Packet을 들어온 Network Device로 반사한다.
* XDP_REDIRECT : 해당 Packet을 다른 Network Device로 넘긴다.

XDP eBPF Program은 Network Device Driver에서 동작하는 eBPF에 적재되어 구동되기 때문에, XDP를 지원하지 않는 Network Device Driver에서는 XDP eBPF Program을 구동할 수 없다. 제한적인 XDP eBPF Program의 구동환경은 XDP eBPF Program의 개발 및 Debugging을 힘들게 한다. 이러한 문제를 해결하기 위해 나온 XDP Type이 **Generic XDP**이다. Generic XDP eBPF Program는 Network Device Driver에서 구동되지 않고 Network Device Driver와 tc 사이에서 구동된다. 따라서 가상 Network Device를 포함한 어떠한 Network Device에서도 XDP eBPF Program을 구동 할 수 있다. Generic XDP가 나오면서 Network Device Driver안에서 구동되는 XDP Type은 **Native XDP**라고 불린다.

Generic XDP는 위에서 언급한 것 처럼 XDP 개발 및 Debugging을 위한 XDP Type이다. Generic XDP eBPF Program은 Native XDP eBPF Program에 비해서 높은 Network Stack에서 실행되는 만큼, Native XDP eBPF Program에 비해서 낮은 Packet 처리량을 갖는다. 또한 더 많은 Helper Function을 이용 할 수 있는 것도 아니다. 하지만 tc BPF Program 보다는 먼저 실행되기 때문에, Packet Drop같은 간단한 동작을 수행하는 경우 tc eBPF Program 보다는 Generic XDP eBPF Program을 이용하는 것이 좀더 유리하다.

#### 1.2. SCHED_CLS, SCHED_ACT

SCHED_CLS, SCHED_ACT BPF Program은 Packet이 Network Device에서 tc로 전달되는 Ingress, 또는 Packet이 tc에서 Network Device로 전달되는 Egress 경로의 Hook에서 동작하는 BPF에 적재되어 구동된다. cBFP, eBPF 둘다 지원한다. XDP eBPF Program보다는 상위 Layer에서 동작하기 때문에 시간당 Packet 처리량은 XDP eBPF Program 보다는 적지만, 좀더 다양한 Packet 처리가 가능하다.

SCHED_CLS, SCHED_ACT BPF Program의 Input Type은 Socket Buffer (\_\_sk_buff)이다. Socket Buffer를 바탕으로 XDP eBPF Program보다 좀더 다양한 Kernel Helper Function을 이용 할 수 있다. SCHED_CLS BPF Program의 실행결과는 classid 반환하고, SCHED_ACT BPF Program의 실행결과는 'TC_ACT_'으로 시작하는 Linux Kernel에 정의된 값을 반환한다.

* TC_ACT_SHOT : Ingress를 통해오는 Packet을 버리고 Socket Buffer를 해지한다. 따라서 Packet은 상위 Network Stack으로 전달되지 못한다.
* TC_ACT_STOLEN : Ingress를 통해오는 Packet을 소모하거나 Queuing한다. 따라서 Packet은 상위 Network Stack으로는 전달되지 못한다.
* TC_ACT_OK : Ingress에서는 해당 Packet을 통과시켜 Network Stack으로 넘기고, Egress에서는 해당 Packet을 Network Device에게 넘긴다.
* TC_ACT_REDIRECT : 해당 Packet을 동일 또는 다른 Network Device의 Ingress나 Engress로 전달한다.

#### 1.3. CGROUP_SOCK_ADDR

#### 1.4. CGROUP_SOCK

#### 1.5. CGROUP_SKB

#### 1.6. SOCK_REUSEPORT

#### 1.7. SOCK_OPS

#### 1.8. SOCKET_FILTER

SOCKET_FILTER BPF Program은 Socket Layer Hook에서 실행되는 BPF에 적재되어 구동된다. SOCKET_FILTER BPF Program은 Socket으로 들어오는 Packet을 필터링, 분류, 파싱하는 역활을 수행한다. 위에서 언급했던것 처럼 cBPF (SO_ATTACH_FILTER), eBPF (SO_ATTACH_BPF) 둘다 지원한다. SOCKET_FILTER BPF Program의 Input Type은 Socket Buffer (__sk_buff)이다. SOCKET_FILTER BPF Program의 실행결과는 기존의 cBPF Program의 반환값을 그대로 이용한다.

### 2. 참조

* [https://www.netronome.com/blog/bpf-ebpf-xdp-and-bpfilter-what-are-these-things-and-what-do-they-mean-enterprise/](https://www.netronome.com/blog/bpf-ebpf-xdp-and-bpfilter-what-are-these-things-and-what-do-they-mean-enterprise/)
* [https://wariua.github.io/facility/extended-bpf.html](https://wariua.github.io/facility/extended-bpf.html)
* [https://cilium.readthedocs.io/en/v1.0/bpf/?fbclid=IwAR38RyvJXSsuzWk1jaTOGR7OhlgvQezoIHRLuiUA4rG2fc-AA70yyQTvxOg#bpf-guide](https://cilium.readthedocs.io/en/v1.0/bpf/?fbclid=IwAR38RyvJXSsuzWk1jaTOGR7OhlgvQezoIHRLuiUA4rG2fc-AA70yyQTvxOg#bpf-guide)
* [http://man7.org/linux/man-pages/man2/bpf.2.html](http://man7.org/linux/man-pages/man2/bpf.2.html)
* [https://kccncna19.sched.com/event/Uae7](https://kccncna19.sched.com/event/Uae7)
