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

Kubernetes는 OIDC 기반의 인증 기법을 제공한다. [그림 1]은 OIDC 기반의 Kubernetes 인증 기법을 나타내고 있다. Kubernetes Client (kubectl)은 Identity Provider에게 **client_id**와 **client_secret**을 전달하여 인증을 하고 **ID Token**을 얻어온다. Identity Provider가 전달하는 ID Token은 인증된 App/User의 정보가 **JWT** 형태로 저장되어 있다. ID Token을 얻은 Kubernetes Client는 ID Token을 **Authorization: Bearer $TOKEN** Header를 통해서 Kubernetes API Server에 전달하여 Kubernetes API Server에게 인증 받는다.

#### 1.1. ID Token Validation

Kubernetes API Server는 ID Token이 유효한지 확인하기 위해서는 **ID Token를 발행한 Identity Provider의 정보**가 포함되어 있는 HTTPS URL 정보가 필요하다. Kubernetes API Server의 "--oidc-issuer-url" Option을 통해서 Identity Provider의 HTTPS URL을 지정할 수 있다. [그림 1]에서 Identity Provider는 "https://accounts.google.com"이기 때문에 "--oidc-issuer-url" Option에 "https://accounts.google.com"을 지정하면 된다. ID Token의 **iss Claim**에도 ID Token의 Identity Provider가 저장되어 있는것을 확인할 수 있다.

"--oidc-issuer-url" Option에 "https://accounts.google.com"가 설정되어 있다면 OpenID Discovery 1.0 표준에서 정의된 경로인 ".well-known/openid-configuration" 경로를 추가하여 "https://accounts.google.com/.well-known/openid-configuration" 경로에서 Identity Provider의 정보를 얻어온다. 또한 Kubernetes API Server는 "--oidc-client-id" Option을 통해서 얻은 Client ID를 통해서 ID Token이 유효한 Client ID를 갖고 있는지도 확인한다. ID Token의 **aud Claim**에 ID Token의 Client ID가 저장된다.

{% highlight yaml %}
kind: RoleBinding
metadata:
  name: ssup2-user-role-binding
  namespace: default
subjects:
- kind: User
  name: https://accounts.google.com#ssup2
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: role-name
  apiGroup: rbac.authorization.k8s.io
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 1] Role Binding with User</figcaption>
</figure>

Kubernetes API Server는 기본적으로 ID Token의 **sub Claim**을 User 이름으로 간주한다. 여기에 Identiy Provider의 HTTPS URL + "#" 문자열이 Prefix로 붙어 Kubernetes API Server 내부에서 User로 이용한다. 따라서 [그림 1]의 ID Token의 경우에는 "https://accounts.google.com#ssup2"라는 User를 나타낸다. 이 User에 Role을 부여하기 위해서는 [Text 1]과 같이 "https://accounts.google.com#ssup2" User에게 Cluster Role Binding, Role Bing을 통해서 Role을 부여하면 된다. Kubernetes API Server의 "--oidc-username-claim" Option과 "--oidc-username-prefix" Option을 통해서 User 이름의 Claim과 Prefix를 변경할 수 있다.

ID Token에 User 이름과 동일하게 Group 정보도 포함될 수 있다. Group Claim은 Kubernetes API Server의 "--oidc-groups-claim" Option을 통해서 반드시 설정해야 한다. "--oidc-groups-claim" Option에 "groups"로 설정되어 있다면 [그림 1]의 ID Token은 "system:masters" Group과, "kube" Group에 소속된 User를 나타낸다. "--oidc-groups-prefix" Option을 통해서 User와 동일하게 Prefix를 붙이도록 설정할 수도 있다. kubectl의 경우 "--token" Option을 통해서 ID Token을 설정하고 이용할 수 있다.

### 2. 참고

* [https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens)
* [https://coffeewhale.com/kubernetes/authentication/oidc/2020/05/04/auth03/](https://coffeewhale.com/kubernetes/authentication/oidc/2020/05/04/auth03/)