---
title: Proxy Server
category: Theory, Analysis
date: 2017-01-23T14:35:00Z
lastmod: 2022-07-14T14:35:00Z
comment: true
adsense: true
---

Forward Proxy와 Reverse Proxy를 분석한다.

### 1. Proxy

![[그림 1] Forward Proxy, Reverse Proxy]({{site.baseurl}}/images/theory_analysis/Proxy_Server/Proxy.PNG)

Proxy Server는 Server, Client 관계에서 Server 또는 Client를 대신하는 역할을 수행하는 Component를 의미한다. Proxy Server는 Client의 요청을 Server 대신 받은 다음, 받은 요청을 Server에게 대신 전달하고, 대신 Server의 응답을 받는다. 이후에 Client에게 Server로부터 받은 응답을 다시 전달하는 방식으로 동작한다. Proxy Server는 어디에 위치하는지에 따라서 Forward Proxy아 Reverse Proxy로 분류할 수 있다. [그림 1]은 Forward Proxy와 Reverse Proxy를 나타내고 있다.

### 1.1. Forward Proxy

Forward Proxy는 다수의 Client의 역할을 대신 수행하는 **Client Side Proxy**를 의미한다. Forward Proxy의 주요 역할은 **Server 응답 Caching**이다. Forward Proxy는 Client의 요청을 받으면 요청을 Server로 전달하기 전에 자신의 Cache에 Server의 유효한 응답이 있는지 검색한다. 만약 Cache에 유효한 응답이 존재하면 Forward Proxy는 Cache로 부터 Server의 응답을 얻어 Client에게 전달한다. 만약 Cache에 유효한 응답이 존재하지 않는다면 Client의 요청을 Server에 전달하여 Server로부터 응답을 받은 다음, 받은 응답을 Caching하고 활용한다.

Forward Proxy의 Server 응답 Caching을 통해서 네트워크 사용량을 줄이고, Client가 빠른 응답을 받을 수 있도록 만든다. 또한 Server의 부하도 경감시키는 역할을 수행한다.

### 1.2. Reverse Proxy

Reverse Proxy는 다수의 Server의 역할을 대신 수행하는 **Server Side Proxy**를 의미한다. Forward Proxy의 주요 역할은 **Server Load Balancing**과 **Server 응답 Caching**이다. Reverse Proxy는 Server Load Balancing을 통해서 Client 요청을 다수의 Server에 골고루 분배하여 Server의 부하를 분산 시키고, 일부 Server가 동작하지 않더라도 Client의 요청을 동작하는 Server에게만 전달하여 Server의 고가용성을 제공한다. 또한 필요에 따라서 Forward Proxy처럼 Server 응답 Caching 역할도 수행가능하다.

### 2. 참조

* [http://www.jscape.com/blog/bid/87783/Forward-Proxy-vs-Reverse-Proxy](http://www.jscape.com/blog/bid/87783/Forward-Proxy-vs-Reverse-Proxy)
