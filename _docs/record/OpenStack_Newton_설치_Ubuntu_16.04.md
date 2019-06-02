---
title: OpenStack Newton 설치 - Ubuntu 16.04
category: Record
date: 2017-07-04T12:00:00Z
lastmod: 2017-07-04T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 설치 환경

설치 환경은 다음과 같다.
* VirtualBox 5.0.14r
  * Controller Node : Ubuntu Server 16.04.2 64bit 1대
  * Compute Node : Ubuntu Server 16.04.2 64bit 1대
  * Block Storage Node : Ubuntu Server 16.04.2 64bit 1대
* OpenStack Newton Version
  * Network : Self-service
* Password
  * OpenStack 설치에 필요한 Password는 간편한 설치를 위해 **root**로 통일한다.
* 모든 Node에서 root User로 설치를 진행한다.

### 2. Node 설정

![[그림 1] Openstack 설치를 위한 Node 구성도]({{site.baseurl}}/images/record/OpenStack_Newton_Install_Ubuntu_16.04/Node_Setting.PNG)

VirtualBox를 이용하여 [그림 1]과 같이 가상의 Controller, Compute, Storage Node (VM)을 생성한다.
* NAT : Virtual Box에서 제공하는 "NAT 네트워크" 이용하여 10.0.0/24 Network를 구축한다.
* Router : 공유기를 이용하여 192.168.77.0/24 Network를 구축한다. (NAT)
* Horizon 설치 후 PC Web Browser를 이용하여 192.168.77.170/horizon에 접속하면 Horizon을 이용할 수 있다.

#### 2.1. 모든 Node

##### 2.1.1. Network 설정

{% highlight text %}
# controller
10.0.0.11       controller

# compute1
10.0.0.31       compute1

# block1
10.0.0.41       block1
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Node의 /etc/hosts</figcaption>
</figure>

/etc/hosts에 [파일 1]의 내용으로 파일을 생성한다.

##### 2.1.1. OpenStack Package 설치

~~~
# apt install software-properties-common
# add-apt-repository cloud-archive:newton
~~~

OpenStack Package 저장소를 추가한다.

~~~
# apt update && apt dist-upgrade
# apt install python-openstackclient
~~~

OpenStack Package를 설치한다.

#### 2.2. Controller Node

##### 2.2.1. Network 설정

{% highlight text %}
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto enp0s3
iface enp0s3 inet static
address 10.0.0.11
netmask 255.255.255.0
gateway 10.0.0.1
dns-nameservers 8.8.8.8

auto enp0s8
iface enp0s8 inet static
address 192.168.77.170
netmask 255.255.255.0
gateway 192.168.77.1
dns-nameservers 8.8.8.8
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] Controller Node의 /etc/network/interfaces</figcaption>
</figure>

/etc/network/interfaces을 [파일 2]과 같이 수정한다.

##### 2.2.2. NTP (Network Time Protocol) 설정

~~~
# apt install chrony
~~~

chrony Package를 설치한다.

{% highlight text %}
...
server 0.asia.pool.ntp.org
server 1.asia.pool.ntp.org
server 2.asia.pool.ntp.org
server 3.asia.pool.ntp.org

allow 10.0.0.0/24
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] Controller Node의 /etc/chrony/chrony.conf</figcaption>
</figure>

 /etc/chrony/chrony.conf에 [파일 3]의 내용을 추가한다.

~~~
# service chrony restart
~~~

chrony를 재시작한다.

##### 2.2.3. SQL Database 설치

~~~
# apt install mariadb-server python-pymysql
~~~

MariaDB Package를 설치한다.

{% highlight text %}
...
[mysqld]
bind-address = 10.0.0.11

default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 4] Controller Node의 /etc/mysql/mariadb.conf.d/99-openstack.cnf</figcaption>
</figure>

/etc/mysql/mariadb.conf.d/99-openstack.cnf 생성 및 [파일 4]와 같이 수정한다.

~~~
# service mysql restart
~~~

MariaDB를 재시작한다.

