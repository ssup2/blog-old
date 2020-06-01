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

[그림 1]은 동일한 HTTP/2 Header를 2번 전송 하였을때의 압축 과정을 나타내고 있다. 처음으로 Header 전송시 전송하려는 Header의 Key-value 중에서 Static Table의 Key-value와 일치하는 경우에는 해당 Key-value는 Static Table의 Index로 변경된다. [그림 1]에서 ":method|GET", ":scheme|POST"가 각각 Static Table의 Index 2, 7로 변경되는 것을 확인할 수 있다.

Static Table을 이용하여 변경되지 않은 나머지 Key-value들은 각각 Huffman Algorithm을 이용해 압축된다. 그리고 Huffman을 통해서 압축된 Key-value는 Dynamic Table에 저장된다. [그림 1]에서 ":host|ssup.com", ":path|/home", "user-agent|Mozila/5.0"는 Dynamic Table의 62에 저장되는 것을 확인할 수 있다. 그 뒤 동일 Header를 한번더 전송하는 경우 Dynamic Table을 이용하여 첫번째 Header를 전송할때보다 효율적으로 압축한다. [그림 1]에서 두번째 전송하는 Header의 경우에는 Huffman Algorithm을 이용하지 않고 Static, Dynamic Table만을 이용하여 Header를 압축하는걸 확인할 수 있다.

Static Table은 61번 Index까지 갖고 있기 때문에 Dynamic Table의 Index는 62번부터 시작한다. Dynamic Table은 FIFO 형태로 동작한다. 즉 Dyanamic Table이 가득차 새로운 Key-value를 저장할 공간이 부족할 경우, 가장 오래 저장된 Key-value를 제거하고 새로운 Key-value를 저장한다.

#### 1.2. Stream, Multiplexing

![[그림 2] HTTP/2 Components]({{site.baseurl}}/images/theory_analysis/HTTP2/HTTP2_Components.PNG)

![[그림 3] HTTP/2 Stream]({{site.baseurl}}/images/theory_analysis/HTTP2/HTTP2_Stream.PNG)

#### 1.3. Server Push

### 2. 참조

* [https://http2.github.io/http2-spec](https://http2.github.io/http2-spec)
* [https://developers.google.com/web/fundamentals/performance/http2?hl=ko](https://developers.google.com/web/fundamentals/performance/http2?hl=ko)
* [https://www.slideshare.net/eungjun/http2-40582114](https://www.slideshare.net/eungjun/http2-40582114)
* [https://b.luavis.kr/http2/](https://b.luavis.kr/http2/)
* [https://www.slideshare.net/BrandonK/http2-analysis-and-performance-evaluation-tech-summit-2017-86562049](https://www.slideshare.net/BrandonK/http2-analysis-and-performance-evaluation-tech-summit-2017-86562049)