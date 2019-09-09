---
title: Kubernetes 설치 / kubespray 이용 / Ubuntu 18.04, OpenStack 환경
category: Record
date: 2019-07-20T12:00:00Z
lastmod: 2019-07-20T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

![[그림 1] Kubernetes 설치 환경]({{site.baseurl}}/images/record/Kubernetes_Install_kubespray_Ubuntu_18.04_OpenStack/Environment.PNG)

[그림 1]은 Kubernetes 설치 환경을 나타내고 있다. 설치 환경은 다음과 같다.
* VM : Ubuntu 18.04, 4 vCPU, 4GB Memory
  * ETCD Node * 3
  * Master Node * 2
  * Slave Node * 3
  * Deploy Node * 1
* Network
  * NAT Network : 192.168.0.0/24
  * Octavia Network : 20.0.0.0/24
  * Tenant Network : 30.0.0.0/24
* OpenStack : Stein
  * API Server : 192.168.0.40:5000
  * Octavia
* Kubernetes
  * CNI : Cilium Plugin
* kubespray : 2.10.4

### 2. Ubuntu Package 설치

~~~
(All)# apt-get update
(All)# apt-get install python-pip python3-pip
~~~

모든 Node에 Python과 Pip를 설치한다.

### 3. Ansible 설정

~~~
(Deploy)# ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:Sp0SUDPNKxTIYVObstB0QQPoG/csF9qe/v5+S5e8hf4 root@kube02
The key's randomart image is:
+---[RSA 2048]----+
|   oBB@=         |
|  .+o+.*o        |
| .. o.+  .       |
|  o..ooo..       |
|   +.=ooS        |
|  . o.=o     . o |
|     +..    . = .|
|      o    ..o o |
|     ..oooo...o.E|
+----[SHA256]-----+
~~~

Deploy Node에서 ssh key를 생성한다. passphrase (Password)는 공백을 입력하여 설정하지 않는다. 설정하게 되면 Deploy Node에서 Managed Node로 SSH를 통해서 접근 할때마다 passphrase를 입력해야 한다.

~~~
(Deploy)# ssh-copy-id root@30.0.0.11
(Deploy)# ssh-copy-id root@30.0.0.12
(Deploy)# ssh-copy-id root@30.0.0.13
~~~

Deploy Node에서 ssh-copy-id 명령어를 이용하여 생성한 ssh Public Key를 나머지 Node의 ~/.ssh/authorized_keys 파일에 복사한다.

### 4. kubespray 설정, 구동

~~~
(Deploy)# ~
(Deploy)# git clone -b v2.10.4 https://github.com/kubernetes-sigs/kubespray.git
(Deploy)# cd kubespray
(Deploy)# pip3 install -r requirements.txt
(Deploy)# cp -rfp inventory/sample inventory/mycluster
~~~

kubespray를 설치하고 Sample Inventory를 복사한다.

{% highlight text %}
[all]
vm01 ansible_host=30.0.0.11 ip=30.0.0.11 etcd_member_name=etcd1
vm02 ansible_host=30.0.0.12 ip=30.0.0.12 etcd_member_name=etcd2
vm03 ansible_host=30.0.0.13 ip=30.0.0.13 etcd_member_name=etcd3

[kube-master]
vm01
vm02

[etcd]
vm01
vm02
vm03

[kube-node]
vm01
vm02
vm03

[k8s-cluster:children]
kube-master
kube-node   
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Deploy Node - ~/kubespray/inventory/mycluster/inventory.ini</figcaption>
</figure>

Deploy Node의 inventory/mycluster/inventory.ini 파일에 각 VM의 정보 및 역활을 저장한다.