##### 2.2.4. Message Queue 설치

~~~
# apt install rabbitmq-server
~~~

RabbitMQ Package를 설치한다.

~~~
# rabbitmqctl add_user openstack root
# rabbitmqctl set_permissions openstack ".\*" ".\*" ".\*"
~~~

RabbitMQ를 설정한다.

##### 2.2.5. Memcached 설치

~~~
# apt install memcached python-memcache
~~~

Memcached Package를 설치한다.

{% highlight text %}
...
-l 10.0.0.11
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 5] Controller Node의 /etc/memcached.conf</figcaption>
</figure>

/etc/memcached.conf에 [파일 5]의 내용을 추가한다.

##### 2.2.6. 환경 변수 파일 생성

{% highlight text %}
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=root
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 6] Controller Node의 /root/admin-openrc</figcaption>
</figure>

/root/admin-openrc 생성 및 [파일 6]와 같이 수정한다.

{% highlight text %}
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=root
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 7] Controller Node의 /root/demo-openrc</figcaption>
</figure>

/root/demo-openrc 생성 및 [파일 7]과 같이 수정한다.

#### 2.3. Compute Node

##### 2.3.1. Network 설정

{% highlight text %}
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto enp0s3
iface enp0s3 inet static
address 10.0.0.31
netmask 255.255.255.0
gateway 10.0.0.1
dns-nameservers 8.8.8.8

auto enp0s8
iface enp0s8 inet static
address 192.168.77.180
netmask 255.255.255.0
gateway 192.168.77.1
dns-nameservers 8.8.8.8
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 8] Compute Node의 /etc/network/interfaces</figcaption>
</figure>

/etc/network/interfaces을 [파일 8]과 같이 수정한다.

##### 2.3.2. NTP (Network Time Protocol) 설정

~~~
# apt install chrony
~~~

chrony Package를 설치한다.

{% highlight text %}
...
server controller iburst
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 9] Compute Node의 /etc/chrony/chrony.conf</figcaption>
</figure>

/etc/chrony/chrony.conf에 [파일 9]의 내용을 추가한다.

~~~
# service chrony restart
~~~

chrony를 재시작한다.

#### 2.4. Storage Node

##### 2.4.1, Network 설정

{% highlight text %}
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto enp0s3
iface enp0s3 inet static
address 10.0.0.41
netmask 255.255.255.0
gateway 10.0.0.1
dns-nameservers 8.8.8.8
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 10] Storage Node의 /etc/network/interfaces</figcaption>
</figure>

/etc/network/interfaces을 [파일 10]과 같이 수정한다.

##### 2.4.2. NTP (Network Time Protocol) 설정

~~~
# apt install chrony
~~~

chrony Package를 설치한다.

{% highlight text %}
...
server controller iburst
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 11] Storage Node의 /etc/chrony/chrony.conf</figcaption>
</figure>

/etc/chrony/chrony.conf에 [파일 11]의 내용을 추가한다.

~~~
# service chrony restart
~~~

chrony를 재시작한다.

### 3. Keystone 설치

#### 3.1. Controller Node

~~~
# mysql -u root -p
mysql> CREATE DATABASE keystone;
mysql> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'root';
mysql> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'root';
mysql> exit;
~~~

Keystone DB를 초기화한다.

~~~
# apt install keystone
~~~

Keystone Package를 설치한다.

{% highlight text %}
...
[database]
connection = mysql+pymysql://keystone:root@controller/keystone

[token]
provider = fernet
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 12] Controller Node의 /etc/keystone/keystone.conf</figcaption>
</figure>

/etc/keystone/keystone.conf에 [파일 12]의 내용을 추가한다.

~~~
# su -s /bin/sh -c "keystone-manage db_sync" keystone
# keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
# keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
# keystone-manage bootstrap --bootstrap-password root --bootstrap-admin-url http://controller:35357/v3/ --bootstrap-internal-url http://controller:35357/v3/ --bootstrap-public-url http://controller:5000/v3/ --bootstrap-region-id RegionOne
~~~

