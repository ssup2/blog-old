---
title: Nginx Thread Pool
category: Theory, Analysis
date: 2020-08-24T12:00:00Z
lastmod: 2020-08-24T12:00:00Z
comment: true
adsense: true
---

Nginx의 Thread Pool 기법을 분석한다.

### 1. Nginx Thread Pool

![[그림 1] Nginx Worker Process without Thread Pool]({{site.baseurl}}/images/theory_analysis/Nginx_Thread_Pool/Nginx_Worker_Process_Without_Thread_Pool.PNG){: width="300px"}

Nginx의 Thread Pool 기법을 분석한다. [그림 1]은 Nginx의 Thread Pool 기법을 적용하지 않은, 기존의 Worker Process의 동작을 나타내고 있다. Nginx의 Worker Process는 Kernel이 제공하는 select(), epoll(), kqueue()와 같은 Multiplexing 함수를 이용하여 단일 Thread 안에서 Event Loop를 동작시킨다. Event Loop는 Event를 대기, 감시, 처리하는 과정을 반복한다.

이러한 단일 Thread Event Loop 기법은 Process/Thread의 과도한 생성을 방지하여 Kernel Memory 절약, Context Switching Overhead 등의 성능적 이점을 가져다 준다. 하지만 Event 처리 시간이 길어져 단일 Thread를 점유하고 있으면 다른 Event 처리도 늦어지는 Blocking 현상이 발생하는 큰 문제점을 갖고 있다. 주로 Disk 동작이 동반되는 File Read/Write 동작의 경우, 상황에 따라서 오랜 시간 Thread를 점유하며 동작하기 때문에 Blocing 현상의 주요 원인이다. 또한 Nginx Third-party Module들의 처리 시간이 긴 함수들도 원인이 될 수 있다.

Nginx는 Backend의 응답을 File로 Caching하기 때문에 File Read/Write 동작이 매우 자주 발생한다. 동일한 요청이 자주온다면 Memory 기반의 Filesystem Cache를 통해서 Disk 접근은 최소화 되기 때문에, 빠른 File Read/Write 동작이 가능하다. 하지만 Video Streaming Data처럼 큰 Data Stream을 주고받는 경우에는 Filesystem Cache의 효과를 얻지 못하기 때문에, 대부분의 File Read/Write 동작은 Disk에 접근하게 되고 느려질수 밖에 없다. 이러한 File Read/Write 동작으로 인한 Blocking 문제를 해결하기 위해서 Nginx의 Thread Pool 기법이 고안되었다.

![[그림 2] Nginx Worker Process with Thread Pool]({{site.baseurl}}/images/theory_analysis/Nginx_Thread_Pool/Nginx_Worker_Process_With_Thread_Pool.PNG)

[그림 2]는 Thread Pool 기법을 적용한 Worker Process를 나타내고 있다. Event Loop가 동작하는 Main Thread에서는 Event를 직접처리 하거나, Event를 Event Queue에 넣는다. Event Queue에 들어간 Event는 Thread Pool의 Worker Thread들이 하나씩 가저가 처리하고, 처리가 완료되면 Main Loop에게 Event 처리 완료 메세지를 보낸다. 이러한 Thread Pool 기법에서는 하나의 Worker Thread가 Event 처리로 Blocking 되어도 나머지 Worker Thread에게는 영향을 주지 않기 때문에 Blocking 문제를 해결할 수 있다.

현재 Nginx는 File Read/Write 동작만 Thread Pool의 Thread에서 처리하고, 나머지 Event들은 기존 그대로 Main Thread에서 처리하고 있다. Thread Pool안의 Thread 개수는 설정을 통해서 변경할 수 있다. Nginx의 Thread Pool 기법은 Nginx 1.7.11 이후 Version에서 이용할 수 있다.

### 2. 참조

* [https://www.nginx.com/blog/thread-pools-boost-performance-9x/](https://www.nginx.com/blog/thread-pools-boost-performance-9x/)