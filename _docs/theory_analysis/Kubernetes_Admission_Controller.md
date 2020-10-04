---
title: Kubernetes Admission Controller
category: Theory, Analysis
date: 2020-10-04T12:00:00Z
lastmod: 2020-10-04T12:00:00Z
comment: true
adsense: true
---

Kubernetes의 Admission Controller를 분석한다.

### 1. Kubernetes Admission Controller

![[그림 1] Kubernetes Admission Controller]({{site.baseurl}}/images/theory_analysis/Kubernetes_Admission_Controller/Kubernetes_Admission_Controller.PNG){: width="700px"}

Kubernetes Admission Controller는 Kubernetes API 처리 과정을 Hooking하여, Kubernetes의 기능을 확장하는 역활을 수행하는 Controller를 의미한다. Kubernetes는 Admission Controller를 통해서 보안, 정책 및 설정 관련 기능을 확장하고 있다. [그림 1]은 Kubernetes Admission Controller를 나타내고 있다. Kubernetes API Server는 API 요청 처리 과정 사이에 Kubernetes API Server 내부에 포함된 Compiled-in Admission Controller들에게 하나씩 차례대로 API 요청을 전달한다. API 요청을 받은 Admission Controller는 해당 API 요청을 거절, 승인 또는 변경&승인 할 수 있다.

Admission Controller로 부터 거절 응답을 받은 Kubernetes API 서버는 해당 API 요청 처리를 중단한다. Admission Controller로 부터 승인 응답을 받은 Kubernetes API 서버는 다음 Admission Controller에게 동일한 API 요청을 전달하고 응답을 기다린다. 변경&승인 응답을 받은 Kubernetes API 서버는 다음 Admission Controller에게 변경된 API 요청을 전달하고 응답을 기다린다. 이런식으로 활성화된 모든 Admission Controller를 지나간 API 요청만이 etcd에 저장되어 반영된다.

API 요청은 Mutating 단계에서 한번, Validating 단계에서 한번, 총 2번 Hook이 존재한다. Mutating 단계의 Hook은 의미 그대로 API 요청을 변경하는 용도로 이용하는 Hook이다. 또한 필요에 따라서는 API 요청을 거절하여 처리를 중단할 수 있다. Validating 단계의 Hook은 그대로 API 요청을 검증하는 용도로 이용하는 Hook이다. API 요청을 거절하여 처리를 중단할 수만 있으며, Validating 단계의 Hook처럼 API 요청을 변경할 수는 없다.

Admission Controller는 Kubernetes API Server와 같이 Compile된 **Compiled-in Admission Controller**와 Kubernetes User가 개발하여 Kubernetes API Server 외부에서 동작하는 **Custom Admission Controller** 2종류가 존재한다.

#### 1.1. Compiled-in Admission Controller

Kubernetes API Server에는 다양한 Compiled-in Admission Controller가 Kubernetes API Server에 포함되어 있으며 Kubernetes API Server의 "--enable-admission-plugins" Option을 통해서 이용할 Compiled-in Admission Controller만 활성화 할 수 있다. Compiled-in Admission Controller는 필요에 따라서 Mutating Hook만 이용하는 Controller, Validating Hook만 이용하는 Controller, Mutating Hook과 Validating Hook을 모두 이용하는 Controller로 구분할 수 있다. Mutating Hook을 이용하는 Controller는 MutationInterface[https://github.com/kubernetes/kubernetes/blob/v1.19.2/staging/src/k8s.io/apiserver/pkg/admission/interfaces.go#L129]의 Admit() 함수를 구현해야 하며, Validating Hook을 이용하는 Controller는 ValidationInterface[https://github.com/kubernetes/kubernetes/blob/f5743093fd1c663cb0cbc89748f730662345d44d/staging/src/k8s.io/apiserver/pkg/admission/interfaces.go#L138]의 Validat() 함수를 구현해야 한다.

DefaultIngressClass Admission Controller는 Mutating Hook만을 이용하는 Compiled-in Admission Controller이다. Mutating Hook은 Ingress Class가 설정되어 있지 않는 Ingress의 Ingress Class를 Default Ingress Class로 설정하는 용도로 이용한다. NamespaceExists Admission Controller는 Validating Hook만을 이용하는 Compiled-in Admission Controller이다. Validating Hook은 존재하지 않는 Namespace 관련 API 요청을 거절하는 용도로 이용한다. 

ServiceAccount Admission Controller는 Mutating Hook과 Validating Hook을 둘다 이용하는 Compiled-in Admission Controller이다. Mutating Hook은 Service Account가 설정되어 있지 않는 Pod에 Default Service Account를 설정하고, 설정된 Service Account의 Token을 Pod 내부에서 얻을수 있도록 Pod에 Mount 설정을 추가하는 용도로 이용한다. Validating Hook은 Pod에 설정된 Service Account가 실제 유효한지 검사하는 용도로 이용한다. 이처럼 Kubernetes의 많은 기능들이 Compiled-in Admission Controller를 통해서 구현된다.

#### 1.2. Custom Admission Controller Registration

{% highlight yaml %}
apiVersion: admissionregistration.k8s.io/v1
  kind: MutatingWebhookConfiguration
  metadata:
    name: MutatingController
  webhooks:
  - name: MutatingWebhook
    admissionReviewVersions: ["v1", "v1beta1"]
    clientConfig:
      service:
        namespace: default
        name: MutatingWebhook
       path: /Mutating
      caBundle: KUBE_CA
    rules:
    - operations:
      - CREATE
      apiGroups:
      - ""
      apiVersions:
      - "v1"
      resources:
      - pods
    failurePolicy: Ignore
    timeoutSeconds: 5
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] MutatingWebhookConfiguration</figcaption>
</figure>

