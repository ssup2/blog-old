---
title: SAML 2.0
category: Theory, Analysis
date: 2020-06-26T12:00:00Z
lastmod: 2020-06-26T12:00:00Z
comment: true
adsense: true
---

SAML (Security Assertion Markup Language) 2.0을 분석한다.

### 1. SAML (Security Assertion Markup Language) 2.0

SAML 2.0은 SSO(Single Sign On)을 구성하기 위해서 많이 이용되는 인증 (Authentication) 및 인가 (Authorization) Protocol이다. 큰 조직의 경우 일반적으로 조직 전용 인증/인가 서버를 구축하며, 조직에 소속되어 있는 User가 조직 내부의 Service를 이용하기 위해서는 자체 구축된 인증/인가 서버와의 인증/인가 과정이 필요하다. 문제는 User가 Google, Facebook과 같은 Service Provider의 Service를 이용하기 위해서는 해당 Service Provider와의 별도의 인증/인가 과정이 필요하다는 점이다. 

SAML 2.0을 이용하여 SSO가 구축이되면 User는 Service Provider와의 인증/인가 과정없이 조직 전용 서버와의 인증/인과 과정만을 통해서 Service Provider의 Service도 이용할 수 있게 된다. 이러한 SAML 2.0 기반 SSO 과정은 인증/인가 정보를 저장하고 있는 **Assertion** 발급을 통해서 이루어진다. Assertion은 XML 형태로 인증/인가 정보를 저정하고 있다.

#### 1.1. Component

![[그림 1] SAML 2.0 Component]({{site.baseurl}}/images/theory_analysis/SAML_2.0/SAML_2.0_Component.PNG){: width="550px"}

[그림 1]은 Web 환경에서 SAML 2.0를 이용하여 인증/인가 기능을 구성했을때 SAML 2.0의 구성요소를 나타내고 있다. **User**는 Service 이용자를 의미한다. **User Agent**는 User의 입력을 받아 Service/Identity Provider에게 전달하거나, Service/Identity Provider으로부터 받은 내용을 User에게 보여주는 역할을 수행한다. 일반적으로는 Web Brower를 의미한다. 

**Service Provider**는 의미 그대로 User가 이용하고자 하는 Service를 제공하는 제공자를 나타낸다. 일반적으로 Google, Facebook과 같은 IT 기업에서 제공하는 API Server로 이해해도 된다. **Identity Provider**는 User의 인증/인가 정보를 저장하고 있으며 Service Provider에게 인증/인가 정보를 제공한다. 일반적으로 특정 조직에서 내부적으로 이용하는 인증/인가 Server로 이해해도 된다. Service Provider와 Identity Provider는 일반적으로 서로 다른 기업/조직으로 구성된다.

#### 1.3. Process

SAML 2.0 Component 사이에는 다음의 Request, Response를 주고 받는다.

* SAML Request : Service Provider가 Identity Provider에게 전달하는 인증 요청이다. XML Format을 이용한다.
* SAML Response : Identity Provider가 Service Provider에게 전달하는 인증 결과이다. XML Format을 이용한다.
* Relay State : Service Provider가 Identity Provider에게 SAML Request를 전송할때 같이 전송되며 Identity Provider가 저장하고 있다가, Identity Provider가 Service Provider에게 SAML Response를 전송할때 같이 전송하는 값이다. Service Provider는 SAML Response를 수신한 후 Relay State를 어떠한 동작을 이어서 진행할지 결정한다. Relay State는 주로 User가 가장 먼저 접근을 시도한 Service Provider의 URL을 저장하는 용도로 이용된다. 따라서 Service Provider는 SAML Response를 수신한 이후에 같이 전송되는 Relay State를 통해서 User를 다시 Redirect 시킨다. Relay State의 Format은 SAML 2.0에 정의되어 있지 않다. 따라서 Service Provider마다 다른 Format의 Relay State를 갖게된다.

