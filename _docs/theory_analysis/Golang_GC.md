---
title: Golang Garbage Collection
category: Theory, Analysis
date: 2021-01-18T12:00:00Z
lastmod: 2021-01-18T12:00:00Z
comment: true
adsense: true
---

Golang의 Garbage Collection을 분석한다.

### 1. Golang Garbage Collection

Golang의 Runtime에는 Heap Memory를 관리하는 역활을 수행하는 Garbage Collector가 존재한다. Golang의 Garbage Collector는 **TCMalloc Memory Allocator**를 기반으로 하는 **CMS(Concurrent Mark and Swap)** 기법만을 이용하여 비교적 단순하게 Garbage Collection을 수행한다. Heap Memory 영역의 단편화를 막기 위한 Compaction 기법이나, Garbage Colleciton을 수행하면서 발생하는 Heap Memory 영역의 Scan을 최소화 하기 위한 Generation 기법은 적용하여 이용하고 있지 않다.

Heap Memory 영역의 단편화는 Heap Memory를 어떻게 할당 하냐에 따라서 최소화시킬 수 있다. Golang에서는 TCMalloc Memory Allocator가 Heap Memory 영역의 단편화를 최소화하면서 빠르게 Memory를 할당하고 있다고 간주하고 있다. 따라서 Golang에서는 Memory 단편화를 큰 문제로 보고 있지 않는다.

Heap Memory 영역의 Scan 최소화를 위한 위한 Generation 기법은 Golang에서도 초반에는 도입을 고려하였지만, 현재까지 Generation 기법은 Golang에 적용되지 않았다. Golang의 Compiler는 좋은 Escape 분석 성능을 바탕으로 짧은 수명을 갖는 Memory 공간을 Heap이 아닌 Stack에 할당한다. 이를 통해서 짧은 수명을 갖는 Heap Memory 공간으로 인한 Garbage Collection의 부하를 줄이고 있다. 따라서 Golang에는 Generation 기법을 도입하여도 큰 이점을 얻을수 있다고 판단하고 있다.

또한 Generation 기법의 Write Barrier의 복잡성 및 최적화의 어려움에 비해서 Generation 기법도 충분히 빠르다고 판단하고 있지 않기 때문에, Golang에 아직까지 Generation 기법이 적용되고 있지 않고 있다.

#### 1.1. Tunning

![[그림 1] GOGC]({{site.baseurl}}/images/theory_analysis/Golang_GC/GOGC.PNG)

Golang은 "GOGC" 환경변수를 통해서 Garbarge Collector의 Garbage Collection 수행 시기를 어느정도 제어할 수 있다. GOGC 환경변수에 설정하는 값은 이전에 Garbage Collection 수행후에도 제거되지 않고 남아서 이용되는 Heap Memory 공간의 용량과 Heap Memory에 새롭개 할당된 공간의 용량의 비율을 나타낸다.

[그림 1]은 GOGC 환경변수에 따른 Garbage Collection 수행을 나타내고 있다. GOGC 환경변수 값이 100일때 Garbage Collection을 수행하고 제거되지 않고 이용되는 Heap Memory 공간이 50MB라면, 이후에 Heap Memory 공간에 50MB를 더 할당 하게되면 다시 Garbage Collection을 수행한다. 만약 GOGC 값이 200이라면 Heap Memory 공간에 100MB를 더 할당 하게되면 다시 Garbage Collection을 수행한다.

이처럼 GOGC 환경변수 값이 높을수록 Garbage Collection을 수행하는 빈도는 낮아지게 된다. 만약 한번만 실행되고 종료되는 Batch Job 처럼 Garbage Collection이 불필요하다면 GOGC 환경변수를 "off"로 설정하여 Garbage Collection이 수행되지 않도록 설정할 수 있다.

### 2. 참조

* [https://engineering.linecorp.com/ko/blog/detail/342/](https://engineering.linecorp.com/ko/blog/detail/342/)
* [https://aidanbae.github.io/video/gogc/](https://aidanbae.github.io/video/gogc/)
* [https://groups.google.com/g/golang-nuts/c/KJiyv2mV2pU](https://groups.google.com/g/golang-nuts/c/KJiyv2mV2pU)
* [http://goog-perftools.sourceforge.net/doc/tcmalloc.html](http://goog-perftools.sourceforge.net/doc/tcmalloc.html)
* [https://golang.org/pkg/runtime/debug/#SetGCPercent](https://golang.org/pkg/runtime/debug/#SetGCPercent)