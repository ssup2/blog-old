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

[그림 1]은 Kubernetes와 동작하는 OpenStack Cinder CSI Plugin을 나타내고 있다. **Cinder CSI Plugin은 CSI Spec의 Controller Plugin 역할과 Node Plugin 역할 모두 수행가능하다.** 따라서 Cinder CSI Plugin은 CSI Spec의 Identity Service, Controller Service, Node Service 3가지 Interface를 지원한다. Cinder CSI Plugin중에서 Controller Plugin으로 동작하는 것은 Controller Plugin Pod에서 동작하고, Node Plugin으로 동작하는 것은 Node Plugin Pod에서 동작한다. Controller Plugin Pod은 K8s의 Deployment 또는 Statefulset에 소속되어 있고, Node Plugin Pod은 K8s의 Daemonset에 소속되어 모든 Worker Node에서 동작한다.

Controller Plugin Pod에서 동작하는 App들은 cinder-csi-plugin, csi-provisioner, csi-attacher, csi-snapshotter, csi-resizer가 있으며 각각의 Container 안에서 동작한다. HA (High Availability)를 위해서 Controller Plugin Pod이 다수가 동작하는 경우, cinder-csi-plugin App을 제외한 나머지 App의 경우 Active-Standby 형태로 동작한다. 각 App의 역할은 다음과 같다.

* cinder-csi-plugin : **Controller Plugin** 역할을 수행하는 Cinder CSI Plugin을 나타낸다. cinder-csi-plugin은 csi.sock 파일을 생성하고, 생성한 csi.sock 파일을 통해서 전달되는 Controller Plugin Pod의 다른 App의 요청에 따라서 Cinder를 제어하는 역할을 수행한다. 요청은 CSI의 Identity Service와 Controller Service Interface를 통해서 이루어진다.
* csi-provisioner : Kubernetes API Server로부터 PersistentVolumeClaim Object의 변화를 Watch하여 CSI Plugin에게 CSI CreateVolume/DeleteVolume 요청을 전송한다.
* csi-attacher : Kubernetes API Server로부터 VolumeAttachment Object의 변화를 Watch하여 CSI Plugin에게 CSI ControllerPublish/ControllerUnpublish 요청을 전송한다.
* csi-snapshotter : Kubernetes API Server로부터 Snapshot CRD (Custom Resource Definition)의 변화를 Watch하여 CSI Plugin에게 CSI CreateSnapshot/DeleteSnapshot 요청을 전송한다.
* csi-resizer : Kubernetes API Server로부터 PersistentVolumeClaim Object의 변화를 Watch하여 CSI Plugin에게 CSI ControllerExpandVolume 요청을 전송한다.

Node Plugin Pod에서 동작하는 App들은 cinder-csi-plugin, node-driver-register가 있으며 각각의 Container 안에서 동작한다. 각 App의 역할은 다음과 같다.

* cinder-csi-plugin : **Node Plugin** 역할을 수행하는 Cinder CSI Plugin을 나타낸다. cinder-csi-plugin은 csi.sock 파일을 생성하고, 생성한 csi.sock 파일을 통해서 전달되는 kubelet의 요청에 따라서 Cinder를 제어하는 역할을 수행한다. 요청은 CSI의 Identity Service과 Node Service Interface를 통해서 이루어진다. kubelet은 cinder-csi-plugin에게 CSI NodeStageVolume/NodeUnstageVolume, CSI NodePublishVolume/NodeUnpublishVolume 4개의 요청을 전송한다.
* node-driver-register : **kubelet의 Plugin Registration**을 이용하여 cinder-csi-plugin을 kubelet에 등록한다. 등록 정보에는 cinder-csi-plugin의 csi.sock 파일의 경로도 포함되어 있다. kubelet은 csi.sock 파일의 경로 정보를 바탕으로 cinder-csi-plugin에게 CSI 요청을 전송한다. regi.sock 파일은 node-driver-register가 생성하며, cinder-csi-plugin을 kubelet에 등록할때만 이용한다.

cinder-csi-plugin은 OpenStack Provider Project에 소속되있고 나머지 App들은 Kubernetes CSI Project에 소속되어 있다. 다른 CSI Plugin을 이용할 경우 cinder-csi-plugin만 원하는 CSI Plugin으로 교체하면 된다.

![[그림 2] Kubernetes OpenStack Cinder CSI Volume Lifecycle]({{site.baseurl}}/images/theory_analysis/Kubernetes_OpenStack_Cinder_CSI_Plugin/OpenStack_Cinder_CSI_Volume_Lifecycle.PNG){: width="500px"}

[그림 2]는 Cinder CSI Plugin에서 지원하는 Cinder Volume의 Lifecycle을 나타내고 있다. Created, Node Ready, Volume Ready, Published 4단계 상태가 존재하는 Volume Lifecycle을 이용한다. 각 단계별로 Cinder Volume Create/Delete, Cinder Volume Attach/Detach, Cinder Volume Format, Mount/Unmount를 진행하는 것을 확인할 수 있다.

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
* Device plugin registration : [https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/device-plugins/#device-plugin-registration](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/device-plugins/#device-plugin-registration)