Keystone을 설정한다.

{% highlight text %}
...
ServerName controller
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 13] Controller Node의 /etc/apache2/apache2.conf</figcaption>
</figure>

/etc/apache2/apache2.conf에 [파일 13]의 내용을 추가한다.

~~~
# service apache2 restart
# rm -f /var/lib/keystone/keystone.db
~~~

Apache HTTP Server 재시작 및 DB 제거한다.

~~~
# export OS_USERNAME=admin
# export OS_PASSWORD=root
# export OS_PROJECT_NAME=admin
# export OS_USER_DOMAIN_NAME=Default
# export OS_PROJECT_DOMAIN_NAME=Default
# export OS_AUTH_URL=http://controller:35357/v3
# export OS_IDENTITY_API_VERSION=3
~~~

환경 변수를 설정한다.

~~~
# openstack project create --domain default --description "Service Project" service
# openstack project create --domain default --description "Demo Project" demo
# openstack user create --domain default --password-prompt demo
# openstack role create user
# openstack role add --project demo --user demo user
~~~

Project, User, Role 생성 및 설정한다.

#### 3.2. 검증

~~~
# openstack --os-auth-url http://controller:35357/v3 --os-project-domain-name Default --os-user-domain-name Default --os-project-name admin --os-username admin token issue
+------------+-----------------------------------------------------------------+
| Field      | Value                                                           |
+------------+-----------------------------------------------------------------+
| expires    | 2016-02-12T20:14:07.056119Z                                     |
| id         | gAAAAABWvi7_B8kKQD9wdXac8MoZiQldmjEO643d-e_j-XXq9AmIegIbA7UHGPv |
|            | atnN21qtOMjCFWX7BReJEQnVOAj3nclRQgAYRsfSU_MrsuWb4EDtnjU7HEpoBb4 |
|            | o6ozsA_NmFWEpLeKy0uNn_WeKbAhYygrsmQGA49dclHVnz-OMVLiyM9ws       |
| project_id | 343d245e850143a096806dfaefa9afdc                                |
| user_id    | ac3377633149401296f6c0d92d79dc16                                |
+------------+-----------------------------------------------------------------+
~~~

~~~
# openstack --os-auth-url http://controller:5000/v3 --os-project-domain-name Default --os-user-domain-name Default --os-project-name demo --os-username demo token issue
+------------+-----------------------------------------------------------------+
| Field      | Value                                                           |
+------------+-----------------------------------------------------------------+
| expires    | 2016-02-12T20:15:39.014479Z                                     |
| id         | gAAAAABWvi9bsh7vkiby5BpCCnc-JkbGhm9wH3fabS_cY7uabOubesi-Me6IGWW |
|            | yQqNegDDZ5jw7grI26vvgy1J5nCVwZ_zFRqPiz_qhbq29mgbQLglbkq6FQvzBRQ |
|            | JcOzq3uwhzNxszJWmzGC7rJE_H0A_a3UFhqv8M4zMRYSbS2YF0MyFmp_U       |
| project_id | ed0b60bf607743088218b0a533d5943f                                |
| user_id    | 58126687cbcc4888bfa9ab73a2256f27                                |
+------------+-----------------------------------------------------------------+
~~~

Controller Node에서 Keystone의 동작 확인한다.

### 4. Glance 설치

#### 4.1. Controller Node

~~~
# mysql -u root -p
mysql> CREATE DATABASE glance;
mysql> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'root';
mysql> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'root';
mysql> exit;
~~~

Glance DB를 초기화한다.

~~~
# . /root/admin-openrc
# openstack user create --domain default --password-prompt glance
# openstack role add --project service --user glance admin
# openstack service create --name glance --description "OpenStack Image" image
~~~

Glance User 생성 및 설정한다.

~~~
# openstack endpoint create --region RegionOne image public http://controller:9292
# openstack endpoint create --region RegionOne image internal http://controller:9292
# openstack endpoint create --region RegionOne image admin http://controller:9292
~~~

