---
title: Kubernetes Authentication Service Account
category: Theory, Analysis
date: 2021-04-25T12:00:00Z
lastmod: 2021-04-25T12:00:00Z
comment: true
adsense: true
---

Kubernetes Authentication 기법중 하나인 Service Account를 분석한다.

### 1. Kubernetes Authentication Service Account

![[그림 1] Kubernetes Service Account]({{site.baseurl}}/images/theory_analysis/Kubernetes_Authentication_Service_Account/Kubernetes_Service_Account.PNG){: width="700px"}

#### 1.1. Create Service Account

Controller Manager : --service-account-private-key-file=/etc/kubernetes/pki/sa.key

{% highlight json %}
# kubectl get serviceaccounts default -o yaml
apiVersion: v1
kind: ServiceAccount
...
secrets:
- name: default-token-d8wvm

# kubectl get secrets default-token-d8wvm -o yaml
apiVersion: v1
data:
  ca.crt: (BASE64)
  namespace: (BASE64)
  token: (BASE64)
kind: Secret
metadata:
...
type: kubernetes.io/service-account-token
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 1] Kubernetes Service Account 확인</figcaption>
</figure>

* token : 
* ca.crt : 
* namespace : 

{% highlight json %}
{
  "alg": "RS256",
  "kid": "DovKx1v1oJHU9-_TMhqvB0X-kEqX6Ex1B0sCplrIicc"
}
{
  "iss": "kubernetes/serviceaccount",
  "kubernetes.io/serviceaccount/namespace": "default",
  "kubernetes.io/serviceaccount/secret.name": "default-token-d8wvm",
  "kubernetes.io/serviceaccount/service-account.name": "default",
  "kubernetes.io/serviceaccount/service-account.uid": "45d65b20-49d0-40aa-8f6d-0af8a8196db6",
  "sub": "system:serviceaccount:default:default"
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 1] Kubernetes Service Account Token</figcaption>
</figure>

#### 1.2. Create Pod with Service Account

{% highlight yaml %}
...
spec:
  containers:
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: default-token-d8wvm
      readOnly: true
...
  serviceAccount: default
  serviceAccountName: default
...
  volumes:
  - name: default-token-d8wvm
    secret:
      defaultMode: 420
      secretName: default-token-d8wvm
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 2] Kubernetes Pod Spec</figcaption>
</figure>

#### 1.3. Use Service Account

API Server : --service-account-key-file=/etc/kubernetes/pki/sa.pub

{% highlight json %}
$ TOKEN="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
$ curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    "https://kubernetes.default.svc.cluster.local/oapi/v1/users/~" \
    -H "Authorization: Bearer $TOKEN"
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 2] Kubernetes Service Account 사용</figcaption>
</figure>

### 2. 참고

* [https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/#accessing-the-api-from-a-pod](https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/#accessing-the-api-from-a-pod)
* [https://docs.openshift.com/container-platform/3.4/dev_guide/service_accounts.html](https://docs.openshift.com/container-platform/3.4/dev_guide/service_accounts.html)
* [https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/)