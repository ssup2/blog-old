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

WebSocket은 Web에서 이용가능한 **Full-duplex** Communication 기술이다. WebSocket은 HTTP를 이용하여 Handshaking을 수행하지만, 일단 WebSocket Session이 생성되면 HTTP의 Respose/Request Message 방식이 아니라 일반 Socket처럼 Stream Message을 주고 받는다.

![]({{site.baseurl}}/images/theory_analysis/WebSocket/WebSocket_Handshaking.PNG){: width="600px"}

위의 그림은 WebSocket의 Handshaking 과정을 나타내고 있다. Client가 먼저 HTTP의 Upgrade Header를 이용하여 WebSocket 사용을 요청한다. Sec-WebSocket-Key는 Random으로 생성되는 값으로써 Sec-WebSocket-Accept 값을 구할때 이용되는 값이다. Client는 Sec-WebSocket-Accept값을 통해 자신이 요청한 WebSocket Handshaking에 대한 응답인지 확인할 수 있다.

Sec-WebSocket-Accept값은 "258EAFA5-E914-47DA-95CA-C5AB0DC85B11" 문자열을 CONCATENATE 한 값과 Sec-WebSocket-Accept값을 더한 다음 SHA-1 Hashing과 Base64 Encoding을 통해 구할 수 있다. Sec-WebSocket-Protocol은 Application이 이용할 SubProtocol을 나타낸다.

WebSocket Handshaking이 완료된뒤 Clinet, Service는 자유롭게 Message를 주고 받는다. Message는 **Data Frame**라는 작은 단위로 쪼개져서 전송된다. Data Frame은 작은 크기의 Header와 Payload로 구성되어 있다.

### 2. 참조
* [https://tools.ietf.org/html/rfc6455](https://tools.ietf.org/html/rfc6455)
* [https://en.wikipedia.org/wiki/WebSocket](https://en.wikipedia.org/wiki/WebSocket)
