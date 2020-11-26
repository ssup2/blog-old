---
title: Kubernetes 설치 / ClusterAPI, External Cloud Provider 이용 / Ubuntu 18.04, OpenStack 환경
category: Record
date: 2020-11-20T12:00:00Z
lastmod: 2020-11-20T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

![[그림 1] Kubernetes 설치 환경]({{site.baseurl}}/images/record/Kubernetes_Install_ClusterAPI_External_Cloud_Provider_Ubuntu_18.04_OpenStack/Environment.PNG)

[그림 1]은 Kubernetes 설치 환경을 나타내고 있다. 설치 환경은 다음과 같다.

* Local Node : Ubuntu 18.04, KVM Enable, 4CPU, 4GB Memory
* Master, Worker Node : Ubuntu 18.04, 4vCPU, 4GB Memory
* Network
  * External Network : 192.168.0.0/24
  * Octavia Network : 20.0.0.0/24
  * Tenant Network : 10.6.0.0/24
* Kubernetes : 1.17.11
  * CNI : Cilium 1.7.11 Plugin
* External Cloud Provider
  * OpenStack Cloud Controller Manager : v1.17.0

### 2. OpenStack OpenRC 설정

OpenStack 구성에 맞게 OpenRC 파일을 작성한다.

{% highlight text %}
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=admin
export OS_AUTH_URL=http://192.168.0.40:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] admin-openrc.sh</figcaption>
</figure>

[파일 1]의 내용을 갖고 있는 admin-openrc.sh 파일을 생성한다.

### 3. Local Kubernetes Cluster 설치

~~~console
(Local)# GO111MODULE="on" go get sigs.k8s.io/kind@v0.9.0 && kind create cluster
(Local)# kubectl cluster-info
Kubernetes master is running at https://127.0.0.1:34839
KubeDNS is running at https://127.0.0.1:34839/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
~~~

Cluster API 구동하기 위한 Local Kubernetes Cluster를 설치하고 구동을 확인한다.

### 4. clusterctl 설치

~~~console
(Local)# snap install yq
~~~

clusterctl에서 이용하는 yq를 설치한다.

~~~console
(Local)# curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v0.3.11/clusterctl-linux-amd64 -o clusterctl
(Local)# chmod +x ./clusterctl
(Local)# sudo mv ./clusterctl /usr/local/bin/clusterctl
(Local)# clusterctl version                                                                                                   [15:57:48]
clusterctl version: &version.Info{Major:"0", Minor:"3", GitVersion:"v0.3.11", GitCommit:"e9cf6846b6d93dedadfcf44c00357d15f5ccba64", GitTreeState:"clean", BuildDate:"2020-11-19T18:49:17Z", GoVersion:"go1.13.15", Compiler:"gc", Platform:"linux/amd64"}
~~~

Cluster API를 Local Kubernetes Cluster에 설치하고 이용하도록 도와주는 clusterctl를 설치한다.

### 5. Cluster API 설치

~~~console
(Local)# clusterctl init --infrastructure openstack
(Local)# kubectl get pod --all-namespaces
capi-kubeadm-bootstrap-system       capi-kubeadm-bootstrap-controller-manager-6b6579d56d-q7cfm       2/2     Running   0          2m44s
capi-kubeadm-control-plane-system   capi-kubeadm-control-plane-controller-manager-6d878bb599-4wh7h   2/2     Running   0          2m43s
capi-system                         capi-controller-manager-7ff4999d6c-252dk                         2/2     Running   0          2m45s
capi-webhook-system                 capi-controller-manager-6c48f8f9bb-qknwx                         2/2     Running   0          2m45s
capi-webhook-system                 capi-kubeadm-bootstrap-controller-manager-56f98bc7f9-whkgb       2/2     Running   0          2m44s
capi-webhook-system                 capi-kubeadm-control-plane-controller-manager-85bcfd7fcd-hxs4v   2/2     Running   0          2m43s
capi-webhook-system                 capo-controller-manager-cc997bf9-vpqxd                           2/2     Running   0          2m43s
capo-system                         capo-controller-manager-64f4d7f476-95fln                         2/2     Running   0          2m42s
cert-manager                        cert-manager-cainjector-fc6c787db-jknzr                          1/1     Running   0          3m17s
cert-manager                        cert-manager-d994d94d7-rrbjg                                     1/1     Running   0          3m17s
cert-manager                        cert-manager-webhook-845d9df8bf-9m4l8                            1/1     Running   0          3m17s
...
~~~