Glance Service API Endpoint를 생성한다.

~~~
# apt install glance
~~~

Glance Package 설치를 설치한다.

{% highlight text %}
...
[database]
connection = mysql+pymysql://glance:root@controller/glance

[keystone_authtoken]
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = root

[paste_deploy]
flavor = keystone

[glance_store]
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 14] Controller Node의 /etc/glance/glance-api.conf</figcaption>
</figure>

/etc/glance/glance-api.conf에 [파일 14]의 내용을 추가한다.

{% highlight text %}
...
[database]
connection = mysql+pymysql://glance:root@controller/glance

[keystone_authtoken]
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = root

[paste_deploy]
flavor = keystone
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 15] Controller Node의 /etc/glance/glance-api.conf</figcaption>
</figure>

/etc/glance/glance-registry.conf에 [파일 15]의 내용을 추가한다.

~~~
# su -s /bin/sh -c "glance-manage db_sync" glance
# service glance-registry restart
# service glance-api restart
~~~

Glance를 설정 및 시작한다.

#### 4.2. 검증

~~~
# . /root/admin-openrc
# wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
# openstack image create "cirros" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --public
# openstack image list
+--------------------------------------+--------+--------+
| ID                                   | Name   | Status |
+--------------------------------------+--------+--------+
| 38047887-61a7-41ea-9b49-27987d5e8bb9 | cirros | active |
+--------------------------------------+--------+--------+
~~~

Controller Node에서 Glance의 동작을 확인한다.

### 5. Nova 설치

#### 5.1. Controller Node

~~~
# mysql -u root -p
mysql> CREATE DATABASE nova_api;
mysql> CREATE DATABASE nova;
mysql> GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'root';
mysql> GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'root';
mysql> GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'root';
mysql> GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'root';
mysql> exit;
~~~

Nova DB를 초기화 한다.

~~~
# . /root/admin-openrc
# openstack user create --domain default --password-prompt nova
# openstack role add --project service --user nova admin
# openstack service create --name nova --description "OpenStack Compute" compute
~~~

Nova User를 생성 및 설정한다.

~~~
# openstack endpoint create --region RegionOne compute public http://controller:8774/v2.1/%\(tenant_id\)s
# openstack endpoint create --region RegionOne compute internal http://controller:8774/v2.1/%\(tenant_id\)s
# openstack endpoint create --region RegionOne compute admin http://controller:8774/v2.1/%\(tenant_id\)s
~~~

Nova Service API Endpoint를 생성한다.

~~~
# apt install nova-api nova-conductor nova-consoleauth nova-novncproxy nova-scheduler
# mkdir /usr/lib/python2.7/dist-packages/keys
~~~

Nova Package를 설치한다.

{% highlight text %}
...
[DEFAULT]
transport_url = rabbit://openstack:root@controller
auth_strategy = keystone
my_ip = 10.0.0.11
use_neutron = True
firewall_driver = nova.virt.firewall.NoopFirewallDriver

[api_database]
connection = mysql+pymysql://nova:root@controller/nova_api

[database]
connection = mysql+pymysql://nova:root@controller/nova

[keystone_authtoken]
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = root

[vnc]
vncserver_listen = $my_ip
vncserver_proxyclient_address = $my_ip

[glance]
api_servers = http://controller:9292

[oslo_concurrency]
lock_path = /var/lib/nova/tmp
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 16] Controller Node의 /etc/nova/nova.conf</figcaption>
</figure>

/etc/nova/nova.conf에 [파일 16]의 내용을 추가한다.

~~~
# su -s /bin/sh -c "nova-manage api_db sync" nova
# su -s /bin/sh -c "nova-manage db sync" nova
# service nova-api restart
# service nova-consoleauth restart
# service nova-scheduler restart
# service nova-conductor restart
# service nova-novncproxy restart
~~~

Nova를 설정 및 시작한다.

#### 5.2. Compute Node

~~~
# apt install nova-compute
~~~

Nova Package를 설치한다.

