---
title: Forward Proxy, Reverse Proxy
category: Theory, Analysis
date: 2017-01-23T14:35:00Z
lastmod: 2017-01-23T14:35:00Z
comment: true
adsense: true
---

### 1. Forward Proxy

![]({{site.baseurl}}/images/theory_analysis/Forward_Proxy_Reverse_Proxy/Forward_Proxy.PNG)

위 그림은 Foward Proxy를 나타내고 있다. PC는 Proxy Server로 www.proxy.com를 이용한다고 설정한다. 그 후 PC에서 동작하는 Web Browser가 Web Server의 url로 정보를 요청하면, Forward Proxy Server는 요청을 받아 PC의 Web Browser를 대신하여 다시 Web 서버에게 요청한다. Forward Proxy Server는 자신이 처리한 요청을 Caching하기 때문에 Forward Proxy Server를 이용하면 Client는 빠른 응답을 얻을 수 있고, 네트워크 사용량도 줄일 수 있다. Foward Proxy는 Client의 역활을 수행하기 때문에 Client Side Proxy 기법이라고 할 수 있다. 일반적으로 이야기하는 Proxy 서버의 역활이 Forward Proxy 방식이다.

### 2. Reverse Proxy

![]({{site.baseurl}}/images/theory_analysis/Forward_Proxy_Reverse_Proxy/Reverse_Proxy.PNG)

위 그림은 Reverse Proxy를 나타내고 있다. Reverse Proxy 기법은 Foward Proxy 기법과 다르게 PC에 Proxy Server를 설정하지 않는다. PC의 Web Browser는 Reverse Proxy Server를 실제 Web Server로 생각하고 Reverse Proxy Server에게 직접 요청을 한다. 요청을 받은 Reverse Proxy Server는 url에 따라서 다시 실제 Web Server에게 요청하고, 요청을 받으면 다시 Web Browser에게 전달한다. Reverse Proxy Server를 이용하여 Caching 뿐만 아니라 Load Balancing도 수행 가능하다. Reverse Proxy는 Server 역활을 수행하기 때문에 Server Side Proxy 기법이라고 할 수 있다.

### 3. 참조

* [http://www.jscape.com/blog/bid/87783/Forward-Proxy-vs-Reverse-Proxy](http://www.jscape.com/blog/bid/87783/Forward-Proxy-vs-Reverse-Proxy)
