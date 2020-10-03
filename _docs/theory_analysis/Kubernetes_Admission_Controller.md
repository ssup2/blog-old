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

![[그림 1] Kubernetes Admission Controller]({{site.baseurl}}/images/theory_analysis/Kubernetes_Admission_Controller/Kubernetes_Admission_Controller.PNG)

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
* [https://docs.openshift.com/container-platform/3.11/architecture/additional_concepts/dynamic_admission_controllers.html](https://docs.openshift.com/container-platform/3.11/architecture/additional_concepts/dynamic_admission_controllers.html)
* [https://m.blog.naver.com/alice_k106/221546328906](https://m.blog.naver.com/alice_k106/221546328906)
