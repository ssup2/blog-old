---
title: Kubernetes with OpenStack Cinder CSI Plugin
category: Theory, Analysis
date: 2019-10-27T12:00:00Z
lastmod: 2019-10-27T12:00:00Z
comment: true
adsense: true
---

Kubernetes와 동작하는 OpenStack Cinder CSI(Container Storage Interface Plugin을 분석한다.

### 1. Kubernetes OpenStack Cinder CSI(Container Storage Interface) Plugin

![[그림 1] Kubernetes OpenStack Cinder CSI Plugin]({{site.baseurl}}/images/theory_analysis/Kubernetes_OpenStack_Cinder_CSI_Plugin/OpenStack_Cinder_CSI_Plugin.PNG)

[그림 1]은 Kubernetes와 동작하는 OpenStack Cinder CSI Plugin을 나타내고 있다. **Cinder CSI Plugin은 CSI Spec의 Controller Plugin 역활과 Node Plugin 역활 모두 수행가능하다.** 따라서 Cinder CSI Plugin은 CSI Spec의 Identity Service, Controller Service, Node Service 3가지 Interface를 지원한다. Cinder CSI Plugin중에서 Controller Plugin으로 동작하는 것은 Controller Plugin Pod에서 동작하고, Node Plugin으로 동작하는 것은 Node Plugin Pod에서 동작한다. Controller Plugin Pod은 K8s의 Deployment 또는 Statefulset에 소속되어 있고, Node Plugin Pod은 Daemonset에 소속되어 모든 Worker Node에서 동작한다.

### 2. 참조

* [https://github.com/container-storage-interface/spec/blob/master/spec.md](https://github.com/container-storage-interface/spec/blob/master/spec.md)
* [https://kubernetes-csi.github.io/docs/](https://kubernetes-csi.github.io/docs/)
* [https://medium.com/google-cloud/understanding-the-container-storage-interface-csi-ddbeb966a3b](https://medium.com/google-cloud/understanding-the-container-storage-interface-csi-ddbeb966a3b)
* [https://docs.docker.com/ee/ucp/kubernetes/storage/use-csi/](https://docs.docker.com/ee/ucp/kubernetes/storage/use-csi/)
* CSI Spec : [https://github.com/container-storage-interface/spec/blob/master/spec.md](https://github.com/container-storage-interface/spec/blob/master/spec.md)
* csi-attacher : [https://github.com/kubernetes-csi/external-attacher](https://github.com/kubernetes-csi/external-attacher)
* csi-provioner : [https://github.com/kubernetes-csi/external-provisioner](https://github.com/kubernetes-csi/external-provisioner)
* csi-snapshotter : [https://github.com/kubernetes-csi/external-snapshotter](https://github.com/kubernetes-csi/external-snapshotter)
* csi-resizer : [https://github.com/kubernetes-csi/external-resizer](https://github.com/kubernetes-csi/external-resizer)
* node-driver-registrar : [https://github.com/kubernetes-csi/node-driver-registrar](https://github.com/kubernetes-csi/node-driver-registrar)
* cinder-csi-plugin : [https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-cinder-csi-plugin.md](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/using-cinder-csi-plugin.md)
