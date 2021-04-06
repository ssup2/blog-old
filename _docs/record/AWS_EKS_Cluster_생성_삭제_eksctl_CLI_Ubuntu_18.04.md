---
title: AWS EKS Cluster 생성 / eksctl CLI 이용 / Ubuntu 18.04
category: Record
date: 2021-04-06T12:00:00Z
lastmod: 2021-04-06T12:00:00Z
comment: true
adsense: true
---

### 1. 실행 환경

* Ubuntu 18.04 LTS 64bit, root user
* EKS Cluster
  * Version 1.18
  * Subnet 10.0.0.0/16
* aws CLI
  * Region ap-northeast-2
  * Version 2.1.34
* eksctl CLI
  * Version 0.43.0

### 2. aws CLI 설치

~~~console
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install
~~~

aws CLI를 설치한다.

~~~console
# aws configure
AWS Access Key ID [None]: <Access Key>
AWS Secret Access Key [None]: <Secret Access Key>
Default region name [None]: ap-northeast-2
Default output format [None]:
~~~

aws CLI에 인증정보를 설정한다.

### 3. eksctl 설치

~~~console
# curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
# sudo mv /tmp/eksctl /usr/local/bin
# eksctl version
~~~

### 4. SSH Key 생성

~~~console
# aws ec2 create-key-pair --key-name ssup2-eks-ssh --query 'KeyMaterial' --output text > ssup2-eks-ssh.pem
~~~

EKS Node에 SSH로 접근하기 위한 SSH Key를 생성한다.

### 5. Cluster 생성

EKS Cluster를 생성한다.

~~~console
# cat > ssup2-eks-cluster.yaml << EOL
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: ssup2-eks-cluster
  region: ap-northeast-2
nodeGroups:
  - name: nodegroup-1
    instanceType: t3.medium
    desiredCapacity: 2
    ssh:
      publicKeyName: ssup2-eks-ssh
  - name: nodegroup-2
    instanceType: t3.medium
    desiredCapacity: 2
    ssh:
      publicKeyName: ssup2-eks-ssh
EOL
~~~

EKS Cluster Spec을 작성한다.

