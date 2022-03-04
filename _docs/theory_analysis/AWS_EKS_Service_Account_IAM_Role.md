---
title: AWS EKS Service Account에 AWS IAM Role 부여
category: Theory, Analysis
date: 2021-04-15T12:00:00Z
lastmod: 2021-04-15T12:00:00Z
comment: true
adsense: true
---

AWS EKS Cluster의 Service Account에 AWS IAM Role을 부여하는 과정을 정리한다.

### 1. AWS EKS Service Account에 AWS IAM Role 부여

![[그림 1] AWS EKS Service Account에 AWS IAM Role 부여]({{site.baseurl}}/images/theory_analysis/AWS_EKS_Service_Account_IAM_Role/AWS_EKS_Service_Account_IAM_Role.PNG)

AWS EKS 1.14 Version 이상에서는 EKS (k8s) Cluster의 Service Account에 AWS IAM의 Role을 부여할 수 있는 기능을 제공하고 있다. 이 기능을 통해서 AWS IAM Role을 부여받은 Service Account를 이용하는 Pod는 AWS Service를 이용할 수 있게 된다. [그림 1]은 EKS Cluster의 Service Account에 AWS IAM의 Role을 부여하고, 해당 Service Account를 이용하는 Pod를 통해서 AWS Service에 접근하는 과정을 나타내고 있다.

본 기능을 Service Account 생성, Pod 생성, Service Account Token 생성/교체, Service Account Token 이용 4단계로 나누어 설명한다. 설명에는 [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)를 예제로 이용한다. AWS ELK Cluster에서 동작하는 AWS Load Balancer Controller도 AWS Service에 접근해야하기 때문에 AWS Load Balancer Controller가 이용하는 Service Account에도 본 기능을 이용하여 AWS Role이 부여되어 있기 때문이다.

#### 1.1. Create Service Account

{% highlight yaml %}
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::132099918825:role/eksctl-ssup2-eks-cluster-addon-iamserviceacc-Role1-13GTAZQ9TJV8M
  creationTimestamp: "2021-04-06T14:53:13Z"
  labels:
    app.kubernetes.io/managed-by: eksctl
  name: aws-load-balancer-controller
  namespace: kube-system
  resourceVersion: "4643"
  selfLink: /api/v1/namespaces/kube-system/serviceaccounts/aws-load-balancer-controller
  uid: ceec1768-8be2-4ca9-9a24-f8bf4c1cce20
secrets:
- name: aws-load-balancer-controller-token-trf5m
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 1] Service Account with Role ARN</figcaption>
</figure>

Service Account에 AWS IAM Role을 부여하기 위해서는 가장 먼저 Service Account를 생성해야 한다. 이때 **eks.amazonaws.com/role-arn** Annotation에 부여할 AWS IAM Role의 ARN을 명시해야 한다. [Text 1]은 AWS Load Balancer Controller가 이용하는 Service Account를 나타내고 있다. "arn:aws:iam::132099918825:role/eksctl-ssup2-eks-cluster-addon-iamserviceacc-Role1-13GTAZQ9TJV8M" Role을 부여하고 있는것을 확인할 수 있다.

{% highlight json %}
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::132099918825:oidc-provider/oidc.eks.ap-northeast-2.amazonaws.com/id/B0678ED568FC12BBC37256BBA2A4BB53"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.ap-northeast-2.amazonaws.com/id/B0678ED568FC12BBC37256BBA2A4BB53:aud": "sts.amazonaws.com",
          "oidc.eks.ap-northeast-2.amazonaws.com/id/B0678ED568FC12BBC37256BBA2A4BB53:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }
  ]
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 2] Role's Trust Relationship</figcaption>
</figure>

[Text 2]는 [Text 1]에서 AWS Load Balancer Controller가 이용하는 Service Account에 부여된 AWS IAM Role의 Trust Relationship을 나타낸다. **Trust Relationship**은 해당 Role을 이용할 수 있는 대상을 제한하는 역활을 수행한다. [Text 2]에서 Principal 항목이 해당 AWS IAM Role을 이용할 수 있는 대상을 나타낸다. 여기에 EKS Cluster의 **OIDC Identity Provider**의 URL이 명시되어 있는것을 확인할 수 있다.

각 EKS Cluster는 자신만의 고유의 OIDC Identity Provider를 갖는다. OIDC Identity Provider는 인증을 제공하는 Server이다. 즉 [Text 2]의 Trust Relationship에 EKS Cluster의 OIDC Identity Provider가 명시되어 있기 때문에, EKS Cluster의 OIDC Identity Provider가 인증한 App은 해당 AWS IAM Role을 이용할 수 있다.

#### 1.2. Create Pod