{% highlight text %}
...
[DEFAULT]
transport_url = rabbit://openstack:root@controller
instances_path = /var/lib/nova/instances
auth_strategy = keystone
my_ip = 10.0.0.31
use_neutron = True
firewall_driver = nova.virt.firewall.NoopFirewallDriver

[keystone_authtoken]
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = root

[vnc]
enabled = True
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = $my_ip
novncproxy_base_url = http://controller:6080/vnc_auto.html

[glance]
api_servers = http://controller:9292

[oslo_concurrency]
lock_path = /var/lib/nova/tmp
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 17] Compute Node의 /etc/nova/nova.conf</figcaption>
</figure>

/etc/nova/nova.conf에 [파일 17]의 내용을 추가한다.

{% highlight text %}
...
[DEFAULT]
compute_driver=libvirt.LibvirtDriver
[libvirt]
virt_type=qemu
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 18] Compute Node의 /etc/nova/nova-compute.conf</figcaption>
</figure>

현재 VirtualBox의 VM은 CPU의 Intel의 VT-X같은 Virtualization Extension을 이용하지 못한다. 따라서 Compute Node는 KVM+QEMU 조합의 가상 머신을 이용하지 못하고 QEMU만을 이용하여 가상 머신을 구동한다. /etc/nova/nova-compute.conf을 [파일 18]과 같이 수정한다.

~~~
# service nova-compute restart
~~~

Nova를 시작한다.

#### 5.3. 검증

~~~
# . /root/admin-openrc
# openstack compute service list
+----+--------------------+------------+----------+---------+-------+----------------------------+
| Id | Binary             | Host       | Zone     | Status  | State | Updated At                 |
+----+--------------------+------------+----------+---------+-------+----------------------------+
|  1 | nova-consoleauth   | controller | internal | enabled | up    | 2016-02-09T23:11:15.000000 |
|  2 | nova-scheduler     | controller | internal | enabled | up    | 2016-02-09T23:11:15.000000 |
|  3 | nova-conductor     | controller | internal | enabled | up    | 2016-02-09T23:11:16.000000 |
|  4 | nova-compute       | compute1   | nova     | enabled | up    | 2016-02-09T23:11:20.000000 |
+----+--------------------+------------+----------+---------+-------+----------------------------+
~~~

Controller Node에서 Nova의 동작을 확인한다.

### 6. Neutron 설치

#### 6.1. Controller Node

~~~
# mysql -u root -p
mysql> CREATE DATABASE neutron;
mysql> GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'root';
mysql> GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'root';
mysql> exit;
~~~

Neutron DB를 초기화 한다.

~~~
# . /root/admin-openrc
# openstack user create --domain default --password-prompt neutron
# openstack role add --project service --user neutron admin
# openstack service create --name neutron --description "OpenStack Networking" network
~~~

Neutron User를 생성 및 설정한다.

~~~
# openstack endpoint create --region RegionOne network public http://controller:9696
# openstack endpoint create --region RegionOne network internal http://controller:9696
# openstack endpoint create --region RegionOne network admin http://controller:9696
~~~

Neutron Service API Endpoint를 생성한다.

~~~
# apt install neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent
~~~

Neutron Package를 설치한다.

{% highlight text %}
...
[DEFAULT]
core_plugin = ml2
service_plugins = router
allow_overlapping_ips = True
transport_url = rabbit://openstack:root@controller
auth_strategy = keystone
notify_nova_on_port_status_changes = True
notify_nova_on_port_data_changes = True

[database]
connection = mysql+pymysql://neutron:root@controller/neutron

[keystone_authtoken]
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = neutron
password = root

[nova]
auth_url = http://controller:35357
auth_type = password
project_domain_name = Default
user_domain_name = Default
region_name = RegionOne
project_name = service
username = nova
password = root
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 19] Controller Node의 /etc/neutron/neutron.conf</figcaption>
</figure>

/etc/neutron/neutron.conf에 [파일 19]의 내용을 추가한다.

