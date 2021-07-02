---
title: Linux BPF (Berkeley Packet Filter) Network Program Type
category: Theory, Analysis
date: 2018-12-30T12:00:00Z
lastmod: 2018-12-30T12:00:00Z
comment: true
adsense: true
---

Network BPF Program Type의 BPF를 분석한다.

### 1. Network BPF Program Type

![[그림 1] Network BPF Program Type]({{site.baseurl}}/images/theory_analysis/Linux_BPF_Network/BPF_Net_Type.PNG){: width="450px"}

[그림 1]는 Linux에서 제공하는 BPF Program Type 중에서 Network과 연관된 Type을 Kernel의 Network Stack과 함께 나타내고 있다. Network Stack별로 다양한 Type의 BPF Program이 존재하며 앞으로도 계속 추가될 예정이다. [그림 1]은 Kernel Version v5.13을 기준으로 하고 있다.

#### 1.1. Device Driver, BPF_PROG_TYPE_XDP

Device Driver 내부에서 동작하는 BPF Program Type은 BPF_PROG_TYPE_XDP Type만 존재한다. 일반적으로 **XDP** (Express Data Path)라고 명칭한다. Network BPF Program Type 중에서 가장 낮은 Level에서 실행되는 Type이다. 따라서 Ingress 기준 시간당 가장 많은 Packet을 처리하는 Type이다. eBPF만을 지원한다.

BPF_PROG_TYPE_XDP Type은 Socket Buffer를 할당하기 전에 수행되기 때문에, XDP eBPF Program의 Input Type은 들어온 Packet의 Data만을 알 수 있는 xdp_md 구조체를 이용한다. 사용할 수 있는 Kernel Helper Function도 제한적이다. XDP eBPF Program은 Packet을 가공하는 동작보다는 Packet Drop, Routing이 주요 목적인 eBPF Program이다. XDP eBPF Program의 실행결과는 다음과 같은 5가지만을 지원한다.

* XDP_DROP : 해당 Packet을 버린다.
* XDP_ABORTED : 해당 Packet을 버리고, trace_xdp_exception을 발생시킨다.
* XDP_PASS : 해당 Packet을 상위 Network Stack으로 넘긴다.
* XDP_TX : 해당 Packet을 들어온 Network Device를 통해서 외부로 전송한다.
* XDP_REDIRECT : 해당 Packet을 다른 Network Device로 넘긴다.

BPF_PROG_TYPE_XDP Type은 Network Device Driver에서 동작하는 eBPF에 적재되어 구동되기 때문에, XDP를 지원하지 않는 Network Device Driver에서는 XDP eBPF Program을 구동할 수 없다. 제한적인 XDP eBPF Program의 구동 환경은 BPF_PROG_TYPE_XDP Type Program의 개발 및 Debugging을 힘들게 한다.

이러한 문제를 해결하기 위해 나온 XDP Type이 **Generic XDP**라고 불리는 기법이다. Generic XDP는 Network Device Driver와 tc 사이에 eBPF를 위치시키고 BPF_PROG_TYPE_XDP type Program을 적재시키는 기법이다. Generic XDP를 통해서 가상 Network Device를 포함한 어떠한 Network Device에서도 Network Device에서도 XDP eBPF Program을 구동 할 수 있다. Generic XDP가 나오면서 기존의 Network Device Driver에서 구동시키는 기법은 Program은 **Native XDP**라고 불린다.

Generic XDP 기법은 위에서 언급한 것 처럼 XDP 개발 및 Debugging을 위한 기법이다. Generic XDP 기법이 Native XDP 기법에 비해서 높은 Network Stack에서 실행되는 만큼, Ingress 기준 Native XDP 기법에 비해서 낮은 Packet 처리량을 갖는다. 또한 더 많은 Helper Function을 이용 할 수 있는 것도 아니다. 하지만 tc Layer에서 동작하는 BPF Program 보다는 먼저 실행되기 때문에, Ingress Packet의 Drop같은 간단한 동작을 수행하는 경우 tc Layer에서 동작하는 BPF Program 보다는 Generic XDP 기법을 이용하는 것이 좀더 유리하다.

#### 1.2. tc (Traffic Control)