{% highlight yaml %}
...
spec:
  containers:
  - args:
    - --cluster-name=ssup2-eks-cluster
    - --ingress-class=alb
    env:
    - name: AWS_DEFAULT_REGION
      value: ap-northeast-2
    - name: AWS_REGION
      value: ap-northeast-2
    - name: AWS_ROLE_ARN
      value: arn:aws:iam::132099918825:role/eksctl-ssup2-eks-cluster-addon-iamserviceacc-Role1-13GTAZQ9TJV8M
    - name: AWS_WEB_IDENTITY_TOKEN_FILE
      value: /var/run/secrets/eks.amazonaws.com/serviceaccount/token
    image: amazon/aws-alb-ingress-controller:v2.1.3
...
    volumeMounts:
    - mountPath: /var/run/secrets/eks.amazonaws.com/serviceaccount
      name: aws-iam-token
      readOnly: true
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: aws-load-balancer-controller-token-wq7kf
      readOnly: true
...
  volumes:
  - name: aws-iam-token
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:
          audience: sts.amazonaws.com
          expirationSeconds: 86400
          path: token
  - name: aws-load-balancer-controller-token-wq7kf
    secret:
      defaultMode: 420
      secretName: aws-load-balancer-controller-token-wq7kf
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 3] Mutated Pod Spec</figcaption>
</figure>

EKS Control Plane에는 기본적으로 Pod Identity Webhook이 존재한다. Pod Identity Webhook은 AWS IAM Role이 부여된 Service Account를 이용하는 Pod가 생성될때, Pod의 Spec을 변경(Mutate)하는 역활을 수행한다. [Text 3]는 Pod Identity Webhook으로 인해서 변경된 AWS Load Balancer Controller Pod를 나타내고 있다.

Pod Identity Webhook은 **AWS_DEFAULT_REGION**, **AWS_REGION**, **AWS_ROLE_ARN**, **AWS_WEB_IDENTITY_TOKEN_FILE** 환경 변수 및 **aws-iam-token** 이름의 Service Account Token Volume을 생성하고 Mount하도록 만든다. Pod Identity Webhook이 추가한 "AWS_*" 환경 변수 및 "aws-iam-token" Token은 AWS SDK에서 이용되는 설정이다. [Text 3]에는 Pod마다 기본적으로 할당되는 Service Account Token 관련 설정도 여전히 존재하는것을 확인 할 수 있다. 이 기본 Service Account Token은 본 글에서는 **Traditional Service Account Token**이라고 명칭한다.

#### 1.3. Create/Rotate Service Account Token

