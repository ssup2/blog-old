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

Kubernetes의 Service Account는 Kubernetes Cluster 내부에서 Object로 관리되는 계정이다. Service Account는 Pod 안의 App 또는 Kubernetes Cluster의 User가 Kubernetes API Server에게 인증할 때 이용된다. [그림 1]은 Service Account를 생성, Service Account를 Pod에 주입, Service Account를 이용하는 과정을 나타내고 있다.

#### 1.1. Service Account

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
<figcaption class="caption">[Text 1] Kubernetes default Service Account Token</figcaption>
</figure>

각 Service Account는 token, ca.crt, namespace 3가지의 정보를 저장하고 있다. **token**은 Kubernetes API Server에 인증할때 이용하는 Token을 의미한다. **JWT** 형태로 되어 있으며 **만료기간이 없는** 특징을 갖고 있다. [Text 1]은 Kubernetes Cluster의 default Service Account의 token을 Decoding한 결과이다. default Service Account와 관련되 정보가 저장되어 있는것을 확인할 수 있다.

**ca.crt**는 Kubernetes API Server가 이용하는 Private Root CA 인증서를 나타낸다. 따라서 대부분의 경우 모든 Service Account의 ca.crt는 동일하다. ca.crt는 Service Account를 이용하는 Client가 Kubernetes API Server에 접근할때 이용된다. **namespace**는 Service Account가 존재하는 Namespace를 나타낸다. Service Account는 각 Namespace마다 별도로 존재하는 Object이다.

##### 1.1.1. default Service Account

{% highlight console %}
# kubectl get sa -A | grep default                           [13:42:56]
cert-manager      default                              1         20d
default           default                              1         20d
kube-system       default                              1         20d
type: kubernetes.io/service-account-token
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 1] Kubernetes Service Account</figcaption>
</figure>

Kubernetes에서는 각 Namespace에 "default" 이름을 갖는 Service Account를 자동으로 생성한다. [Console 1]은 각 Namespace 마다 존재하는 "default" Service Account를 나타내고 있다. "default" Service Account는 Pod 생성시 Pod가 이용할 Service Account를 명시하지 않으면 Pod가 기본적으로 이용하는 Service Account이다. Pod가 "kube-system" Namespace에 생성되었고, Pod가 이용하는 Service Account가 명시되지 않았다면, 해당 Pod는 "kube-system" Namespace의 "default" Service Account를 이용하게 된다.

Namespace가 생성될때 "default" Service Account를 생성하거나, Namespace가 제거될때 "default" Service Account를 삭제하는 역활은 Kubernetes Controller Manager의 **serviceacount** Controller가 수행한다.

#### 1.2. Create Service Account

{% highlight console %}
# kubectl get serviceaccounts default -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: default
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
  name: default-token-d8wvm
...
type: kubernetes.io/service-account-token
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 2] Kubernetes Service Account 확인</figcaption>
</figure>

Kubernetes에서 Service Account의 token, ca.crt, namespace는 Service Account에 직접 저장되지 않고, Service Account에 명시되어 있는 Secret에 저장되어 있다. [Console 2]는 "default" Service Account에 명시된 Secret에 저장되어 있는 token, ca.crt, namespace 정보를 확인하는 과정을 나타내고 있다.

Kubernetes Client에 의해서 Service Account가 생성이 되면, Kubernetes Controller Manager의 serviceaccount-token Controller는 생성된 Service Account 정보를 Kubernetes API Server로부터 얻은 다음, token, ca.crt, namespace 정보가 포함된 Secret을 생성한다. 이후에 생성한 Secret의 이름을 Service Account에 저장하여 Service Account 설정을 마친다.

[Text 1]에 보면 JWT Token이 RSA256 비대칭 암호화 알고리즘을 이용하여 Signing된 것을 확인할 수 있다. JWT Signing시 이용한 Key는 Controller Manager의 "--service-account-private-key-file" Option을 통해서 지정한다.

#### 1.3. Create Pod with Service Account

Pod가 생성될때 Service Account를 지정하지 않으면 Pod가 존재하는 Namespace의 "default" Service Account를 이용하도록 Kubernetes가 강제로 설정한다. 이러한 강제 설정은 Kubernetes API Server에 존재하는 ServiceAccount Admission Controller에 의해서 이루어진다. 

