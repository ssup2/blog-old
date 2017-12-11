---
title: WebSocket
category: Theory, Analysis
date: 2017-12-11T12:00:00Z
lastmod: 2017-12-11T12:00:00Z
comment: true
adsense: true
---

WebSocket을 분석한다.

### 1. WebSocket

WebSocket은 Web에서 이용가능한 **Full-duplex** Communication 기술이다. WebSocket은 HTTP를 이용하여 Handshaking을 수행하지만, 일단 WebSocket Session이 생성되면 HTTP의 Respose/Request Message 방식이 아니라 일반 Socket처럼 Message Stream을 주고 받는다.

![]({{site.baseurl}}/images/theory_analysis/WebSocket/WebSocket_Handshaking.PNG){: width="600px"}

위의 그림은 WebSocket의 Handshaking 과정을 나타내고 있다.

### 2. 참조
* [https://tools.ietf.org/html/rfc6455] (https://tools.ietf.org/html/rfc6455)
* [https://en.wikipedia.org/wiki/WebSocket](https://en.wikipedia.org/wiki/WebSocket)
