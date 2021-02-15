---
title: Nginx Architecture
category: Theory, Analysis
date: 2020-08-20T12:00:00Z
lastmod: 2020-08-20T12:00:00Z
comment: true
adsense: true
---

Nginx의 Architecture를 분석한다.

### 1. Nginx Architecture

![[그림 1] Nginx Architecture]({{site.baseurl}}/images/theory_analysis/Nginx_Architecture/Nginx_Architecture.PNG)

[그림 1]은 Nginx의 Architecture를 나타내고 있다. Nginx는 Master Process, Worker Process, Cache Loader Process, Cache Manager Process와 Config 파일로 구성되어 있다.

#### 1.1 Master Process

Master Process는 Nginx 실행시 가장 먼저 실행되는 Process이다. Config 파일로 부터 얻은 설정 내용을 바탕으로 Worker Process, Cache Loader Process, Cache Manager Process를 생성하고 관련 설정 내용을 생성한 Process에게 전달하는 역할을 수행한다.

#### 1.2. Worker Process

Worker Process는 실제 Client의 요청을 받아 처리하는 Process이다. 다수의 Worker Process가 동작하며 Master Process는 Config 파일에 설정되어 있는 Worker Process의 개수 만큼 Worker Process를 생성한다. Client의 요청은 다수의 Worker Process들에게 분배되어 처리된다. Worekr Process는 기본적으로 **단일 Thread**를 이용하여 select(), epoll(), kqueue()와 같은 Kernel에서 제공하는 Mutiplexing 함수를 이용하여 Client의 요청을 **Async**로 처리한다. 즉 Client와의 Connection 개수가 증가해도 Worker Process의 개수는 증가하지 않고, 기존의 생성되어 있는 Worker Process들에 의해서 Async로 처리된다.

Apache HTTP Server와 같이 기존의 Web Server들은 Client와의 Connection을 담당하는 전용 Process/Thread를 생성해서 이용하는 방식을 이용했다. 이러한 방식은 Client와의 Connection이 증가할 수록 Process/Thread의 개수도 증가하게 되어 Memory 낭비, 과도한 Context Switching Overhead 문제를 발생시켰다. Nginx는 Async 방식을 이용하여 이러한 문제들을 해결하였고, 기존의 Web Server들에 비해서 더 좋은 성능을 보여준다.

Worker Process는 단일 Thread 안에서만 요청을 처리하기 때문에 처리시간이 오래 걸리는 함수를 호출하면 Worker Process가 처리해야 하는 다른 요청들은 처리되지 못하고 대기해야하는 Blocking 문제가 발생한다. 주로 Disk 동작이 동반되는 File Read/Write 관련 함수의 경우 상황에 따라서 오랜 처리 시간이 발생할 수 있다. Nginx는 이러한 Blocking 문제를 해결하기 위해서 File Read/Write 동작을 별도의 Thread Pool에서 처리하는 Thread Pool 기법을 제공하고 있다.

Master Process는 Worker Process에게 Client의 Connection(요청)을 분배하는 별도의 기법을 이용하지 않고 Kernel의 기능을 그대로 이용한다. 각 Worker Process들은 모든 Worker Process들이 공유하는 Listen Socket을 select(), epoll(), kqueue()와 같은 Mutiplexing 함수에 각자 등록하고 Mutiplexing 함수에서 대기한다. 이후 Client로부터 Connection 요청이 오면 Kernel은 Mutiplexing 함수에서 대기하는 Worker Process중에서 임의의 Worker Process를 깨워 Connection 요청을 처리하게 만든다. 

즉 동일한 Socket을 여러 Process에서 동시에 Mutiplexing 함수에 등록 및 대기하고 있더라도, Event 발생시 Kernel은 임의의 Process를 하나만을 깨운다는 특징을 이용하여 Client의 Connection을 분배한다.

#### 1.3. Cache

Nginx는 Backend로부터 전송되는 응답을 Cache에 저장한 다음, Client으로 부터 동일한 요청이 올경우 Cache에 저장되어 있는 Backend의 응답을 활용하는 Caching 기법을 이용하고 있다. Cache의 Key, Meta 정보는 Nginx의 모든 Process가 접근할 수 있는 Shared Memory에 저장되며, Cache의 Data는 File에 저장된다. 

Cache의 Data는 File로 저장되더라도 Kernel이 제공하는 Filesystem Cache에 의해서 Disk뿐만 아니라 적절하게 Memory에도 저장되기 때문에, Nginx는 대부분 빠르게 Cache의 Data를 얻을 수 있다. 하지만 Cache의 Data가 Filesystem Cache에 존재하지 않고 Disk에만 존재하여 오랜 시간 걸릴수도 있다. 이러한 문제를 해결하는 방법중 하나는 위에서 언급한 Thread Pool 기법을 이용하는 것이다. Linux의 경우 Filesystem Cache로 Page Cache를 제공하고 있다. Nginx가 Cache의 Data를 별도의 Memory에 저장하고 이용하지는 않는다.

Cache의 Data는 기본적으로 Cache의 크기 초과로 인해서 지워지지 않는 이상은 계속 남아있으면서 Nginx에 의해서 이용된다. Cache의 크기가 초과하는 경우 LRU(Least Recently Used) Algorithm에 의해서 가장 나중에 이용된 Cache의 Data부터 지워진다. 또는 일정 시간이 지나면 Cache가 Expiration되어 지워질 수 있도록 설정할 수도 있다. 이러한 Cache 크기 및 Expiration 관리는 Cache Manager Process가 주기적으로 수행한다. Cache의 크기 및 Cache의 Expiration 시간은 Config 파일을 통해서 설정할 수 있다.

Cache Loader Process는 Nginx가 시작하면서 Master Process에 의해서 한번만 실행되며, File로 저장된 Cache의 Data를 바탕으로 Shared Memory에 Cache의 Key와 Meta를 설정하는 역할을 수행한다.

#### 1.4. Client, Backend

Nginx은 HTTP/HTTPS를 기반으로하는 L7 Web Server, Load Balancer 역할을 수행한다. 또한 TCP/UDP를 기반으로 하는 L4 Load Balancer의 역할도 수행이 가능하다. Nginx가 L7 Web Server, Load Balancer로 동작하는 경우, Nginx는 Client와 HTTP/HTTPS로 통신을 수행하고 Backend와는 HTTPS/HTTPS 또는 FastCGI를 이용하여 통신한다. Nginx가 L4 Load Balancer로 동작하는 경우, Nginx는 Client 및 Backend와 TCP/UDP를 이용하여 통신한다. Nginx의 Backend에는 NoSQL로 분류되는 Memcached, Redis와 같은 Key-Value Store를 이용할 수도 있다.

### 2. 참조

* [https://www.slideshare.net/jen6/nginx-architecture](https://www.slideshare.net/jen6/nginx-architecture)
* [http://www.aosabook.org/en/nginx.html](http://www.aosabook.org/en/nginx.html)
* [https://www.slideshare.net/joshzhu/nginx-internals](https://www.slideshare.net/joshzhu/nginx-internals)
* [https://www.nginx.com/blog/nginx-high-performance-caching/](https://www.nginx.com/blog/nginx-high-performance-caching/)
* [https://www.nginx.com/blog/thread-pools-boost-performance-9x/](https://www.nginx.com/blog/thread-pools-boost-performance-9x/)
* [https://stackoverflow.com/questions/11488453/can-i-call-accept-for-one-socket-from-several-threads-simultaneously](https://stackoverflow.com/questions/11488453/can-i-call-accept-for-one-socket-from-several-threads-simultaneously)