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

#### 1.1. Header Compression

![[그림 1] HTTP/2 Header Compression]({{site.baseurl}}/images/theory_analysis/HTTP2/HTTP2_Header_Compression.PNG){: width="700px"}

#### 1.2. Stream, Multiplexing

![[그림 2] HTTP/2 Components]({{site.baseurl}}/images/theory_analysis/HTTP2/HTTP2_Header_Compression.PNG){: width="700px"}

![[그림 2] HTTP/2 Components]({{site.baseurl}}/images/theory_analysis/HTTP2/HTTP2_Stream.PNG){: width="700px"}

#### 1.3. Server Push

### 2. 참조

* [https://http2.github.io/http2-spec](https://http2.github.io/http2-spec)
* [https://developers.google.com/web/fundamentals/performance/http2?hl=ko](https://developers.google.com/web/fundamentals/performance/http2?hl=ko)
* [https://www.slideshare.net/eungjun/http2-40582114](https://www.slideshare.net/eungjun/http2-40582114)
* [https://b.luavis.kr/http2/](https://b.luavis.kr/http2/)
* [https://www.slideshare.net/BrandonK/http2-analysis-and-performance-evaluation-tech-summit-2017-86562049](https://www.slideshare.net/BrandonK/http2-analysis-and-performance-evaluation-tech-summit-2017-86562049)