{% highlight text %}
...
[ml2]
type_drivers = flat,vlan,vxlan
tenant_network_types = vxlan
mechanism_drivers = linuxbridge,l2population
extension_drivers = port_security

[ml2_type_flat]
flat_networks = provider

[ml2_type_vxlan]
vni_ranges = 1:1000

[securitygroup]
enable_ipset = True
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 20] Controller Node의 /etc/neutron/plugins/ml2/ml2_conf.ini</figcaption>
</figure>

/etc/neutron/plugins/ml2/ml2_conf.ini에 [파일 20]의 내용을 추가한다.

{% highlight text %}
...
[linux_bridge]
physical_interface_mappings = provider:enp0s8

[vxlan]
enable_vxlan = True
local_ip = 10.0.0.11
l2_population = True

[securitygroup]
enable_security_group = True
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 21] Controller Node의 /etc/neutron/plugins/ml2/linuxbridge_agent.ini</figcaption>
</figure>

/etc/neutron/plugins/ml2/linuxbridge_agent.ini에 [파일 21]의 내용을 추가한다.

{% highlight text %}
...
[DEFAULT]
interface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 22] Controller Node의 /etc/neutron/l3_agent.ini</figcaption>
</figure>

/etc/neutron/l3_agent.ini에 [파일 22]의 내용을 추가한다.

{% highlight text %}
...
[DEFAULT]
interface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
enable_isolated_metadata = True
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 23] Controller Node의 /etc/neutron/dhcp_agent.ini</figcaption>
</figure>

/etc/neutron/dhcp_agent.ini에 [파일 23]의 내용을 추가한다.

{% highlight text %}
...
[DEFAULT]
nova_metadata_ip = controller
metadata_proxy_shared_secret = root
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 24] Controller Node의 /etc/neutron/metadata_agent.ini</figcaption>
</figure>

/etc/neutron/metadata_agent.ini에 [파일 24]의 내용을 추가한다.

{% highlight text %}
...
[neutron]
url = http://controller:9696
auth_url = http://controller:35357
auth_type = password
project_domain_name = Default
user_domain_name = Default
region_name = RegionOne
project_name = service
username = neutron
password = root
service_metadata_proxy = True
metadata_proxy_shared_secret = root
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 25] Controller Node의 /etc/nova/nova.conf</figcaption>
</figure>

/etc/nova/nova.conf에 [파일 25]의 내용을 추가한다.

~~~
# su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
# service nova-api restart
# service neutron-server restart
# service neutron-linuxbridge-agent restart
# service neutron-dhcp-agent restart
# service neutron-metadata-agent restart
# service neutron-l3-agent restart
~~~

Neutron를 시작한다.

#### 6.2. Compute Node

~~~
# apt install neutron-linuxbridge-agent
~~~

Neutron Package를 설치한다.

{% highlight text %}
...
[DEFAULT]
transport_url = rabbit://openstack:root@controller
auth_strategy = keystone

[keystone_authtoken]
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = neutron
password = root
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 26] Compute Node의 /etc/neutron/neutron.conf</figcaption>
</figure>

/etc/neutron/neutron.conf에 [파일 26]의 내용을 추가한다.

{% highlight text %}
...
[linux_bridge]
physical_interface_mappings = provider:enp0s8

[vxlan]
enable_vxlan = True
local_ip = 10.0.0.31
l2_population = True

[securitygroup]
enable_security_group = True
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 27] Compute Node의 /etc/neutron/plugins/ml2/linuxbridge_agent.ini</figcaption>
</figure>

/etc/neutron/plugins/ml2/linuxbridge_agent.ini에 [파일 27의] 내용을 추가한다.

{% highlight text %}
...
[neutron]
url = http://controller:9696
auth_url = http://controller:35357
auth_type = password
project_domain_name = Default
user_domain_name = Default
region_name = RegionOne
project_name = service
username = neutron
password = root
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 28] Compute Node의 /etc/nova/nova.conf</figcaption>
</figure>

/etc/nova/nova.conf에 [파일 28]의 내용을 추가한다.

