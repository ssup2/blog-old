---
title: Kubernetes Ceph RBD 연동 / Ubuntu 18.04 환경
category: Record
date: 2018-07-15T12:00:00Z
lastmod: 2019-05-21T12:00:00Z
comment: true
adsense: true
---

### 1. 설정 환경

설정 환경은 다음과 같다.
* Kubernetes 1.12
* Ceph
  * Monitor IP : 10.0.0.10:6789
  * Pool Name : kube

### 2. Ceph RDB 연동

~~~console
# ceph auth get client.admin 2>&1 |grep "key = " |awk '{print  $3'} |xargs echo -n > /tmp/secret
# kubectl create secret generic ceph-admin-secret --from-file=/tmp/secret --namespace=kube-system
~~~

Ceph Admin secret을 생성한다.

~~~console
# ceph osd pool create kube 8 8
# ceph auth add client.kube mon 'allow r' osd 'allow rwx pool=kube'
# ceph auth get-key client.kube > /tmp/secret
# kubectl create secret generic ceph-secret --from-file=/tmp/secret --namespace=kube-system
~~~

Ceph Pool 및 User secret을 생성한다.

~~~console
# git clone https://github.com/kubernetes-incubator/external-storage.git
# cd external-storage/ceph/rbd/deploy
~~~

rbd-provisioner, role, cluster role yaml을 Download 한다.

{% highlight yaml %}
...
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "create", "delete"]
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 7] rbac/clusterrole.yaml</figcaption>
</figure>

rbac/clusterrole.yaml 파일에 [파일 7]의 내용을 추가한다. (Secret Role)

~~~console
# NAMESPACE=default
# sed -r -i "s/namespace: [^ ]+/namespace: $NAMESPACE/g" ./rbac/clusterrolebinding.yaml ./rbac/rolebinding.yaml
# kubectl -n $NAMESPACE apply -f ./rbac 
~~~

rbd-provisioner, role, cluster role을 설정한다.

{% highlight yaml %}
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: kube
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ceph.com/rbd
parameters:
  monitors: 10.0.0.10:6789
  pool: kube
  adminId: admin
  adminSecretNamespace: kube-system
  adminSecretName: ceph-admin-secret
  userId: kube
  userSecretNamespace: kube-system
  userSecretName: ceph-secret
  imageFormat: "2"
  imageFeatures: layering
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 8] storage_class.yaml</figcaption>
</figure>

storage_class.yaml 파일 생성 및 [파일 8]의 내용으로 저장한다.

~~~console
# kubectl create -f ./storage_class.yaml
# kubectl get storageclasses.storage.k8s.io
NAME            PROVISIONER    AGE
rbd (default)   ceph.com/rbd   19m
~~~

Storage Class 생성 및 확인한다.

### 3. 참조

* [https://github.com/kubernetes-incubator/external-storage/tree/master/ceph/rbd](https://github.com/kubernetes-incubator/external-storage/tree/master/ceph/rbd)
* [http://blog.51cto.com/ygqygq2/2163656](http://blog.51cto.com/ygqygq2/2163656)
