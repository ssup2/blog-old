---
title: OpenStack Stein 설치 / Kolla-Ansible 이용 / Ubuntu 18.04, ODROID-H2 Cluster 환경
category: Record
date: 2019-07-14T12:00:00Z
lastmod: 2019-07-14T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

![[그림 1] OpenStack Stein 설치 환경 (ODROID-H2 Cluster)]({{site.baseurl}}/images/record/OpenStack_Stein_Install_Kolla-Ansible_Ubuntu_18.04_ODROID-H2_Cluster/Environment.PNG)

[그림 1]은 ODROID-H2 Cluster로 OpenStack 설치 환경을 나타내고 있다. 상세한 환경 정보는 다음과 같다.

* OpenStack : Stein
* Kolla : 8.0.0
* Kolla-Ansible : 8.0.0
* Octiava : 4.0.1
* Node : Ubuntu 18.04, root user
  * ODROID-H2
    * Node 01 : Controller Node, Network Node, Ceph Node (MON, MGR, OSD)
    * Node 02, 03 : Compute Node, Ceph Node (OSD)
  * VM
    * Node 09 : Monitoring Node, Registry Node, Deploy Node
* Network
  * NAT Network : External Network (Provider Network), 192.168.0.0/24
    * Floating IP Range : 192.168.0.200 ~ 224
  * Private Network : Guest Network (Tanant Network), Management Network, 10.0.0.0/24
    * Node Default Gateway
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
* Prometheus : Metric 정보를 저장한다.
* Grafana : Prometheus에 저장된 Metric 정보를 다양한 Graph로 시각화한다.
* Ceph : Glance, Cinder의 Backend Storage 역활을 수행한다.

### 3. Network 설정

#### 3.1. Node01 Node

{% highlight yaml linenos %}
network:
    ethernets:
        enx88366cf9f9ed:
            addresses:
            - 0.0.0.0/8
        enp2s0:
            addresses:
            - 192.168.0.31/24
            gateway4: 192.168.0.1
            nameservers:
                addresses:
                - 8.8.8.8
        enp3s0:
            addresses:
            - 10.0.0.11/24
    version: 2
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Node01 - /etc/netplan/50-cloud-init.yaml</figcaption>
</figure>

Node01 Interface의 IP를 설정한다.

#### 3.2. Node02 Node

{% highlight yaml linenos %}
network:
    ethernets:
        enp2s0:
            addresses:
            - 192.168.0.32/24
            gateway4: 192.168.0.1
            nameservers:
                addresses:
                - 8.8.8.8
        enp3s0:
            addresses:
            - 10.0.0.12/24
    version: 2
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] Node02 - /etc/netplan/50-cloud-init.yaml</figcaption>
</figure>

Node02 Interface의 IP를 설정한다.

#### 3.3. Node03 Node

{% highlight yaml linenos %}
network:
    ethernets:
        enp2s0:
            addresses:
            - 192.168.0.33/24
            gateway4: 192.168.0.1
            nameservers:
                addresses:
                - 8.8.8.8
        enp3s0:
            addresses:
            - 10.0.0.13/24
    version: 2
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] Node03 - /etc/netplan/50-cloud-init.yaml</figcaption>
</figure>

Node03 Interface의 IP를 설정한다.

#### 3.4. Node09 Node

{% highlight yaml linenos %}
network:
    ethernets:
        eth0:
            addresses:
            - 192.168.0.39/24
            gateway4: 192.168.0.1
            nameservers:
                addresses:
                - 8.8.8.8
        eth1:
            addresses:
            - 10.0.0.19/24
    version: 2
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 4] Node09 - /etc/netplan/50-cloud-init.yaml</figcaption>
</figure>

Node04 Interface의 IP를 설정한다.

### 4. Package 설치

#### 4.1. Deploy Node

~~~console
(Deploy)# apt-get install software-properties-common
(Deploy)# apt-add-repository ppa:ansible/ansible
(Deploy)# apt-get update
(Deploy)# apt-get install ansible python-pip python3-pip libguestfs-tools
(Deploy)# pip install kolla==8.0.0 kolla-ansible==8.0.0 tox gitpython pbr requests jinja2 oslo_config
(Deploy)# pip install python-openstackclient python-glanceclient python-neutronclient
~~~

Deploy Node에 Ansible과 Kolla-ansible 및 Kolla Container Image Build를 위한 Ubuntu, Python Package를 설치한다. 또한 OpenSTack CLI Client도 설치한다.

