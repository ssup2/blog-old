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

[그림 1]은 Nginx Architecture를 나타내고 있다. Nginx의 Master Process는 Nginx 실행시 가장 먼저 실행되는 Process이다. Config 파일로 부터 얻은 설정 내용을 바탕으로 Worker Process, Cache Loader Process, Cache Manager Process를 생성하고 관련 설정 내용을 생성한 Process에게 전달하는 역활을 수행한다.

Worker Process는 실제 Client의 요청을 처리하는 Process이다. 다수의 Worker Process가 동작하며 Master Process는 Config 파일에 설정되어 있는 Worker Process의 개수 만큼 Worker Process를 생성한다. Worekr Process는 기본적으로 단일 Thread안에서 select(), epoll(), kqueue()와 같은 Kernel에서 제공하는 Mutiplexing 함수를 이용하여 Client의 요청을 **Async**로 처리한다. 즉 Client와의 Connection 개수가 증가해도 Worker Process의 개수는 증가하지 않고, 기존의 생성되어 있는 Worker Process들에 의해서 Async로 처리된다.

Apache HTTP Server와 같이 기존의 Web Server들은 Client와의 Connection을 담당하는 전용 Process/Thread를 생성해서 이용하는 방식을 이용했다. 이러한 방식은 Client와의 Connection이 증가할 수록 Process/Thread의 개수도 증가하게 되어 Memory 낭비, 과도한 Context Switching Overhead 문제를 발생시켰다. Nginx는 Async 방식을 이용하여 이러한 문제들을 해결하였고, 기존의 Web Server들에 비해서 더 좋은 성능을 보여준다.

### 2. 참조

* [https://www.slideshare.net/jen6/nginx-architecture](https://www.slideshare.net/jen6/nginx-architecture)
* [http://www.aosabook.org/en/nginx.html](http://www.aosabook.org/en/nginx.html)
* [https://www.slideshare.net/joshzhu/nginx-internals](https://www.slideshare.net/joshzhu/nginx-internals)
* [https://www.nginx.com/blog/nginx-high-performance-caching/](https://www.nginx.com/blog/nginx-high-performance-caching/)
* [https://www.nginx.com/blog/thread-pools-boost-performance-9x/](https://www.nginx.com/blog/thread-pools-boost-performance-9x/)
* [https://stackoverflow.com/questions/11488453/can-i-call-accept-for-one-socket-from-several-threads-simultaneously](https://stackoverflow.com/questions/11488453/can-i-call-accept-for-one-socket-from-several-threads-simultaneously)