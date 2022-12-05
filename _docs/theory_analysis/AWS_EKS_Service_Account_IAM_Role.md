---
title: AWS Amazon EKS Service Account에 AWS IAM Role 부여
category: Theory, Analysis
date: 2021-04-15T12:00:00Z
lastmod: 2022-07-28T12:00:00Z
comment: true
adsense: true
---

AWS EKS Cluster의 Service Account에 AWS IAM Role을 부여하는 과정을 정리한다. 이러한 기능을 **IRSA(IAM Roles for Service Accounts)**라고 명칭한다.

### 1. AWS EKS Service Account에 AWS IAM Role 부여 (IRSA)

![[그림 1] AWS EKS Service Account에 AWS IAM Role 부여]({{site.baseurl}}/images/theory_analysis/AWS_EKS_Service_Account_IAM_Role/Amazon_EKS_Service_Account_IAM_Role.PNG)

AWS EKS 1.14 Version 이상에서는 EKS (K8s) Cluster의 Service Account에 AWS IAM Role을 부여할 수 있는 기능을 제공하고 있다. 이 기능을 통해서 AWS IAM Role을 부여 받은 Service Account를 이용하는 Pod는 AWS Service를 이용할 수 있게 된다. [그림 1]은 이러한 과정을 Service Account 생성, Pod 생성, Service Account Token 생성/교체, Service Account Token 이용 4단계로 나누어 나타내고 있다. [그림 1]의 주요 구성 요소들은 다음과 같다.

* AWS EKS OIDC Identity Provider : 각 EKS Cluster 마다 가지고 있는 전용 OIDC Identity Provider를 나타낸다. AWS IAM에게 신뢰하는 OIDC Identity Provider로 등록(Federate)되어 있다.
* Private/Public Key : AWS EKS OIDC Identity Provider와 Kubernetes API 서버는 동일한 Private/Public Key를 공유하여 이용한다.
* Pod Identity Webhook : Kubernetes API Server의 Mutating Webhook을 나타낸다. Pod가 AWS IAM Role을 부여 받은 Service Account를 이용하는 경우, Pod 내부에서 Service Account에 부여된 AWS IAm Role을 이용할 수 있도록 Pod의 Spec을 변경하는 역활을 수행한다.
* Projected SA Token : AWS IAM Role이 부여된 Service Account의 Token을 나타낸다. Kubernetes에서 기본적으로 이용되는 기본 Service Account Token과는 별개의 Token이다. 기본 Service Account Token과 다르게 **만료시간**과 **Audience**가 설정되어 있으며, 주기적으로 Token이 교체된다는 특징을 갖는다. JWT Token 형태를 갖추고 있다.

설명의 예제는 [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)를 이용한다. AWS ELK Cluster에서 동작하는 AWS Load Balancer Controller도 NLB (Network Load Balancer), ALB (Application Load Balancer) AWS Service에 접근하여 Load Balancer를 제어해야 하기 때문에, AWS Load Balancer Controller가 이용하는 Service Account에도 본 기능을 이용하여 AWS IAM Role이 부여되어 있기 때문이다.

#### 1.1. Service Account 생성

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

Service Account에 AWS IAM Role을 부여하기 위해서는 가장 먼저 Service Account를 생성해야 한다. 이때 **eks.amazonaws.com/role-arn Annotation**에 부여할 **AWS IAM Role의 ARN**을 명시해야 한다. [Text 1]은 AWS Load Balancer Controller가 이용하는 Service Account를 나타내고 있다. "arn:aws:iam::132099918825:role/eksctl-ssup2-eks-cluster-addon-iamserviceacc-Role1-13GTAZQ9TJV8M" Role을 부여하고 있는것을 확인할 수 있다.

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
<figcaption class="caption">[Text 2] AWS IAM Role's Trust Relationship</figcaption>
</figure>

[Text 2]는 [Text 1]에서 AWS Load Balancer Controller가 이용하는 Service Account에 부여된 AWS IAM Role의 Trust Relationship을 나타낸다. **Trust Relationship**은 해당 AWS IAM Role을 이용하기 위한 **인증 방법 및 조건**을 나타낸다. Principal 항목은 해당 AWS IAM Role을 부여받기 위해서 누구로부터 인증을 받아야 하는지를 나타낸다. [Text 2]에는 EKS Cluster의 OIDC Identity Provider의 URL이 명시되어 있는것을 확인할 수 있다. 따라서 EKS Cluster 내부에서 동작하는 Pod는 해당 EKS Cluster의 OIDC Identity Provider로부터 인증을 받아야 해당 AWS IAM Role을 부여 받을 수 있다는 것을 의미한다.

