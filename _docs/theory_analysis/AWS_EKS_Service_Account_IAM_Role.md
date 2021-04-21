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
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 2] Mutated Pod Spec</figcaption>
</figure>

#### 1.3. Create/Rotate Token

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
<figcaption class="caption">[Text 3] Token</figcaption>
</figure>

#### 1.4. Use Token

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
<figcaption class="caption">[Text 4] Role's Trust Relationships</figcaption>
</figure>

### 2. 참조

* [https://aws.amazon.com/ko/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/](https://aws.amazon.com/ko/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/)
* [https://aws.amazon.com/ko/blogs/containers/enabling-cross-account-access-to-amazon-eks-cluster-resources/](https://aws.amazon.com/ko/blogs/containers/enabling-cross-account-access-to-amazon-eks-cluster-resources/)
* [https://pnguyen.io/posts/eks-iam-roles-for-service-accounts/](https://pnguyen.io/posts/eks-iam-roles-for-service-accounts/)
* [https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html](https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html)
* [https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html)
* [https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-token-volume-projection](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-token-volume-projection)
* [https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/)
* [https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-issuer-discovery](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-issuer-discovery)
* [https://tech.devsisters.com/posts/pod-iam-role/](https://tech.devsisters.com/posts/pod-iam-role/)
* [https://www.blog-dreamus.com/post/flo-tech-aws-eks%EC%97%90%EC%84%9C%EC%9D%98-iam-%EC%97%AD%ED%95%A0-%EB%B6%84%EB%A6%AC](https://www.blog-dreamus.com/post/flo-tech-aws-eks%EC%97%90%EC%84%9C%EC%9D%98-iam-%EC%97%AD%ED%95%A0-%EB%B6%84%EB%A6%AC)
* [https://qiita.com/hiyosi/items/feec917d502af8ad8863](https://qiita.com/hiyosi/items/feec917d502af8ad8863)