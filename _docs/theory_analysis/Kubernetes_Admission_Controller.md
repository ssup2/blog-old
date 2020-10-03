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

Kubernetes Admission Controller는 Kubernetes API 처리 과정 사이의 **Webhook**을 이용하여, Kubernetes의 기능을 확장하는 역활을 수행하는 Plugin을 의미한다. Kubernetes는 Admission Controller를 통해서 보안, 정책, 설정 관련 기능을 확장시킬 수 있다. [그림 1]은 Kubernetes Admission Controller를 나타내고 있다. Kubernetes API Server는 API 요청 처리 과정 사이에 Kubernetes API Server에 등록되어 있는 Admission Controller의 Webhook을 호출한다. Admission Controller의 Webhook에 의해서 API 요청은 변경되거나 중단될 수 있다.

Webhook은 Mutating Admission을 수행하는 Webhook과 Validating Admission을 수행하는 Webhook으로 구분된다. Mutating Admission Webhook은 의미 그대로 API 요청을 변경하는 용도로 이용하는 Webhook이다. 또한 필요에 따라서는 API 요청을 거절하여 처리를 중단할 수 있다. Validating Admission Webhook은 의미 그대로 API 요청을 검증하는 용도로 이용하는 Webhook이다. API 요청을 거절하여 처리를 중단할 수만 있으며, Mutating Admission Webhook처럼 API 요청을 변경할 수는 없다.

Admission Controller는 Kubernetes API Server와 같이 Compile된 **Compiled-in Admission Controller**와 Kubernetes User가 개발하여 Kubernetes API Server 외부에서 동작하는 **Custom Admission Controller** 2종류가 존재한다. Compiled-in Admission Controller는 다양한 종류가 존재하며 Kubernetes API Server의 "--enable-admission-plugins" Option을 통해서 이용할 Compiled-in Admission Controller를 설정할 수 있다.

#### 1.1. Registration

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

#### 1.2. Request, Response

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