Trust Relationship의 Action에는 AWS IAM Role을 부여 받기 위한 방법이 명시되어 있으며, [Text 2]의 Action 항목에 AssumeRoleWithWebIdentity이 명시되어 있는것을 확인할 수 있다. AssumeRoleWithWebIdentity는 OIDC Identity Provider가 발급하는 JWT Token을 통해서 인증한다는걸 의미한다. Condition에는 JWT Token에 포함되어 있어야 하는 Claim의 조건을 나타낸다. [Text 2]에서는 aud Claim에 "sts.amazonaws.com", sub Claim에 "system:serviceaccount:kube-system:aws-load-balancer-controller"가 명시되어야 한다는 걸 나타낸다.

IRSA 과정에서 JWT Token로 Projected SA Token을 이용하며 Projected SA Token은 위에 명시한 모든 조건을 만족시킨다. 따라서 Projected SA Token을 이용하여 Service Account에 부여된 AWS IAM Role을 획득하고 이용할 수 있다.

#### 1.2. Pod 생성

{% highlight yaml %}
..은
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
  serviceAccount: aws-load-balancer-controller
  serviceAccountName: aws-load-balancer-controller
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

Pod 내부에서 AssumeRoleWithWebIdentity 동작을 수행하기 위해서는 Pod가 동작하는 Kubernetes Cluster의 Region, 부여 받는 AWS IAM Role, JWT Token의 위치 정보등이 필요하다. 이러한 필요 정보들은 EKS Control Plane에 존재하는 **Pod Identity Webhook**에 의해서 강제로 Pod에 주입된다. Pod Identity Webhook은 AWS IAM Role이 부여된 Service Account를 이용하는 Pod가 생성될때, Pod의 Spec을 변경(Mutate)하여 정보를 주입한다. [Text 3]는 Pod Identity Webhook으로 인해서 변경된 AWS Load Balancer Controller Pod를 나타내고 있다.

Pod Identity Webhook은 AWS_DEFAULT_REGION, AWS_REGION, AWS_ROLE_ARN, AWS_WEB_IDENTITY_TOKEN_FILE 환경 변수 및 aws-iam-token 이름의 Projected SA Token Volume을 생성하고 Mount하도록 만든다. aws-iam-token 이름의 Projected SA Token Volume안에 Projected SA Token이 존재한다. Projected SA Token Volume 설정에 만료 시간 및 Audience 설정도 포함되어 있는것을 확인할 수 있다.

Pod Identity Webhook이 추가한 "AWS_*" 환경 변수 및 "aws-iam-token" Token은 AWS SDK에서 이용된다. AWS SDK는 설정된 환경 변수의 정보를 통해서 AssumeRoleWithWebIdentity 동작을 수행한다. [Text 3]에서는 Pod마다 기본적으로 할당되는 기본 Service Account 설정도 여전히 존재하는 것을 확인할 수 있다.

#### 1.3. Service Account Token 생성/교체

AssumeRoleWithWebIdentity 동작을 수행하기 위해서는 OIDC Identity Provider가 발급한 인증 정보가 포함된 JWT 형태의 ID Token을 이용해야 한다. 하지만 Kubernetes API Server는 OIDC Identity Provider로부터 발급한 ID Token을 받지 않고 직접 JWT Token을 생성하여 Pod에 주입시킨다. K8s API Server가 OIDC Identity Provider를 대신하여 JWT Token을 생성하기 위해서는 OIDC Identity Provider가 이용하는 Private/Public Key를 API Server도 이용한다.

Kubernetes API Server에서는 다음의 Parameter들을 통해서 JWT Token 생성에 필요한 설정을 수행한다.

* service-account-signing-key-file : Service Account Token을 Sign할 때 이용하는 Key 파일의 경로를 지정한다. EKS Cluster의 OIDC Identity Provider의 Private Key가 지정되어 있을것으로 예상된다.
* service-account-key-file : Sign된 Service Account Token을 검증할때 이용하는 Key 파일의 경로를 지정한다. EKS Cluster의 OIDC Identity Provider의 Public Key가 지정되어 있을것으로 예상된다.
* service-account-issuer : Service Account Token의 발급자인 OIDC Identity Provider의 URL을 설정한다. EKS의 Kubernetes API Server에는 EKS Cluster의 OIDC Identity Provider URL이 설정되어 있을것으로 예상된다.

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
<figcaption class="caption">[Text 4] Projected SA Token</figcaption>
</figure>

[Text 4]은 AWS Load Balancer Controller Pod의 Projected SA Token을 JWT Deconding을 수행 하였을때의 내용을 나타내고 있다. service-account-issuer Parameter에 의해서 Issuer(iss) Claim에는 EKS Cluster의 OIDC Identity Provider의 URL이 설정된다. [Text 3]에서 Audience에 "sts.amazonaws.com" 설정으로 인해서 Audience(aud) Claim에도 "sts.amazonaws.com"가 설정된다.

