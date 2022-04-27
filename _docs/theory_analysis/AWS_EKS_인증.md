---
title: AWS EKS 인증
category: Theory, Analysis
date: 2021-04-28T12:00:00Z
lastmod: 2022-04-28T12:00:00Z
comment: true
adsense: true
---

AWS EKS의 인증 과정을 분석한다.

### 1. AWS EKS 인증

![[그림 1] AWS EKS 인증]({{site.baseurl}}/images/theory_analysis/AWS_EKS_인증/AWS_EKS_인증.PNG){: width="650px"}

[그림 1]은 AWS EKS Cluster의 인증 과정을 나타내고 있다. EKS Cluster는 **AWS IAM Authenticator**를 이용하여 인증을 수행한다. AWS IAM Authenticator 기반의 EKS Cluster 인증 기법은 kubectl에서 EKS Cluster의 K8s API Server 접근하거나, Worker Node에서 동작하는 kubelet에서 EKS Cluster의 K8s API Server 접근시에 이용한다.

{% highlight yaml %}
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
<figcaption class="caption">[파일 1] kubelet kubeconfig</figcaption>
</figure>

{% highlight yaml %}
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ...
    server: https://B0678ED568FC12BBC37256BBA2A4BB53.yl4.ap-northeast-2.eks.amazonaws.com
  name: ssup2-eks-cluster.ap-northeast-2.eksctl.io
contexts:
- context:
    cluster: ssup2-eks-cluster.ap-northeast-2.eksctl.io
    user: ssup2@ssup2-eks-cluster.ap-northeast-2.eksctl.io
  name: ssup2@ssup2-eks-cluster.ap-northeast-2.eksctl.io
current-context: ssup2@ssup2-eks-cluster.ap-northeast-2.eksctl.io
kind: Config
preferences: {}
users:
- name: ssup2@ssup2-eks-cluster.ap-northeast-2.eksctl.io
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
<figcaption class="caption">[파일 2] kubectl kubeconfig</figcaption>
</figure>

[파일 1]은 kubelet의 kubeconfig을 나타내고 있고, [파일 2]은 kubectl의 kubeconfig를 나타내고 있다. 두 kubeconfig 모두 user 부분을 확인해보면 "aws eks get-token" 명령어를 수행하는 것을 확인할 수 있다. "aws eks get-token" 명령어는 "aws eks get-token"을 수행하는 Identity(대상)가 누구인지 알려주는 AWS STS의 **GetCallerIdentity API의 Presigned URL**을 생성하고, 생성한 URL을 Encoding하여 Token을 생성한다. 여기서 Identity는 **AWS IAM의 User/Role**을 의미한다.

Presigned URL은 의미그대로 미리 할당된 URL을 의미한다. AWS STS의 GetCallerIdentity API를 호출하기 위해서는 AccessKey/SecretAccessKey와 같은 Secret이 필요하지만, Presigned URL을 이용하여 GetCallerIdentity API를 호출하면 Secret없이 호출이 가능하다. Token을 통해서 전달되는 GetCallerIdentity API의 Presigned URL은 AWS IAM Authenticator에게 전달되어 "aws eks get-token" 명령어를 수행한 Identity이 누구인지 파악하는데 이용된다.

{% highlight console %}
# aws eks get-token --cluster-name ssup2-eks-cluster
{
	"kind": "ExecCredential",
	"apiVersion": "client.authentication.k8s.io/v1alpha1",
	"spec": {},
	"status": {
		"expirationTimestamp": "2022-04-26T17:46:42Z",
		"token": "k8s-aws-v1.aHR0cHM6Ly9zdHMuYXAtbm9ydGhlYXN0LTIuYW1hem9uYXdzLmNvbS8_QWN0aW9uPUdldENhbGxlcklkZW50aXR5JlZlcnNpb249MjAxMS0wNi0xNSZYLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFSNVFPRVpQVTRRWFg1SDRGJTJGMjAyMjA0MjYlMkZhcC1ub3J0aGVhc3QtMiUyRnN0cyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjIwNDI2VDE3MzI0MlomWC1BbXotRXhwaXJlcz02MCZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QlM0J4LWs4cy1hd3MtaWQmWC1BbXotU2lnbmF0dXJlPTIxOGQ4MDQ5NTBlZGMxMWRlZmQ0OWMwYTFkNWZkYWNjMzI0Y2M4MzBmZDZmMDZkNTlhN2Q5NzUwMGZhM2U3Mzg"
	}
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 1] aws eks get-token 명령어 Output</figcaption>
</figure>

