---
title: CORS (Cross-Origin Resource Sharing)
category: Theory, Analysis
date: 2021-12-31T12:00:00Z
lastmod: 2021-12-31T12:00:00Z
comment: true
adsense: true
---

CORS (Cross-Origin Resource Sharing)을 분석한다.

### 1. CORS (Cross-Origin Resource Sharing)

CORS (Cross-Origin Resource Sharing)는 Web Application이 다른 출처의 Resource에 접근할 수 있는 권한을 부여하는 기법이다. 여기서 Web Application은 Web Browser에서 실행되는 **JavaScript**라고 이해하면 되고, 출처는 **Origin**이란 단어로 표현된다.

User가 Web Browser를 통해서 "https://ssup2.com"에 접속하면 Web Browser는 "https://ssup2.com"으로부터 JavaScript를 받아 수행한다. 이때 받은 JavaScript 내부에서는 "https://ssup2.github.io"의 Resource를 받아오는 동작이 포함될 수 있다. 이 경우 Web Browser가 접속한 Origin(https://ssup2.com)이 아닌 다른 Origin (Cross-Origin, https://ssup2.github.io)의 Resource를 이용해야하기 때문에, Web Browser는 CORS 기법을 이용해야 한다. Web Browser는 CORS를 통해서 "https://ssup2.github.io"으로 부터 Resource 사용허가를 먼저 받은 다음, "https://ssup2.github.io"의 Resource에 접근한다.

CORS 기법이 존재하지 않는다면 Cross-Origin에서는 Web Browser가 허락된 Resource를 요청하는지 판별할 수 없게 된다. 또한 CORS 기법을 통해서 악의적 JavaScript로 인해서 User의 Web Browser가 악의적인 동작을 수행하는것을 어느정도 방지할 수 있다. CORS 기법이 존재하기 전에는 이와 같은 보안적 이유로 인해서 JavaScript 내부에서는 Cross-Origin의 Resource를 이용할 수 없었다.

#### 1.1. Origin

![[그림 1] Origin]({{site.baseurl}}/images/theory_analysis/CORS/Origin.PNG){: width="400px"}

[그림 1]은 Origin의 정의를 나타내고 있다. **Scheme, Host, Port의 조합**이 하나의 Origin을 나타낸다. 따라서 "https://ssup2.com"와 "https://ssup2.github.io"는 서로 다른 Origin이기 때문에 CORS 기법이 이용된다. 반면 "https://ssup2.com"와 "https://ssup2.com/category"는 동일한 Origin이기 때문에 CORS 기법없이 이용되지 않는다.

#### 1.2. CORS Process

![[그림 2] CORS Preflight]({{site.baseurl}}/images/theory_analysis/CORS/CORS_Preflight_Process.PNG)

![[그림 3] CORS Simple Request]({{site.baseurl}}/images/theory_analysis/CORS/CORS_Simple_Request_Process.PNG)

#### 1.3. CORS Header

### 2. 참조

* [https://ko.javascript.info/fetch-crossorigin](https://ko.javascript.info/fetch-crossorigin)
* [https://developer.mozilla.org/ko/docs/Web/HTTP/CORS](https://developer.mozilla.org/ko/docs/Web/HTTP/CORS)
* [https://evan-moon.github.io/2020/05/21/about-cors/](https://evan-moon.github.io/2020/05/21/about-cors/)