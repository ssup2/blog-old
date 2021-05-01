---
title: Kubernetes Authentication OIDC
category: Theory, Analysis
date: 2021-04-29T12:00:00Z
lastmod: 2021-04-29T12:00:00Z
comment: true
adsense: true
---

OIDC 기반 Kubernetes Authentication 기법을 분석한다.

### 1. Kubernetes Authentication OIDC

![[그림 1] Kubernetes Authentication OIDC]({{site.baseurl}}/images/theory_analysis/Kubernetes_Authentication_OIDC/Kubernetes_Authentication_OIDC.PNG)

Kubernetes는 OIDC 기반의 인증 기법을 제공한다. [그림 1]은 OIDC 기반의 Kubernetes 인증 기법을 나타내고 있다. Kubernetes Client (kubectl)은 Identity Provider에게 **client_id**와 **client_secret**을 전달하여 인증을 하고 **id_token**을 얻어온다. Identity Provider가 전달하는 id_token은 인증된 App/User의 정보가 **JWT** 형태로 저장되어 있다. id_token을 얻은 Kubernetes Client는 id_token을 **Authorization: Bearer $TOKEN** Header로 전달하여 Kubernetes API Server에게 인증 받는다.

### 2. 참고

* [https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens)
* [https://coffeewhale.com/kubernetes/authentication/oidc/2020/05/04/auth03/](https://coffeewhale.com/kubernetes/authentication/oidc/2020/05/04/auth03/)