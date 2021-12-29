---
title: Web Browser Local Storage, Session Storage, Cookie
category: Theory, Analysis
date: 2021-12-27T12:00:00Z
lastmod: 2021-12-27T12:00:00Z
comment: true
adsense: true
---

Web Browser에서 이용하는 Local Storage, Session Storage, Cookie를 분석한다. 

### 1. Local Storage

![[그림 1] Chrome Local Storage]({{site.baseurl}}/images/theory_analysis/Web_Browser_Local_Storage_Session_Storage_Cookie/Chrome_Local_Storage.PNG){: width="400px"}

Local Storage는 Web Browser가 이용하는 Key/Value 기반 저장 공간이다. Web Brower가 설치된 PC의 Storage에 저장되며, Web Browser의 Java Script/HTML에서만 이용할 수 있다. 각 Domain당 최대 5MB의 저장 공간을 이용할 수 있다. Local Storage에 저장된 Data는 만료가 없다는 특징을 가지고 있다.

### 2. Session Storage

![[그림 2] Chrome Session Storage]({{site.baseurl}}/images/theory_analysis/Web_Browser_Local_Storage_Session_Storage_Cookie/Chrome_Session_Storage.PNG){: width="400px"}

Session Storage는 Web Browser가 이용하는 Key/Value 기반 저장 공간이다. Web Browser가 설치된 PC의 Storage에 저장되며, Web Browser의 Java Script/HTML에서만 이용할 수 있다. 각 Domain당 최대 5MB의 저장 공간을 이용할 수 있다.

Session Storage에 저장된 Data는 Web Browser의 Window/Tab의 수명과 동일하다. 즉 Web Browser의 Windows/Tab이 닫희는 경우 Session Storage에 저장된 Data도 모두 제거된다. 이러한 특징이 Local Storage와 가장 큰 차이점이다.

### 3. Cookie

![[그림 3] Chrome Cookie]({{site.baseurl}}/images/theory_analysis/Web_Browser_Local_Storage_Session_Storage_Cookie/Chrome_Cookie.PNG){: width="700px"}

Cookie는 Web Browser가 설치된 PC의 Storage를 이용하는 저장공간이지만, 저장되는 Data는 주로 Web Server가 전송하는 Data를 저장하는 저장 공간이다. Web Server는 Web Browser에게 응답을 전송할 때 필요에 따라서 Cookie에 저장될 Data도 같이 전송한다. Web Browser는 Web Server에게 Cookie에 저장될 Data를 전송받으면 Cookie에 저장하고, 이후 Web Server에게 요청을 전송할 때 Cookie에 저장된 Data도 같이 전송한다. 즉 Cookie는 Web Server를 위한 저장 공간이다. 물론 Web Browser에서도 Cookie에 저장된 Data를 활용할 수도 있다.

Web Server에서 Cookie가 필요하는 이유는 Web Server가 Web Browser를 인지하여 User에게 Stateful한 환경을 제공하기 위해서이다. HTTP/HTTPS은 Stateless Protocol이기 때문에 단순히 HTTP/HTTPS을 통해서는 Stateful한 동작을 User에게 제공하기 어렵다. Web Server는 Cookie를 통해서 Web Client가 요청 전송시 특정 Data를 같이 전송하도록 만들수 있기 때문에, 이를 활용하여 Web Server는 Web Browser를 구분할 수 있게 되고, User에게 Stateful 환경을 제공할 수 있게 된다.

### 4. 참조

* [http://www.gwtproject.org/doc/latest/DevGuideHtml5Storage.html](http://www.gwtproject.org/doc/latest/DevGuideHtml5Storage.html)
* [https://krishankantsinghal.medium.com/local-storage-vs-session-storage-vs-cookie-22655ff75a8](https://krishankantsinghal.medium.com/local-storage-vs-session-storage-vs-cookie-22655ff75a8)