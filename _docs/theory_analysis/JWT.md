---
title: JWT (JSON Web Token)
category: Theory, Analysis
date: 2020-06-20T12:00:00Z
lastmod: 2020-06-20T12:00:00Z
comment: true
adsense: true
---

JWT (JSON Web Token)을 분석한다.

### 1. JWT (JSON Web Token)

![[그림 1] JWT]({{site.baseurl}}/images/theory_analysis/JWT/JWT.PNG){: width="750px"}

JWT는 이름 그대로 JSON 기반의 Web Token을 의미한다. [그림 1]은 JWT의 구조 및 JWT의 생성 과정을 나타내고 있다. JWT는 Header, Payload, Signature 3부분으로 구성되어 있고, 각 부분은 "." (마침표)를 통해서 연결되어 있다. Header와 Payload는 JSON 기반의 Key-value 형태로 구성되어 있고, Signature는 Header와 Payload를 기반으로 생성된다.

#### 1.1. Header

Header에는 Type을 나타내는 "typ" Key와 Algorithm을 나타내는 "alg" Key가 존재한다. Type은 Token의 Type을 의미하며 JWT는 "JWT"라는 문자열을 고정값으로 갖는다. Algorithm은 Header와 Payload를 기반으로 Signature를 생성할때 이용하는 암호화 Algorithm을 의미한다. Header의 내용은 Base64로 Encoding되어 JWT에 저장된다.

#### 1.2. Payload

Payload에는 Token의 Meta Data와 Token이 전달하려는 실제 Data가 Key-value 형태로 저장된다. Payload Key-value는 Claim이라고 부르며 Claim에는 Reserved Claim과 Custom Claim으로 구분된다. Custom Claim은 다시 Public Claim과 Private Claim으로 구분된다. Reserved Claim은 Token의 Meta 정보를 저장한다. Reserved Claim의 이름으로는 Token의 발급자를 의미하는 "iss", Token의 이름을 나타내는 "sub", 토근의 발급시간을 나타내는 "iat" 등이 존재한다.

Custom Claim에는 Token이 전달하려는 실제 Data가 저장된다. Public Claim의 이름은 모두에게 공개되어 있으며, 각 Public Claim의 이름은 일반적으로 많이 전송하는 Data들을 나타낸다. 즉 Public Claim은 일반적으로 많이 전송하는 Data를 저장한다. Public Claim의 이름으로는 Full Name을 의미하는 "name", Email 주소를 의미하는 "email" 등의 존재한다. Private Claim의 이름은 Token을 주고 받는 App들의 협의하에 결정된 이름을 이용한다. [그림 1]의 "app" Key는 Private Claim의 Key를 나타내고 있다.

Reserved Claim과 Public Claim은 [링크](https://www.iana.org/assignments/jwt/jwt.xhtml#claims)에서 확인 가능하다. Payload의 내용 또한 Header처럼 Base64로 Encoding되어 JWT에 저장된다.

#### 1.3. Signature

JWT의 Header와 Payload는 Base64로 Encoding 되어 있기 때문에 누구든지 JWT의 Header와 Payload를 Decoding하여 확인할 수 있고, JWT를 가로채어 기존의 Payload를 조작된 Payload와 교체하는 일도 어렵지 않다. JWT에서는 이러한 보안 문제를 해결하기 위해서 Signature를 이용한다. Signature를 통해서 Header와 Payload가 조작되지 않았으며, 인증된 App으로부터 전송 되었다는걸 검증할 수 있다.

Signature는 Base64로 Encoding된 Header와 Payload를 "." (마침표)로 연결한 문자열과 사용자가 임의로 설정한 Password (대칭키, 비대칭키)를 이용하여 암호화 한다음, 다시 Base64로 Encoding하여 생성한다. JWT를 수신한 App은 수신한 JWT의 Header, Payload 및 자신이 알고 있는 Password를 이용하여 Signature를 생성한 다음, 수신한 JWT의 Signature와 비교한다. 만약 두 Signature가 동일하다면 해당 JWT는 유효하다는 의미한다.

Payload가 변경 되었거나 Password를 알지 못하는 (검증되지 않은) App이 엉뚱한 Password를 이용하여 Signature를 생성하여 JWT에 포함시켰다면, JWT의 Signature와 JWT의 수신한 App에서 생성한 Signature는 다를수 밖에 없기 때문이다. 이처럼 JWT는 외부의 도움없이 JWT 자체만으로도 자신이 유효하다는걸 검증할 수 있다.

JWT에서는 Signature 생성을 위해서 다양한 암호화 Algorithm을 이용할 수 있다. 일반적으로 대칭키 기반의 암호화가 필요한 경우에는 HMACSHA256 Algorithm을 많이 이용하고, 비대칭키 (공개키, 비공개키) 기반의 암호화가 필요한 경우에는 RSA256 Algorithm을 이용한다. [그림 1]에서는 HMACSHA256 Algorithm을 이용해 암호화 하는 과정을 나타내고 있다.

#### 1.4. 특징, 용도

JWT는 Payload에 원하는 Data를 저장할 수 있고, Signature를 이용하여 자신의 무결성을 검증할 수 있다. JWT처럼 자신에게 필요한 모든 정보를 담고 있는 특징을 **Self-contained**라고 표현한다. JWT의 Self-contained 특징은 JWT를 REST API Server와 같이 Stateless App에서 이용하기 유리하도록 만든다.

Stateless App의 가장 큰 장점은 자유로운 Scale Out이다. Stateless App에서 Self-containerd 특징을 갖고 있지 않는 Token, 즉 Token의 의미 파악과 유효성 검사를 외부 Token Server의 도움을 받아 진행해야 하는 Token을 이용한다면, Stateless App이 Scale Out 될때마다 외부 Token Server의 부하도 같이 증가한다. 이러한 외부 Token Server의 부하 증가는 Stateless App의 Scale Out을 방해하는 요소가 된다. JWT를 수신하는 App은 수신한 JWT의 의미 파악 및 유효성 검증을 App 스스로 수행할 수 있기 때문에 이러한 부하 문제가 발생하지 않는다.

JWT는 Payload에 인가 정보를 넣어 주로 Service의 인증/인가를 수행하는 Token으로 이용되거나, Web 환경에서 암호화 하여 Data를 주고받는 목적으로 이용된다.

### 2. 참조

* [https://velopert.com/2389](https://velopert.com/2389)
* [https://jwt.io/](https://jwt.io/)
* [http://www.opennaru.com/opennaru-blog/jwt-json-web-token/](http://www.opennaru.com/opennaru-blog/jwt-json-web-token/)
* [https://auth0.com/docs/tokens/concepts/jwt-claims](https://auth0.com/docs/tokens/concepts/jwt-claims)
* [https://community.apigee.com/questions/61057/is-the-jwt-signature-properly-encoded.html](https://community.apigee.com/questions/61057/is-the-jwt-signature-properly-encoded.html)
* Claim Type : [https://www.iana.org/assignments/jwt/jwt.xhtml#claims](https://www.iana.org/assignments/jwt/jwt.xhtml#claims)