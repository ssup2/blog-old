---
title: Kubernetes Kubeflow 설치 / Ubuntu 18.04 환경
category: Record
date: 2020-12-26T12:00:00Z
lastmod: 2020-12-26T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

![[그림 1] Kubeflow 설치를 위한 Node 구성도]({{site.baseurl}}/images/record/Kubernetes_Kubeflow_Install_Ubuntu_18.04/Node_Setting.PNG)

설치 환경은 다음과 같다.
* Kubernetes 1.18.14
* Kubeflow 1.2.0
* Istio 1.3
* Helm 3.4.2
* NFS Server
  * 192.168.0.60:/nfs_root/ssup2_kubeflow

### 2. NFS Package 설치

~~~console
(Worker/Master)# apt-get install nfs-common
~~~

Kubernetes Cluster에서 NFS Client Provisioner를 이용하기 위해서 Master, Worker Node에 nfs-common Packet를 설치한다.

### 3. NFS Client Provisioner 설치

~~~console
(User)# helm repo add stable https://charts.helm.sh/stable
(User)# helm repo update
(User)# helm install nfs-client-provisioner --set nfs.server=192.168.0.60 --set nfs.path=/nfs_root/ssup2_kubeflow stable/nfs-client-provisioner
(User)# kubectl get sc
NAME         PROVISIONER                            AGE
nfs-client   cluster.local/nfs-client-provisioner   5m52s
~~~

Helm을 이용하여 NFS Client Provisioner를 설치한다.

~~~console
(User)# kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
~~~

nfs-client Storage Class를 Default Storage Class로 설정한다.

### 4. Kubernetes API Servr 설정

{% highlight text %}
...
spec:
  containers:
  - command:
    - kube-apiserver
    - --service-account-signing-key-file=/etc/kubernetes/pki/sa.key
    - --service-account-issuer=kubernetes.default.svc
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] /etc/kubernetes/manifests/kube-apiserver.yaml</figcaption>
</figure>

Istio 설치를 위해서 Master Node의 /etc/kubernetes/manifests/kube-apiserver.yaml 파일에 [파일 1]의 내용처럼 service-account-signing-key-file, service-account-issuer 설정을 추가한다.

### 5. kfctl 설치

~~~console
(User)# mkdir ~/kubeflow
(User)# cd ~/kubeflow
(User)# curl -L -O -J https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-gbc038f9_linux.tar.gz
(User)# tar -xvf kfctl_v1.2.0-0-gbc038f9_linux.tar.gz
(User)# rm kfctl_v1.2.0-0-gbc038f9_linux.tar.gz
~~~

kubeflow 관리 도구인 kfctl을 설치한다.

### 6. Kubeflow 설치

{% highlight text %}
export PATH=$PATH:~/kubeflow
export KF_NAME=ssup2-kubeflow
export BASE_DIR=~/kubeflow/cluster
export KF_DIR=${BASE_DIR}/${KF_NAME}
export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_k8s_istio.v1.2.0.yaml"
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] ~/kubeflow/kfctl_env</figcaption>
</figure>

[파일 1]의 내용으로 kfctl을 위한 env 파일을 생성한다.

~~~console
(User)# . ~/kubeflow/kfctl_env
(User)# mkdir -p ${KF_DIR}
(User)# cd ${KF_DIR}
(User)# kfctl apply -V -f ${CONFIG_URI}
~~~

Kubeflow를 설치한다. 설치가 완료된 이후에 istio-system Namespace의 istio-ingressgateway Service의 NodePort를 이용하여 Kubeflow Dashboard에 접근한다.
  * http://192.168.0.61:31380/

### 7. 참조

* kustomize Install : [https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/)
* Kubeflow Install : [https://www.kubeflow.org/docs/started/k8s/kfctl-k8s-istio/](https://www.kubeflow.org/docs/started/k8s/kfctl-k8s-istio/)
* Kubeflow kustomize : [https://www.kubeflow.org/docs/other-guides/kustomize/](https://www.kubeflow.org/docs/other-guides/kustomize/)