#### 4.2. Registry Node

~~~console
(Registry)# apt-get install docker-ce
~~~

Registry Node에 Registry Node 구동을 위한 Docker를 설치한다.


#### 4.3. Network, Compute Node

~~~console
(Network, Compute)# apt-get remove --purge openvswitch-switch
~~~

Open vSwitch Package가 설치되어 있다면 해당 Package를 지워서 Host에서 동작하는 Open vSwitch를 제거해야 한다. Open vSwitch 관련 Daemon은 오직 Container에서 동작해야 한다. Host와 Container에서 동시에 Open vSwitch 관련 Daemon을 구동하면 제대로 동작하지 않는다.

#### 4.4. All Node

~~~console
(All Node)# apt-get install ifupdown
(All Node)# apt-get remove --purge netplan.io
~~~

ifupdown을 설치하고 netplan을 삭제한다.

### 5. Ansible 설정

Deploy Node에서 다른 Node에게 Password 없이 SSH로 접근할 수 있도록 설정한다.

~~~console
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

~~~console
(Deploy)# ssh-copy-id root@10.0.0.11
(Deploy)# ssh-copy-id root@10.0.0.12
(Deploy)# ssh-copy-id root@10.0.0.13
(Deploy)# ssh-copy-id root@10.0.0.19
~~~

ssh-copy-id 명령어를 이용하여 생성한 ssh Public Key를 나머지 Node의 ~/.ssh/authorized_keys 파일에 복사한다.

{% highlight text linenos %}
...
10.0.0.11 node01
10.0.0.12 node02
10.0.0.13 node03
10.0.0.19 node09
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 5] Deploy Node - /etc/hosts</figcaption>
</figure>

Deploy Node의 /etc/hosts 파일 내용을 [파일 5]과 같이 수정한다.

{% highlight text linenos %}
...
[defaults]
host_key_checking=False
pipelining=True
forks=100
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 6] Deploy Node - /etc/ansible/ansible.cfg:</figcaption>
</figure>

Deploy Node의 /etc/ansible/ansible.cfg 파일을 [파일 6]와 같이 수정한다.

### 6. Kolla-Ansible 설정

~~~console
(Deploy)# mkdir -p ~/kolla-ansible
(Deploy)# cp /usr/local/share/kolla-ansible/ansible/inventory/* ~/kolla-ansible/
(Deploy)# mkdir -p /etc/kolla
(Deploy)# cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
~~~

Inventory 파일들을 복사한다. 또한 Config 파일인 **global.yaml** 파일과 Password 정보가 포함되어 있는 **passwords.yml** 파일을 복사한다.

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

[compute]
node02
node03

[monitoring]
node09 api_interface=eth1

# When compute nodes and control nodes use different interfaces,
# you need to comment out "api_interface" and other interfaces from the globals.yml
# and specify like below:
#compute01 neutron_external_interface=eth0 api_interface=em1 storage_interface=em1 tunnel_interface=em1

[storage]
node01
node02
node03

[deployment]
node09

[baremetal:children]
control
network
compute
storage
monitoring

# You can explicitly specify which hosts run each project by updating the
# groups in the sections below. Common services are grouped together.
[chrony-server:children]
haproxy
...
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 7] Deploy Node - ~/kolla-ansible/multinode</figcaption>
</figure>

Ansible Inventory를 설정한다. Deploy Node에 ~/kolla-ansible/multinode 파일을 [파일 7]의 내용으로 변경한다. ~/kolla-ansible/multinode 파일의 윗부분에 있는 [control], [network], [external-compute], [monitoring], [storage], [deployment] 부분만 ODROID-H2 Cluster 환경에 맞게 번경하였고 나머지 파일의 아랫부분은 기본 설정값을 그대로 유지한다.

{% highlight yaml linenos %}
# Database
database_password: admin

# Registry
docker_registry_password: admin

# OpenStack
keystone_admin_password: admin
keystone_database_password: admin

glance_database_password: admin
glance_keystone_password: admin

nova_database_password: admin
nova_api_database_password: admin
nova_keystone_password: admin

placement_keystone_password: admin
placement_database_password: admin

neutron_database_password: admin
neutron_keystone_password: admin
metadata_secret: admin

cinder_database_password: admin
cinder_keystone_password: admin

octavia_database_password: admin
octavia_keystone_password: admin
octavia_ca_password: admin

