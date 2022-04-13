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

![[그림 1] OIDC Component]({{site.baseurl}}/images/theory_analysis/OIDC/OIDC_Component.PNG){: width="700px"}

OIDC는 OAuth 2.0을 기반으로 **인증(Authentication)**을 수행하는 인증 Protocol이다. OIDC는 SSO (Single Sign On)을 구성하는데 많이 이용되고 있다. OAuth 2.0는 인가(Authorization)만을 수행하는 Protocol이기 때문에 OAuth 2.0 환경에서 인증 시스템도 필요한 경우에는 OIDC를 도입하여 해결할 수 있다. [그림 1]은 Web 환경에서 OIDC를 이용할 경우 OIDC 관련 Component를 나타내고 있다.

OIDC는 OAuth 2.0을 기반으로 하기 때문에, OIDC의 Component는 OAuth 2.0 Component와 거의 동일하다. OIDC에서는 App에게 인증 정보를 제공하는 구성 요소를 **Identity (OIDC) Provider**라고 명칭한다. Identity Provider는 OAuth 2.0 관점에서는 인증에 필요한 User 정보를 저장하고 있는 Resource Server와 Authorization Server의 조합으로 구성된다. 여기서 Authorization Server는 App에게 Access Token을 통한 인가 정보뿐만 아니라, User의 정보를 저장하고 있는 **ID Token**이라고 불리는 Token을 App에게 전달하여 인증 Server의 역활도 수행한다.

#### 1.1. ID Token

OIDC는 App에게 User의 인증 정보를 전달하기 위해서 ID Token을 이용한다. ID Token은 **JWT**로 구성되어 있다. App은 JWT를 통해서 ID Token이 Identity Provider가 생성한 Token이라는 사실과, ID Token의 내용이 변조되지 않았다는 사실을 보장 받을 수 있다. ID Token(JWT)의 Signature 생성은 일반적으로 Identity Provider의 비공개키로 이루어진다. 따라서 ID Token을 검증은 Identity Provider의 공개키를 통해서 이루어진다.

ID Token에는 일반적으로 다음과 같은 Claim을 포함하고 있다.

* iss (Issuer) : ID Token의 발급자를 의미한다.
* sub (Subject) : ID Token에 저장된 User의 식별자를 의미한다.
* aud (Audience) : ID Token을 수신하고 이용하는 주체를 의미힌다. 일반적으로 Identity Provider에게 전달하는 Client ID가 Audience Claim에 설정된다.
* exp (Expiration): : ID Token의 만료 시간을 의미한다.

![[그림 1] OIDC의 ID Token 발급 과정]({{site.baseurl}}/images/theory_analysis/OIDC/OIDC_ID_Token_Flow.PNG)

[그림 1]은 OIDC의 ID Token 발급 과정을 나타내고 있다. ID Token의 발급 과정은 OAuth 2.0의 Access Token을 발급받는 과정과 거의 동일하다. 단 마지막 12번 과정에서 Authorization Server로부터 Access Token 대신 ID Token이 App에게 전달된다는 점이 다르다. 필요에 따라서는 App은 ID Token 뿐만 아니라 OAuth 2.0의 Access Token, Refresh Token도 같이 전달받을 수 있다.

### 2. 참조

* [https://www.oauth.com/oauth2-servers/openid-connect/id-tokens/](https://www.oauth.com/oauth2-servers/openid-connect/id-tokens/)
* [https://coffeewhale.com/kubernetes/authentication/oidc/2020/05/04/auth03/](https://coffeewhale.com/kubernetes/authentication/oidc/2020/05/04/auth03/)
* [https://darutk.medium.com/understanding-id-token-5f83f50fa02e](https://darutk.medium.com/understanding-id-token-5f83f50fa02e)
* [https://benohead.com/blog/2018/07/05/oauth-2-0-openid-connect-explained/](https://benohead.com/blog/2018/07/05/oauth-2-0-openid-connect-explained/)