~~~
# service nova-compute restart
# service neutron-linuxbridge-agent restart
~~~

Neutron를 시작한다.

#### 6.3. 검증

~~~
# . /root/admin-openrc
# neutron ext-list
+---------------------------+-----------------------------------------------+
| alias                     | name                                          |
+---------------------------+-----------------------------------------------+
| default-subnetpools       | Default Subnetpools                           |
| network-ip-availability   | Network IP Availability                       |
| network_availability_zone | Network Availability Zone                     |
| auto-allocated-topology   | Auto Allocated Topology Services              |
| ext-gw-mode               | Neutron L3 Configurable external gateway mode |
| binding                   | Port Binding                                  |
| agent                     | agent                                         |
| subnet_allocation         | Subnet Allocation                             |
| l3_agent_scheduler        | L3 Agent Scheduler                            |
| tag                       | Tag support                                   |
| external-net              | Neutron external network                      |
| net-mtu                   | Network MTU                                   |
| availability_zone         | Availability Zone                             |
| quotas                    | Quota management support                      |
| l3-ha                     | HA Router extension                           |
| flavors                   | Neutron Service Flavors                       |
| provider                  | Provider Network                              |
| multi-provider            | Multi Provider Network                        |
| address-scope             | Address scope                                 |
| extraroute                | Neutron Extra Route                           |
| timestamp_core            | Time Stamp Fields addition for core resources |
| router                    | Neutron L3 Router                             |
| extra_dhcp_opt            | Neutron Extra DHCP opts                       |
| dns-integration           | DNS Integration                               |
| security-group            | security-group                                |
| dhcp_agent_scheduler      | DHCP Agent Scheduler                          |
| router_availability_zone  | Router Availability Zone                      |
| rbac-policies             | RBAC Policies                                 |
| standard-attr-description | standard-attr-description                     |
| port-security             | Port Security                                 |
| allowed-address-pairs     | Allowed Address Pairs                         |
| dvr                       | Distributed Virtual Router                    |
+---------------------------+-----------------------------------------------+
~~~

Compute Node에서 Neutron의 동작을 확인한다.

### 7. Horizon 설치

#### 7.1. Controller Node

~~~
# apt install openstack-dashboard
~~~

Horizon Package를 설치한다.

{% highlight python %}
...
OPENSTACK_HOST = "controller"
OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST
OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"
...
ALLOWED_HOSTS = ['*', ]
...
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'

CACHES = {
    'default': {
         'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
         'LOCATION': 'controller:11211',
    }
}
...
TIME_ZONE = "Asia/Seoul"
...
OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True
OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "default"
OPENSTACK_API_VERSIONS = {
    "identity": 3,
    "image": 2,
    "volume": 2,
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 29] Controller Node의 /etc/openstack-dashboard/local_settings.py</figcaption>
</figure>

/etc/openstack-dashboard/local_settings.py에 [파일 29]와 같이 수정한다.

~~~
# service apache2 reload
~~~

Horizon 시작

#### 7.2. 검증

Web Brower를 통해 Horizon에 접속한다.
* http://192.168.77.170/horizon
* Login : Domain - default, 사용자 이름 - admin, 암호 - root

### 8. Cinder 설치

#### 8.1. Compute Node

{% highlight text %}
...
[cinder]
os_region_name = RegionOne
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 30] Compute Node의 /etc/nova.nova.conf</figcaption>
</figure>

/etc/nova.nova.conf에 [파일 30]의 내용을 추가한다.

#### 8.2. Controller Node

~~~
# mysql -u root -p
mysql> CREATE DATABASE cinder;
mysql> GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'root';
mysql> GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'root';
> exit;
~~~

Cinder DB를 초기화한다.

~~~
# . admin-openrc
# openstack user create --domain default --password-prompt cinder
# openstack role add --project service --user cinder admin
# openstack service create --name cinder --description "OpenStack Block Storage" volume
# openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
~~~

Cinder User를 생성 및 설정한다.

