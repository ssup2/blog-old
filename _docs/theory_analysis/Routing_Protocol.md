---
title: Routing Protocol
category: Theory, Analysis
date: 2019-01-22T12:00:00Z
lastmod: 2019-01-22T12:00:00Z
comment: true
adsense: true
---

Routing Protocol을 Link State, Distance Vector, Path Vector로 분류하고 분석한다.

### 1. Link State

![]({{site.baseurl}}/images/theory_analysis/Routing_Protocol/Link_State.PNG){: width="400px"}

위의 그림은 Link State Protocol을 나타내고 있다. Link State Protocol에서 **모든 Router는 완전한 Network Topology 정보를 갖는다.** 각 Router는 Network Topology 정보를 바탕으로 모든 Router를 대상으로 **Dijkstra 알고리즘**을 활용하여 최단 경로를 찾고, Routing Table을 설정한다.

Network Topology를 구성하기 위해서 각 Router는 자신과 인접한 Router를 파악하고, Router의 Latency 및 Router와 연결된 Link의 Bandwidth 등을 고려하여 Router별 Cost를 계산한다. 그 후 Router는 자신이 파악한 Router 목록 및 Router별 Cost 정보를 자신과 연결된 모든 Router에게 전송하여 공유한다. 각 Router는 공유된 정보를 바탕으로 Network Topology를 파악한다. 만약 Link나 Router에 장애가 발생하여 Packet 전송이 불가능한 경우, 장애를 발견한 Router는 장애가 발생한 Link나 Router를 Network Topology에서 제거한뒤 변경된 Network Topology 정보를 다른 Router들에게 전달한다. 각 Router는 바뀐 Network Topology에 따라 Routing Table을 수정한다.

Link State Protocol에서 각 Router는 완전한 Network Topology 정보를 바탕으로 Packet Looping 현상을 방지 할 수있고, Packet Load Balancing 같은 정교한 Routing이 가능하게 만든다. 하지만 각 Router가 완전한 Network Topology를 알기 위해서는 Router 사이의 많은 정보 교환이 Link State Protocol의 가장 큰 단점이다. OSPF, IS-IS Protocol이 Link State 기반의 Protocol이다.

### 2. Distance Vector

![]({{site.baseurl}}/images/theory_analysis/Routing_Protocol/Distance_Vector.PNG){: width="700px"}

위의 그림은 Distance Vector Protocol을 나타내고 있다. Distance Vector Protocol에서 **각 Router는 오직 인접한 Router의 거리 및 Packet을 목적지 Router로 보내기 위한 경유 Router 정보 Table만 가지고 있다.** 전체 Network Topology 정보는 갖고 있지 않는다. 위의 그림에서 Router A는 Router E로 Packet을 보내기 위해서는 Router C와 Router D를 경유해서 보내야 한다. 따라서 Router A의 Routing Table에는 Router E로 Packet을 보낼때는 Router C로 Packet을 보내야 한다는 정보가 써있다. 거리는 Packet이 하나의 Router를 지날때 마다 1씩 증가한다. Packet이 Router A에서 Router E로 전달될 경우 Router C와 Router D, 2개의 Router를 경유하기 때문에 거리는 3가 된다.

각 Router는 완전한 Network Topology 정보를 알지 못하기 때문에 Network Topology에 따라서 순서대로 Router 사이의 최단 경로를 구하는 Dijkstra 알고리즘을 이용하지 못한다. 대신 각 Router와 인접한 Router의 거리 정보만으로 Router 사이의 최단 경로를 구하는 **Bellman-Ford 알고리즘**을 이용한다. 각 Router는 자신과 인접한 Router 및 거리 정보를 기록하고 Router끼리 교환하면서 Routing Table을 완성한다. 각 Router는 인접한 Router 목록 및 거리만을 알고 있으면 되기 때문에 Router 사이의 정보 교환양이 적다.

하지만 각 Router는 완전한 Network Topology를 알지 못하고 **인접한 Router의 정보에 의지**하는 알고리즘의 특징 때문에 Packet Looping 현상이 빈번하게 발생할 수 있고, 발생하더라도 발견하기 쉽지 않다. Distance Vector에서 빈번하게 발생하는 Count to Infinity 현상도 Packet Looping이다. Distance Vector RIP, EIGRP Protocol이 Distance Vector 기반의 Protocol이다.

#### 2.1. Count to Infinity

![]({{site.baseurl}}/images/theory_analysis/Routing_Protocol/Count_To_Infinity.PNG){: width="700px"}

Count to Infinity는 Distance Vector Protocol에서 빈번하게 발생 할 수 있는 Packet Looping 현상이다. 위의 그림은 Count to Infinity 현상을 나타내고 있다. Router C에 장애를 발견한 Router A는 Router Table을 수정하여 Packet이 Router C에게 전달되지 못하게 한다. 그 후 수정된 Routing Table 정보를 Router B에게 전달한다. Router B는 Router A로부터 받은 Routing Table 정보를 바탕으로 Router C의 거리를 1 증가시킨다. Router B의 Routing Table이 변경 되있기 때문에 Router B는 변경된 Routing Table 정보를 다시 Router A에게 전달한다. Router A는 Router B의 Routing Table 정보를 바탕으로 C의 거리를 1 증가 시킨다. Router A와 Router B의 Routing Table의 Router C의 거리값은 계속 증가하게 된다. Count to Infinity 문제를 가장 쉽게 해결하는 방법은 거리 값이 특정 값 이상으로 오르지 못하게 제한을 두는 방법이 있다.

### 3. Path Vector

![]({{site.baseurl}}/images/theory_analysis/Routing_Protocol/Path_Vector.PNG){: width="700px"}

위의 그림은 Path Vector Protocol을 나타내고 있다. Path Vector Protocol에서 각 Router는 특정 Router로 Packet을 보낼때 Packet이 경유하는 모든 Router들을 기록하여 Path 정보를 저장한다. 각 Router는 자신과 인접한 Router의 Path 정보를 기록하고 Router끼리 교환하면서 Routing Table을 완성한다. Path 정보를 교환하는 방식이기 때문에 Distance Vector보다는 많은 양의 정보를 Router끼리 교환해야 하지만 Path 정보를 바탕으로 Packet Looping 현상을 쉽게 얘방 및 감지 할 수 있다. BGP Protocol이 Path Vector 기반의 Protocol이다.

### 4. 참조

* [https://www.slideshare.net/ayyakathir/it6601-mobile-computing-55359646](https://www.slideshare.net/ayyakathir/it6601-mobile-computing-55359646)
* [https://www.slideshare.net/WayneJonesJnr/ch22-3361678](https://www.slideshare.net/WayneJonesJnr/ch22-3361678)
* [https://www.slideshare.net/vsharma87/internet-routing-protocols-fundamental-concepts-of-distancevector-and-linkstate-routing](https://www.slideshare.net/vsharma87/internet-routing-protocols-fundamental-concepts-of-distancevector-and-linkstate-routing)
* [https://www.quora.com/Why-is-Dijkstra-used-for-link-state-routing-and-Bellman-Ford-for-distance-vector-routing-Why-not-use-the-same](https://www.quora.com/Why-is-Dijkstra-used-for-link-state-routing-and-Bellman-Ford-for-distance-vector-routing-Why-not-use-the-same)
* [https://courses.cs.washington.edu/courses/cse461/18sp/slides/sections/section-6.pdf](https://courses.cs.washington.edu/courses/cse461/18sp/slides/sections/section-6.pdf)