tc BPF Program Type은 tc Layer에 존재하는 BPF에서 동작하는 Type이다. 모든 tc BPF Program Type은 Input으로 Socket Buffer (\_\_sk_buff)를 받는다. Socket Buffer 및 Socket Buffer를 활용한 Helper Function을 통해서 BPF_PROG_TYPE_XDP Type보다는 다양한 Packet 처리가 가능하다. BPF_PROG_TYPE_SCHED_ACT, BPF_PROG_TYPE_SCHED_CLS Type이 존재한다.

##### 1.2.1. BPF_PROG_TYPE_SCHED_ACT

BPF_PROG_TYPE_SCHED_ACT Type은 Packet을 Drop, Forwarding 같은 Packet 처리 역활을 수행한다. Ingress/Egress 둘다 처리가 가능하며, eBPF/cBPF 둘다 지원한다. 'TC_ACT_'으로 시작하는 Linux Kernel에 정의된 값을 반환한다.

* TC_ACT_OK : Ingress에서는 해당 Packet을 통과시켜 Network Stack으로 넘기고, Egress에서는 해당 Packet을 Network Device에게 넘긴다.
* TC_ACT_SHOT : Ingress를 통해오는 Packet을 버리고 Socket Buffer를 해지한다. 따라서 Packet은 상위 Network Stack으로 전달되지 못한다.
* TC_ACT_STOLEN : Ingress를 통해오는 Packet을 소모하거나 Queuing한다. 따라서 Packet은 상위 Network Stack으로는 전달되지 못한다.
* TC_ACT_REDIRECT : 해당 Packet을 동일 또는 다른 Network Device의 Ingress나 Egress로 전달한다.

##### 1.2.2. BPF_PROG_TYPE_SCHED_CLS

BPF_PROG_TYPE_SCHED_CLS Type은 Packet에 classid를 설정하는 역활을 수행한다. 따라서 classid를 반환한다. Ingress/Egress 둘다 처리가 가능하며, eBPF/cBPF 둘다 지원한다. BPF_PROG_TYPE_SCHED_CLS Type은 **direct-action** 이라고 불리는 기법을 이용할 수 있다. direct-action 기법을 이용하면 BPF_PROG_TYPE_SCHED_CLS Type도 BPF_PROG_TYPE_SCHED_ACT Type과 같이 Packet 처리가 가능하다. 즉 BPF_PROG_TYPE_SCHED_ACT과 같이 'TC_ACT_'으로 시작하는 Linux Kernel에 정의된 값을 반환할 수 있다.

BPF_PROG_TYPE_SCHED_CLS Type은 BPF_PROG_TYPE_SCHED_ACT Type보다 먼저 실행되기 때문에 Packet 처리는 direct-action 기법을 이용하여 BPF_PROG_TYPE_SCHED_CLS Type에서 수행하는 것이 성능상 이점을 얻을 수 있다.

#### 1.3. cgroup

cgroup BPF Program Type은 각 Cgroup마다 존재하는 BPF에서 동작하는 Type이다. cgroup BPF Program Type은 오직 해당 cgroup에 포함되어 있는 Process들의 Packet만 처리한다. 해당 cgroup에 포함되어 있지 않는 Process들의 Packet은 처리하지 않는다. 따라서 특정 Process Group에게만 BPF Program을 적용하고 싶으면 cgroup BPF Program Type과 cgroup을 이용하면 된다. BPF_PROG_TYPE_CGROUP_SKB, BPF_PROG_TYPE_CGROUP_SOCK, BPF_PROG_TYPE_CGROUP_SOCK_ADDR, BPF_PROG_TYPE_CGROUP_SOCKOPT Type이 존재한다.

##### 1.3.1. BPF_PROG_TYPE_CGROUP_SKB 

BPF_PROG_TYPE_CGROUP_SKB Type은 cgroup에 포함되어 있는 Process의 Ingress/Egress Packet을 Filtering하는 역할을 수행한다. eBPF만 지원한다.

##### 1.3.2. BPF_PROG_TYPE_CGROUP_SOCK

BPF_PROG_TYPE_CGROUP_SOCK Type은 cgroup에 포함되어 있는 Process가 Socket을 생성, 삭제, Binding하는 경우 호출되어 동작을 허용할지를 결정하는 역활을 수행한다. Socket 관련 통계 정보를 얻을때도 이용가능하다. eBPF만 지원한다.

##### 1.3.3. BPF_PROG_TYPE_CGROUP_SOCK_ADDR

