---
title: Kubernetes Kubeflow 설치 (Not Working) / Ubuntu 18.04, Jetson Nano Cluster 환경
category: Record
date: 2020-04-20T12:00:00Z
lastmod: 2020-04-20T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

* Kubeflow 1.0
* Kubernetes 1.15.11
* Helm 3.0.2
* NFS Server (Master Node)
  * 192.168.0.41:/nfs_root

### 2. NFS Client Provisioner 설치

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

### 3. Kubeflow 설치

~~~console
# mkdir ~/kubeflow
# cd ~/kubeflow
# curl -L -J https://github.com/kubeflow/kfctl/releases/download/v1.0.2/kfctl_v1.0.2-0-ga476281_linux.tar.gz --output kfctl_v1.0.2-0-ga476281_linux.tar.gz
# tar -xvf kfctl_v1.0.2-0-ga476281_linux.tar.gz
# rm kfctl_v1.0.2-0-ga476281_linux.tar.gz
~~~

kfctl을 설치한다.

{% highlight text %}
export PATH=$PATH:~/kubeflow
export KF_NAME=my-kubeflow
export BASE_DIR=~/kubeflow
export KF_DIR=${BASE_DIR}/${KF_NAME}
export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.0-branch/kfdef/kfctl_k8s_istio.v1.0.2.yaml"
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] ~/kubeflow/kfctl_env</figcaption>
</figure>

[파일 1]의 내용으로 kfctl을 위한 env 파일을 생성한다.

~~~console
# . ~/kubeflow/kfctl_env
# mkdir -p ${KF_DIR}
# cd ${KF_DIR}
# kfctl apply -V -f ${CONFIG_URI}
~~~

Kubeflow를 설치한다.

### 4. 참조

* Local Path Provisioner : [https://github.com/rancher/local-path-provisioner#deployment](https://github.com/rancher/local-path-provisioner#deployment)
* Kubeflow Install : [https://www.kubeflow.org/docs/started/k8s/kfctl-k8s-istio/](https://www.kubeflow.org/docs/started/k8s/kfctl-k8s-istio/)
* Kubeflow ARM Support : [https://github.com/kubeflow/kfctl/pull/318](https://github.com/kubeflow/kfctl/pull/318)