horizon_secret_key: admin
horizon_database_password: admin

memcache_secret_key: admin

nova_ssh_key:
  private_key: |
    -----BEGIN PRIVATE KEY-----
    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
    IF1ExGI4cbSuAWSAN5kYhY6yiOf4uA==
    -----END PRIVATE KEY-----
  public_key: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZqI3UF+5q/SalhTdUz3I/G7/Yg58oeL1FLOciC7j8Gpf/3P0q3g+0k7Ftj0KVtD+QTwrDj+agIyu+MTnqNt+9qHS5F8ib3MXkK27QArwT94HDWwPLKX9+CCtUYjyJh96AH0gvwEjBATo0g05xeBmeZ2/5IfVPwSDL/hGOBJtea/2prUf13PN8JjKP4qlzbJJX9fRuv2xT8vUdcAvLXpbqzMaHB71N4LmDkNMjh3k4m4Rs04TQx9q0OcsJczcSgCT6qwO4Y+k+5xBavpb5lGv9KaM7klTaK8DojrXBuJa7YloAOo5EDEq32Xa0mc2eb8HqlPf4Z8E8IQZARUtnVN7WzUraSqBsjQm1PpC5WMd39yzcYs2whNQCIpSNx0v+z+2n3/s8rR5jXe3SpCCPnXi7FnjF6aXHmA5RLYxzP6ihs5rg0lm66vEVRIoHGPknEvwAmnBEB1wms9Hx/V540Vl2fVb5TGWFq/6dUjxYiA/Px0Yk5cqui18UKqZrSV5VhjqAuEUzcVIRyVnRlM4X23MshiSVVfBZuiJnyK2PvOTzlonBkOv4z1WxLNnJvjohnRuKIOL+M8twp0ZGpbRHfGfGz6ZE/iYTjOzqCEi8gXi0EooolzGb3abpQLBnkYSrx9KLhFDwYNgyQX3vTryAGPUTOa0Un5OU7DU584/RoHoPOw==

keystone_ssh_key:
  private_key: |
    -----BEGIN PRIVATE KEY-----
    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
    rSP+fx+AovIkyL3UybeH0FRf+p59NYI=
    -----END PRIVATE KEY-----
  public_key: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC65KILqRN8m7hHTThOhmnRsp7Cj9WmF1TrPXlbtEQodIy6EFcxwKWdgSCCGqF0VSN/yfq382WO1/lviNd98gB2NmGusZ1CcI9BMgAb07TXqyHphvglHvTZ3Ls7pU6pgxRc9tPOsAVsVbNJvGlSfu/WUsxvimMunR8STuSgxRZpPlOT41jHe6tXC1TbRbtlAIECs+rl9gMDp6FvbiMy9eoPnb7ukEDDJRrdq+LVoczd+1If4dNhx46EXUH0IM+VR5+GUtsBC01haNRSSaNR39+cXua7CL8vsl9unpbP0Dvf64uDvqU9OAxbFHZO4+rdUoZeqPZY1i4fJMSt+vIeZtnUYNzLT6cNKNJJbtZDbnjwsvLeaM8segF/WSquAdyZoJJHAnA29l57YWSK8H0Y3QVyCXEvUyRSyE43UL2ziEOYBHsn4PAecIaSm6um0fdXgeMdizhO1SJ1yT3drkxyOghYEaFEBBrVDIT78ZbHqcRS+xBPvIUobNHkfriUSVUVDKnK1cqffTh/gSA+LVYn9IktAlBv5ws+knuH4wzL/81xa8axQYEFJ7TbfvZZubK97yxFPLQbK20ogOMjr30K+Znn00DHSlqQxOsTFPWWBkzIcCAeU4MREKb4BbXJlCHBeJucyZg+EsEVC5IJKsKyY80WciByhRgP3XJ9wXTgYJRZ0w==

