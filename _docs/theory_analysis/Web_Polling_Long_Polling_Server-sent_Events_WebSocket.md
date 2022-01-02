---
title: Web Polling, Long Polling, Server-sent Events, WebSocket
category: Theory, Analysis
date: 2022-01-02T12:00:00Z
lastmod: 2022-01-02T12:00:00Z
comment: true
adsense: true
---

Web Browser와 Server 사이에서 여전하 가장 많잉 이용되는 HTTP/1.1 Procotol은 Web Browser (Client)가 먼저 Server에세 요청을 전달하면 Server가 요청에 대한 응답을 전송하는 단방향 Protocol이다. 이러한 제한된 Web 환경에서 Web Browser와 Server 사이의 양방향 실시간 통신을 위한 다양한 우회 기법들이 존재한다. 이와 관련된 Polling, Long Polling, Server-sent Events, WebSocket을 비교 분석한다.

### 1. Polling

![[그림 1] Polling]({{site.baseurl}}/images/theory_analysis/Web_Polling_Long_Polling_Server-sent_Events_WebSocket/Polling.PNG){: width="600px"}

Polling은 가장 간단하게 Server에서 Web Browser에게 Data를 전달할 수 있는 기법이다. [그림 1]은 Polling 기법을 나타내고 있다. Web Browser는 주기적으로 Server에게 Event가 발생하였는지 확인한다. 만약 Event가 발생하지 않았다면 응답에도 Event 정보는 포함되지 않는다. 반면 Event가 발생하였다면 응답에 Event 정보도 같이 전송한다.

Web Browser에서 주기적으로 Server에게 Event가 발생하였는지 확인하는 방식이기 때문에 실시간성이 떨어지는 단점을 가지고 있다. 또한 Event가 발생하지 않았더라도 Web Browser와 Server 사이의 주기적으로 요청/응답을 송수신 하기 때문에 주기적으로 Traffic이 발생한다는 단점도 가지고 있다. 

하지만 호환성 측면에서 대부분의 Web Browser에서 이용할 수 있다는 장점과, Event 정보를 한번에 얻어와 Web Browser에서 Batch로 처리할 수 있다는 장점도 가지고 있다. 일반적으로 HTTP Protocol과 AJAX의 기반의 Timer를 활용한 Polling 방식으로 구현된다.

### 2. Long Polling

![[그림 2] Long Polling]({{site.baseurl}}/images/theory_analysis/Web_Polling_Long_Polling_Server-sent_Events_WebSocket/Long_Polling.PNG){: width="600px"}

Long Polling은 Polling 방식의 단점인 부족한 실시간성을 보완할 수 있는 기법이다. [그림 2]는 Long Polling 기법을 나타내고 있다. Web Browser는 요청을 전송하면 Server는 Event가 발생하기 전까지 응답을 전송하지 않다가 Event가 발생하면 Event와 함께 응답을 전송하는 방식이다.

이러한 특징 때문에 Server의 Event를 거의 실시간으로 Web Browser에게 전송할수 있는 장점을 갖게 된다. 하지만 Web Browser에서 Server의 Event를 하나 받기 위해서는 Web Browser의 요청 과정이 반드시 필요하기 때문에 Server의 Event가 자주 발생하면 비효율적인 Traffic 낭비가 발생할 수 있다. 따라서 Long Polling은 Server의 Event가 자주 발생하지 않는 환경에서 이용해야 한다.

일반적으로 HTTP Protocol과 JavaScript에서 `await` 문법과 함께 쉼게 구현되며, 대부분의 Web Browser에서 이용할 수 있는 장점도 가지고 있다.

### 3. Server-sent Events

![[그림 3] Server-sent Events]({{site.baseurl}}/images/theory_analysis/Web_Polling_Long_Polling_Server-sent_Events_WebSocket/Server-sent_Events.PNG){: width="600px"}

