---
title: HTTP/2
category: Theory, Analysis
date: 2020-06-01T12:00:00Z
lastmod: 2020-06-01T12:00:00Z
comment: true
adsense: true
---

HTTP2를 분석한다.

### 1. HTTP2

HTTP/2는 기존 HTTP/1의 느린 성능 개선을 목적으로 탄생하게된 Protocol이다. HTTP/2가 HTTP/1에 비해서 개선된 점들은 다음과 같다.

#### 1.1. Header 압축

![[그림 1] HTTP/2 Header 압축]({{site.baseurl}}/images/theory_analysis/HTTP2/HTTP2_Header_Compression.PNG)

일반적으로 HTTP Header에는 Cookie, User-Agent와 같은 많은 Meta Data를 저장하고 있기 때문에 HTTP Header의 길이는 HTTP Body의 길이와 비교해도 큰 차이가 나지 않는 경우가 많다. 문제는 Stateless한 HTTP의 특성 때문에 동일한 Server에게 동일한 HTTP Header 내용을 여러번 전송하는 경우가 빈번하게 발생한다는 점이다. 따라서 긴 HTTP Header는 HTTP 통신의 주요 Overhead 중 하나이다.

HTTP/2는 이러한 HTTP Header의 Overhead를 줄이기 위해서 Header 압축 기법을 제공한다. [그림 1]은 Header 압축 기법을 나타내고 있다. HTTP/2의 Header 압축은 내부적으로 **HPACK**이라고 불리는 Module이 담당하는데 HPACK은 Huffman Algorithm과 Static Table, Dynamic Table을 통해서 압축을 수행한다. Huffman Algorithm은 자주 나오는 문자열 순서대로 짧은 Bitmap으로 Mapping하여 Data를 압축하는 기법이다. Static Table은 HTTP/2 Spec에 정의된 Table로 HTTP/2 Header로 자주 사용되는 Key-value 값 쌍을 저장하고 있는 Table이다. Dynamic Table은 한번 전송/수신한 Header의 Key-value 값을 임의로 저장하는 Buffer 역활을 수행하는 Table이다.

[그림 1]은 동일한 HTTP/2 Header를 2번 전송 하였을때의 압축 과정을 나타내고 있다. 처음으로 Header 전송시 전송하려는 Header의 Key-value 중에서 Static Table의 Key-value와 일치하는 경우에는 해당 Key-value는 Static Table의 Index로 변경된다. [그림 1]에서 ":method GET", ":scheme POST"가 각각 Static Table의 Index 2, 7로 변경되는 것을 확인할 수 있다.

Static Table을 이용하여 변경되지 않은 나머지 Key-value들은 각각 Huffman Algorithm을 이용해 압축된다. 그리고 Huffman을 통해서 압축된 Key-value는 Dynamic Table에 저장된다. [그림 1]에서 ":host ssup.com", ":path /home", "user-agent Mozila/5.0"는 Dynamic Table의 62에 저장되는 것을 확인할 수 있다. 그 뒤 동일 Header를 한번더 전송하는 경우 Dynamic Table을 이용하여 첫번째 Header를 전송할때보다 효율적으로 압축한다. [그림 1]에서 두번째 전송하는 Header의 경우에는 Huffman Algorithm을 이용하지 않고 Static, Dynamic Table만을 이용하여 Header를 압축하는걸 확인할 수 있다.

Static Table은 61번 Index까지 갖고 있기 때문에 Dynamic Table의 Index는 62번부터 시작한다. Dynamic Table은 FIFO 형태로 동작한다. 즉 Dynamic Table이 가득차 새로운 Key-value를 저장할 공간이 부족할 경우, 가장 오랜 기간 저장된 Key-value를 제거하고 새로운 Key-value를 저장한다.

#### 1.2. Stream, Multiplexing

![[그림 2] HTTP/2 Components]({{site.baseurl}}/images/theory_analysis/HTTP2/HTTP2_Components.PNG)

[그림 2]는 HTTP/2의 구성요소를 나타내고 있다. HTTP/2는 하나의 **Connection**안에서 논리적 Channel 역활을 수행하는 다수의 **Stream**을 두어 Multiplexing을 구현한다. 각 Stream 안에서는 Server와 Client는 다른 Stream에 관계 없이 독립적으로 **Message**를 주고 받는다. Message는 **Frame**이라고 불리는 전송 최소 단위로 쪼개져 구성된다.

![[그림 3] HTTP/3 Stream Multiplexing]({{site.baseurl}}/images/theory_analysis/HTTP2/HTTP2_Stream_Multiplexing.PNG)