kolla_ssh_key:
  private_key: |
    -----BEGIN PRIVATE KEY-----
    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
    SGFlm9DOlGgUTBJZnAcFBXFVbBn9BA==
    -----END PRIVATE KEY-----
  public_key: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiG/gEHogaHk1TaRB2R37gsSMMAsO73D9lMpDdgViYOG/QHFhXwsdpdE/TWxW1rilK6OnqPjMah5ASf2cqtPB/jVbTtwccp6WEk1L2mfHBHgo5yVVLLmQQjff/1qZXjjnWRJ134qaUr3Fw9NnuX5fJ3k+dYCuMmWV02ZvAyq2wxG1YepRnG71Cgs5En2uHPTSWkkUc1WM5S3ZMgC/JXChiALzCFFiOeVFXfYz0Jslmm77HNB9fFgBBL71L7hy+PlJx+3O5rtC5Zxi+zcALdcOJtn4eXt2uKii5gaY3DB9q+RMrBjqanASdA808rok4jr9AiYMRW1lWNjO1uZxEZMWhaWgUCpoW8JYoEkJfjQQJRpFXImJBOzxZFGv/IDt8MFw/NOyY1Kuob5BNfbOTpYgkdAJrErcy0aEyteiSWo4k/bvdEk/tPRGZFm3dDVIYeiEl9iowgyl5QcSL1jsNdpfLXpYp9W8oL15q6xb50yOUPGn/Z3CtWqtyYMW6u2TIfpCiO/G3PX1D/82LdvxPha/tZcCN0ewTe95bVclazIMyTTBk4YHNda0WWjlHXPsBnYrgj49/dgOltcaRblSOPp2wlnDarHMuwUu8khCepP9sf6camPhCuPen9jtGOxIR8LI82FcLOU8KkCPQOz2N1+zq8of6APcJMNSdobTYFZQISQ==

# RabbitMQ
rabbitmq_password: admin
rabbitmq_monitoring_password: admin
rabbitmq_cluster_cookie: admin

# HAProxy
haproxy_password: admin
keepalived_password: admin

# Redis
redis_master_password: admin

# Ceph
ceph_cluster_fsid: b5168ed4-a98f-4ff0-a39f-51f59a3d64d0
ceph_rgw_keystone_password: 3c4f1800-a518-4efc-b98d-339665bfa810
rbd_secret_uuid: 867a11a1-aa92-40d0-8910-32df2281193e
cinder_rbd_secret_uuid: cf2898a9-2fda-4ad3-94f7-f61fe06eb829

# Prometheus
prometheus_mysql_exporter_database_password: admin
prometheus_alertmanager_password: admin

# Grafana
grafana_database_password: admin
grafana_admin_password: admin
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 8] Deploy Node - /etc/kolla/passwords.yml</figcaption>
</figure>

OpenStack에서 이용하는 Password 정보를 입력한다. Deploy Node의 /etc/kolla/passwords.yml 파일을 [파일 8]의 내용처럼 수정한다. 대부분의 password는 **admin**으로 설정한다.

{% highlight yaml linenos %}
# Kolla
openstack_release: "stein"

kolla_base_distro: "ubuntu"
kolla_install_type: "source"

kolla_internal_vip_address: "10.0.0.20"
kolla_external_vip_address: "192.168.0.40"

# Docker
docker_registry: "10.0.0.19:5000"
docker_namespace: "kolla"
docker_registry_insecure: "yes"
docker_registry_username: "admin"
docker_registry_password: "admin"

# Neutron
network_interface: "enp3s0"
kolla_external_vip_interface: "enp2s0"
neutron_external_interface : "enx88366cf9f9ed"
neutron_plugin_agent: "openvswitch"
neutron_ipam_driver: "internal"
octavia_network_interface: "enp2s0"

# Nova
nova_console: "novnc"

# OpenStack
enable_glance: "yes"
enable_haproxy: "yes"
enable_keystone: "yes"
enable_mariadb: "yes"
enable_memcached: "yes"

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
enable_heat: "no"
enable_prometheus: "yes"
enable_grafana: "yes"

# Glance
glance_backend_ceph: "yes"

# Ceph
ceph_enable_cache: "no"

# Octavia
#octavia_loadbalancer_topology: "ACTIVE_STANDBY"
#octavia_amp_flavor_id: "100"
#octavia_amp_boot_network_list:
#octavia_amp_secgroup_list:
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 9] Deploy Node - /etc/kolla/globals.yml</figcaption>
</figure>

Kolla-Ansible을 설정한다. Deploy Node의 /etc/kolla/globals.yml 파일을 [파일 9]의 내용처럼 수정한다. Octavia는 OpenStack을 한번이상 구동한 뒤에야 설정할 수 있기 때문에, Octavia 설정은 주석처리 상태로 놔둔다.

~~~console
(Deploy)# kolla-ansible -i ~/kolla-ansible/multinode bootstrap-servers
~~~

