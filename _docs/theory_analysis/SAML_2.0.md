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

SAML 2.0은 SSO SSO(Single Sign On)을 구성하기 위해서 많이 이용되는 인증 (Authentication) 및 인가 (Authorization) Protocol이다. SAML 2.0은 **인증 및 인가 정보를 담고 있는 Assertion**을 발급하고 이용하는 과정을 정의하고 있다. Assertion은 XML 형태로 인증 및 인가 정보를 저정하고 있다.

#### 1.1. Component

![[그림 1] SAML 2.0 Component]({{site.baseurl}}/images/theory_analysis/SAML_2.0/SAML_2.0_Component.PNG){: width="550px"}

[그림 1]은 Web 환경에서 SAML 2.0를 이용하여 인증 및 인가 기능을 구성했을때 SAML 2.0의 구성요소를 나타내고 있다. User는 Service 이용자를 의미한다. User Agent는 User의 입력을 받아 Service/Identity Provider에게 전달하거나, Service/Identity Provider으로부터 받은 내용을 User에게 보여주는 역활을 수행한다. 일반적으로는 Web Brower를 의미한다. Service Provider는 의미 그대로 User가 이용하고자 하는 Service를 제공한다. Identity Provider는 Service Provider에게 인증 및 인가 정보를 제공한다.

#### 1.2. Process

![[그림 2] SAML 2.0 Process]({{site.baseurl}}/images/theory_analysis/SAML_2.0/SAML_2.0_Process.PNG){: width="700px"}

[그림 2]는 SAML 2.0의 처리과정을 나타내고 있다.

* 1,2 : User는 User Agent를 통해서 Service Provider의 URL에 접근하여 Service를 요청한다.
* 3 : Service Provider는 User Agent로부터 받은 요청에 인증 및 인가 정보가 없기 때문에, User Agent가 인증 및 인가 정보를 얻을 수 있도록 SAML Request와 함께 Identitiy Provider로 Redirect 명령을 User Agent에게 전달한다. 여기서 SAML Request는 User 인증 Request를 의미한다. Service Provider는 설정에 의해서 Identity Provider의 위치를 알고 있어야 한다.
* 4,5,6,7,8,9 : User Agent는 Identity Provider로 접근하여 User에게 인증 UI를 보여주어 User의 Login을 통해서 인증 정보를 Identity Server에게 전달하고 SAML Response를 얻는다. SAML Response에는 인증 및 인가 정보가 저장되어 있는 Assertion이 포함되어 있다.
* 10, 11 : User Agent는 얻은 SAML Response를 바탕으로 Service Provider와 Session을 얻는다.
* 12, 13 : User Agent는 Session을 통해서 원래 얻으려고 했던 Service를 다시 요청하여 얻은 다음 User에게 보여준다. 이후 Session을 얻은 User Agent는 User에 요청에 따라서 인가된 Service를 자유롭게 얻어 User에게 보여준다.

### 2. 참조

* [https://developer.okta.com/docs/concepts/saml/](https://developer.okta.com/docs/concepts/saml/)
* [https://support.google.com/a/answer/6262987?hl=ko](https://support.google.com/a/answer/6262987?hl=ko)
* [https://en.wikipedia.org/wiki/SAML_2.0](https://en.wikipedia.org/wiki/SAML_2.0)
