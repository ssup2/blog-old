---
title: Golang Garbage Collector
category: Theory, Analysis
date: 2021-01-18T12:00:00Z
lastmod: 2021-01-18T12:00:00Z
comment: true
adsense: true
---

Golang의 Garbage Collector을 분석한다.

### 1. Golang Garbage Collector

Golang의 Runtime에는 Heap Memory를 관리하는 역활을 수행하는 Garbage Collector가 존재한다. Golang의 Garbage Collector는 단순히 **TCMalloc Memory Allocator**를 기반으로 하는 **CMS(Concurrent Mark and Swap)** 기법만을 이용하여 Garbage Collection을 수행한다. Heap Memory 영역의 단편화를 막기 위한 Compaction 기법이나, Garbage Colleciton을 수행하면서 발생하는 Heap Memory 영역의 Scan을 최소화 하기 위한 Generation 기법은 적용하여 이용하고 있지 않다.

Heap Memory 영역의 단편화는 Heap Memory를 어떻게 할당 하냐에 따라서 최소화시킬 수 있다. Golang에서는 TCMalloc Memory Allocator가 Heap Memory 영역의 단편화를 최소화하면서 빠르게 Memory를 할당하고 있다고 간주하고 있다. 따라서 Golang에서는 Memory 단편화를 큰 문제로 보고 있지 않는다.

Heap Memory 영역의 Scan 최소화를 위한 위한 Generation 기법은 Golang에서도 초반에는 도입을 고려하였지만, 현재까지 Generation 기법은 Golang에 적용되지 않았다. Golang의 Compiler는 좋은 Escape 분석 성능을 바탕으로 짧은 수명을 갖는 Memory 공간을 Heap이 아닌 Stack에 할당한다. 이를 통해서 짧은 수명을 갖는 Heap Memory 공간으로 인한 Garbage Collection의 부하를 줄이고 있다. 따라서 Golang에는 Generation 기법을 도입하여도 큰 이점을 얻을수 있다고 판단하고 있다.

또한 Generation 기법의 Write Barrier의 복잡성 및 최적화의 어려움에 비해서 Generation 기법도 충분히 빠르다고 판단하고 있지 않기 때문에, Golang에 아직까지 Generation 기법이 적용되고 있지 않고 있다.

#### 1.1. Tunning

### 2. 참조

* [https://engineering.linecorp.com/ko/blog/detail/342/](https://engineering.linecorp.com/ko/blog/detail/342/)
* [https://aidanbae.github.io/video/gogc/](https://aidanbae.github.io/video/gogc/)
* [https://groups.google.com/g/golang-nuts/c/KJiyv2mV2pU](https://groups.google.com/g/golang-nuts/c/KJiyv2mV2pU)
* [http://goog-perftools.sourceforge.net/doc/tcmalloc.html](http://goog-perftools.sourceforge.net/doc/tcmalloc.html)