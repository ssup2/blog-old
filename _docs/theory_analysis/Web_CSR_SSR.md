---
title: Web Client Side Rendering, Server Side Rendering
category: Theory, Analysis
date: 2022-01-05T12:00:00Z
lastmod: 2022-01-05T12:00:00Z
comment: true
adsense: true
---

Web의 Client Side Rendering 기법과 Server Side Rendering 기법을 분석한다.

### 1. Client Side Rendering (CSR)

![[그림 1] CSR]({{site.baseurl}}/images/theory_analysis/Web_CSR_SSR/CSR.PNG){: width="700px"}

CSR (Client Side Rendering) 기법은 Web Page Rendering을 Client인 Web Browser에서 모두 수행하는 기법을 의미한다. 여기서 Rendering을 수행한다 의미는 JavaScript를 수행하여 불완전한 형태의 HTML을 형태를 갖춘 HTML(DOM Tree)로 구성하는 과정을 의미한다. Web Browser는 형태를 갖춘 Web Page의 HTML을 얻을 수 있어야 Web Page를 UI로 나타낼 수 있다. Rendering 과정에는 필요에 따라서 외부의 Server로부터 Data를 가져오는 과정도 포함된다.

[그림 1]은 CSR 과정을 나타내고 있다. User가 특정 Web Page를 Web Browser를 통해서 Server에게 요청하면, Server는 Web Page의 HTML과 HTML에 내장된 JavaScript를 모두 Web Browser에게 전달한다. 이후 Web Browser는 Rendering을 수행하여 HTML을 구성하고, Web Page의 UI를 User에게 노출시킨다.

### 2. Server Side Rendering (SSR)

![[그림 2] SSR]({{site.baseurl}}/images/theory_analysis/Web_CSR_SSR/SSR.PNG){: width="700px"}

SSR (Server Side Rendering) 기법은 Web Page Rendering을 Server에서 수행하는 기법을 의미한다. [그림 2]는 SSR을 나타내고 있다. User가 특정 Web Page를 Web Browser를 통해서 Server에게 요청하면, Server는 Server 내부적으로 Rendering을 수행하여 형태를 갖춘 HTML을 Web Browser에게 전송한다.

형태를 갖춘 HTML을 수신한 Web Browser는 먼저 User에게 Web Page의 UI를 노출한다. 이때 User는 Web Page의 UI를 볼수만 있을뿐 Web Page를 조작할 수는 없다. 이후에 Web Browser는 Web Page에 필요한 추가적인 JavaScript들을 받은 다음 User가 완전히 Web Page를 이용할 수 있도록 만든다.

### 3. CSR vs SSR

CSR 기법에서 Server는 가지고 있는 HTML과 JavaScript를 Web Browser에게 전달만 해주면 되기 때문에 Server는 부하 없이 빠르게 응답이 가능하다. 또한 Rendering 되기전의 불완전한 HTML을 전송하는 방식이기 때문에, 전송하는 HTML의 크기도 일반적으로 Rendering된 HTML을 전송하는 SSR에 비해서 작은 편이다. 따라서 TTI (Time To Interactive) 측면에서는 일반적으로 CSR이 SSR보다 유리하다.

반면 SSR 기법에서는 Web Browser는 Rendering을 통해서 형태를 갖춘 HTML의 수신이 완료되면 추가적인 동작이 필요없이 바로 Web UI를 User에게 노출시킬 수 있기 때문에 FP (First Paint) 측면에는 SSR 기법이 CSR 기법보다 유리하다.

Server의 부하는 Rendering을 Server가 수행하는 SSR가 CSR에 비해서 높은편이다. SEO (Search Engine Optimization) 관점에서는 완전한 형태의 HTML을 전송해주는 SSR이 CSR에 비해서 유리하다. CSR 대신 SSR을 선택하는 가장 큰 이유는 일반적으로 FP (First Paint) 및 SEO의 이점을 가져 가기 위해서이다.

### 3. 참조

* [https://developers.google.com/web/updates/2019/02/rendering-on-the-web?hl=ko](https://developers.google.com/web/updates/2019/02/rendering-on-the-web?hl=ko)
* [https://medium.com/walmartglobaltech/the-benefits-of-server-side-rendering-over-client-side-rendering-5d07ff2cefe8](https://medium.com/walmartglobaltech/the-benefits-of-server-side-rendering-over-client-side-rendering-5d07ff2cefe8)
* [https://velog.io/@gkrba1234/SSR%EA%B3%BC-CSR%EC%97%90-%EB%8C%80%ED%95%B4-%EC%95%8C%EC%95%84%EB%B3%B4%EC%9E%90](https://velog.io/@gkrba1234/SSR%EA%B3%BC-CSR%EC%97%90-%EB%8C%80%ED%95%B4-%EC%95%8C%EC%95%84%EB%B3%B4%EC%9E%90)