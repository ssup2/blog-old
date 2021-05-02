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

Kubernetes는 Webhook 기반의 인증 기법을 제공한다. Webhook 기반의 인증 기법은 다양한 형태의 외부 인증서버와 연동할 수 있다는 장점을 갖고 있다. 
[그림 1]은 Webhook 기반의 Kubernetes 인증 기법을 나타내고 있다. Kubernetes Client (kubectl)은 외부 인증서버에게 인증과정을 통해서 Token을 얻어온다. Token을 얻은 Kubernetes Client는 Token을 **Authorization: Bearer $TOKEN** Header를 통해서 Kuberenetes API Server에 전달한다. Token을 전달받은 Kubernetes API Server는 외부의 인증 서버에게 Token 정보가 포함된 TokenReview Object를 전달하여 인증받는다.

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