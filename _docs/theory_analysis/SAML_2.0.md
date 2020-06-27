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

SAML 2.0은 SSO SSO(Single Sign On)을 구성하기 위해서 많이 이용되는 인증 (Authentication)과 인가 (Authorization) Protocol이다. SAML 2.0 Protocol은 의미 그대로 인증, 인가 정보를 담고 있는 **Assertion**을 발급하고 이용한다.

#### 1.1. Component

![[그림 1] SAML 2.0 Component]({{site.baseurl}}/images/theory_analysis/SAML_2.0/SAML_2.0_Component.PNG){: width="550px"}

[그림 1]은 SAML 2.0의 구성요소를 나타내고 있다. User는 Service 이용자를 의미한다. User Agent는 User의 입력을 받아 Service/Identity Provider에게 전달하거나, Service/Identity Provider으로부터 받은 내용을 User에게 보여주는 역활을 수행한다. 일반적으로는 Web Brower를 의미한다. Service Provider는 의미 그대로 User가 이용하고자 하는 Service를 제공한다. Identity Provider는 Service Provider에게 인증, 인가 정보를 제공한다.

#### 1.2. Process

![[그림 2] SAML 2.0 Process]({{site.baseurl}}/images/theory_analysis/SAML_2.0/SAML_2.0_Process.PNG){: width="700px"}

### 2. 참조

* [https://developer.okta.com/docs/concepts/saml/](https://developer.okta.com/docs/concepts/saml/)
* [https://support.google.com/a/answer/6262987?hl=ko](https://support.google.com/a/answer/6262987?hl=ko)
* [http://saml.xml.org/assertions](http://saml.xml.org/assertions)