Server-sent Events 기법은 Web Browser의 간섭없이 Server에서 Web Browser 단방향으로 Event를 전송하는 기법이다. 즉 Web Browser가 Server의 Event를 Subscribe를 통해서 Server의 Event를 전송받는 기법이다. Web Browser에서 Server로는 Event를 전송할 수 없다. [그림 3]은 Server-sent Events 기법을 나타내고 있다. Web Browser는 Server에게 특정 Event를 Subscribe하는 요청 전송한다. 이후에 Server에서는 해당 Event가 발생시 Web Browser에게 해당 Event를 전송한다.

Server-sents Events는 HTML5의 표준에 포함되어 있으며 HTTP Protocol 기반으로 동작한다. HTTP 1.1 Protocol로도 동작은 가능하지만 가능하면 HTTP 2.0 Procotol을 통해 이용하는 것을 권장한다. 대부분의 Web Browser는 하나의 Server를 대상으로 최대 6개의 TCP Connection을 허용하기 때문에 HTTP 1.1 Protocol을 통해서는 최대 6개의 Event만 Subscribe가 가능하기 때문이다. 반면에 HTTP 2 Protocol을 이용하면 HTTP 2 Protocol의 TCP Connection Multiplexing 기능을 통해서 하나의 TCP Connection을 통해서 다수의 Event를 Subscribe 할 수 있게된다.

일반적으로 JavaScript의 `EventSource()` 함수를 통해서 Server-sent Events를 이용할 수 있다. Internet Explore와 같은 일부 Web Browser에서 제대로 지원하지 않는다는 단점도 가지고 있다. Server-sent Events는 WebSocket과 비교하면 Event Subscribe에 특화되어 있다. 단방향 통신만 지원하지만 각 Event를 Event ID를 통해 관리하고, Network 장애시 Reconnection 과정도 WebSocket에 비해서 잘 정의되어 있다. 또한 HTTP Protocol 기반이기 때문에 WebSocket에 비해서 Firewall 정책으로부터 좀더 자유로운 장점도 가지고 있다.

### 4. WebSocket

![[그림 4] WebSocket]({{site.baseurl}}/images/theory_analysis/Web_Polling_Long_Polling_Server-sent_Events_WebSocket/WebSocket.PNG){: width="600px"}

WebSocket 기법은 Web Browser와 Server 사이의 양방향 실시간 통신을 지원하는 기법이다. [그림 4]는 WebSocket 기법을 나타내고 있다. Web Browser와 Server는 Handshake 과정에서는 HTTP Protocol을 이용하지만, HTTP Upgrade Protocol을 통해서 HTTP Procotol에서 WebSocket Protocol로 전환후에는 HTTP Protocol을 이용하지 않고, WebSocket Protocol만 이용한다.

일반적으로 JavaScript의 `WebSocket()` 함수를 통해서 Event를 주고 받는다. WebSocket은 Server-sent Events에 비교하면 양방향 실시간 통신을 지원한다는 점과, Server-sent Events에 비해서 좀더 많은 Web Browser에서 지원한다는 장점을 갖는다. 하지만 Message, Event를 주고 받을때는 HTTP Protocol을 이용하지 않기 때문에 Firewall 정책으로부터 좀더 제한된다는 단점도 가지고 있다.

### 6. 참조

* [https://medium.com/system-design-blog/long-polling-vs-websockets-vs-server-sent-events-c43ba96df7c1](https://medium.com/system-design-blog/long-polling-vs-websockets-vs-server-sent-events-c43ba96df7c1)
* [https://codeburst.io/polling-vs-sse-vs-websocket-how-to-choose-the-right-one-1859e4e13bd9](https://codeburst.io/polling-vs-sse-vs-websocket-how-to-choose-the-right-one-1859e4e13bd9)
* [https://stackoverflow.com/questions/5195452/websockets-vs-server-sent-events-eventsource](https://stackoverflow.com/questions/5195452/websockets-vs-server-sent-events-eventsource)
* [https://ko.javascript.info/long-polling](https://ko.javascript.info/long-polling)
* [https://stackoverflow.com/questions/39274809/does-server-sent-events-utilise-http-2-pipelining](https://stackoverflow.com/questions/39274809/does-server-sent-events-utilise-http-2-pipelining)
