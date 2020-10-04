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

Kubernetes Admission Controller는 Kubernetes API 처리 과정을 Hooking하여, Kubernetes의 기능을 확장하는 역활을 수행하는 Controller를 의미한다. Kubernetes는 Admission Controller를 통해서 보안, 정책 및 설정 관련 기능을 확장하고 있다. [그림 1]은 Kubernetes Admission Controller를 나타내고 있다. Kubernetes API Server는 API 요청 처리 과정 사이에 Kubernetes API Server 내부에 포함된 Compiled-in Admission Controller들에게 하나씩 순차적으로 API 요청 정보를 전달한다. API 요청 정보를 받은 Admission Controller는 해당 API 요청을 거절, 승인 또는 변경&승인 할 수 있다.

Admission Controller로 부터 거절 응답을 받은 Kubernetes API 서버는 해당 API 요청 처리를 중단한다. Admission Controller로 부터 승인 응답을 받은 Kubernetes API 서버는 다음 Admission Controller에게 동일한 API 요청 정보를 전달하고 응답을 기다린다. 변경&승인 응답을 받은 Kubernetes API 서버는 다음 Admission Controller에게 변경된 API 요청 정보를 전달하고 응답을 기다린다. 이런식으로 활성화된 모든 Admission Controller를 지나간 API 요청만이 etcd에 저장되어 반영된다.

API 요청은 Mutating 단계에서 한번, Validating 단계에서 한번, 총 2번 Hook이 존재한다. Mutating 단계의 Hook은 의미 그대로 API 요청을 변경하는 용도로 이용하는 Hook이다. 또한 필요에 따라서는 API 요청을 거절하여 처리를 중단할 수 있다. Validating 단계의 Hook은 그대로 API 요청을 검증하는 용도로 이용하는 Hook이다. API 요청을 거절하여 처리를 중단할 수만 있으며, Validating 단계의 Hook처럼 API 요청을 변경할 수는 없다.

Admission Controller는 Kubernetes API Server와 같이 Compile된 **Compiled-in Admission Controller**와 Kubernetes User가 개발하여 Kubernetes API Server 외부에서 동작하는 **Custom Admission Controller** 2종류가 존재한다.

#### 1.1. Compiled-in Admission Controller

