---
title: Golang Google OIDC 이용
category: Programming
date: 2022-02-16T00:00:00Z
lastmod: 2022-02-16T00:00:00Z
comment: true
adsense: true
---

Golang을 활용하여 Google OIDC 기반의 Token을 획득하고 분석한다.

### 1. Test

### 2. Code

### 3. Token

{% highlight text %}
http://127.0.0.1:3000/auth/google/callback?state=HeLK6b0uTARRKUaX4fLqsw&code=4%2F0AX4XfWj1XzuCgumNoRlYBfzzeCSBzszRvXMlt1uYohiQDOYJ61NrFKIgDmuuOrM5m6JDKw&scope=email+profile+openid+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email&authuser=0&prompt=none
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 1] Callback URL</figcaption>
</figure>

{% highlight json %}
{
    "OAuth2Token": {
        "access_token": "ya29.A0ARrdaM9ORJsRuSy9s7k63RvRZxpSQsC_1ufHuLiafxH0mN1JzTCqb0abZoF2VAMzESSMFk7ir0pdML9hCawtvo__sJvmvA671pk6cW_VztdG9fb_10S4QCKkmaf8IkcTE9dPTUolp7ZH89DDCO1FYWJfON6C-w",
        "token_type": "Bearer",
        "expiry": "2022-02-18T01:08:28.186549937+09:00"
    },
    "IDTokenClaims": {
        "iss": "https://accounts.google.com",
        "azp": "554362356429-cu4gcpn45gb3incmm2v32sofslliffg2.apps.googleusercontent.com",
        "aud": "554362356429-cu4gcpn45gb3incmm2v32sofslliffg2.apps.googleusercontent.com",
        "sub": "113632458324056836621",
        "email": "supsup5642@gmail.com",
        "email_verified": true,
        "at_hash": "DCPA9BEHbfPo4BN2_qlvug",
        "nonce": "jbcf4kkkyU0ZLXy_59OdOg",
        "name": "신정섭",
        "picture": "https://lh3.googleusercontent.com/a/AATXAJzlONqtNnSJ0Qez5wk_7m2aCZ_xtoFjcyLFgxWy=s96-c",
        "given_name": "정섭",
        "family_name": "신",
        "locale": "ko",
        "iat": 1645110509,
        "exp": 1645114109
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 2] Access Token, ID Token</figcaption>
</figure>

### 4. 참조

* [https://www.daleseo.com/google-oidc/](https://www.daleseo.com/google-oidc/)
* [https://www.daleseo.com/google-oauth/](https://www.daleseo.com/google-oauth/)
* [https://opentutorials.org/course/2473/16571](https://opentutorials.org/course/2473/16571)
* [https://github.com/coreos/go-oidc](https://github.com/coreos/go-oidc)