Kolla Ansible bootstrap-servers을 각 Node에 필요한 Ubuntu, Python Package를 설치한다.

### 7. Docker 설정

#### 7.1. Registry Node

~~~console
(Registry)# mkdir ~/auth
(Registry)# docker run --entrypoint htpasswd registry:2 -Bbn admin admin > ~/auth/htpasswd
(Registry)# docker run -d -p 5000:5000 --restart=always --name registry_private -v ~/auth:/auth -e "REGISTRY_AUTH=htpasswd" -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" registry:2
~~~

Registry Node에서 Docker Registry를 구동시킨다. ID/Password는 admin/admin으로 설정한다.

#### 7.2. All Node

{% highlight text linenos %}
[Service]
MountFlags=shared
ExecStart=
ExecStart=/usr/bin/dockerd --insecure-registry 10.0.0.19:5000 --log-opt max-file=5 --log-opt max-size=50m
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 10] All Node - /etc/systemd/system/docker.service.d/kolla.conf</figcaption>
</figure>

~~~console
(All)# service docker restart
~~~

Node에서 동작하는 모든 Docker Daemon에 Registry Node에서 동작하는 Docker Registry를 Insecure Registry로 등록한다. 모든 Node의 /etc/systemd/system/docker.service.d/kolla.conf 파일을 [파일 10]의 내용으로 생성한 다음, Docker를 재시작한다.

### 8. Octavia 인증서 설정

~~~console
(Network)# git clone -b 4.0.1 https://github.com/openstack/octavia.git
(Network)# cd octavia
(Network)# sed -i 's/foobar/admin/g' bin/create_certificates.sh
(Network)# ./bin/create_certificates.sh cert $(pwd)/etc/certificates/openssl.cnf
(Network)# mkdir -p /etc/kolla/config/octavia
(Network)# cp cert/private/cakey.pem /etc/kolla/config/octavia/
(Network)# cp cert/ca_01.pem /etc/kolla/config/octavia/
(Network)# cp cert/client.pem /etc/kolla/config/octavia/
~~~

Network Node에서 Octavia에서 이용하는 인증서를 생성한다.

### 9. Ceph 설정

~~~console
(Ceph)# parted /dev/nvme0n1 -s -- mklabel gpt mkpart KOLLA_CEPH_OSD_BOOTSTRAP_BS 1 -1
(Ceph)# printf 'KERNEL=="nvme0n1p1", SYMLINK+="nvme0n11"\nKERNEL=="nvme0n1p2", SYMLINK+="nvme0n12"' > /etc/udev/rules.d/local.rules
~~~

Ceph Node의 /dev/nvme0n1 Block Device에 KOLLA_CEPH_OSD_BOOTSTRAP_BS Label을 붙인다. Kolla-Ansible은 OSD가 KOLLA_CEPH_OSD_BOOTSTRAP_BS 붙은 Block Device를 이용하도록 설정한다. Kolla-Ansible의 Role의 오류로 인해서 NVME를 Ceph의 Storage로 이용할 경우 잘못된 Partition 이름을 참조하는 버그가 있다. 이러한 문제를 해결하기 위해서 Partiton Symbolic Link를 udev를 통해서 생성한다.

### 10. Kolla Container Image 생성 및 Push

~~~console
(Deploy)# cd ~
(Deploy)# git clone -b 8.0.0 https://github.com/openstack/kolla.git
(Deploy)# cd kolla
(Deploy)# tox -e genconfig
(Deploy)# docker login 10.0.0.19:5000
(Deploy)# mkdir -p logs
(Deploy)# python tools/build.py -b ubuntu --tag stein --skip-parents --skip-existing --type source --registry 10.0.0.19:5000 --push --logs-dir logs
~~~

Kolla Container Image를 생성하고 Registry에 Push한다. Image는 Ubuntu Image를 Base로하여 생성한다.

### 11. Kolla-Ansible을 이용하여 OpenStack 배포

~~~console
(Deploy)# kolla-ansible -i ~/kolla-ansible/multinode prechecks
(Deploy)# kolla-ansible -i ~/kolla-ansible/multinode deploy
~~~

OpenStack을 배포하여 OpenStack을 구동한다.

### 12. OpenStack 초기화 수행

~~~console
(Deploy)# kolla-ansible post-deploy
(Deploy)# . /etc/kolla/admin-openrc.sh
(Deploy)# . /usr/local/share/kolla-ansible/init-runonce
~~~

