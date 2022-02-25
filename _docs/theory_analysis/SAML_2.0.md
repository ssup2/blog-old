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

#### 1.2. Process

![[그림 2] SAML 2.0 Process]({{site.baseurl}}/images/theory_analysis/SAML_2.0/SAML_2.0_Process.PNG){: width="700px"}

[그림 2]는 SAML 2.0의 처리 과정을 나타내고 있다.

* 1,2 : User는 User Agent를 통해서 Service Provider의 URL에 접근하여 Service를 요청한다.
* 3 : Service Provider는 User Agent로부터 받은 요청에 인증/인가 정보가 없기 때문에, User Agent가 인증/인가 정보를 얻을 수 있도록 SAML Request와 함께 Identitiy Provider로 Redirect 명령을 User Agent에게 전달한다. 여기서 SAML Request는 User 인증 요청를 의미한다. Service Provider는 설정에 의해서 Identity Provider의 위치 및 정보를 이전에 알고 있어야 한다.
* 4,5,6,7,8,9 : User Agent는 Identity Provider로 접근하여 User에게 인증 UI를 보여주어 User의 Login을 통해서 인증 정보를 Identity Server에게 전달하고 SAML Response를 얻는다. SAML Response에는 인증/인가 정보가 저장되어 있는 Assertion이 포함되어 있다. 또한 User Agent는 Identitiy Provider로부터 SAML Response와 함께 Service Provider의 **ACS (Assertion Consumer Service)**로 Redirect 명령도 전달 받는다. Identity Provider는 설정에 의해서 Service Provider의 ACS 정보를 이전에 알고 있어야 한다.
* 10, 11 : User Agent는 얻은 SAML Response와 함께 Service Provider의 ACS로 접근한다. Service Provider의 ACS는 SAML Response의 Assertion 정보를 확인하고 User Agent에게 Session 정보를 전달한다. 그리고 원래 User Agent를 처음 접근하려고 했던 Service Provider의 URL로 다시 Redirect 시킨다.
* 12, 13 : User Agent는 받은 Session 정보를 통해서 Session을 설정하고 처음에 접근하려고 했던 Service URL에 다시 접근하여 Service를 이용한다. Session이 설정된 User Agent는 이후 자유롭게 Service Provider의 Service를 이용할 수 있게 된다.

### 2. 참조

* [https://developer.okta.com/docs/concepts/saml/](https://developer.okta.com/docs/concepts/saml/)
* [https://docs.aws.amazon.com/ko_kr/IAM/latest/UserGuide/id_roles_providers_saml.html](https://docs.aws.amazon.com/ko_kr/IAM/latest/UserGuide/id_roles_providers_saml.html)
* [https://support.google.com/a/answer/6262987?hl=ko](https://support.google.com/a/answer/6262987?hl=ko)
* [https://en.wikipedia.org/wiki/SAML_2.0](https://en.wikipedia.org/wiki/SAML_2.0)
* [https://www.samltool.com/generic_sso_res.php](https://www.samltool.com/generic_sso_res.php)
* [https://stackoverflow.com/questions/28110014/can-saml-do-authorization](https://stackoverflow.com/questions/28110014/can-saml-do-authorization)
* [https://stackoverflow.com/questions/28117725/sso-saml-redirect-a-user-to-a-specified-landing-page-after-successful-log-in](https://stackoverflow.com/questions/28117725/sso-saml-redirect-a-user-to-a-specified-landing-page-after-successful-log-in)