[Console 1]은 "aws eks get-token" 명령어의 출력 결과를 나타내고 있다.

{% highlight console %}
# base64url decode aHR0cHM6Ly9zdHMuYXAtbm9ydGhlYXN0LTIuYW1hem9uYXdzLmNvbS8_QWN0aW9uPUdldENhbGxlcklkZW50aXR5JlZlcnNpb249MjAxMS0wNi0xNSZYLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFSNVFPRVpQVTRRWFg1SDRGJTJGMjAyMjA0MjYlMkZhcC1ub3J0aGVhc3QtMiUyRnN0cyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjIwNDI2VDE3MzI0MlomWC1BbXotRXhwaXJlcz02MCZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QlM0J4LWs4cy1hd3MtaWQmWC1BbXotU2lnbmF0dXJlPTIxOGQ4MDQ5NTBlZGMxMWRlZmQ0OWMwYTFkNWZkYWNjMzI0Y2M4MzBmZDZmMDZkNTlhN2Q5NzUwMGZhM2U3Mzg
https://sts.ap-northeast-2.amazonaws.com/?Action=GetCallerIdentity&Version=2011-06-15&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAR5QOEZPU4QXX5H4F%2F20220426%2Fap-northeast-2%2Fsts%2Faws4_request&X-Amz-Date=20220426T173242Z&X-Amz-Expires=60&X-Amz-SignedHeaders=host%3Bx-k8s-aws-id&X-Amz-Signature=218d804950edc11defd49c0a1d5fdacc324cc830fd6f06d59a7d97500fa3e738
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 2] Decode Token</figcaption>
</figure>

[Console 1]의 token의 "k8s-aws-v1" 뒤부분의 문자열을 base64url로 decoding을 수행하면 [Console 2]의 내용과 같이 GetCallerIdentity API의 Presigned URL을 확인할 수 있다.

{% highlight console %}
# curl -H "x-k8s-aws-id: ssup2-eks-cluster" "https://sts.ap-northeast-2.amazonaws.com/?Action=GetCallerIdentity&Version=2011-06-15&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAR5QOEZPU4QXX5H4F%2F20220426%2Fap-northeast-2%2Fsts%2Faws4_request&X-Amz-Date=20220426T173242Z&X-Amz-Expires=60&X-Amz-SignedHeaders=host%3Bx-k8s-aws-id&X-Amz-Signature=218d804950edc11defd49c0a1d5fdacc324cc830fd6f06d59a7d97500fa3e738"
<GetCallerIdentityResponse xmlns="https://sts.amazonaws.com/doc/2011-06-15/">
  <GetCallerIdentityResult>
    <Arn>arn:aws:iam::142021912854:user/ssup2</Arn>
    <UserId>DCDAJXZHJQB4JQK2FDWQ</UserId>
    <Account>142021912854</Account>
  </GetCallerIdentityResult>
  <ResponseMetadata>
    <RequestId>9bdb9ca4-65c5-4659-8ca0-0e0625d14c5d</RequestId>
  </ResponseMetadata>
</GetCallerIdentityResponse>
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 3] Get Identity from AWS STS</figcaption>
</figure>