{% highlight yaml %}
apiVersion: admissionregistration.k8s.io/v1
  kind: ValidatingWebhookConfiguration
  metadata:
    name: ValidatingController
  webhooks:
  - name: ValidatingWebhook
    admissionReviewVersions: ["v1", "v1beta1"]
    clientConfig:
      service:
        namespace: default
        name: ValidatingWebhook
       path: /Validating
      caBundle: KUBE_CA
    rules:
    - operations:
      - DELETE
      apiGroups:
      - ""
      apiVersions:
      - "v1"
      resources:
      - pods
    failurePolicy: Fail
    timeoutSeconds: 5
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] ValidatingWebhookConfiguration</figcaption>
</figure>

{% highlight yaml %}
{
  "apiVersion": "admission.k8s.io/v1",
  "kind": "AdmissionReview",
  "request": {
    "uid": "705ab4f5-6393-11e8-b7cc-42010a800002",
    "kind": {"group":"autoscaling","version":"v1","kind":"Scale"},
    "resource": {"group":"apps","version":"v1","resource":"deployments"},
    "subResource": "scale",

    "requestKind": {"group":"autoscaling","version":"v1","kind":"Scale"},
    "requestResource": {"group":"apps","version":"v1","resource":"deployments"},
    "requestSubResource": "scale",

    "name": "my-deployment",
    "namespace": "my-namespace",

    "operation": "UPDATE",
    "userInfo": {
      "username": "admin",
      "uid": "014fbff9a07c",
      "groups": ["system:authenticated","my-admin-group"],
      "extra": {
        "some-key":["some-value1", "some-value2"]
      }
    },

    "object": {"apiVersion":"autoscaling/v1","kind":"Scale",...},
    "oldObject": {"apiVersion":"autoscaling/v1","kind":"Scale",...},
    "options": {"apiVersion":"meta.k8s.io/v1","kind":"UpdateOptions",...},

    "dryRun": false
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Data 1] Webhook Request</figcaption>
</figure>

{% highlight yaml %}
{
  "apiVersion": "admission.k8s.io/v1",
  "kind": "AdmissionReview",
  "response": {
    "uid": "<value from request.uid>",
    "allowed": false,
    "status": {
      "code": 403,
      "message": "You cannot do this because it is Tuesday and your name starts with A"
    }
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Data 2] Webhook Response</figcaption>
</figure>

{% highlight yaml %}
{
  "apiVersion": "admission.k8s.io/v1",
  "kind": "AdmissionReview",
  "response": {
    "uid": "<value from request.uid>",
    "allowed": true,
    "patchType": "JSONPatch",
    "patch": "W3sib3AiOiAiYWRkIiwgInBhdGgiOiAiL3NwZWMvcmVwbGljYXMiLCAidmFsdWUiOiAzfV0="
  }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Data 3] Webhook Response with JSON Patch</figcaption>
</figure>

### 2. 참조

* [https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/)
* [https://kubernetes.io/blog/2019/03/21/a-guide-to-kubernetes-admission-controllers/](https://kubernetes.io/blog/2019/03/21/a-guide-to-kubernetes-admission-controllers/)
* [https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)
* [https://docs.openshift.com/container-platform/3.11/architecture/additional_concepts/dynamic_admission_controllers.html](https://docs.openshift.com/container-platform/3.11/architecture/additional_concepts/dynamic_admission_controllers.html)
* [https://m.blog.naver.com/alice_k106/221546328906](https://m.blog.naver.com/alice_k106/221546328906)
