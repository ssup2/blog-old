---
title: Kubernetes Kubeflow 설치 (Not Working) / Ubuntu 18.04, Jetson Nano Cluster 환경
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

* Kubeflow 1.2.0
* Kubernetes 1.18.14
* Helm 3.0.2
* NFS Server (Master Node)
  * 192.168.0.41:/nfs_root

### 2. kustomize 설치

~~~console
# curl -s "https://raw.githubusercontent.com/\
kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
~~~

kubectl 명령어에 포함된 kustomize는 resouces 문법을 지원하지 않기 때문에, 최신 kustomize를 설치하여 이용한다.

### 3. kfctl 설치

~~~console
# mkdir ~/kubeflow
# cd ~/kubeflow
# curl -L -O -J https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-gbc038f9_linux.tar.gz
# tar -xvf kfctl_v1.2.0-0-gbc038f9_linux.tar.gz
# rm kfctl_v1.2.0-0-gbc038f9_linux.tar.gz
~~~

kubeflow 관리 도구인 kfctl을 설치한다.

### 4. NFS Client Provisioner 설치

~~~console
# helm repo update
# helm install nfs-client-provisioner --set nfs.server=192.168.0.41 --set nfs.path=/nfs_root stable/nfs-client-provisioner-arm
# kubectl get sc
NAME         PROVISIONER                            AGE
nfs-client   cluster.local/nfs-client-provisioner   5m52s
~~~

Helm을 이용하여 NFS Client Provisioner를 설치한다.

~~~console
# kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
~~~

nfs-client Storage Class를 Default Storage Class로 설정한다.

### 4. Kubeflow 설치

#### 4.1. Kubeflow kustomize 파일 생성

{% highlight text %}
export PATH=$PATH:~/kubeflow
export KF_NAME=ssup2-kubeflow
export BASE_DIR=~/kubeflow
export KF_DIR=${BASE_DIR}/${KF_NAME}
export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_k8s_istio.v1.2.0.yaml"
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] ~/kubeflow/kfctl_env</figcaption>
</figure>

[파일 1]의 내용으로 kfctl을 위한 env 파일을 생성한다.

~~~console
# . ~/kubeflow/kfctl_env
# mkdir -p ${KF_DIR}
# cd ${KF_DIR}
# kfctl build -V -f ${CONFIG_URI}
~~~

Kubeflow를 kustomize 파일을 생성한다.

#### 4.2. cert-manager 설치

~~~
# kustomize build --load_restrictor none ssup2-kubeflow/kustomize/cert-manager-crds | kubectl apply -f -
# kustomize build --load_restrictor none ssup2-kubeflow/kustomize/cert-manager-kube-system-resources  | kubectl apply -f -

# sed -i 's/cert-manager-cainjector:/cert-manager-cainjector-arm64:/g' ~/kubeflow/ssup2-kubeflow/.cache/manifests/manifests-1.2.0/cert-manager/cert-manager/base/deployment.yaml
# sed -i 's/cert-manager-controller:/cert-manager-controller-arm64:/g' ~/kubeflow/ssup2-kubeflow/.cache/manifests/manifests-1.2.0/cert-manager/cert-manager/base/deployment.yaml
# sed -i 's/cert-manager-webhook:/cert-manager-webhook-arm64:/g' ~/kubeflow/ssup2-kubeflow/.cache/manifests/manifests-1.2.0/cert-manager/cert-manager/base/deployment.yaml
# kustomize build --load_restrictor none ssup2-kubeflow/kustomize/cert-manager | kubectl apply -f -
~~~

#### 4.3. isito 설치

### 5. 참조

* kustomize Install : [https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/)
* Kubeflow Install : [https://www.kubeflow.org/docs/started/k8s/kfctl-k8s-istio/](https://www.kubeflow.org/docs/started/k8s/kfctl-k8s-istio/)
* Kubeflow kustomize : [https://www.kubeflow.org/docs/other-guides/kustomize/](https://www.kubeflow.org/docs/other-guides/kustomize/)
* Kubeflow ARM Support : [https://github.com/kubeflow/kfctl/pull/318](https://github.com/kubeflow/kfctl/pull/318)