---
title: HTTP Cookie, Session
category: Theory, Analysis
date: 2018-05-09T12:00:00Z
lastmod: 2018-05-09T12:00:00Z
comment: true
adsense: true
---

HTTP Cookie와 Session을 분석한다.

### 1. Cookie

![[그림 1] HTTP Cookie]({{site.baseurl}}/images/theory_analysis/HTTP_Cookie_Session/HTTP_Cookie.PNG){: width="600px"}

HTTP Cookie는 Client(Web Browser)가 저장하고 있는 Key-Value 값을 의미한다. [그림 1]은 Cookie 발급 과정을 나타내고 있다.

* Client는 Server에게 Web Page를 요청한다.
* Server는 Web Page와 함께 Set-Cookie Header에 Cookie 정보를 전송한다. 또한 Cookie의 만기 시간(Expires), 유효범위(Domain, Path) 정보도 같이 보낸다. [그림 1]에서 name Cookie의 값은 supsup이고, 유효기간은 2018년 10월 21일이다. 유효범위는 ssup2.com Domain의 /(root) Path, 즉 ssup2.com Domain 및 모든 Subdomain의 Web Page에서 해당 Cookie가 유효하다는 의미이다.
* Client는 Server가 저장을 요청한 Cookie 정보를 바탕으로 적절한 Cookie를 Cookie Header에 포함시켜 전송한다.

Client는 Server에게 요청 전송시 Server가 요청한 Cookie를 포함하여 Server에게 전송하기 때문에, Server는 어떤 Client로 부터 요청이 전송되었는지 파악할 수 있게 된다. 따라서 HTTP Cookie를 통해서 Server는 **상태**가 존재하는 Logic을 제공할 수 있다. HTTP Cookie를 이용하여 주로 Session 관리, 개인화, 사용자 행동 트래킹 같은 동작을 구현한다.

### 2. Session

![[그림 2] HTTP Session]({{site.baseurl}}/images/theory_analysis/HTTP_Cookie_Session/HTTP_Session.PNG){: width="600px"}

HTTP Cookie는 HTTP Session을 구현하기 위해 이용된다. Client는 Server의 요청에 따라서 JSESSION Cookie에 Session ID를 저장한다. 그 후 Server에게 Web Page를 요청할때 마다 JSESSION Cookie를 전송한다. Server에서는 JSESSION Cookie의 Session ID 값을 보고 Web Page 요청이 어느 Client에서 왔는지 구분하여 Session을 구현한다.

일반적으로 Session Cookie는 유효시간이 포함되지 않는데, 유효시간이 포함되지 않은 Cookie는 Client 종료시 사라지는 Cookie를 의미한다. 하지만 요즘 대부분의 Web Browser(Client)는 유효기간이 없는 Cookie도 유지시켜 Session을 유지한다.

### 3. 참조

* [https://developer.mozilla.org/ko/docs/Web/HTTP/Cookies](https://developer.mozilla.org/ko/docs/Web/HTTP/Cookies)
* [https://www.dev2qa.com/http-session-management-cookie/](https://www.dev2qa.com/http-session-management-cookie/)
