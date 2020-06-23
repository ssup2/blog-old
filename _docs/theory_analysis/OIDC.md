---
title: OIDC (OpenID Connect)
category: Theory, Analysis
date: 2020-06-26T12:00:00Z
lastmod: 2020-06-26T12:00:00Z
comment: true
adsense: true
---

OIDC (OpenID Connect)를 분석한다.

### 1. OIDC (OpenID Connect)

OIDC는 OAuth 2.0을 기반으로 인증(Authentication)을 수행하는 인증 Layer이다. OAuth 2.0는 인가(Authorization)만을 수행하는 Protocol이기 때문에 인증도 같이 필요한 경우에는 OICD를 도입하여 해결할 수 있다. OIDC는 인증을 위해서 **ID Token**이라고 불리는 추가 Token을 이용한다. ID Token은 App 이용을 위해서 인증 과정을 거친 App 사용자의 정보가 포함된 Token이다. App은 ID Token의 App 사용자 정보를 통해서 현재 App을 누가 이용하고 있는지 확인할 수 있다.

![[그림 1] OIDC의 ID Token 발급 과정]({{site.baseurl}}/images/theory_analysis/OIDC/OIDC_ID_Token_Flow.PNG)

[그림 1]은 OIDC의 ID Token의 발급 과정을 나타내고 있다. ID Token은 OAuth 2.0에 따라서 사용자 인증을 수행한 Authorization Server에서 Access Token이 발급될때 같이 발급되어 App에게 전달된다. 즉 OIDC가 적용된 OAuth 2.0의 Authorization Server는 인가 Server 역활 뿐만아니라 인증 Server 역활도 수행한다.

ID Token은 **JWT**로 구성되어 있다. JWT에는 필요한 Data를 자유롭게 저장할 수 있다. 또한 JWT를 이용하는 App은 JWT가 갖고 있는 Signature를 통해서 외부의 도움없이 스스로 JWT가 갖고 있는 Data가 유효한 Data인지 확인할 수 있다. 따라서 Authorization Server는 App에서 필요한 사용자 정보를 자유롭게 추가하여 ID Token을 생성할 수 있고, ID Token을 이용하는 App은 Authorization Server의 도움없이 ID Token의 사용자 정보가 유효한 정보인지 확인할 수 있다.

### 2. 참조

* [https://www.oauth.com/oauth2-servers/openid-connect/id-tokens/](https://www.oauth.com/oauth2-servers/openid-connect/id-tokens/)
