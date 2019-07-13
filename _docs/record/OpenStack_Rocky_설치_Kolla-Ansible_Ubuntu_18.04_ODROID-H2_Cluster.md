---
title: OpenStack Rocky 설치 / Kolla-Ansible 이용 / Ubuntu 18.04, ODROID-H2 Cluster 환경
category: Record
date: 2019-07-06T12:00:00Z
lastmod: 2019-07-06T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

![[그림 1] OpenStack Rocky 설치 환경 (ODROID-H2 Cluster)]({{site.baseurl}}/images/record/OpenStack_Rocky_Install_Kolla-Ansible_Ubuntu_18.04_ODROID-H2_Cluster/Environment.PNG)

[그림 1]은 ODROID-H2 Cluster로 OpenStack 설치 환경을 나타내고 있다. 상세한 환경 정보는 다음과 같다.

* OpenStack : Rocky Version
* Kolla-Ansible : 7.1.1
* Node : Ubuntu 18.04, root user
  * ODROID-H2
    * Node 01 : Controller Node, Network Node
    * Node 02,03 : Compute Node
  * VM
    * Node 9 : Monitoring Node, Registry Node, Deploy Node
* Network
  * NAT Network : External Network (Provider Network), 192.168.0.0/24
      * Floating IP Range : 192.168.0.200 ~ 224
  * Private Network : Guest Network (Tanant Network), Management Network 10.0.0.0/24
* Storage
  * /dev/mmcblk0 : Root Filesystem, 64GB
  * /dev/nvme0n1 : Ceph, 256GB

### 2. OpenStack 구성

OpenStack의 구성요소 중에서 설치할 구성요소는 다음과 같다.

* Nova : VM Service를 제공한다.
* Neutron : Network Service를 제공한다.
* Octavia : Load Balacner Service를 제공한다.
* Keystone : Authentication, Authorization Service를 제공한다.
* Glance : VM Image Service를 제공한다.
* Cinder : VM Block Storage Service를 제공한다.
* Horizon : Web Dashboard Service를 제공한다.
* Ceph : Glance, Cinder의 Backend Storage 역활을 수행한다.

### 3. Package 설치

#### 3.1. Deploy Node

~~~
(Deploy)# apt-get install software-properties-common
(Deploy)# apt-add-repository ppa:ansible/ansible
(Deploy)# apt-get update
(Deploy)# apt-get install libffi-dev gcc libssl-dev python3-dev python3-selinux python3-setuptools python-oslo.config ansible
(Deploy)# apt remove golang-docker-credential-helpers
(Deploy)# pip install kolla-ansible tox pbr requests docker gitpython jinja2 oslo_config
~~~

Deploy Node에 필요한 Ubuntu Package들을 설치한다.

#### 3.2. Registry, Controller, Compute Node

~~~
(Registry, Controller, Compute)# apt-get update
(Registry, Controller, Compute)# apt-get install python3-dev python3-pip docker.io
(Registry, Controller, Compute)# apt remove golang-docker-credential-helpers
(Registry, Controller, Compute)# pip install docker==3.0.0
~~~

Registry, Controller, Compute Node에 필요한 Ubuntu, Python Package를 설치한다.

### 4. Docker 설정

#### 4.1. Registry Node

~~~
(Registry)# mkdir ~/auth
(Registry)# docker run --entrypoint htpasswd registry:2 -Bbn admin admin > ~/auth/htpasswd
(Registry)# docker run -d -p 5000:5000 --restart=always --name registry_private -v ~/auth:/auth -e "REGISTRY_AUTH=htpasswd" -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" registry:2
~~~

Registry Node에 Docker Registry를 구동시킨다. ID/Password는 admin/admin으로 설정한다.

#### 4.2. Network Node

~~~
(Network)# mkdir -p /etc/systemd/system/docker.service.d
(Network)# tee /etc/systemd/system/docker.service.d/kolla.conf <<-'EOF'
[Service]
MountFlags=shared
EOF
(Network)# systemctl daemon-reload
(Network)# systemctl restart docker
~~~

Network Node에서 동작하는 Docker에 shared Mount Flag를 추가하고, Docker를 재시작 한다.

#### 4.3. Registry, Controller, Compute, Network Node