SAML Request, SAML Response, Relay State를 Service Provider와 Identity Provider 사이에 주고 받기 위해서는, Identity Provider에 Service Provider가 이전에 등록되어 있어야 한다. SAML 2.0은 SAML Request, SAML Response, Relay State를 주고 받는 방식은 HTTP Redirect (URL Query) 또는 HTTP Post 이용하는 방식중에 선택할 수 있다.

##### 1.2.1. Service Provider HTTP Redirect, Identity Provider HTTP Post

![[그림 2] SAML 2.0 Process - Service Provider HTTP Redirect, Identity Provider HTTP Post]({{site.baseurl}}/images/theory_analysis/SAML_2.0/SAML_2.0_Process_SP_Redirect_IdP_Post.PNG){: width="700px"}

[그림 2]는 Service Provider의 경우 HTTP Redirect를 통해서 SAML Request와 Relay State를 Identity Provider에게 전송하고, Identity Provider는 HTTP Post Method의 Body를 통해서 SAML Response와 Relay State를 Service Provider에게 전송하는 과정을 나타내고 있다. SAML 2.0에서 가장 많이 이용되는 형태이다.

* 1,2 : User는 User Agent를 통해서 Service Provider의 URL에 접근하여 Service를 요청한다.
* 3 : Service Provider는 User Agent로부터 받은 요청에 인증/인가 정보가 없기 때문에, User Agent가 인증/인가 정보를 얻을 수 있도록 SAML Request, Relay State와 함께 Identitiy Provider로 **HTTP Redirect** 명령을 User Agent에게 전달한다. SAML Request와 Relay State는 Redirect되는 URL의 Query 형태로 전달된다.
* 4,5 : User Agent는 Identity Provider에 SAML Request, Relay State에 접근한다. Identity Provider는 URL Query에 존재하는 SAML Request와 Relay State를 바탕으로 인증 UI 구성하여 User Agent에게 전송한다.
* 6,7,8,9 : User가 Login을 수행하면 Identity Provider는 인증 이후에 User Agent가 SAML Response, Relay State를 Service Provider의 **ACS (Assertion Consumer Service)** URL로 **HTTP Post** 요청을 통해서 전달하도록 만든다. SAML Response, Relay State는 Post 요청의 Body로 전송된다.
* 10, 11 : User Agent는 HTTP Post 요청을 통해서 ACS URL로 접근한다. Service Provider의 ACS는 HTTP Post 요청의 Body에 존재하는 SAML Response의 Assertion 정보를 통해서 Session을 설정한다. 또한 HTTP Post 요청의 Body에 존재하는 Relay State를 통해서 User가 처음 접근을 시도했던 Service Provider의 URL을 찾아내고 다시 Redirect 시킨다.
* 12, 13 : User Agent는 Service Provider의 ACS가 설정한 Session을 통해서 Service Provider의 Service에 접근한다.

### 2. 참조

* [https://developer.okta.com/docs/concepts/saml/](https://developer.okta.com/docs/concepts/saml/)
* [https://docs.aws.amazon.com/ko_kr/IAM/latest/UserGuide/id_roles_providers_saml.html](https://docs.aws.amazon.com/ko_kr/IAM/latest/UserGuide/id_roles_providers_saml.html)
* [https://support.google.com/a/answer/6262987?hl=ko](https://support.google.com/a/answer/6262987?hl=ko)
* [https://en.wikipedia.org/wiki/SAML_2.0](https://en.wikipedia.org/wiki/SAML_2.0)
* [https://www.samltool.com/generic_sso_res.php](https://www.samltool.com/generic_sso_res.php)
* [https://stackoverflow.com/questions/28110014/can-saml-do-authorization](https://stackoverflow.com/questions/28110014/can-saml-do-authorization)
* [https://stackoverflow.com/questions/28117725/sso-saml-redirect-a-user-to-a-specified-landing-page-after-successful-log-in](https://stackoverflow.com/questions/28117725/sso-saml-redirect-a-user-to-a-specified-landing-page-after-successful-log-in)