Compiled-in Admission Controller는 Kubernetes API Server와 같이 Compile되어 존재하는 Admission Controller를 의미한다. Kubernetes API Server의 "--enable-admission-plugins" Option을 통해서 이용할 Compiled-in Admission Controller만 활성화 할 수 있다. Compiled-in Admission Controller는 필요에 따라서 Mutating Hook만 이용하는 Controller, Validating Hook만 이용하는 Controller, Mutating Hook과 Validating Hook을 모두 이용하는 Controller로 구분할 수 있다. Mutating Hook을 이용하는 Controller는 [MutationInterface](https://github.com/kubernetes/kubernetes/blob/v1.19.2/staging/src/k8s.io/apiserver/pkg/admission/interfaces.go#L129)의 Admit() 함수를 구현해야 하며, Validating Hook을 이용하는 Controller는 [ValidationInterface](https://github.com/kubernetes/kubernetes/blob/f5743093fd1c663cb0cbc89748f730662345d44d/staging/src/k8s.io/apiserver/pkg/admission/interfaces.go#L138)의 Validat() 함수를 구현해야 한다.

DefaultIngressClass Admission Controller는 Mutating Hook만을 이용하는 Compiled-in Admission Controller이다. Mutating Hook은 Ingress Class가 설정되어 있지 않는 Ingress의 Ingress Class를 Default Ingress Class로 설정하는 용도로 이용한다. NamespaceExists Admission Controller는 Validating Hook만을 이용하는 Compiled-in Admission Controller이다. Validating Hook은 존재하지 않는 Namespace 관련 API 요청을 거절하는 용도로 이용한다. 

ServiceAccount Admission Controller는 Mutating Hook과 Validating Hook을 둘다 이용하는 Compiled-in Admission Controller이다. Mutating Hook은 Service Account가 설정되어 있지 않는 Pod에 Default Service Account를 설정하고, 설정된 Service Account의 Token을 Pod 내부에서 얻을수 있도록 Pod에 Mount 설정을 추가하는 용도로 이용한다. Validating Hook은 Pod에 설정된 Service Account가 실제 유효한지 검사하는 용도로 이용한다. 이처럼 Kubernetes의 많은 기능들이 Compiled-in Admission Controller를 통해서 구현된다.

#### 1.2. Custom Admission Controller

Custom Admission Controller는 Kubernetes API Server 외부에서 동작하는 Kubernetes User가 개발한 Admission Controller를 의미한다. Custom Admission Controller의 동작을 이해하기 위해서는 Compiled-in Admission Controller인 MutatingAdmissionWebhook Controller와 ValidatingAdmissionWebhook Controller의 역활을 이해하고 있어야한다. 

[그림 1]은 MutatingAdmissionWebhook Controller와 ValidatingAdmissionWebhook Controller의 동작도 나타내고 있다. MutatingAdmissionWebhook Controller는 Mutating Hook을 이용하여 API 요청 정보를 Custom Admission Controller의 Webhook에 전달한다. API 요청 정보가 전달되어야 Custom Admission Controller 및 Webhook이 다수 존재한다면 API 요청 정보를 하나씩 순차적으로 Custom Admission Controller에게 전달하고 응답을 대기하는 동작을 반복한다.

ValidationAdmissionWebhook은 Validating Hook을 이용하여 API 요청 정보를 Custom Admission Controller의 Webhook에 전달한다. API 요청 정보가 전달되어야 Custom Admission Controller 및 Webhook이 다수 존재한다면 API 요청 정보를 동시에 Custom Admission Controller에게 전달하고 응답을 대기하는 동작을 반복한다.

Custom Admission Controller는 HA (High Availability)를 위해서 다수의 Pod에서 동작하며, Service를 통해서 묶여 있다. MutatingAdmissionWebhook Controller와 ValidatingAdmissionWebhook Controller은 Custom Admission Controller Pod의 Service를 통해서 API 요청 정보를 전달한다. API 요청 정보는 HTTP 형태로 Custom Admission Controller에게 전달된다.

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
      caBundle: <kube_ca>
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

Custom Admission Controller가 MutatingAdmissionWebhook Controller로부터 API 요청 정보를 전달받기 위해서는 Custom Admission Controller를 MutatingAdmissionWebhook Controller에 등록해야 한다. MutatingWebhookConfiguration 파일을 통해서 Custom Admission Controller를 MutatingAdmissionWebhook Controller에게 등록할 수 있다. [파일 1]은 MutatingWebhookConfiguration 파일을 나타내고 있다.

이와 유사하게 Custom Admission Controller가 ValidatingAdmissionWebhook Controller로부터 API 요청 정보를 전달받기 위해서는 Custom Admission Controller를 ValidatingAdmissionWebhook Controller에 등록해야 한다. ValidatingWebhookConfiguration 파일을 통해서 Custom Admission Controller를 ValidatingAdmissionWebhook Controller에게 등록할 수 있다. [파일 2]는 ValidatingWebhookConfiguration 파일을 나타내고 있다.

MutatingWebhookConfiguration와 ValidatingWebhookConfiguration은 동일한 형태로 구성되어 있는걸 확인할 수 있다. webhooks 항목을 통해서 다수의 Webhook을 한번에 등록할 수 있다. clientConfig 항목에는 Webhook에 접근하기 위해 필요한 Service 정보, Path 정보가 포함되어 있다. [파일 1]에서 Webhook은 default Namespace의 MutatingWebhook Service의 /Mutating Path에 존재한다. rules 항목은 어떤 API 요청 정보를 Custom Admission Controller에게 전송할지 설정하는 부분이다. [파일 1]에서는 v1 API Version의 Pod Create 관련 API 요청 정보만 Custom Admission Controller에게 전송된다.

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
<figcaption class="caption">[Data 1] Custom Admission Controller에게 전송되는 API 요청 정보</figcaption>
</figure>

[Data 1]은 MutatingAdmissionWebhook Controller또는 ValidatingAdmissionWebhook Controller가 Custom Admission Controller 전송하는 API 요청 정보를 나타내고 있다. name, namespace 항목을 통해서 어떤 Object를 위한 API 요청이었는지 파악할 수 있다. userInfo 항목에는 API 요청을 전송한 User의 정보가 저장되어 있다. oldObject 항목에는 API 요청전의 Object의 상태를 저장하고 있다. object 항목에는 API 요청으로 인해서 생성 또는 변경될 Object의 최종 상태를 저장하고 있다.

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
<figcaption class="caption">[Data 2] Custom Admission Controller의 응답</figcaption>
</figure>

[Data 2]는 Custom Admission Controller가 Kubernetes API Server에게 전송하는 응답을 나타내고 있다. allowed 항목에는 API 요청의 승인 여부를 저장한다. status 항목에는 API 요청의 거절 이유를 저장할 수 있다.

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
<figcaption class="caption">[Data 3] Mutating Custom Admission Controller의 API 요청 변경 응답</figcaption>
</figure>

[Data 3]은 Mutating Custom Admission Controller에서 API 요청을 변경해야 하는경우 Mutating Custom Admission Controller가 Kubernetes API Server에게 전송하는 응답을 나타내고 있다. API 요청의 변경 내역은 JSON의 변경 내역을 저장하는 형태인 JSONPatch를 Base64 형태로 Encoding하여 patch 항목에 저장한다.

### 2. 참조

* [https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/)
* [https://kubernetes.io/blog/2019/03/21/a-guide-to-kubernetes-admission-controllers/](https://kubernetes.io/blog/2019/03/21/a-guide-to-kubernetes-admission-controllers/)
* [https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)
* [https://docs.openshift.com/container-platform/3.11/architecture/additional_concepts/dynamic_admission_controllers.html](https://docs.openshift.com/container-platform/3.11/architecture/additional_concepts/dynamic_admission_controllers.html)
* [https://m.blog.naver.com/alice_k106/221546328906](https://m.blog.naver.com/alice_k106/221546328906)
