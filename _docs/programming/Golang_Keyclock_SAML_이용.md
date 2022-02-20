---
title: Golang Keycloak SAML 이용
category: Programming
date: 2022-02-20T00:00:00Z
lastmod: 2022-02-20T00:00:00Z
comment: true
adsense: true
---

Golang을 활용하여 Keycloak의 SAML을 이용하고 분석한다.

### 1. Keycloak 설치, 설정

~~~console
# docker run --name keycloak -p 8080:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin -d quay.io/keycloak/keycloak:17.0.0 start-dev
~~~

Docker를 이용하여 Keycloak을 설치한다. Keycloak의 Admin ID/Password는 admin/admin으로 설정한다.

### 2. Code

{% highlight golang linenos %}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Golang Google OIDC Example App</figcaption>
</figure>

### 3. 참조

* [https://www.keycloak.org/getting-started/getting-started-docker](https://www.keycloak.org/getting-started/getting-started-docker)
* [https://docs.anchore.com/3.0/docs/overview/sso/examples/keycloak/](https://docs.anchore.com/3.0/docs/overview/sso/examples/keycloak/)