clusterctl을 이용하여 Local Kubernetes Cluster에 Cluster API를 설치한다.

~~~console
(Local)# kubectl -n capo-system set env deployment/capo-controller-manager CLUSTER_API_OPENSTACK_INSTANCE_CREATE_TIMEOUT=60
~~~

OpenStack Controller Manager가 Instance 생성시 최대 60분 대기하도록 설정한다.

### 6. VM Image Build, Import

Cluster API를 통해서 생성할 Kubernetes Cluster Node의 VM Image를 Build 한다.

~~~console
(Local)# apt install qemu-kvm libvirt-bin qemu-utils
~~~

VM Image Build에 필요한 Ubuntu Package를 설치한다.

~~~console
(Local)# apt install python3-pip
(Local)# pip3 install ansible --user
(Local)# export PATH=$PATH:$HOME/.local/bin
~~~

Ansible을 설치한다.

~~~console
(Local)# export VER="1.6.5"
(Local)# wget "https://releases.hashicorp.com/packer/${VER}/packer_${VER}_linux_amd64.zip"
(Local)# unzip packer_1.6.5_linux_amd64.zip 
(Local)# sudo mv packer /usr/local/bin 
~~~

packer를 설치한다.

~~~console
(Local)# curl -L https://github.com/kubernetes-sigs/image-builder/tarball/master -o image-builder.tgz
(Local)# tar xzf image-builder.tgz
(Local)# cd kubernetes-sigs-image-builder-3c3a17/images/capi
(Local)# make build-qemu-ubuntu-1804
~~~

VM Image를 Build 하고 Size를 줄인다. Image를 Build 하기 위해서는 **KVM**이 지원되는 환경이어야 한다. Build된 Image는 QCOW2 Format을 갖는다.

~~~console
(Local)# . admin-openrc.sh
(Local)# openstack image create --disk-format qcow2 --container-format bare --public --file ./output/ubuntu-1804-kube-v1.17.11/ubuntu-1804-kube-v1.17.11 ubuntu-18.04-capi
~~~

Build된 Image를 OpenStack에 Import한다.

### 7. Openstack 설정

Cluster API를 위한 OpenStack을 설정한다.

~~~console
(Local)# . admin-openrc.sh
(Local)# openstack keypair create --private-key ssup2_pri.key ssup2
~~~

Cluster API를 통해서 생성할 Kubernetes Cluster Node에 설정할 Keypair를 생성한다.

~~~console
(Local)# . admin-openrc.sh
(Local)# openstack application credential create cloud-controller-manager
+--------------+----------------------------------------------------------------------------------------+
| Field        | Value                                                                                  |
+--------------+----------------------------------------------------------------------------------------+
| description  | None                                                                                   |
| expires_at   | None                                                                                   |
| id           | 96e2f01837884a59b5d70fa8a6960c9a                                                       |
| name         | cloud-controller-manager                                                               |
| project_id   | b21b68637237488bbb5f33ac8d86b848                                                       |
| roles        | admin member reader                                                                    |
| secret       | nKhWeYW0zEbkIqO4V8ubVXoHQDsfc8U8Z-eJ-up2JtvyxHWujeCB47XKJcvmaLcQjX0Qxg7CffgqwM0pdyeaww |
| system       | None                                                                                   |
| unrestricted | False                                                                                  |
| user_id      | f2bf159333f245b49240d1444f449e33                                                       |
+--------------+----------------------------------------------------------------------------------------+
~~~

