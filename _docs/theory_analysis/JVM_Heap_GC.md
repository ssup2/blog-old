---
title: JVM Heap, GC (Garbage Collection)
category: Theory, Analysis
date: 2017-01-16T12:00:00Z
lastmod: 2017-01-16T12:00:00Z
comment: true
adsense: true
---

### 1. JVM Heap

![]({{site.baseurl}}/images/theory_analysis/JVM_Heap_GC/JVM_Heap.PNG){: width="500px"}

JVM Heap은 주로 new 문법으로 할당된 Object(Instance)들이 위치하는 Memory 영역이다. JVM Heap은 그게 Young Generation, Old Generation, Permanment 3가지 영역으로 나누어진다. Young Generation은 생성된지 오래 되지 않은 Object들이 위치하는 영역이고, Old Generation은 생성된후 여러번의 GC 동작 후에도 살아남아 존재하는 Object들이 위치하는 영역이다.

Permanent 영역은 Static Object, String Object, Class Meta, Method Meta, JIT Meta 정보 등이 저장되는 공간이다. Permanent 영역은 GC의 영역이 아니다. 또한 Java8 Version에서는 Permanent 영역이 존재하지 않기 때문에 본 글에서는 상세히 다루지 않는다.

![]({{site.baseurl}}/images/theory_analysis/JVM_Heap_GC/JVM_Heap_Option.PNG){: width="600px"}

위의 그림은 JVM Heap 관련 Option들을 나타내고 있다. 옵션을 통해 각 영역의 크기를 다양하게 설정 가능하다. -Xms은 JVM 시작시 Heap Size, -Xmx은 최대 Heap Size를 의미한다.

### 2. Garbage Collector

#### 2.1. Serial, Parallel, CMS

#### 2.2. G1

### 3. Object Reachability

### 4. 참조

* [http://d2.naver.com/helloworld/1329](http://d2.naver.com/helloworld/1329)
* [http://d2.naver.com/helloworld/329631](http://d2.naver.com/helloworld/329631)
* Java 8 Perm - [https://yckwon2nd.blogspot.kr/2015/03/java8-permanent.html](https://yckwon2nd.blogspot.kr/2015/03/java8-permanent.html)
* G1 - [http://www.oracle.com/technetwork/tutorials/tutorials-1876574.html](http://www.oracle.com/technetwork/tutorials/tutorials-1876574.html)
