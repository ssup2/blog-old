---
title: HTTP Basic 인증
category: Theory, Analysis
date: 2017-08-10T12:00:00Z
lastmod: 2017-08-10T12:00:00Z
comment: true
adsense: true
---

### 1. HTTP Basic 인증

HTTP Basic 인증 기법은 HTTP 표준에 정의된 가장 단순한 인증 기법이다. 아래의 그림은 HTTP Basic 인증 기법의 Example을 나타내고 있다.

![]({{site.baseurl}}/images/theory_analysis/HTTP_Basic_Authorization/HTTP_Basic_Example.PNG){: width="600px"}

* Client는 Server에게 Resource를 요청한다.
* Client가 요청한 Resource를 이용하기 위해서는 인증이 필요하다. 따라서 Server는 Client에게 **WWW-Authenticate Header**를 통해 인증 필요성을 Client에게 전달한다. Basic 문자열을 통해 Basic 인증 과정이 필요하다는걸  Client에게 알린다.
  * realm은 요청한 Resource의 Protection Space를 나타내는 속성이다. Resource가 속해 있는 Protection Space마다 Client는 각기 다른 ID, Password를 이용할 수 도 있다.
* 인증 요청을 받은 Client는 **ID:Password** 문자열을 **Base64**로 Encoding한 String을 Authorize Header에 추가한뒤 다시 한번 Server에게 Resource를 요청한다. 위의 그림에서는 ID, Password가 각각 ssup2라고 가정하였다. ssup2:ssup2 문자열을 Base64의 Encoding 결과가 c3N1cDI6c3N1cDI= 문자열 이다.
* Encoding된 ID:Passowrd 문자열을 받은 Server는 자신이 Encoding한 값과 일치하는지 확인한 후 일치하면, 요청한 Resource를 전달한다.

### 2. 분석

Client가 ID, Password를 알고 있고, HTTP를 이용하여 단순한 인증이 필요할때 HTTP Basic 인증이 이용된다. ID, Password가 Base64로 Encoding되어 있어 ID, Password가 쉽게 노출되는 구조이다. SSL이나 TLS를 이용하여 ID, Password의 노출을 막을 수 있다.

### 3. 참조

* HTTP Basic Authentication Scheme - [https://tools.ietf.org/html/rfc7617](https://tools.ietf.org/html/rfc7617)
* [http://iloveulhj.github.io/posts/http/http-basic-auth.html](http://iloveulhj.github.io/posts/http/http-basic-auth.html)