OpenStack Cloud Controller Manager에서 이용할 application credential을 생성한다.

### 8. Kubernetes Cluster 생성

{% highlight text %}
clouds:
  openstack:
    insecure: true
    verify: false
    identity_api_version: 3
    auth:
      auth_url: http://192.168.0.40:5000/v3
      project_name: admin
      username: admin
      password: admin
      project_domain_name: default
      user_domain_name: default
    region: RegionOne
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] clouds.yaml</figcaption>
</figure>

clusterctl에서 이용할 [파일 2]의 내용을 갖고 있는 clouds.yaml 파일을 생성한다.

{% highlight text %}
---
apiVersion: cluster.x-k8s.io/v1alpha3
kind: Cluster
metadata:
  name: ${CLUSTER_NAME}
spec:
  clusterNetwork:
    pods:
      cidrBlocks: ["192.167.0.0/16"]
    serviceDomain: "cluster.local"
  infrastructureRef:
    apiVersion: infrastructure.cluster.x-k8s.io/v1alpha3
    kind: OpenStackCluster
    name: ${CLUSTER_NAME}
  controlPlaneRef:
    kind: KubeadmControlPlane
    apiVersion: controlplane.cluster.x-k8s.io/v1alpha3
    name: ${CLUSTER_NAME}-control-plane
---
apiVersion: infrastructure.cluster.x-k8s.io/v1alpha3
kind: OpenStackCluster
metadata:
  name: ${CLUSTER_NAME}
spec:
  cloudName: ${OPENSTACK_CLOUD}
  cloudsSecret:
    name: ${CLUSTER_NAME}-cloud-config
    namespace: ${NAMESPACE}
  managedAPIServerLoadBalancer: true
  managedSecurityGroups: true
  nodeCidr: 10.6.0.0/24
  dnsNameservers:
  - ${OPENSTACK_DNS_NAMESERVERS}
  disablePortSecurity: false
  useOctavia: true
  bastion:
    enabled: true
    flavor: m1.medium
    image: ubuntu-18.04-capi
    sshKeyName: ssup2
---
apiVersion: controlplane.cluster.x-k8s.io/v1alpha3
kind: KubeadmControlPlane
metadata:
  name: "${CLUSTER_NAME}-control-plane"
spec:
  replicas: ${CONTROL_PLANE_MACHINE_COUNT}
  infrastructureTemplate:
    kind: OpenStackMachineTemplate
    apiVersion: infrastructure.cluster.x-k8s.io/v1alpha3
    name: "${CLUSTER_NAME}-control-plane"
  kubeadmConfigSpec:
    initConfiguration:
      nodeRegistration:
        name: '{{ local_hostname }}'
        kubeletExtraArgs:
          cloud-provider: external
    clusterConfiguration:
      imageRepository: k8s.gcr.io
      apiServer:
        extraArgs:
          cloud-provider: external
      controllerManager:
        extraArgs:
          cloud-provider: external
    joinConfiguration:
      nodeRegistration:
        name: '{{ local_hostname }}'
        kubeletExtraArgs:
          cloud-provider: external
  version: "${KUBERNETES_VERSION}"
---
apiVersion: infrastructure.cluster.x-k8s.io/v1alpha3
kind: OpenStackMachineTemplate
metadata:
  name: ${CLUSTER_NAME}-control-plane
spec:
  template:
    spec:
      flavor: ${OPENSTACK_CONTROL_PLANE_MACHINE_FLAVOR}
      image: ${OPENSTACK_IMAGE_NAME}
      sshKeyName: ${OPENSTACK_SSH_KEY_NAME}
      cloudName: ${OPENSTACK_CLOUD}
      cloudsSecret:
        name: ${CLUSTER_NAME}-cloud-config
        namespace: ${NAMESPACE}
