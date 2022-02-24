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

### 2. 인증서 생성

~~~console
# openssl req -x509 -newkey rsa:2048 -keyout myservice.key -out myservice.cert -days 365 -nodes -subj "/CN=myservice.example.com"
~~~

### 3. Code

{% highlight golang linenos %}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Golang Google OIDC Example App</figcaption>
</figure>

### 4. 참조

* [https://www.keycloak.org/getting-started/getting-started-docker](https://www.keycloak.org/getting-started/getting-started-docker)
* [https://docs.anchore.com/3.0/docs/overview/sso/examples/keycloak/](https://docs.anchore.com/3.0/docs/overview/sso/examples/keycloak/)
* [https://github.com/crewjam/saml](https://github.com/crewjam/saml)
* [https://goteleport.com/blog/how-saml-authentication-works/](https://goteleport.com/blog/how-saml-authentication-works/)
* [https://www.rancher.co.jp/docs/rancher/v2.x/en/admin-settings/authentication/keycloak/](https://www.rancher.co.jp/docs/rancher/v2.x/en/admin-settings/authentication/keycloak/)