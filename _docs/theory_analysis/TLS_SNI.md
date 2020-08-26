---
title: TLS SNI (Server Name Indication)
category: Theory, Analysis
date: 2020-08-26T12:00:00Z
lastmod: 2020-08-26T12:00:00Z
comment: true
adsense: true
---

TLS의 SNI (Server Name Indication)를 분석한다.

### 1. SNI (Server Name Indication)

SNI는 TLS의 Handshake 과정중 가장 처음에 이루어지는 Hello 과정에 이용되는 TLS 확장 Field이다. 예전에는 하나의 Server(IP)에 하나의 Domain을 등록하여 이용하였다. 하지만 현재는 하나의 Server(IP)에 다수의 Domain을 등록하여 이용하고 있다. 이러한 이유 때문에 Client가 SNI가 없는 SSL을 통해서 다수의 Domain을 갖고 있는 Server에 인증서를 요청하는 경우, Server는 어떤 Domain의 인증서를 Client에 전달해야할지 정확히 알 수 없다.

![[그림 1] SNI를 이용한 TLS의 Handshake 과정]({{site.baseurl}}/images/theory_analysis/TLS_SNI/TLS_SNI.PNG){: width="600px"}

TLS의 SNI는 이러한 문제를 해결한다. [그림 1]은 SNI를 이용하는 TLS의 Handshake 과정을 나타내고 있다. 동작은 단순하다. Client는 Hello Message의 SNI Field에 어떤 Domain의 인증서를 받을지 명시하여 Server에게 전송한다. 그 후 Server는 Hello Message의 SNI Field에 비어있는 값을 전송하여 SNI 요청을 받은 사실을 Client에게 알린다. 그리고 Client로부터 요청을 받은 Domain의 인증서를 Client에게 전송한다. 이후의 Handshake 과정은 TLS/SSL의 Handshake 과정과 동일하다.

Client의 Hello Message는 암호화 되지 않고 Server에게 전송되기 때문에, SNI Field도 암호화 되지 않고 그대로 노출된다는 문제점을 갖고 있다.

### 2. 참조

* [https://msm8994.tistory.com/38](https://msm8994.tistory.com/38)
* [https://www.researchgate.net/figure/SNI-extension-of-the-TLS-handshake-protocol_fig6_321580115](https://www.researchgate.net/figure/SNI-extension-of-the-TLS-handshake-protocol_fig6_321580115)