---
apiVersion: cluster.x-k8s.io/v1alpha3
kind: MachineDeployment
metadata:
  name: "${CLUSTER_NAME}-md-0"
spec:
  clusterName: "${CLUSTER_NAME}"
  replicas: ${WORKER_MACHINE_COUNT}
  selector:
    matchLabels:
  template:
    spec:
      clusterName: "${CLUSTER_NAME}"
      version: "${KUBERNETES_VERSION}"
      failureDomain: ${OPENSTACK_FAILURE_DOMAIN}
      bootstrap:
        configRef:
          name: "${CLUSTER_NAME}-md-0"
          apiVersion: bootstrap.cluster.x-k8s.io/v1alpha3
          kind: KubeadmConfigTemplate
      infrastructureRef:
        name: "${CLUSTER_NAME}-md-0"
        apiVersion: infrastructure.cluster.x-k8s.io/v1alpha3
        kind: OpenStackMachineTemplate
---
apiVersion: infrastructure.cluster.x-k8s.io/v1alpha3
kind: OpenStackMachineTemplate
metadata:
  name: ${CLUSTER_NAME}-md-0
spec:
  template:
    spec:
      cloudName: ${OPENSTACK_CLOUD}
      cloudsSecret:
        name: ${CLUSTER_NAME}-cloud-config
        namespace: ${NAMESPACE}
      flavor: ${OPENSTACK_NODE_MACHINE_FLAVOR}
      image: ${OPENSTACK_IMAGE_NAME}
      sshKeyName: ${OPENSTACK_SSH_KEY_NAME}
---
apiVersion: bootstrap.cluster.x-k8s.io/v1alpha3
kind: KubeadmConfigTemplate
metadata:
  name: ${CLUSTER_NAME}-md-0
spec:
  template:
    spec:
      joinConfiguration:
        nodeRegistration:
          name: '{{ local_hostname }}'
          kubeletExtraArgs:
            cloud-provider: external
---
apiVersion: v1
kind: Secret
metadata:
  name: ${CLUSTER_NAME}-cloud-config
  labels:
    clusterctl.cluster.x-k8s.io/move: "true"
data:
  clouds.yaml: ${OPENSTACK_CLOUD_YAML_B64}
  cacert: ${OPENSTACK_CLOUD_CACERT_B64}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] template.yaml</figcaption>
</figure>

Cluster Manifest Template 역활을 수행하는 [파일 3]의 내용을 갖고 있는 template.yaml 파일을 생성한다. https://raw.githubusercontent.com/kubernetes-sigs/cluster-api-provider-openstack/v0.3.3/templates/cluster-template-external-cloud-provider.yaml 파일에서 "disableServerTags: true" 제거, cidrBlocks을 "192.167.0.0/16"으로 변경, Bastion VM 설정을 추가하였다.

ClusterAPI는 기본적으로 생성한 Kubernetes Cluster의 Node에 SSH 접근이 불가능 하도록 Security Group을 설정한다. Bastion VM은 ClusterAPI를 통해 생성한 Kubernetes Cluster의 Node에 SSH로 접근할 수 있게 만드는 통로 역활을 수행한다.

~~~console
(Local)# wget https://raw.githubusercontent.com/kubernetes-sigs/cluster-api-provider-openstack/master/templates/env.rc -O env.rc
~~~

clusterctl에서 이용할 환경변수를 설정하는 env.rc Script 파일을 받는다.

~~~console
(Local)# source env.rc clouds.yaml openstack
(Local)# export OPENSTACK_CONTROLPLANE_IP=10.0.0.20 \
export OPENSTACK_SSH_KEY_NAME=ssup2 \
export OPENSTACK_IMAGE_NAME=ubuntu-18.04-capi \
export OPENSTACK_FAILURE_DOMAIN=nova \
export OPENSTACK_DNS_NAMESERVERS=8.8.8.8 \
export OPENSTACK_CONTROL_PLANE_MACHINE_FLAVOR=m1.medium \
export OPENSTACK_NODE_MACHINE_FLAVOR=m1.medium
~~~