~~~console
# eksctl create cluster -f ssup2-eks-cluster.yaml
2021-04-06 14:21:50 [ℹ]  eksctl version 0.43.0
2021-04-06 14:21:50 [ℹ]  using region ap-northeast-2
2021-04-06 14:21:51 [ℹ]  setting availability zones to [ap-northeast-2b ap-northeast-2c ap-northeast-2a]
2021-04-06 14:21:51 [ℹ]  subnets for ap-northeast-2b - public:192.168.0.0/19 private:192.168.96.0/19
2021-04-06 14:21:51 [ℹ]  subnets for ap-northeast-2c - public:192.168.32.0/19 private:192.168.128.0/19
2021-04-06 14:21:51 [ℹ]  subnets for ap-northeast-2a - public:192.168.64.0/19 private:192.168.160.0/19
2021-04-06 14:21:51 [ℹ]  nodegroup "nodegroup-1" will use "ami-018f6f9b3c61e383c" [AmazonLinux2/1.18]
2021-04-06 14:21:51 [ℹ]  using EC2 key pair "ssup2-eks-ssh"
2021-04-06 14:21:51 [ℹ]  nodegroup "nodegroup-2" will use "ami-018f6f9b3c61e383c" [AmazonLinux2/1.18]
2021-04-06 14:21:51 [ℹ]  using EC2 key pair "ssup2-eks-ssh"
2021-04-06 14:21:51 [ℹ]  using Kubernetes version 1.18
2021-04-06 14:21:51 [ℹ]  creating EKS cluster "ssup2-eks-cluster" in "ap-northeast-2" region with un-managed nodes
2021-04-06 14:21:51 [ℹ]  2 nodegroups (nodegroup-1, nodegroup-2) were included (based on the include/exclude rules)
2021-04-06 14:21:51 [ℹ]  will create a CloudFormation stack for cluster itself and 2 nodegroup stack(s)
2021-04-06 14:21:51 [ℹ]  will create a CloudFormation stack for cluster itself and 0 managed nodegroup stack(s)
2021-04-06 14:21:51 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=ap-northeast-2 --cluster=ssup2-eks-cluster'
2021-04-06 14:21:51 [ℹ]  CloudWatch logging will not be enabled for cluster "ssup2-eks-cluster" in "ap-northeast-2"
2021-04-06 14:21:51 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=ap-northeast-2 --cluster=ssup2-eks-cluster'
2021-04-06 14:21:51 [ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "ssup2-eks-cluster" in "ap-northeast-2"
2021-04-06 14:21:51 [ℹ]  2 sequential tasks: { create cluster control plane "ssup2-eks-cluster", 3 sequential sub-tasks: { wait for control plane to become ready, create addons, 2 parallel sub-tasks: { create nodegroup "nodegroup-1", create nodegroup "nodegroup-2" } } }
2021-04-06 14:21:51 [ℹ]  building cluster stack "eksctl-ssup2-eks-cluster-cluster"
2021-04-06 14:21:52 [ℹ]  deploying stack "eksctl-ssup2-eks-cluster-cluster"
2021-04-06 14:22:22 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-cluster"
2021-04-06 14:22:52 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-cluster"
2021-04-06 14:23:52 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-cluster"
2021-04-06 14:24:52 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-cluster"
2021-04-06 14:25:52 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-cluster"
2021-04-06 14:26:52 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-cluster"
2021-04-06 14:27:52 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-cluster"
2021-04-06 14:28:53 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-cluster"
2021-04-06 14:29:53 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-cluster"
2021-04-06 14:30:53 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-cluster"
2021-04-06 14:31:53 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-cluster"
2021-04-06 14:32:53 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-cluster"
2021-04-06 14:32:55 [ℹ]  building nodegroup stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:32:55 [ℹ]  building nodegroup stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:32:55 [ℹ]  --nodes-min=2 was set automatically for nodegroup nodegroup-2
2021-04-06 14:32:55 [ℹ]  --nodes-max=2 was set automatically for nodegroup nodegroup-2
2021-04-06 14:32:55 [ℹ]  --nodes-min=2 was set automatically for nodegroup nodegroup-1
2021-04-06 14:32:55 [ℹ]  --nodes-max=2 was set automatically for nodegroup nodegroup-1
2021-04-06 14:32:55 [ℹ]  deploying stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:32:55 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:32:55 [ℹ]  deploying stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:32:55 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:33:11 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:33:13 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:33:31 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:33:31 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:33:46 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:33:47 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:34:03 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:34:07 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:34:20 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:34:24 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:34:40 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:34:43 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:34:56 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:35:01 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:35:15 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:35:19 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:35:34 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:35:34 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:35:52 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:35:53 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:36:07 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:36:09 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:36:25 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:36:26 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:36:41 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:36:43 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:36:57 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-2"
2021-04-06 14:37:00 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-nodegroup-nodegroup-1"
2021-04-06 14:37:00 [ℹ]  waiting for the control plane availability...
2021-04-06 14:37:00 [✔]  saved kubeconfig as "/root/.kube/config"
2021-04-06 14:37:00 [ℹ]  no tasks
2021-04-06 14:37:00 [✔]  all EKS cluster resources for "ssup2-eks-cluster" have been created
2021-04-06 14:37:00 [ℹ]  adding identity "arn:aws:iam::132099918825:role/eksctl-ssup2-eks-cluster-nodegrou-NodeInstanceRole-1DV6ZYBOMIR3T" to auth ConfigMap
2021-04-06 14:37:00 [ℹ]  nodegroup "nodegroup-1" has 0 node(s)
2021-04-06 14:37:00 [ℹ]  waiting for at least 2 node(s) to become ready in "nodegroup-1"
2021-04-06 14:37:33 [ℹ]  nodegroup "nodegroup-1" has 2 node(s)
2021-04-06 14:37:33 [ℹ]  node "ip-192-168-48-175.ap-northeast-2.compute.internal" is ready
2021-04-06 14:37:33 [ℹ]  node "ip-192-168-75-136.ap-northeast-2.compute.internal" is ready
2021-04-06 14:37:33 [ℹ]  adding identity "arn:aws:iam::132099918825:role/eksctl-ssup2-eks-cluster-nodegrou-NodeInstanceRole-1MZ7I3GEFCBJM" to auth ConfigMap
2021-04-06 14:37:33 [ℹ]  nodegroup "nodegroup-2" has 0 node(s)
2021-04-06 14:37:33 [ℹ]  waiting for at least 2 node(s) to become ready in "nodegroup-2"
2021-04-06 14:39:55 [ℹ]  nodegroup "nodegroup-2" has 2 node(s)
2021-04-06 14:39:55 [ℹ]  node "ip-192-168-46-6.ap-northeast-2.compute.internal" is ready
2021-04-06 14:39:55 [ℹ]  node "ip-192-168-90-3.ap-northeast-2.compute.internal" is ready
2021-04-06 14:39:57 [ℹ]  kubectl command should work with "/root/.kube/config", try 'kubectl get nodes'
2021-04-06 14:39:57 [✔]  EKS cluster "ssup2-eks-cluster" in "ap-northeast-2" region is ready
~~~

작성한 EKS Cluster Spec과 eksctl CLI를 통해서 EKS Cluster를 생성한다.

### 6. EKS Cluster 동작 확인

생성한 EKS Cluster의 동작을 확인한다.

~~~console
# eksctl utils write-kubeconfig --cluster ssup2-eks-cluster
2021-04-06 14:40:28 [ℹ]  eksctl version 0.43.0
2021-04-06 14:40:28 [ℹ]  using region ap-northeast-2
2021-04-06 14:40:29 [✔]  saved kubeconfig as "/root/.kube/config"
~~~

생성한 EKS Cluster의 kubeconfig를 설정한다.

~~~console
# kubectl version
Client Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.5", GitCommit:"6b1d87acf3c8253c123756b9e61dac642678305f", GitTreeState:"clean", BuildDate:"2021-03-31T15:33:39Z", GoVersion:"go1.15.10", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"18+", GitVersion:"v1.18.9-eks-d1db3c", GitCommit:"d1db3c46e55f95d6a7d3e5578689371318f95ff9", GitTreeState:"clean", BuildDate:"2020-10-20T22:18:07Z", GoVersion:"go1.13.15", Compiler:"gc", Platform:"linux/amd64"}

# kubectl get nodes
NAME                                            STATUS   ROLES    AGE   VERSION
ip-192-168-46-6.ap-northeast-2.compute.internal     Ready    <none>   3m29s   v1.18.9-eks-d1db3c
ip-192-168-48-175.ap-northeast-2.compute.internal   Ready    <none>   4m1s    v1.18.9-eks-d1db3c
ip-192-168-75-136.ap-northeast-2.compute.internal   Ready    <none>   4m2s    v1.18.9-eks-d1db3c
ip-192-168-90-3.ap-northeast-2.compute.internal     Ready    <none>   3m25s   v1.18.9-eks-d1db3c
~~~

생성한 EKS Cluster의 Node와 Version을 확인한다.

### 7. AWS Load Balancer Controller 설치

AWS Load Balancer Controller를 설치한다.

~~~console
# eksctl utils associate-iam-oidc-provider --cluster ssup2-eks-cluster --approve
2021-04-06 14:44:35 [ℹ]  eksctl version 0.43.0
2021-04-06 14:44:35 [ℹ]  using region ap-northeast-2
2021-04-06 14:44:36 [ℹ]  will create IAM Open ID Connect provider for cluster "ssup2-eks-cluster" in "ap-northeast-2"
2021-04-06 14:44:36 [✔]  created IAM Open ID Connect provider for cluster "ssup2-eks-cluster" in "ap-northeast-2"
~~~

Cluster를 위한 OICD Provider를 생성한다.

~~~console
# curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.3/docs/install/iam_policy.json
# aws iam create-policy --policy-name ssup2-AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json
{
    "Policy": {
        "PolicyName": "ssup2-AWSLoadBalancerControllerIAMPolicy",
        "PolicyId": "ANPAR5QOEZPURVEDEZBPN",
        "Arn": "arn:aws:iam::132099918825:policy/ssup2-AWSLoadBalancerControllerIAMPolicy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2021-04-06T14:50:22+00:00",
        "UpdateDate": "2021-04-06T14:50:22+00:00"
    }
}

# eksctl create iamserviceaccount --cluster=ssup2-eks-cluster --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=arn:aws:iam::132099918825:policy/ssup2-AWSLoadBalancerControllerIAMPolicy --override-existing-serviceaccounts --approve
2021-04-06 14:52:18 [ℹ]  eksctl version 0.43.0
2021-04-06 14:52:18 [ℹ]  using region ap-northeast-2
2021-04-06 14:52:19 [ℹ]  1 iamserviceaccount (kube-system/aws-load-balancer-controller) was included (based on the include/exclude rules)
2021-04-06 14:52:19 [!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set
2021-04-06 14:52:19 [ℹ]  1 task: { 2 sequential sub-tasks: { create IAM role for serviceaccount "kube-system/aws-load-balancer-controller", create serviceaccount "kube-system/aws-load-balancer-controller" } }
2021-04-06 14:52:19 [ℹ]  building iamserviceaccount stack "eksctl-ssup2-eks-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2021-04-06 14:52:20 [ℹ]  deploying stack "eksctl-ssup2-eks-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2021-04-06 14:52:20 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2021-04-06 14:52:36 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2021-04-06 14:52:53 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2021-04-06 14:53:12 [ℹ]  waiting for CloudFormation stack "eksctl-ssup2-eks-cluster-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2021-04-06 14:53:13 [ℹ]  created serviceaccount "kube-system/aws-load-balancer-controller"

# kubectl -n kube-system get sa
NAME                                 SECRETS   AGE
...
aws-load-balancer-controller         1         3m7s
...
~~~

AWS Load Balancer Controller가 이용할 Policy를 생성하고 Policy와 연결되는 k8s Service Account를 생성한다.

~~~console
# kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.1.1/cert-manager.yaml
# curl -o v2_1_3_full.yaml https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.1.3/docs/install/v2_1_3_full.yaml

## Delete service account manifest in v2_1_3_full.yaml
## Replace "your-cluster-name" to "ssup2-eks-cluster" in deployment manifest in v2_1_3_full.yaml 

# kubectl apply -f v2_1_3_full.yaml
# kubectl -n kube-system get pod
NAME                                          READY   STATUS    RESTARTS   AGE
aws-load-balancer-controller-bc59445f-l4brz   1/1     Running   0          28s
...
~~~

AWS Load Balancer Controller를 배포한다.

### 8. EKS Cluster 삭제

~~~console
$ eksctl delete cluster --region=ap-northeast-2 --name=ssup2-eks-cluster 
~~~

EKS Cluster를 삭제한다.