GetCallerIdentity API의 Presigned URL에 "x-k8s-aws-id: Cluster 이름" Header와 함께 Get 요청을 수행하면 "aws eks get-token" 명령어를 수행한 Identity이 누구인지 알 수 있다. [Console 3]은 [Console 2]에서 얻은 GetCallerIdentity API의 Presigned URL을 대상으로 Get 요청을 수행하는 예제를 나타내고 있다. "ssup2" User가 "aws eks get-token" 명령어를 수행했다는 사실을 알 수 있다.

AWS IAM Authenticator는 EKS Cluster의 K8s API Server에 인증 Webhook Server로 등록되어 있다. 따라서 kubelet/kubectl이 "aws eks get-token" 명령어를 통해서 생성한 Token은 AWS IAM Authenticator에게 전달된다. AWS IAM Authenticator는 [Console 2], [Console 3]의 과정을 통해서 "aws eks get-token" 명령어를 수행한 대상을 파악한다.

{% highlight yaml %}
apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::132099418825:role/eksctl-ssup2-eks-cluster-nodegrou-NodeInstanceRole-1CR0AFVMLFHSE
      username: system:node:{{EC2PrivateDNSName}}
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::132099418825:role/eksctl-ssup2-eks-cluster-nodegrou-NodeInstanceRole-1FLORRGQWIWD8
      username: system:node:{{EC2PrivateDNSName}}
  mapUsers: |
    - userarn: arn:aws:iam::142627221238:user/ssup2
      username: admin
      groups:
        - system:masters
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] aws-auth ConfigMap in kube-system Namespace</figcaption>
</figure>

AWS IAM Authenticator는 "aws eks get-token" 명령어를 수행한 Identity를 파악한 다음, 파악한 Identity가 EKS Cluster의 어떤 User/Group과 **Mapping** 되는지 확인한다. 이후 AWS IAM Authenticator는 Mapping 되는 EKS Cluster의 User/Group을 EKS Cluster의 K8s API Server에게 전달한다.

"aws eks get-token" 명령어을 수행한 Identity와 EKS Cluster의 User/Group과의 Mapping 정보는 kube-system Namespace에 존재하는 **aws-auth** ConfigMap에 저장되어 있다. [파일 3]은 "aws-auth" ConfigMap의 예제를 나타내고 있다. mapUser 항목은 "aws eks get-token" 명령어을 수행한 AWS IAM User와 EKS Cluster의 User/Group을 Mapping을 하는데 이용되며, mapRoles 항목은 "aws eks get-token" 명령어를 수행한 AWS IAM Role과 EKS Cluster의 User/Group을 Mapping 하는데 이용한다.

[파일 3]에서 ssup2 AWS IAM User는 EKS Cluster의 admin User 또는 system:master Group에 Mapping되는걸 확인할 수 있다. EKS Cluster에서 Node Group 생성시 각 Node Group에서 이용하는 AWS IAM Role이 생성되는데, Node Group의 AWS IAM Role도 [파일 3]의 mapRoles 항목에서 확인할 수 있다.

### 2. 참조

* [https://faddom.com/accessing-an-amazon-eks-kubernetes-cluster/](https://faddom.com/accessing-an-amazon-eks-kubernetes-cluster/)
* [https://github.com/kubernetes-sigs/aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator)
* [https://m.blog.naver.com/alice_k106/221967218283](https://m.blog.naver.com/alice_k106/221967218283)
* [http://www.noobyard.com/article/p-ktxvpcyg-er.html](http://www.noobyard.com/article/p-ktxvpcyg-er.html)
* [https://github.com/saibotsivad/base64-url-cli](https://github.com/saibotsivad/base64-url-cli)
* [https://github.com/aws/aws-cli/blob/master/awscli/customizations/eks/get_token.py](https://github.com/aws/aws-cli/blob/master/awscli/customizations/eks/get_token.py)
* [https://github.com/boto/boto3/blob/master/docs/source/guide/s3-presigned-urls.rst](https://github.com/boto/boto3/blob/master/docs/source/guide/s3-presigned-urls.rst)