clusterctl에서 이용할 환경변수를 설정한다. VM Image, VM Flavor, DNS 등을 환경변수로 설정한다. 

~~~console
(Local)# clusterctl config cluster ssup2 --from template.yaml --kubernetes-version v1.17.11 --control-plane-machine-count=3 --worker-machine-count=1 > ssup2_cluster.yaml
(Local)# kubectl apply -f ssup2_cluster.yaml
~~~

Cluster Manifest 파일을 생성하고, 생성한 Cluster Manifest 파일을 이용하여 Kubernetes Cluster를 생성한다.

### 9. Cilium CNI & OpenStack External Cloud Provider 설치

Kubernetes Cluster를 생성하면 Control Plain (Master Node) VM이 하나만 생성되고, 더 이상 Control Plain이 생성되지 않는다. Control Plain Node VM의 Node Object의 "spec.providerID" 값이 설정 되어있지 않기 때문이다. "spec.providerID" 값은 OpenStack External Cloud Provider가 설치되어야 설정된다.

~~~console
(Local)# clusterctl get kubeconfig ssup2 > /root/.kube/ssup2.kubeconfig
~~~

clusterctl 파일을 이용하여 생성한 Kubernetes Cluster의 kubeconfig 파일을 생성한다.

~~~
(Local)# kubectl --kubeconfig='/root/.kube/ssup2.kubeconfig' create -f https://raw.githubusercontent.com/cilium/cilium/1.7.11/install/kubernetes/quick-install.yaml
~~~

OpenStack External Cloud Provider 설치전에 Cilium CNI Plugin을 설치하여, OpenStack External Cloud Provider가 설치 될수 있도록 만든다.

{% highlight text %}
[Global]
auth-url="http://192.168.0.40:5000/v3"
application-credential-id="96e2f01837884a59b5d70fa8a6960c9a"
application-credential-secret="nKhWeYW0zEbkIqO4V8ubVXoHQDsfc8U8Z-eJ-up2JtvyxHWujeCB47XKJcvmaLcQjX0Qxg7CffgqwM0pdyeaww"

[BlockStorage]
bs-version=v3

[LoadBalancer]
use-octavia=True
subnet-id=67ca5cfd-0c3f-434d-a16c-c709d1ab37fb
floating-network-id=00a8e738-c81e-45f6-9788-3e58186076b6
lb-method=ROUND_ROBIN
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 4] cloud.conf</figcaption>
</figure>

OpenStack External Cloud Controller Manager에서 이용할 [파일 4]의 내용을 갖고 있는 cloud.conf 파일을 생성한다.

~~~console
(Local)# kubectl --kubeconfig='/root/.kube/ssup2.kubeconfig' create secret -n kube-system generic cloud-config --from-file=cloud.conf
(Local)# kubectl --kubeconfig='/root/.kube/ssup2.kubeconfig' apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/v1.17.0/cluster/addons/rbac/cloud-controller-manager-roles.yaml
(Local)# kubectl --kubeconfig='/root/.kube/ssup2.kubeconfig' apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/v1.17.0/cluster/addons/rbac/cloud-controller-manager-role-bindings.yaml
(Local)# kubectl --kubeconfig='/root/.kube/ssup2.kubeconfig' apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/v1.17.0/manifests/controller-manager/openstack-cloud-controller-manager-ds.yaml
~~~

cloud-config Secret을 생성하고, OpenStack External Cloud Provider를 배포한다.

~~~console
~~~

OpenStack External Cloud Provider를 배포된 이후에 나머지 Control Plain (Master Node) VM이 생성되는걸 확인할 수 있다.

### 10. Kubernetes Cluster 동작 확인

~~~
(Local)# kubectl get cluster
NAME    PHASE
ssup2   Provisioned