{% highlight text %}
...
## There are some changes specific to the cloud providers
## for instance we need to encapsulate packets with some network plugins
## If set the possible values are either 'gce', 'aws', 'azure', 'openstack', 'vsphere', 'oci', or 'external'
## When openstack is used make sure to source in the openstack credentials
## like you would do when using openstack-client before starting the playbook.
## Note: The 'external' cloud provider is not supported.
## TODO(riverzhang): https://kubernetes.io/docs/tasks/administer-cluster/running-cloud-controller/#running-cloud-controller-manager
cloud_provider: openstack
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] Deploy Node - ~/kubespray/inventory/mycluster/group_vars/all/all.yml</figcaption>
</figure>

Deploy Node의 inventory/mycluster/group_vars/all/all.yml 파일에 Cloud Provider를 OpenStack으로 설정한다.

{% highlight text %}
# # When OpenStack is used, if LBaaSv2 is available you can enable it with the following 2 variables.
openstack_lbaas_enabled: True
openstack_lbaas_subnet_id: [Tenant Network Subnet ID]
# To enable automatic floating ip provisioning, specify a subnet.
openstack_lbaas_floating_network_id: [NAT (External) Network ID]
# # Override default LBaaS behavior
openstack_lbaas_use_octavia: True
openstack_lbaas_method: "ROUND_ROBIN"
#openstack_lbaas_provider: "haproxy"
openstack_lbaas_create_monitor: "yes"
openstack_lbaas_monitor_delay: "1m"
openstack_lbaas_monitor_timeout: "30s"
openstack_lbaas_monitor_max_retries: "3"     
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] Deploy Node - ~/kubespray/inventory/mycluster/group_vars/all/openstack.yml</figcaption>
</figure>

Deploy Node의 inventory/mycluster/group_vars/all/openstack.yml 파일에 Kubernetes LoadBalancer Service를 위하여 Octavia Load Balancer를 설정한다. External Network의 ID와 External Network의 Subnet ID를 확인하여 설정한다.

{% highlight text %}
...
kube_network_plugin: cilium
...
persistent_volumes_enabled: true
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 4] Deploy Node - ~/kubespray/inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml</figcaption>
</figure>

Deploy Node의 inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml 파일에 CNI Plugin으로 cilium을 이용하도록 설정하고, Persistent Volume을 Enable 설정하여 Kubernetes가 OpenStack의 Cinder를 이용하도록 설정한다.

{% highlight text %}
...
## General
# Set the hostname to inventory_hostname
override_system_hostname: false
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 5] Deploy Node - ~/kubespray/roles/bootstrap-os/defaults/main.yml</figcaption>
</figure>

Deploy Node의 roles/bootstrap-os/defaults/main.yml 파일에 Kubernetes가 설치되는 Hostname을 Override하지 않도록 설정한다.

{% highlight text %}
export OS_AUTH_URL=http://192.168.0.40:5000/v3
export OS_PROJECT_ID=[Project ID]
export OS_PROJECT_NAME="admin"
export OS_USER_DOMAIN_NAME="Default"
export OS_USERNAME="admin"
export OS_PASSWORD="admin"
export OS_REGION_NAME="RegionOne"
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 6] Deploy Node - ~/kubespray/openstack-rc</figcaption>
</figure>

OpenStack RC 파일의 정보를 바탕으로 openstack-rc 파일을 생성한다.

~~~
(Deploy)# source ~/kubespray/openstack-rc
(Deploy)# ansible-playbook -i ~/kubespray/inventory/mycluster/inventory.ini --become --become-user=root cluster.yml
~~~

Deploy Node에서 Kubernets Cluster를 구성한다.

### 5. Kubernetes Cluster 초기화

~~~
(Deploy)# source openstack-rc
(Deploy)# ansible-playbook -i ~/kubespray/inventory/mycluster/inventory.ini --become --become-user=root reset.yml
~~~

Deploy Node에서 Kubernetes Cluster를 초기화한다.

### 6. 참고

* [https://kubespray.io/#/](https://kubespray.io/#/)
* [https://github.com/kubernetes-sigs/kubespray/blob/master/docs/openstack.md](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/openstack.md)