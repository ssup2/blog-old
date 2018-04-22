---
title: HTTP Digest 인증
category: Theory, Analysis
date: 2017-08-12T12:00:00Z
lastmod: 2017-08-12T12:00:00Z
comment: true
adsense: true
---

### 1. HTTP Digest 인증

HTTP Digest 인증 기법은 HTTP Basic 인증 기법의 보안 취약점을 개선하기 위한 인증 기법이다. 아래의 그림은 HTTP Digest 인증 기법의 Example을 나타내고 있다.

![]({{site.baseurl}}/images/theory_analysis/HTTP_Digest_Authorization/HTTP_Digest_Example.PNG){: width="700px"}

* Client는 Server에게 Resource를 요청한다.
* Client가 요청한 Resource를 이용하기 위해서는 인증이 필요하다. 따라서 Server는 Client에게 **WWW-Authenticate Header**를 통해 인증 필요성을 Client에게 전달한다. Digest 문자열을 통해 Digest 인증 과정이 필요한걸 Client에게 알린다.
  * realm은 요청한 Resource의 Protection Space를 나타내는 속성이다. Resource가 속해 있는 Protection Space마다 Client는 각기 다른 ID, Password를 이용할 수 도 있다.
  * nonce는 Client가 Server에게 Resource를 요청 할 때마다 Server에서 생성하는 임의의 값이다. Client는 Server로 부터 받은 nonce를 그대로 Server에게 전달 해야한다. Server에서는 nonce가 다르면 Resource 요청을 거부한다. 따라서 nonce를 통해 Server Replay Attack을 방지 할 수 있다.
  * qop는 Quality of protection의 약자로 의미 그대로 Protection 등급을 나타낸다.
* 인증 요청을 받은 Client는 Server로부터 받은 nonce, qop, realm 속성값을 Authorization Header에 그대로 추가하고 그 외의 필요한 속성값들을 추가한다.
  * nc는 nonce count의 약자로 Client가 Server로부터 받은 nonce를 이용하여 Server에게 몇번 요청했는지를 나타낸다.
  * cnonce는 Client에서 생성하는 임의의 값이다. nonce와 유사하게 Client Replay Attack 방지를 한다.
  * response는 인증에 필요한 정보가 포함된 Digest이다. 아래와 같이 계산된다.

  {: .newline }
  > HA1 = MD5(username:realm:password)
  > HA2 = MD5(method:uri)
  > response = MD5(HA1:nonce:nc:cnonce:qop:HA2)

* Server는 nonce와 response의 일치를 확인하면 Client가 요청한 Resource와 함께 Authorization-Info Header를 통해 인증 정보도 같이 전송한다.
  * qop는 Server에서 이용한 Protection 등급을 나타낸다.
  * nc와 cnonce는 client에서 보낸 값과 일치 해야한다.
  * rspauth는 response auth를 의미하며 Server와 Client사이의 상호 인증시 이용된다.
  * nextnonce는 Client가 Server에게 다음 요청시 사용되길 원하는 nonce값을 나타낸다.

### 2. 분석

Password를 MD5로 Encoding하여 Basic 인증의 약점인 보안 부분을 보완하였다. 또한 임의로 발급되는 값이 nonce를 Data뿐만 아니라 이용하여 Server나 Client 자체를 보호 할 수 있게 되었다.

### 3. 참조

* HTTP Digest Authentication Scheme - [https://tools.ietf.org/html/rfc2069](https://tools.ietf.org/html/rfc2069)
* [https://msdn.microsoft.com/en-us/library/aa479391.aspx](https://msdn.microsoft.com/en-us/library/aa479391.aspx)
* [https://technet.microsoft.com/en-us/library/cc780170(v=ws.10).aspx](https://technet.microsoft.com/en-us/library/cc780170(v=ws.10).aspx)
* [https://lbadri.wordpress.com/2012/08/10/digest-authentication-with-asp-net-web-api-part-1/](https://lbadri.wordpress.com/2012/08/10/digest-authentication-with-asp-net-web-api-part-1/)
* [http://iloveulhj.github.io/posts/http/http-digest-auth.html](http://iloveulhj.github.io/posts/http/http-digest-auth.html)
* [http://flylib.com/books/en/1.2.1.123/1/](http://flylib.com/books/en/1.2.1.123/1/)