Kubernetes Client로부터 Pod 생성 요청을 받은 Kubernetes API Server는 Pod 생성 요청을 ServiceAccount Admission Controller에 전송한다. ServiceAccount Admission Controller는 Pod의 Spec을 변경(Mutation)하여 Pod 내부에서 Service Account를 이용할 수 있도록 만든다.

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

ServiceAccount Admission Controller는 Pod 생성 요청에 포함된 Pod의 Spec을 보고 Spec에 Service Account가 명시되어 있지 않는다면 "default" Service Account를 이용하도록 Pod의 Spec을 변경한다. 또한 Service Account에 포함된 token, ca.crt, namespace를 Pod 내부에서 접근 가능하도록 Volume으로 Mount 하도록 Pod의 Spec을 변경한다. [Text 2]는 ServiceAccount Admission Controller가 변경하는 Pod의 Spec을 나타내고 있다.

{% highlight console %}
# ls /var/run/secrets/kubernetes.io/serviceaccount
ca.crt  namespace  token
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 3] Kubernetes Pod 내부에서 token, ca.crt, namespace 확인</figcaption>
</figure>

Volume이 기본적으로 Mount되는 경로는 "/var/run/secrets/kubernetes.io/serviceaccount"로 설정된다. 따라서 Pod 내부에서 "/var/run/secrets/kubernetes.io/serviceaccount" 경로에 들어가면 token, ca.crt, namespace 파일을 확인할 수 있게된다. 만약 Pod의 Spec에 이용할 Service Account가 명시되어 있다면, ServiceAccount Admission Controller는 명시된 Service Account를 Pod 내부에서 이용할 수 있도록 Volume 관련 Spec만 변경한다.

#### 1.4. Use Service Account

Service Account의 Token을 알고 있는 Kubernetes Client (kubectl)은 Service Account의 Token을 Kubernetes API Server에게 전달하여 인증을 진행한다. Service Account의 Token은 **Authorization: Bearer $TOKEN** Header로 전달하면 된다. Service Account의 Token을 전달받은 Kubernetes API Server는 "--service-account-key-file" Option으로 설정된 Key를 이용하여 Token이 유효한지 검증한다.

따라서 Controller Manager의 "--service-account-private-key-file" Option으로 설정된 Key와 Kubernetes API Server의 "--service-account-key-file" Option으로 설정된 Key는 반드시 서로 비대칭 Key Pair 관계를 갖고 있어야한다. 또한 Kubernetes API Server는 Private Root CA 인증서를 이용하기 때문에 Client도 Kubernetes API Server의 Private Root CA 인증서를 갖고 있어야 한다.

##### 1.4.1. in Pod

{% highlight console %}
$ TOKEN="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
$ curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt "https://kubernetes.default.svc.cluster.local/api/v1/nodes" -H "Authorization: Bearer $TOKEN"
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 4] Kubernetes Service Account 사용</figcaption>
</figure>

Pod 내부에서는 curl 명령어를 통해서 간단하게 Service Account를 이용할 수 있다. [Console 4]는 Pod 내부에서 curl 명령어를 통해서 Service Account를 이용하는 방법을 나타내고 있다. Pod 내부에서 확인할 수 있는 Service Account의 Token과 Kubernetees API Server의 ca.crt를 이용하면 된다.

##### 1.4.2. in kubeconfig

{% highlight yaml %}
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: <K8s_API_SERVER_ROOT_CA_CRT>
    server: <K8s_API_SERVER_URL>
  name: my-cluster 
contexts:
- context:
  name: default-context
  context:
    cluster: my-cluster
    user: my-user
current-context: default-context
users:
- name: my-user
  user:
    token: <SERVICE_ACCOUNT_TOKEN>
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 3] kubeconfig with Service Account</figcaption>
</figure>

kubeconfig 설정을 통해서 kubectl에서도 Service Account를 이용할 수 있다. [Text 3]은 Service Account를 이용하는 kubeconfig를 나타내고 있다. Service Account의 Token과 Kubernetees API Server의 ca.crt가 명시되어 있는것을 확인할 수 있다.

### 2. 참고

* [https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/#accessing-the-api-from-a-pod](https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/#accessing-the-api-from-a-pod)
* [https://docs.openshift.com/container-platform/3.4/dev_guide/service_accounts.html](https://docs.openshift.com/container-platform/3.4/dev_guide/service_accounts.html)
* [https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/)
* [https://stackoverflow.com/questions/55629894/kubernetes-kubeconfig-with-service-account-token](https://stackoverflow.com/questions/55629894/kubernetes-kubeconfig-with-service-account-token)