HTTP/2에서 Stream이라는 개념이 탄생한 이유는 Server와 Client의 전송 대기 시간 감소 및 HOL Blocking (Head of Line Blocking) 현상을 제거 하기 위해서 이다. [그림 3]은 Stream Multiplexing을 나타내고 있다. 기존 HTTP/1에서는 하나의 Connection 내부에서 Server나 Client는 동시에 Message를 전송하지 못하고 Message를 Ping-pong 형태로 주고 받을수 밖에 없었다. 따라서 Server나 Client는 불필요한 대기시간이 길어지게 되고, 앞의 Message 전송이 느려지면 뒤의 Message 전송에 큰 영향을 미치게 된다. HTTP/2에서는 Stream 이라는 논리적인 Channel을 도입하여 HOL Blocking 문제를 해결하였다. HTTP/2는 각 Stream 단위로 Flow Control을 수행한다. HTTP/2의 Stream Flow Control은 TCP의 Flow Control처럼 Window를 생성하는 방식을 이용한다.

![[그림 4] HTTP/2 Frame Interleaving]({{site.baseurl}}/images/theory_analysis/HTTP2/HTTP2_Frame_interleaving.PNG)

[그림 4]는 HTTP/2에서 Stream을 통해서 실제 어떻게 Multiplexing을 구현하는지를 나타내고 있다. Stream의 구현은 Frame Interleaving을 통해서 구현된다. 각 Stream에 소속되어 있는 Frame들은 시분활을 통해 동시에 전송된다. 목적지에 도착한 Frame들은 Frame Header에 포함된 Stream Number 정보를 통해서 재조합되어 Server 또는 Client에게 전달된다. Frame Header에는 Frame의 Type을 나타내는 정보도 포함되어 있으며 대표적인 Type에는 HTTP/2의 Header가 포함되어 있는 HEADER Type과 HTTP/2의 Body가 포함되어 있는 DATA Type이 존재한다.

#### 1.3. Stream Priority

![[그림 5] HTTP/2 Stream Priority]({{site.baseurl}}/images/theory_analysis/HTTP2/HTTP2_Stream_Priority.PNG){: width="200px"}

HTTP/2의 Stream은 Weight 기반 Priority 기능을 제공한다. Stream Priority 기능을 통해서 우선순위가 높은 Message를 먼저 보낼수 있다. [그림 5]는 각 Stream의 Weight 값과 Stream 사이의 Weight 관계를 나타내고 있다. Stream 사이의 Weight 관계는 Tree 형태를 이룬다. Weight는 1부터 256까지의 값을 가질수 있다. 기본적으로 Weight에 비례하여 Stream에 할당되는 Resource양이 결정된다. 여기서 Resource는 CPU, Memory, Network Bandwidth 같은 Message 전송에 필요한 자원을 의미한다.

[그림 5]에서 Stream A의 Weight는 12, Stream B에는 4의 Weight가 설정되어 있기 때문에, Stream A와 Stream B의 Resource 비율은 3:1이 된다. Stream B의 하위 Stream은 Stream C 밖에 없기 때문에 Stream B와 Stream C의 Resource 비율은 1:1이 된다. Stream C의 하위 Stream은 Weight가 8인 Stream D와 Weight가 4인 Stream E가 존재하기 때문에 Stream D는 Stream C가 이용할 수 있는 Resource의 2/3만큼 쓸수 있고, Stream C는 Stream D가 이용할 수 있는 Resource의 1/3만큼 쓸수 있다. 따라서 Stream C, D, E의 비율은 3:2:1이 된다. 종합하면 Stream A, B, C, D, E의 Resource 비율은 9:3:3:2:1이 된다.

#### 1.4. Server Push

![[그림 6] HTTP/2 Server Push]({{site.baseurl}}/images/theory_analysis/HTTP2/HTTP2_Server_Push.PNG){: width="450px"}

HTTP/2에서 Server는 Client의 요청 Message를 받으면 요청에 대한 응답 Message 뿐만 아니라, Client에서 아직 요청하지 않았지만 Client에게 필요할 걸로 예상되는 다른 Message도 함께 전송하는 Server Push 기능을 제공한다. [그림 6]은 Server Push 동작을 나타내고 있다. Client는 /index.html 파일만 Server에게 요청했지만 Server는 /index.html을 그리는데 필요한 PNG 파일들도 별도의 Strema을 통해서 동시에 같이 Client에게 전송하는 것을 확인할 수 있다.

[그림 4]에서 PUSH_PROMISE Type의 Frame을 확인할 수 있는데, Server Push의 시작을 Client에게 알리는 역활을 수행한다. PUSH_PROMISE Type의 Frame에는 Message를 전송할 Stream을 명시하여 Client가 해당 Stream을 통해서 Message를 수신할 수 있도록 만든다.

### 2. 참조

* [https://http2.github.io/http2-spec](https://http2.github.io/http2-spec)
* [https://developers.google.com/web/fundamentals/performance/http2?hl=ko](https://developers.google.com/web/fundamentals/performance/http2?hl=ko)
* [https://www.slideshare.net/eungjun/http2-40582114](https://www.slideshare.net/eungjun/http2-40582114)
* [https://b.luavis.kr/http2/](https://b.luavis.kr/http2/)
* [https://www.slideshare.net/BrandonK/http2-analysis-and-performance-evaluation-tech-summit-2017-86562049](https://www.slideshare.net/BrandonK/http2-analysis-and-performance-evaluation-tech-summit-2017-86562049)