BPF_PROG_TYPE_CGROUP_SOCK_ADDR Type은 cgroup에 포함되어 있는 Process가 connect(), bind(), sendto(), recvmsg() System Call을 호출하는 경우 호출되어 Socket의 IP, Port를 변경하는 역활을 수행한다. eBPF만 지원한다.

##### 1.3.4. BPF_PROG_TYPE_CGROUP_SOCKOPT

BPF_PROG_TYPE_CGROUP_SOCKOPT Type은 cgroup에 포함되어 있는 Process가 setsockopt(), getsockopt() System Call을 호출하여 Socket Option을 변경하는 경우 호출되어 Socket Option을 변경하는 역활을 수행한다. eBPF만 지원한다.

#### 1.4. Socket

Socket BPF Program Type은 각 Socket마다 존재하는 eBPF에서 동작하는 Type이다. BPF_PROG_TYPE_SOCKET_FILTER, BPF_PROG_TYPE_SOCK_OPS, BPF_PROG_TYPE_SK_SKB, BPF_PROG_TYPE_SK_MSG, BPF_PROG_TYPE_SK_REUSEPORT, BPF_PROG_TYPE_SK_LOOKUP Type이 존재한다.

##### 1.4.1. BPF_PROG_TYPE_SOCKET_FILTER

BPF_PROG_TYPE_SOCKET_FILTER Type은 Socket의 Ingress/Egress Packet을 Filtering 하는 역활을 수행한다. cBPF (SO_ATTACH_FILTER), eBPF (SO_ATTACH_BPF) 둘다 지원한다.

##### 1.4.2. BPF_PROG_TYPE_SOCK_OPS

BPF_PROG_TYPE_SOCKET_FILTER Type은 Process가 Socket을 제어하는 과정중 여러번 호출되어 Socket을 제어하는 역활을 수행한다. eBPF만 지원한다.

##### 1.4.3. BPF_PROG_TYPE_SK_SKB

BPF_PROG_TYPE_SK_SKB Type은 Socket이 수신하는 각각의 Packet을 Drop하거나 다른 Socket으로 전송하는 역활을 수행한다.

##### 1.4.4. BPF_PROG_TYPE_SK_MSG

BPF_PROG_TYPE_SK_MSG Type은 Socket이 송신하는 각각의 Packet에 대해서 허용/거부를 결정하는 역활을 수행한다.

##### 1.4.5. BPF_PROG_TYPE_SK_REUSEPORT

BPF_PROG_TYPE_SK_REUSEPORT Type은 Process가 Socket을 bind() System Call을 통해서 Binding 할때 호출된다. BPF_PROG_TYPE_SK_REUSEPORT Type을 통해서 다수의 Process가 하나의 Port를 Binding하여 이용하는 것이 가능하다.

##### 1.4.6. BPF_PROG_TYPE_SK_LOOKUP

BPF_PROG_TYPE_SK_LOOKUP Type은 수신한 Packet을 어느 Socket에서 수신하게 할지 결정하는 역활을 수행한다. 

### 2. 참조

* [https://blogs.oracle.com/linux/post/bpf-a-tour-of-program-types](https://blogs.oracle.com/linux/post/bpf-a-tour-of-program-types)
* [https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_networking/assembly_understanding-the-ebpf-features-in-rhel_configuring-and-managing-networking](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_networking/assembly_understanding-the-ebpf-features-in-rhel_configuring-and-managing-networking)
* [https://elixir.bootlin.com/linux/latest/source/include/uapi/linux/bpf.h](https://elixir.bootlin.com/linux/latest/source/include/uapi/linux/bpf.h)
* [https://qmonnet.github.io/whirl-offload/2020/04/11/tc-bpf-direct-action/](https://qmonnet.github.io/whirl-offload/2020/04/11/tc-bpf-direct-action/)
* [https://cilium.readthedocs.io/en/v1.0/bpf/?fbclid=IwAR38RyvJXSsuzWk1jaTOGR7OhlgvQezoIHRLuiUA4rG2fc-AA70yyQTvxOg#bpf-guide](https://cilium.readthedocs.io/en/v1.0/bpf/?fbclid=IwAR38RyvJXSsuzWk1jaTOGR7OhlgvQezoIHRLuiUA4rG2fc-AA70yyQTvxOg#bpf-guide)
* [http://man7.org/linux/man-pages/man2/bpf.2.html](http://man7.org/linux/man-pages/man2/bpf.2.html)
* [https://kccncna19.sched.com/event/Uae7](https://kccncna19.sched.com/event/Uae7)