AWS Load Balancer Controller는 kube-system Namespace에서 동작하며 aws-load-balancer-controller Service Account를 이용하기 때문에 Subject(sub) Claim에는 관련 내용이 설정된다. Expiration(exp) Claim에 만료시간이 존재하는것도 확인할 수 있다. [Text 3]의 Projected SA Token 내용이 [Text 2]의 AWS IAM Role의 Condition 조건을 만족시키는 것을 확인할 수 있다.

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
<figcaption class="caption">[Text 5] 기본 Service Account Token</figcaption>
</figure>

[Text 5]는 AWS Load Balancer Controller Pod에 기본적으로 생성되는 기본 Service Account Token을 JWT Deconding을 수행 하였을때의 내용을 나타내고 있다. [Text 4]의 Projected SA Token과 비교하면 Expiration Claim, Audience Claim을 포함하여 몇개의 Claim이 포함되어 있지 않는것을 확인할 수 있다.

#### 1.4. Service Account Token 이용

Pod 내부의 App은 AssumeRoleWithWebIdentity 동작을 통해서 Credential을 얻기 위해서 Projected SA Token을 AWS STS에게 전송한다. Projected SA Token을 받은 AWS STS는 Token의 Issuer를 확인하고 자신이 신뢰하는 (Federated) OIDC Identity Provider인지 확인한다. 자신이 신뢰하는 OIDC Identity Provider인지 확인이 되었다면, OIDC Identity Provider의 Public Key를 이용하여 Projected SA Token이 유효한지 검사한다. 유효한 Projected SA Token이라고 판단하였다면 AWS STS는 Credential을 Pod 내부의 App에게 전송한다. 이후에 App은 Credential을 이용하여 AWS IAM Role을 부여받고 AWS Service에 접근한다.

Projected SA Token은 실제로 EKS Cluster의 OIDC Identity Provider가 발급한게 아니라 Kubernetes API Server가 발급하였지만, Kubernetes API Server는 발급시 OIDC Identity Provider와 같이 이용하는 Private Key를 이용하여 Projected SA Token을 발급하였기 때문에 AWS STS는 EKS Cluster의 OIDC Identity Provider가 발급한 Token이라고 **간주**하고 처리한다.

{% highlight text %}
# aws iam list-open-id-connect-providers
{
    "OpenIDConnectProviderList": [
        {
            "Arn": "arn:aws:iam::132099918825:oidc-provider/oidc.eks.ap-northeast-2.amazonaws.com/id/B0678ED568FC12BBC37256BBA2A4BB53"
        }
    ]
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 1] Federated OIDC Identity Provider 조회</figcaption>
</figure>

[Console 1]은 AWS IAM을 통해서 신뢰하는 OIDC Identity Provider의 List를 조회하는 모습을 나타낸다. EKS Cluster의 OIDC Identity Provider도 신뢰하는 OIDC Identity Provider로 등록되어 있는것을 확인할 수 있다.

### 2. 참조

* [https://aws.amazon.com/ko/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/](https://aws.amazon.com/ko/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/)
* [https://aws.amazon.com/ko/blogs/containers/enabling-cross-account-access-to-amazon-eks-cluster-resources/](https://aws.amazon.com/ko/blogs/containers/enabling-cross-account-access-to-amazon-eks-cluster-resources/)
* [https://pnguyen.io/posts/eks-iam-roles-for-service-accounts/](https://pnguyen.io/posts/eks-iam-roles-for-service-accounts/)
* [https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html](https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html)
* [https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html)
* [https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-token-volume-projection](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-token-volume-projection)
* [https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/)
* [https://reece.tech/posts/oidc-k8s-to-aws/](https://reece.tech/posts/oidc-k8s-to-aws/)
* [https://tech.devsisters.com/posts/pod-iam-role/](https://tech.devsisters.com/posts/pod-iam-role/)
* [https://www.blog-dreamus.com/post/flo-tech-aws-eks%EC%97%90%EC%84%9C%EC%9D%98-iam-%EC%97%AD%ED%95%A0-%EB%B6%84%EB%A6%AC](https://www.blog-dreamus.com/post/flo-tech-aws-eks%EC%97%90%EC%84%9C%EC%9D%98-iam-%EC%97%AD%ED%95%A0-%EB%B6%84%EB%A6%AC)
* [https://qiita.com/hiyosi/items/feec917d502af8ad8863](https://qiita.com/hiyosi/items/feec917d502af8ad8863)
* [https://stackoverflow.com/questions/57192079/serviceaccount-token-volume-projection-projected-token-in-path-in-manifest-f](https://stackoverflow.com/questions/57192079/serviceaccount-token-volume-projection-projected-token-in-path-in-manifest-f)
* [https://kangwoo.kr/2020/02/13/service-account-token-volume-projection/](https://kangwoo.kr/2020/02/13/service-account-token-volume-projection/)
* [https://banzaicloud.com/blog/kubernetes-oidc/](https://banzaicloud.com/blog/kubernetes-oidc/)
* [https://www.ianunruh.com/posts/oauth2-proxy-with-k8s-service-accounts/](https://www.ianunruh.com/posts/oauth2-proxy-with-k8s-service-accounts/)