{% highlight text linenos %}
{
  "insecure-registries" : ["10.0.0.19:5000"]
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Controller, Compute, Network Node - /etc/docker/daemon.json</figcaption>
</figure>

~~~
(Controller, Compute, Network)# service docker restart
(Controller, Compute, Network)# docker login 10.0.0.19:5000
~~~

Controller, Compute, Network Node에서 동작한는 Docker Daemon에게 Registry Node에 구동시킨 Docker Registry를 Insecure Registry로 등록한다. Controller, Compute, Network Node의 /etc/docker/daemon.json 파일을 [파일 1]의 내용으로 생성한 다음, Docker를 재시작한다.

### 5. Ansible 설정

Deploy Node에서 다른 Node에게 Password 없이 SSH로 접근할 수 있도록 설정한다.

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

Deploy Node에서 ssh key를 생성한다. passphrase (Password)는 공백을 입력하여 설정하지 않는다. 설정하게 되면 Deploy Node에서 다른 Node로 SSH를 통해서 접근 할때마다 passphrase를 입력해야 한다.

~~~
(Deploy)# ssh-copy-id root@10.0.0.10
(Deploy)# ssh-copy-id root@10.0.0.11
(Deploy)# ssh-copy-id root@10.0.0.12
(Deploy)# ssh-copy-id root@10.0.0.19
~~~

ssh-copy-id 명령어를 이용하여 생성한 ssh Public Key를 나머지 Node의 ~/.ssh/authorized_keys 파일에 복사한다.

{% highlight text linenos %}
...
10.0.0.10 node01
10.0.0.11 node02
10.0.0.12 node03
10.0.0.19 node09
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] Deploy Node - /etc/hosts</figcaption>
</figure>

Deploy Node의 /etc/hosts 파일 내용을 [파일 2]과 같이 수정한다.

{% highlight text linenos %}
...
[defaults]
host_key_checking=False
pipelining=True
forks=100
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] Deploy Node - /etc/ansible/ansible.cfg:</figcaption>
</figure>

Deploy Node의 /etc/ansible/ansible.cfg 파일을 [파일 3]와 같이 수정한다.

### 6. Ceph 설정

~~~
(Ceph)# parted /dev/nvme0n1 -s -- mklabel gpt mkpart KOLLA_CEPH_OSD_BOOTSTRAP 1 -1
~~~

Ceph Node의 /dev/nvme0n1 Block Device에 KOLLA_CEPH_OSD_BOOTSTRAP Label을 붙인다. Kolla-Ansible은 OSD가 KOLLA_CEPH_OSD_BOOTSTRAP이 붙은 Block Device를 이용하도록 설정한다.

### 7. Octavia 설정

~~~
(network)# git clone https://review.openstack.org/p/openstack/octavia
(network)# cd octavia
(network)# sed -i 's/foobar/admin/g' bin/create_certificates.sh
(network)# ./bin/create_certificates.sh cert $(pwd)/etc/certificates/openssl.cnf
(network)# mkdir -p /etc/kolla/config/octavia
(network)# cp cert/private/cakey.pem /etc/kolla/config/octavia/
(network)# cp cert/ca_01.pem /etc/kolla/config/octavia/
(network)# cp cert/client.pem /etc/kolla/config/octavia/
~~~

Network Node에 Octavia에서 이용하는 인증서를 생성한다.

### 8. Kolla Container Image 생성 및 Push

~~~
(Deploy)# git clone -b stable/rocky --single-branch https://github.com/openstack/kolla.git
(Deploy)# cd kolla
(Deploy)# tox -e genconfig
(Deploy)# docker login 10.0.0.19:5000
(Deploy)# mkdir -p logs
(Deploy)# python3 tools/build.py -b ubuntu --tag rocky --skip-parents --skip-existing --type source --registry 10.0.0.19:5000 --push --logs-dir logs
~~~

Deploy Node에서 Kolla Container Image를 생성하고 Registry에 Push한다. Image는 Ubuntu Image를 Base로하여 생성한다.

### 9. Kolla-Ansible을 이용하여 OpenStack 설치

~~~
(Deploy)# cp /usr/local/share/kolla-ansible/ansible/inventory/* ~/kolla-ansible/
(Deploy)# cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
~~~

Config 파일인 **global.yaml** 파일과 Password 정보가 포함되어 있는 passwords.yml 파일을 복사한다.

{% highlight text linenos %}
# These initial groups are the only groups required to be modified. The
# additional groups are for more control of the environment.
[control]
# These hostname must be resolvable from your deployment host
node01

# The above can also be specified as follows:
#control[01:03]     ansible_user=kolla

# The network nodes are where your l3-agent and loadbalancers will run
# This can be the same as a host in the control group
[network]
node01

# inner-compute is the groups of compute nodes which do not have
# external reachability.
# DEPRECATED, the group will be removed in S release of OpenStack,
# use variable neutron_compute_dvr_mode instead.
[inner-compute]

# external-compute is the groups of compute nodes which can reach
# outside.
# DEPRECATED, the group will be removed in S release of OpenStack,
# use variable neutron_compute_dvr_mode instead.
[external-compute]
node02
node03

[compute:children]
inner-compute
external-compute

[monitoring]
node09 neutron_external_interface=eth0 api_interface=eth1

# When compute nodes and control nodes use different interfaces,
# you need to comment out "api_interface" and other interfaces from the globals.yml
# and specify like below:
#compute01 neutron_external_interface=eth0 api_interface=em1 storage_interface=em1 tunnel_interface=em1