{% highlight json %}
{
  "aud": [
    "sts.amazonaws.com"
  ],
  "exp": 1618776732,
  "iat": 1618690332,
  "iss": "https://oidc.eks.ap-northeast-2.amazonaws.com/id/B0678ED568FC12BBC37256BBA2A4BB53",
  "kubernetes.io": {
    "namespace": "kube-system",
    "pod": {
      "name": "aws-load-balancer-controller-bc59445f-l4brz",
      "uid": "6fc3fe55-6add-4712-bfdc-c0073b99d33f"
    },
    "serviceaccount": {
      "name": "aws-load-balancer-controller",
      "uid": "ceec1768-8be2-4ca9-9a24-f8bf4c1cce20"
    }
  },
  "nbf": 1618690332,
  "sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 4] Service Account Token</figcaption>
</figure>

[Text 4]은 AWS Load Balancer Controller Pod에 Inject된 "aws-iam-token" Service Account Token의 내용을 나타내고 있다. Token은 JWT 형태로 RS256 Algorithm을 이용하여 Encoding되어 있으며, Decoding을 하면 [Text 4]의 내용을 확인할 수 있다. Issuer(iss) 항목에는 EKS Cluster의 OIDC Identity Provider의 URL이 존재한다. Audience(aud) 항목에는 "sts.amazonaws.com"가 설정되어 있다. Inject된 Service Account Token은 AWS STS(Security Token Service)가 OIDC Identity Provider를 통해서 인증을 받을때 이용하기 때문이다.

Inject된 Service Account Token은 Expiration이 포함되어 있기 때문에 특정 시간이 지나면 만기가 된다. 따라서 kubelet은 주기적으로 AWS EKS API Server를 통해서 serviceaccount-token Controller에게 새로운 Service Account Token을 얻어와 Pod에게 주입한다. 이러한 주기적인 주입은 **Service Account Token의 Projected Volume** 기능을 통해서 이루어진다. Pod 내부의 App도 새롭개 Inject된 Token을 주기적으로 다시 읽어서 이용하도록 동작되어야 한다.

Service Account Token의 Projected Volume 기능은 Kubernetes API Server에 다음의 Parameter들을 설정하면 이용 가능하다. 아래의 설정들은 Traditional Service Account Token과는 무관하다.
* service-account-signing-key-file : Service Account Token을 Sign 할 때 이용하는 Key 파일의 경로를 지정합니다.
* service-account-issuer : Service Account Token의 발급자를 설정합니다. EKS의 Kubernetes API Server에는 [Text 4]의 Issue 항목의 내용인 EKS Cluster의 OIDC Identity Provider URL이 설정되어 있을것으로 예상된다.
* service-account-api-audiences : Service Account Token을 사용하는 대상을 설정합니다. EKS의 Kubernetes API Server에는 [Tex t 4]의 Audience 항목의 내용인 "sts.amazonaws.com"가 설정되어 있을것으로 예상된다.

{% highlight json %}
{
  "iss": "kubernetes/serviceaccount",
  "kubernetes.io/serviceaccount/namespace": "kube-system",
  "kubernetes.io/serviceaccount/secret.name": "aws-load-balancer-controller-token-trf5m",
  "kubernetes.io/serviceaccount/service-account.name": "aws-load-balancer-controller",
  "kubernetes.io/serviceaccount/service-account.uid": "ceec1768-8be2-4ca9-9a24-f8bf4c1cce20",
  "sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 5] Traditional Service Account Token</figcaption>
</figure>

[Text 5]는 AWS Load Balancer Controller Pod에 생성된 Traditional Service Account Token의 내용이다. Token은 RS256 Algorithm을 이용하여 Endcoding되어 있으며, Decoding하면 [Text 5]의 내용을 확인할 수 있다. Issuer(iss), Audience(aud), Expiration(exp) 정보가 포함되어 있다. Pod Identity Webhook가 Inject하는 "aws-iam-token" 이름의 Service Account Token은 Kubernetes가 기본적으로 생성하는 "Traditional Service Account Token"과의 내용도 다른것을 확인 할 수 있다.

#### 1.4. Use Token

Pod 내부의 App은 AWS의 STS로부터 Credential을 얻기 위해서 Inject된 Service Account Token과 권한을 얻으려는 IAM Role의 ARN을 AWS의 STS에게 전송한다. AWS STS는 Token의 Issuer 항목을 통해서 EKS Cluster의 OIDC Identity Provider를 발견하고, OIDC Identity Provider에게 Service Account Token을 인증 받는다. AWS의 STS가 OIDC Identity Provider 발견하고 관련 정보를 얻는 과정은 **OpenID Connect Discovery 1.0** 표준에 의해서 진행된다.

Service Account Token의 인증이 완료되면 STS는 허용되는 IAM Role인지 확인한다. 허용되는 IAM Role이라면 AWS의 STS는 Credential을 Pod 내부의 App에게 전달한다. Pod 내부의 App은 수신한 Credential을 가지고 AWS Service에 접근한다.

### 2. 참조

* [https://aws.amazon.com/ko/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/](https://aws.amazon.com/ko/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/)
* [https://aws.amazon.com/ko/blogs/containers/enabling-cross-account-access-to-amazon-eks-cluster-resources/](https://aws.amazon.com/ko/blogs/containers/enabling-cross-account-access-to-amazon-eks-cluster-resources/)
* [https://pnguyen.io/posts/eks-iam-roles-for-service-accounts/](https://pnguyen.io/posts/eks-iam-roles-for-service-accounts/)
* [https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html](https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html)
* [https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html)
* [https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-token-volume-projection](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-token-volume-projection)
* [https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/)
* [https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-issuer-discovery](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-issuer-discovery)
* [https://reece.tech/posts/oidc-k8s-to-aws/](https://reece.tech/posts/oidc-k8s-to-aws/)
* [https://tech.devsisters.com/posts/pod-iam-role/](https://tech.devsisters.com/posts/pod-iam-role/)
* [https://www.blog-dreamus.com/post/flo-tech-aws-eks%EC%97%90%EC%84%9C%EC%9D%98-iam-%EC%97%AD%ED%95%A0-%EB%B6%84%EB%A6%AC](https://www.blog-dreamus.com/post/flo-tech-aws-eks%EC%97%90%EC%84%9C%EC%9D%98-iam-%EC%97%AD%ED%95%A0-%EB%B6%84%EB%A6%AC)
* [https://qiita.com/hiyosi/items/feec917d502af8ad8863](https://qiita.com/hiyosi/items/feec917d502af8ad8863)
* [https://stackoverflow.com/questions/57192079/serviceaccount-token-volume-projection-projected-token-in-path-in-manifest-f](https://stackoverflow.com/questions/57192079/serviceaccount-token-volume-projection-projected-token-in-path-in-manifest-f)
* [https://kangwoo.kr/2020/02/13/service-account-token-volume-projection/](https://kangwoo.kr/2020/02/13/service-account-token-volume-projection/)