~~~
# openstack endpoint create --region RegionOne volume public http://controller:8776/v1/%\(tenant_id\)s
# openstack endpoint create --region RegionOne volume internal http://controller:8776/v1/%\(tenant_id\)s
# openstack endpoint create --region RegionOne volume admin http://controller:8776/v1/%\(tenant_id\)s
# openstack endpoint create --region RegionOne volumev2 public http://controller:8776/v2/%\(tenant_id\)s
# openstack endpoint create --region RegionOne volumev2 internal http://controller:8776/v2/%\(tenant_id\)s
# openstack endpoint create --region RegionOne volumev2 admin http://controller:8776/v2/%\(tenant_id\)s
~~~

Cinder Service API Endpoint를 생성한다.

~~~
# su -s /bin/sh -c "cinder-manage db sync" cinder
# apt install cinder-api cinder-scheduler
~~~

Cinder Package를 설치한다.

{% highlight text %}
...
[DEFAULT]
transport_url = rabbit://openstack:root@controller
auth_strategy = keystone
my_ip = 10.0.0.11

[database]
connection = mysql+pymysql://cinder:root@controller/cinder

[keystone_authtoken]
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = cinder
password = root

[oslo_concurrency]
lock_path = /var/lib/cinder/tmp
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 31] Controller Node의 /etc/cinder/cinder.conf</figcaption>
</figure>

/etc/cinder/cinder.conf에 [파일 31]의 내용을 추가한다.

~~~
# service nova-api restart
# service cinder-scheduler restart
# service cinder-api restart
~~~

Cinder를 시작한다.

#### 8.3. Storage Node

~~~
# apt install lvm2
# pvcreate /dev/sdb
# vgcreate cinder-volumes /dev/sdb
~~~

LVM를 설치 및 설정한다.

{% highlight text %}
...
devices {
...
filter = [ "a/sdb/", "r/.*/"]
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 32] Storage Node의 /etc/lvm/lvm.conf</figcaption>
</figure>

/etc/lvm/lvm.conf에 [파일 32]의 내용을 추가한다.

~~~
# apt install cinder-volume
~~~

Cinder Package를 설치한다.

{% highlight text %}
...
[DEFAULT]
transport_url = rabbit://openstack:root@controller
auth_strategy = keystone
my_ip = 10.0.0.41
enabled_backends = lvm
glance_api_servers = http://controller:9292

[database]
connection = mysql+pymysql://cinder:root@controller/cinder

[keystone_authtoken]
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = cinder
password = root

[lvm]
volume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver
volume_group = cinder-volumes
iscsi_protocol = iscsi
iscsi_helper = tgtadm

[oslo_concurrency]
lock_path = /var/lib/cinder/tmp
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 33] Storage Node의 /etc/cinder/cinder.conf</figcaption>
</figure>

/etc/cinder/cinder.conf에 [파일 33]의 내용을 추가한다.

~~~
# service tgt restart
# service cinder-volume restart
~~~

Cinder를 시작한다.

#### 8.4. 검증

~~~
# . admin-openrc
# openstack volume service list
+------------------+------------+------+---------+-------+----------------------------+
| Binary           | Host       | Zone | Status  | State | Updated_at                 |
+------------------+------------+------+---------+-------+----------------------------+
| cinder-scheduler | controller | nova | enabled | up    | 2016-09-30T02:27:41.000000 |
| cinder-volume    | block@lvm  | nova | enabled | up    | 2016-09-30T02:27:46.000000 |
+------------------+------------+------+---------+-------+----------------------------+
~~~

Controller Node에서 Cinder의 동작 확인한다.

### 9. 참조

* OpenStack 설치 한글 : [https://docs.openstack.org/newton/install-guide-ubuntu/](https://docs.openstack.org/newton/install-guide-ubuntu/)
* OpenStack 설치 영문 : [https://docs.openstack.org/newton/ko_KR/install-guide-ubuntu/](https://docs.openstack.org/newton/ko_KR/install-guide-ubuntu/)