[storage]
node01
node02
node03

[storage:vars]
ansible_python_interpreter=/usr/bin/python3

[deployment]
node09                                     

[deployment:vars]
ansible_python_interpreter=/usr/bin/python3

[baremetal:children]

# You can explicitly specify which hosts run each project by updating the
# groups in the sections below. Common services are grouped together.
[chrony-server:children]
haproxy
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 4] Deploy Node - ~/kolla-ansible/multinode</figcaption>
</figure>

Ansible Inventory를 설정한다. Deploy Node에 ~/kolla-ansible/multinode 파일을 [파일 4]의 내용으로 변경한다. ~/kolla-ansible/multinode 파일의 윗부분에 있는 [control], [network], [external-compute], [monitoring], [storage], [deployment], [baremetal] 부분만 ODROID-H2 Cluster 환경에 맞게 번경하였고 나머지 파일의 아랫부분은 기본 설정값을 그대로 유지한다.

#### 9.2. Kolla-Ansible Password 설정

{% highlight yaml linenos %}
# Database
database_password: admin

# OpenStack
keystone_admin_password: admin
keystone_database_password: admin

glance_database_password: admin
glance_keystone_password: admin

nova_database_password: admin
nova_api_database_password: admin
nova_keystone_password: admin

neutron_database_password: admin
neutron_keystone_password: admin
metadata_secret: admin

cinder_database_password: admin
cinder_keystone_password: admin

octavia_database_password: admin
octavia_keystone_password: admin
octavia_ca_password: admin

memcache_secret_key: admin

# RabbitMQ
rabbitmq_password: admin
rabbitmq_monitoring_password: admin
rabbitmq_cluster_cookie: admin
outward_rabbitmq_password: admin
outward_rabbitmq_cluster_cookie: admin

# Redis
redis_master_password: admin

# OpenDaylight
opendaylight_password: admin

# Ceph
ceph_cluster_fsid: b5168ed4-a98f-4ff0-a39f-51f59a3d64d0
ceph_rgw_keystone_password: 3c4f1800-a518-4efc-b98d-339665bfa810
rbd_secret_uuid: 867a11a1-aa92-40d0-8910-32df2281193e
cinder_rbd_secret_uuid: cf2898a9-2fda-4ad3-94f7-f61fe06eb829
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 5] Deploy Node - /etc/kolla/passwords.yml</figcaption>
</figure>

OpenStack에서 이용하는 Password 정보를 입력한다. Deploy Node의 /etc/kolla/passwords.yml 파일을 [파일 5]의 내용처럼 수정한다. 대부분의 password는 **admin**으로 설정한다.

{% highlight yaml linenos %}
# Kolla
openstack_release: "rocky"

# Neutron
network_interface: "enp3s0
neutron_external_interface : "enp2s0"
neutron_plugin_agent: "opendaylight"
neutron_ipam_driver: "internal"

# Nova
nova_console: "novnc"

# OpenDayligth
enable_opendaylight_l3: "yes"

# OpenStack
enable_glance: "yes"
enable_haproxy: "no"
enable_keystone: "yes"
enable_mariadb: "yes"
enable_memcached: "yes"
enable_neutron: "yes"
enable_nova: "yes"

enable_ceph: "yes"
enable_ceph_mds: "no"
enable_ceph_rgw: "no"
enable_ceph_nfs: "no"
enable_ceph_dashboard: "yes"
enable_chrony: "yes"
enable_cinder: "yes"
enable_fluentd: "no"
enable_horizon: "yes"
enable_nova_fake: "no"
enable_nova_ssh: "yes"
enable_octavia: "yes"
enable_opendaylight: "yes"
enable_openvswitch: "yes"
enable_prometheus: "yes"

# Glance
glance_backend_ceph: "yes"

# Ceph
ceph_enable_cache: "no"

# Prometheus
enable_prometheus_node_exporter: "yes"
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 6] Deploy Node - /etc/kolla/globals.yaml</figcaption>
</figure>

Kolla-Ansible을 설정한다. Deploy Node의 /etc/kolla/globals.yaml 파일을 [파일 6]의 내용처럼 수정한다.

~~~
(Deploy)# kolla-ansible -i ~/kolla-ansible/multinode bootstrap-servers
(Deploy)# kolla-ansible -i ~/kolla-ansible/multinode prechecks
(Deploy)# kolla-ansible -i ~/kolla-ansible/multinode deploy
~~~

Kolla Ansible을 이용하여 Openstack을 설치한다.

### 10. 참조

* [https://docs.openstack.org/kolla-ansible/rocky/](https://docs.openstack.org/kolla-ansible/rocky)
* [https://shreddedbacon.com/post/openstack-kolla/](https://shreddedbacon.com/post/openstack-kolla/)