(Local)# kubectl get kubeadmcontrolplane
NAME                  INITIALIZED   API SERVER AVAILABLE   VERSION    REPLICAS   READY   UPDATED   UNAVAILABLE
ssup2-control-plane   true          true                   v1.17.11   3          3       3

(Local)# kubectl get machine
NAME                          PROVIDERID                                         PHASE     VERSION
ssup2-control-plane-88c9w     openstack://2dcc2ba4-2968-4e5a-8c85-11c61054b015   Running   v1.17.11
ssup2-control-plane-m6hkz     openstack://79608e3b-d863-46ae-84a2-7855175b4450   Running   v1.17.11
ssup2-control-plane-smlkx     openstack://f3214c23-a011-4353-bf9f-6a440097dd5e   Running   v1.17.11
ssup2-md-0-7b7b86d6f7-whvwh   openstack://2facf68d-95e5-4d1a-882f-43b3bcafc2ba   Running   v1.17.11

(Local)# kubectl get openstackmachine
NAME                        CLUSTER   INSTANCESTATE   READY   PROVIDERID                                         MACHINE
ssup2-control-plane-b74l9   ssup2     ACTIVE          true    openstack://f3214c23-a011-4353-bf9f-6a440097dd5e   ssup2-control-plane-smlkx
ssup2-control-plane-l28lt   ssup2     ACTIVE          true    openstack://2dcc2ba4-2968-4e5a-8c85-11c61054b015   ssup2-control-plane-88c9w
ssup2-control-plane-pcrxg   ssup2     ACTIVE          true    openstack://79608e3b-d863-46ae-84a2-7855175b4450   ssup2-control-plane-m6hkz
ssup2-md-0-t5jtt            ssup2     ACTIVE          true    openstack://2facf68d-95e5-4d1a-882f-43b3bcafc2ba   ssup2-md-0-7b7b86d6f7-whvwh

(Local)# kubectl --kubeconfig='/root/.kube/ssup2.kubeconfig' get nodes
NAME                        STATUS   ROLES    AGE     VERSION
ssup2-control-plane-b74l9   Ready    master   94m     v1.17.11
ssup2-control-plane-l28lt   Ready    master   8m28s   v1.17.11
ssup2-control-plane-pcrxg   Ready    master   70m     v1.17.11
ssup2-md-0-t5jtt            Ready    <none>   89m     v1.17.11
~~~

Kubernetes Cluster 동작을 확인한다.

### 11. Kubernetes Cluster VM Node에 SSH 접근

Bastion VM으로 ssup2 Keypair를 이용해 SSH로 접속한 다음, Bastion VM 내부에서 다시 ssup2 Keypair를 이용하여 Kubernetes Cluster VM Node에 접근해야 한다.

### 12. 참조

* [https://kind.sigs.k8s.io/](https://kind.sigs.k8s.io/)
* [https://cluster-api.sigs.k8s.io/](https://cluster-api.sigs.k8s.io/)
* [https://cluster-api.sigs.k8s.io/user/quick-start.html](https://cluster-api.sigs.k8s.io/user/quick-start.html)
* [https://image-builder.sigs.k8s.io/capi/providers/openstack.html](https://image-builder.sigs.k8s.io/capi/providers/openstack.html)
* [https://github.com/kubernetes-sigs/cluster-api-provider-openstack](https://github.com/kubernetes-sigs/cluster-api-provider-openstack)
* [https://github.com/kubernetes-sigs/cluster-api-provider-openstack/blob/master/docs/configuration.md](https://github.com/kubernetes-sigs/cluster-api-provider-openstack/blob/master/docs/configuration.md)
* [https://github.com/kubernetes-sigs/cluster-api-provider-openstack/blob/v0.3.3/docs/external-cloud-provider.md](https://github.com/kubernetes-sigs/cluster-api-provider-openstack/blob/v0.3.3/docs/external-cloud-provider.md)