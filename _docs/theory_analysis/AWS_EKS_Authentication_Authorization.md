---
title: AWS EKS Authentication, Authorization (WIP)
category: Theory, Analysis
date: 2021-04-15T12:00:00Z
lastmod: 2022-03-31T12:00:00Z
comment: true
adsense: true
---

AWS EKS의 Authentication, Authorization를 분석한다.

### 1. AWS EKS Authentication, Authorization

#### 1.1. kubelet

{% highlight console %}
# cat /etc/eksctl/kubeconfig.yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /etc/eksctl/ca.crt
    server: https://B0678ED568FC12BBC37256BBA2A4BB53.yl4.ap-northeast-2.eks.amazonaws.com
  name: ssup2-eks-cluster.ap-northeast-2.eksctl.io
contexts:
- context:
    cluster: ssup2-eks-cluster.ap-northeast-2.eksctl.io
    user: kubelet@ssup2-eks-cluster.ap-northeast-2.eksctl.io
  name: kubelet@ssup2-eks-cluster.ap-northeast-2.eksctl.io
current-context: kubelet@ssup2-eks-cluster.ap-northeast-2.eksctl.io
kind: Config
preferences: {}
users:
- name: kubelet@ssup2-eks-cluster.ap-northeast-2.eksctl.io
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - eks
      - get-token
      - --cluster-name
      - ssup2-eks-cluster
      - --region
      - ap-northeast-2
      command: aws
      env:
      - name: AWS_STS_REGIONAL_ENDPOINTS
        value: regional
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 1] kubelet</figcaption>
</figure>

{% highlight console %}
{
	"kind": "ExecCredential",
	"apiVersion": "client.authentication.k8s.io/v1alpha1",
	"spec": {},
	"status": {
		"expirationTimestamp": "2022-03-31T01:33:44Z",
		"token": "k8s-aws-v1.aHR0cHM6Ly9zdHMu..."
	}
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 2] aws eks get-token Output</figcaption>
</figure>

#### 1.2. kubectl

{% highlight console %}
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeE1EUXdOakUwTWpneU5Wb1hEVE14TURRd05ERTBNamd5TlZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBSzZqCjliUkZndjFZTWtVSXg3dXlnOTUyRVRkRXlQbzR4Z2hyakwyQjBpazBhUXFVQU5uL21hV0JCUmpNc2RHM3dLdmsKSVZQYnRNcG9DSTY3WnhSOSsvdFhDZGJEZm1GMVhKRllzSld3aTdiNVloQzZXcXNTU3N1TXBpa3JSZTh6UlNGcwpwL3JrNzNmUGs4Z2pOR2pUcWE1ZFlJOFJJcjBpaS9NckZ6eDhqTFl2cGR5cHdsZ3NBTEl4eUF1MEdTajhXb3ZmClErKytwcGh6aU95K2luclBicUI0ZndqWHczeWhGVEJDUHNKSDRuY3JsTHZvWXM2MndJMm5lTlc3VDAzMGhPa04KMzFmOVVmOGdRQlZZTjNnTFhyUE5KTng1Y1dndFR1TFpmQU9FMjZYVkY3dzM1YXhodmRuRWZqRDFad3h4Smg1aAovZEdMR2N4LzJzZjRPZ0Ixb01jQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFDeEZuVGVLUmcrV3JZTVJWNzJScFVkbVVBdTgKdFN4ZHVxVjNIeHFLUXFHdWE2OEhDNkxmQWROcWQ5bWd2Zi9JTzgvdHFocVFNbkxKWXB1bGFDNk01WEFBYk5BdQpxZjJHTFVIaC9JS1ZSMmJUeG1EejFYbEhIaFJuMWhOdnpOZlFycGhJaHBWWG1KbWtGeURINnZjT2lMT2hvQko1CllOUkxpeEN1ei85WCtxcEZsa0lhaUNqcjNZMnNtN0dpMkIyakN6N3FKc3FFT1gralhTNHh0enEvc3NJK0pSL2MKejdvRXJjdnlsVGpCcXVabXF2RnlJYU1kNmlPQk9UQTF2cDFBNE11aVViSktFYWY2ZU4xM0JOanZFMXAxRXJtVgowRVNRWEhvVEg0YnhKNGw1Zmt0VlJ4VFJkTHc0Z0dBSTc5MWlEM0RWQi83ZHF4Vld0cGRIelFNb2VwZz0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=            server: https://B0678ED568FC12BBC37256BBA2A4BB53.yl4.ap-northeast-2.eks.amazonaws.com
  name: ssup2-eks-cluster.ap-northeast-2.eksctl.io
contexts:
- context:
    cluster: ssup2-eks-cluster.ap-northeast-2.eksctl.io
    user: kakao_ccc@ssup2-eks-cluster.ap-northeast-2.eksctl.io
  name: kakao_ccc@ssup2-eks-cluster.ap-northeast-2.eksctl.io
current-context: kakao_ccc@ssup2-eks-cluster.ap-northeast-2.eksctl.io
kind: Config
preferences: {}
users:
- name: kakao_ccc@ssup2-eks-cluster.ap-northeast-2.eksctl.io
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - eks
      - get-token
      - --cluster-name
      - ssup2-eks-cluster
      - --region
      - ap-northeast-2
      command: aws
      env:
      - name: AWS_STS_REGIONAL_ENDPOINTS
        value: regional
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 3] kubeconfig</figcaption>
</figure>

#### 1.3. OIDC Provider

`arn:aws:iam::<account-id>:oidc-provider/oidc.eks.<region>.amazonaws.com/id/<id>`

### 2. 참조

* [https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/what-is-eks.html](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/what-is-eks.html)
* [https://faddom.com/accessing-an-amazon-eks-kubernetes-cluster/](https://faddom.com/accessing-an-amazon-eks-kubernetes-cluster/)
