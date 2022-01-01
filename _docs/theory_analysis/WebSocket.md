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

WebSocket은 Web Browser와 Server 사이의 **Full-duplex**를 구현가능하게 만드는 Protocol이다. Web Socket은 Handshaking시에는 HTTP Protocol을 이용하지만, Handshaking 이후에는 HTTP를 이용하지 않고 TCP/IP Stack 위에서 WebSocket 자체 Protocol을 이용하여 Web Browser와 Server가 Data를 주고 받는다. 즉 Web Client와 Server는 HTTP Protocol에서 WebSocket Protocol로 전환한다.

![[그림 1] Websocket Handshaking]({{site.baseurl}}/images/theory_analysis/WebSocket/WebSocket_Handshaking.PNG){: width="600px"}

[그림 1]은 WebSocket의 Handshaking 과정을 나타내고 있다. HTTP Procotol에서 WebSocket Protocol의 전환은 HTTP의 Upgrade Protocol에 의해서 이루어진다. Upgrade Protocol은 HTTP에서 다른 Protocol로 전환을 위한 Protocol이다. [그림 1]에서 "Upgrade: websocket", "Connection: Upgrade"와 같은 Upgrade Protocol 관련 Header들을 Web Browser와 Server가 주고 받는것을 확인할 수 있다.

Sec-WebSocket-Key는 Random으로 생성되는 값으로써 Sec-WebSocket-Accept 값을 구할때 이용되는 값이다. Client는 Sec-WebSocket-Accept값을 통해 자신이 요청한 WebSocket Handshaking에 대한 응답인지 확인할 수 있다.

Sec-WebSocket-Accept값은 "258EAFA5-E914-47DA-95CA-C5AB0DC85B11" 문자열을 CONCATENATE 한 값과 Sec-WebSocket-Accept값을 더한 다음 SHA-1 Hashing과 Base64 Encoding을 통해 구할 수 있다. Sec-WebSocket-Protocol은 Application이 이용할 SubProtocol을 나타낸다. WebSocket Handshaking이 완료된후 Client와 Server는 서로 자유롭게 Message를 주고 받을 수 있다. Message는 **Data Frame**라는 작은 단위로 쪼개져서 전송된다. Data Frame은 작은 크기의 Header와 Payload로 구성되어 있다.

### 2. 참조
* [https://tools.ietf.org/html/rfc6455](https://tools.ietf.org/html/rfc6455)
* [https://en.wikipedia.org/wiki/WebSocket](https://en.wikipedia.org/wiki/WebSocket)
* [https://stackoverflow.com/questions/14133452/which-osi-layer-does-websocket-protocol-lay-on](https://stackoverflow.com/questions/14133452/which-osi-layer-does-websocket-protocol-lay-on)
