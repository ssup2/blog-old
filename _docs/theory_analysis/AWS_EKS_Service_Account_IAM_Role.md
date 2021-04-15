---
title: AWS EKS Service Account와 AWS IAM Role 연동
category: Theory, Analysis
date: 2021-04-15T12:00:00Z
lastmod: 2021-04-15T12:00:00Z
comment: true
adsense: true
---

AWS EKS Cluster의 Service Account와 AWS IAM Role을 연동하는 과정을 정리한다.

### 1. AWS EKS Service Account와 AWS IAM Role 연동

![[그림 1] B-Tree]({{site.baseurl}}/images/theory_analysis/AWS_EKS_Service_Account_IAM_Role/AWS_EKS_Service_Account_IAM_Role.PNG)

AWS EKS 1.14 Version 이상에서는 EKS (K8s) Cluster의 Service Account에 AWS IAM의 Role을 부여할 수 있는 기능을 제공하고 있다. 이 기능을 통해서 Pod에게 AWS Service에 접근할 수 있는 권한을 줄 수 있다.

### 2. 참조

* [https://pnguyen.io/posts/eks-iam-roles-for-service-accounts/](https://pnguyen.io/posts/eks-iam-roles-for-service-accounts/)
* [https://aws.amazon.com/ko/blogs/containers/enabling-cross-account-access-to-amazon-eks-cluster-resources/](https://aws.amazon.com/ko/blogs/containers/enabling-cross-account-access-to-amazon-eks-cluster-resources/)
* [https://tech.devsisters.com/posts/pod-iam-role/](https://tech.devsisters.com/posts/pod-iam-role/)
* [https://www.blog-dreamus.com/post/flo-tech-aws-eks%EC%97%90%EC%84%9C%EC%9D%98-iam-%EC%97%AD%ED%95%A0-%EB%B6%84%EB%A6%AC](https://www.blog-dreamus.com/post/flo-tech-aws-eks%EC%97%90%EC%84%9C%EC%9D%98-iam-%EC%97%AD%ED%95%A0-%EB%B6%84%EB%A6%AC)