OpenStack 초기화를 수행한다. 초기화가 완료되면 Network, Image, Flavor 등의 Service들이 초기화된다.

### 13. External Network, Octavia Network 생성

~~~console
(Deploy)# . /etc/kolla/admin-openrc.sh
(Deploy)# openstack port list
(Deploy)# openstack router remove port demo-router [Port ID]
(Deploy)# openstack router delete demo-router
(Deploy)# openstack network delete public1
(Deploy)# openstack network delete demo-net
~~~

init-runonce Script로 인해서 생긴 모든 Network와 Router를 삭제한다.

~~~console
(Deploy)# . /etc/kolla/admin-openrc.sh
(Deploy)# openstack router create external-router
(Deploy)# openstack network create --share --external --provider-physical-network physnet1 --provider-network-type flat external-net
(Deploy)# openstack subnet create --network external-net --allocation-pool start=192.168.0.200,end=192.168.0.224 --dns-nameserver 8.8.8.8 --gateway 192.168.0.1 --subnet-range 192.168.0.0/24 external-sub
(Deploy)# openstack router set --external-gateway external-net --enable-snat --fixed-ip subnet=external-sub,ip-address=192.168.0.225 external-router
~~~

External Router, External Network, External Subnet를 생성하고 External Router에 External Network를 연결한다. External Router는 SNAT를 수행하도록 설정한다.

~~~console
(Deploy)# openstack network create --share --provider-network-type vxlan octavia-net
(Deploy)# openstack subnet create --network octavia-net --dns-nameserver 8.8.8.8 --gateway 20.0.0.1 --subnet-range 20.0.0.0/24 octavia-sub
(Deploy)# openstack router add subnet external-router octavia-sub
~~~

Octavia Network와 Octvia Subnet을 생성하고 External Network를 연결한다.

~~~console
(Controller)# route add -net 20.0.0.0/24 gw 192.168.0.225
(Controller)# printf '#!/bin/bash\nroute add -net 20.0.0.0/24 gw 192.168.0.225' > /etc/rc.local
(Controller)# chmod +x /etc/rc.local
~~~

Controller Node에서 Nat Network로 Octavia Network IP를 Dest IP로 갖고 있는 Packet 전송시, 해당 Packet이 External Router로 전송하도록 Controller Node에 Routing Rule을 추가한다.

### 14. Glance에 VM Image 등록

~~~console
(Deploy)# . /etc/kolla/admin-openrc.sh
(Deploy)# cd ~/kolla-ansible
(Deploy)# wget http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
(Deploy)# guestmount -a bionic-server-cloudimg-amd64.img -m /dev/sda1 /mnt
(Deploy)# chroot /mnt
(Deploy / chroot)# passwd root
(Deploy / chroot)# sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
(Deploy / chroot)# sed -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
(Deploy / chroot)# sync
(Deploy / chroot)# exit
(Deploy)# umount /mnt
(Deploy)# openstack image create --disk-format qcow2 --container-format bare --public --file ./bionic-server-cloudimg-amd64.img ubuntu-18.04
~~~

Ubuntu Image를 Download 받은 후 root 계정 설정, SSHD 설정을 진행한다. 설정이 완료된 Ubuntu Image를 Glance에 등록한다.

~~~console
(Deploy)# . /etc/kolla/admin-openrc.sh
(Deploy)# export OS_USERNAME=octavia
(Deploy)# cd ~
(Deploy)# git clone -b 4.0.1 https://github.com/openstack/octavia.git
(Deploy)# cd octavia/diskimage-create
(Deploy)# ./diskimage-create.sh -r root
(Deploy)# openstack image create --disk-format qcow2 --container-format bare --public --tag amphora --file ./amphora-x64-haproxy.qcow2 ubuntu-16.04-amphora
~~~

octavia User로 Octavia Amphora Image를 생성하고 Glance에 등록한다. tag는 반드시 amphora라고 설정해야 한다.

### 15. Octavia Flavor, Keypair, Security Group 설정 및 Octavia 배포

~~~console
(Deploy)# . /etc/kolla/admin-openrc.sh
(Deploy)# export OS_USERNAME=octavia
(Deploy)# openstack flavor create --id 100 --vcpus 2 --ram 2048 --disk 10 "m1.amphora" --public
~~~

octavia User로 Octavia Amphora VM을 위해서 Flavor를 생성한다. Flavor ID는 100으로 설정할 예정이기 때문에 Flavor ID는 반드시 100으로 생성해야 한다.

