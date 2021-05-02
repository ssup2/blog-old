---
title: Kubernetes Authentication Webhook
category: Theory, Analysis
date: 2021-05-03T12:00:00Z
lastmod: 2021-05-03T12:00:00Z
comment: true
adsense: true
---

Webhook 기반 Kubernetes Authentication 기법을 분석한다.

### 1. Kubernetes Authentication Webhook

![[그림 1] Kubernetes Authentication Service Account]({{site.baseurl}}/images/theory_analysis/Kubernetes_Authentication_Webhook/Kubernetes_Authentication_Webhook.PNG){: width="700px"}

{% highlight yaml %}
apiVersion: v1
kind: Config
# clusters refers to the remote authentication server.
clusters:
  - name: authentication-server
    cluster:
      certificate-authority: authentication-server-ca-crt-path
      server: https://authentication-server.ssup2.com/authenticate

# users refers to the API server's webhook configuration.
users:
  - name: k8s-api-server
    user:
      client-certificate: k8s-api-server-crt-path
      client-key: k8s-api-server-crt-key-path

current-context: webhook
contexts:
- context:
    cluster: authentication-server
    user: k8s-api-server
  name: webhook
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 1] Webhook Config</figcaption>
</figure>

{% highlight json %}
{
  "apiVersion": "authentication.k8s.io/v1",
  "kind": "TokenReview",
  "spec": {
    "token": "<token>",
    "audiences": ["https://ssup2.com", "https://ssup3.com"]
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 2] TokenReview Spec</figcaption>
</figure>

{% highlight yaml %}
{
  "apiVersion": "authentication.k8s.io/v1",
  "kind": "TokenReview",
  "status": {
    "authenticated": true,
    "user": {
      "username": "ssup2",
      "groups": ["system:masters", "kube"]
    },
    "audiences": ["https://ssup2.com", "https://ssup3.com"]
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 3] TokenReview Status Success</figcaption>
</figure>

{% highlight yaml %}
{
  "apiVersion": "authentication.k8s.io/v1",
  "kind": "TokenReview",
  "status": {
    "authenticated": false,
    "error": "Credentials are expired"
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 4] TokenReview Status Failed</figcaption>
</figure>

### 2. 참고

* [https://kubernetes.io/docs/reference/access-authn-authz/authentication/#webhook-token-authentication](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#webhook-token-authentication)
* [https://coffeewhale.com/kubernetes/authentication/webhook/2020/05/05/auth04/](https://coffeewhale.com/kubernetes/authentication/webhook/2020/05/05/auth04/)