~~~console
(Deploy)# . /etc/kolla/admin-openrc.sh
(Deploy)# export OS_USERNAME=octavia
(Deploy)# openstack keypair create -- octavia_ssh_key 
~~~

octavia User로 octavia_ssh_key Keypair를 생성한다. Keypair 이름은 반드시 octavia_ssh_key로 생성해야 한다.

~~~console
(Deploy)# . /etc/kolla/admin-openrc.sh
(Deploy)# export OS_USERNAME=octavia
(Deploy)# openstack security group create octavia-sec
(Deploy)# openstack security group rule create --protocol icmp octavia-sec
(Deploy)# openstack security group rule create --protocol tcp --dst-port 22 octavia-sec
(Deploy)# openstack security group rule create --protocol tcp --dst-port 9443 octavia-sec
~~~

octavia User로 octavia-sec Security Group을 생성한다.

{% highlight yaml linenos %}
...
# Octavia
octavia_loadbalancer_topology: "ACTIVE_STANDBY"
octavia_amp_flavor_id: "100"
octavia_amp_boot_network_list: "[octavia-net Network ID]"
octavia_amp_secgroup_list: "[octavia-sec Security Group ID]"
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 11] Deploy Node - /etc/kolla/globals.yml</figcaption>
</figure>

/etc/kolla/globals.yml 파일을 [파일 11]의 내용처럼, Octavia 설정 주석을 제거하여 Octavia를 설정한다. octavia_amp_boot_network_list에는 위에서 생성한 octavia-net Network의 ID를 넣는다. octavia_amp_secgroup_list에는 위에서 생성한 octavia-sec Security Group의 ID를 넣는다.

~~~console
(Deploy)# kolla-ansible -i ~/kolla-ansible/multinode deploy -t octavia
~~~

Octavia만 배포한다.

### 16. 재설치를 위한 초기화

~~~console
(Deploy)# kolla-ansible -i ~/kolla-ansible/multinode destroy --yes-i-really-really-mean-it 
~~~

모든 OpenStack Container를 삭제한다.

~~~console
(Ceph)# parted /dev/nvme0n1 rm 1
(Ceph)# parted /dev/nvme0n1 rm 2
(Ceph)# reboot now
(Ceph)# parted /dev/nvme0n1 -s -- mklabel gpt mkpart KOLLA_CEPH_OSD_BOOTSTRAP_BS 1 -1
~~~

모든 Ceph Node의 OSD Block을 초기화 한다.

### 17. Dashboard 정보

접속할 수 있는 Dashboard 정보는 아래와 같다. URL, ID, Password 순서로 나열하였다.

* Horizon : http://10.0.0.20:80, admin, admin
* RabbitMQ : http://10.0.0.20:15672, openstack, admin
* Prometheus : http://10.0.0.20:9091
* Grafana : http://10.0.0.20:3000, admin, admin
* Alertmanager : http://10.0.0.20:9093, admin, admin

### 18. Debugging

~~~console
(Node01)# ls /var/log/kolla
ansible.log  ceph  chrony  cinder  glance  horizon  keystone  mariadb  neutron  nova  octavia  openvswitch  prometheus  rabbitmq
~~~

각 Node의 **/var/log/kolla** Directory에 OpenStack Service들의 Log가 저장된다.

### 19. 참조

* [https://docs.openstack.org/kolla/stein/](https://docs.openstack.org/kolla/stein/)
* [https://docs.openstack.org/kolla-ansible/stein/](https://docs.openstack.org/kolla-ansible/stein)
* [https://shreddedbacon.com/post/openstack-kolla/](https://shreddedbacon.com/post/openstack-kolla/)
* [https://docs.oracle.com/cd/E90981_01/E90982/html/kolla-openstack-network.html](https://docs.oracle.com/cd/E90981_01/E90982/html/kolla-openstack-network.html)
* [https://github.com/osrg/openvswitch/blob/master/debian/openvswitch-switch.README.Debian](https://github.com/osrg/openvswitch/blob/master/debian/openvswitch-switch.README.Debian)
* [https://blog.zufardhiyaulhaq.com/manual-instalation-octavia-openstack-queens/](https://blog.zufardhiyaulhaq.com/manual-instalation-octavia-openstack-queens/)
* [http://www.panticz.de/openstack-octavia-loadbalancer](http://www.panticz.de/openstack-octavia-loadbalancer)