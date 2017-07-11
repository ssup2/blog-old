---
title: OpenStack Newton 설치
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

* Virtual Box 5.0.14r
  * Controller Node - Ubuntu Server 16.04.2 64bit - 1대
  * Compute Node - Ubuntu Server 16.04.2 64bit - 1대
  * Block Storage Node - Ubuntu Server 16.04.2 64bit - 1대
* OpenStack Newton Version
  * Network - Self-service
* Password
  * OpenStack 설치에 필요한 Password는 간편한 설치를 위해 **root** 로 통일한다.

### 2. Node 설정

![]({{site.baseurl}}/images/record/OpenStack_Newton_Install/Node_Setting.PNG)

* Virtual Box를 이용하여 위의 그림과 같이 가상의 Controller, Compute, Storage Node (VM)을 생성한다.
* NAT - Virtual Box에서 제공하는 "NAT 네트워크" 이용하여 10.0.0/24 Network를 구축한다.

#### 2.1. 모든 Node

##### 2.1.1. Network 설정

* /etc/hosts에 다음의 내용 추가

~~~
# controller
10.0.0.11       controller

# compute1
10.0.0.31       compute1

# block1
10.0.0.41       block1
~~~

##### 2.1.1. OpenStack Package 설치

* OpenStack Package 저장소 추가

> \# apt install software-properties-common <br>
> \# add-apt-repository cloud-archive:newton

* OpenStack Package 설치

> \# apt update && apt dist-upgrade
> \# apt install python-openstackclient

#### 2.2. Controller Node

##### 2.2.1. Network 설정

* /etc/network/interfaces을 다음과 같이 수정

~~~
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
~~~

##### 2.2.2. NTP (Network Time Protocol) 설정

* chrony Package 설치

> \# apt install chrony

* /etc/chrony/chrony.conf에 다음의 내용 추가

~~~
server 0.asia.pool.ntp.org
server 1.asia.pool.ntp.org
server 2.asia.pool.ntp.org
server 3.asia.pool.ntp.org

allow 10.0.0.0/24
~~~

* chrony 재시작

> \# service chrony restart

##### 2.2.3. SQL Database 설치

* MariaDB Package 설치

> \# apt install mariadb-server python-pymysql

* /etc/mysql/mariadb.conf.d/99-openstack.cnf 생성 및 다음과 같이 수정

~~~
[mysqld]
bind-address = 10.0.0.11

default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
~~~

* MariaDB 재시작

> \# service mysql restart

##### 2.2.4. Message Queue 설치

* RabbitMQ Package 설치

> \# apt install rabbitmq-server

* RabbitMQ 설정

> \# rabbitmqctl add_user openstack root <br>
> \# rabbitmqctl set_permissions openstack ".\*" ".\*" ".\*"

##### 2.2.5. Memcached 설치

* Memcached Package 설치

> \# apt install memcached python-memcache

* /etc/memcached.conf에 다음의 내용 추가

~~~
-l 10.0.0.11
~~~

##### 2.2.6. 환경 변수 파일 생성

* /root/admin-openrc 생성 및 다음과 같이 수정

~~~
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=root
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
~~~

* /root/demo-openrc 생성 및 다음과 같이 수정

~~~
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=root
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
~~~

#### 2.3. Compute Node

##### 2.3.1. Network 설정

* /etc/network/interfaces을 다음과 같이 수정

~~~
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
~~~

##### 2.3.2. NTP (Network Time Protocol) 설정

* chrony Package 설치

> \# apt install chrony

* /etc/chrony/chrony.conf에 다음의 내용 추가

~~~
server controller iburst
~~~

* chrony 재시작

> \# service chrony restart

#### 2.4. Storage Node

##### 2.4.1, Network 설정

* /etc/network/interfaces을 다음과 같이 수정

~~~
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

auto enp0s8
iface enp0s8 inet static
address 192.168.77.190
netmask 255.255.255.0
gateway 192.168.77.1
dns-nameservers 8.8.8.8
~~~

##### 2.4.2. NTP (Network Time Protocol) 설정

* chrony Package 설치

> \# apt install chrony

* /etc/chrony/chrony.conf에 다음의 내용 추가

~~~
server controller iburst
~~~

* chrony 재시작

> \# service chrony restart

### 3. Keystone 설치

#### 3.1. Controller Node

* Keystone DB 초기화

> \# mysql -u root -p

> mysql> CREATE DATABASE keystone; <br>
> mysql> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'root'; <br>
> mysql> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'root';
> mysql> exit;

* Keystone Package 설치

> \# apt install keystone

* /etc/keystone/keystone.conf에 다음의 내용을 추가

~~~
[database]
connection = mysql+pymysql://keystone:root@controller/keystone

[token]
provider = fernet
~~~

* Keystone 설정

> \# su -s /bin/sh -c "keystone-manage db_sync" keystone <br>
> \# keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone <br>
> \# keystone-manage credential_setup --keystone-user keystone --keystone-group keystone <br>
> \# keystone-manage bootstrap --bootstrap-password root --bootstrap-admin-url http://controller:35357/v3/ --bootstrap-internal-url http://controller:35357/v3/ --bootstrap-public-url http://controller:5000/v3/ --bootstrap-region-id RegionOne

* /etc/apache2/apache2.conf에 다음의 내용 추가

~~~
ServerName controller
~~~

* Apache HTTP Server 재시작 및 DB 제거

> \# service apache2 restart <br>
> \# rm -f /var/lib/keystone/keystone.db <br>

* 환경 변수 설정

> \# export OS_USERNAME=admin <br>
> \# export OS_PASSWORD=root <br>
> \# export OS_PROJECT_NAME=admin <br>
> \# export OS_USER_DOMAIN_NAME=Default <br>
> \# export OS_PROJECT_DOMAIN_NAME=Default <br>
> \# export OS_AUTH_URL=http://controller:35357/v3 <br>
> \# export OS_IDENTITY_API_VERSION=3

* Project, User, Role 생성 및 설정

> \# openstack project create --domain default --description "Service Project" service <br>
> \# openstack project create --domain default --description "Demo Project" demo <br>
> \# openstack user create --domain default --password-prompt demo <br>
> \# openstack role create user <br>
> \# openstack role add --project demo --user demo user

#### 3.2. 검증

* Controller Node에서 Keystone 동작 확인

> \# openstack --os-auth-url http://controller:35357/v3 --os-project-domain-name Default --os-user-domain-name Default --os-project-name admin --os-username admin token issue

~~~
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

> \# openstack --os-auth-url http://controller:5000/v3 --os-project-domain-name Default --os-user-domain-name Default --os-project-name demo --os-username demo token issue

~~~
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

### 4. Glance 설치

#### 4.1. Controller Node

* Glance DB 초기화

> \# mysql -u root -p

> mysql> CREATE DATABASE glance; <br>
> mysql> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'root'; <br>
> mysql> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'root'; <br>
> mysql> exit;

* Glance User 생성 및 설정

> \# . /root/admin-openrc <br>
> \# openstack user create --domain default --password-prompt glance <br>
> \# openstack role add --project service --user glance admin <br>
> \# openstack service create --name glance --description "OpenStack Image" image <br>

* Glance Service API Endpoint 생성

> \# openstack endpoint create --region RegionOne image public http://controller:9292 <br>
> \# openstack endpoint create --region RegionOne image internal http://controller:9292 <br>
> \# openstack endpoint create --region RegionOne image admin http://controller:9292

* Glance Package 설치

> \# apt install glance

* /etc/glance/glance-api.conf에 다음의 내용을 추가

~~~
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
~~~

* /etc/glance/glance-registry.conf에 다음의 내용을 추가

~~~
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
~~~

* Glance 설정 및 시작

> \# su -s /bin/sh -c "glance-manage db_sync" glance <br>
> \# service glance-registry restart <br>
> \# service glance-api restart

#### 4.2. 검증

* Controller Node에서 Glance 동작 확인

> \# . /root/admin-openrc <br>
> \# wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img <br>
> \# openstack image create "cirros" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --public <br>
> \# openstack image list

~~~
+--------------------------------------+--------+--------+
| ID                                   | Name   | Status |
+--------------------------------------+--------+--------+
| 38047887-61a7-41ea-9b49-27987d5e8bb9 | cirros | active |
+--------------------------------------+--------+--------+
~~~

### 5. Nova 설치

#### 5.1. Controller Node

* Nova DB 초기화

> \# mysql -u root -p

> mysql> CREATE DATABASE nova_api; <br>
> mysql> CREATE DATABASE nova; <br>
> mysql> GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'root'; <br>
> mysql> GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'root'; <br>
> mysql> GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'root'; <br>
> mysql> GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'root'; <br>
> mysql> exit;

* Nova User 생성 및 설정

> \# . /root/admin-openrc <br>
> \# openstack user create --domain default --password-prompt nova <br>
> \# openstack role add --project service --user nova admin <br>
> \# openstack service create --name nova --description "OpenStack Compute" compute

* Nova Service API Endpoint 생성

> \# openstack endpoint create --region RegionOne compute public http://controller:8774/v2.1/%\(tenant_id\)s <br>
> \# openstack endpoint create --region RegionOne compute internal http://controller:8774/v2.1/%\(tenant_id\)s <br>
> \# openstack endpoint create --region RegionOne compute admin http://controller:8774/v2.1/%\(tenant_id\)s

* Nova Package 설치

> \# apt install nova-api nova-conductor nova-consoleauth nova-novncproxy nova-scheduler <br>
> \# mkdir /usr/lib/python2.7/dist-packages/keys

* /etc/nova/nova.conf에 다음의 내용을 추가

~~~
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
~~~

* Nova 설정 및 시작

> \# su -s /bin/sh -c "nova-manage api_db sync" nova <br>
> \# su -s /bin/sh -c "nova-manage db sync" nova <br>
> \# service nova-api restart <br>
> \# service nova-consoleauth restart <br>
> \# service nova-scheduler restart <br>
> \# service nova-conductor restart <br>
> \# service nova-novncproxy restart

#### 5.2. Compute Node

* Nova Package 설치

> \# apt install nova-compute

* /etc/nova/nova.conf에 다음의 내용을 추가

~~~
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
~~~

* 현재 VirtualBox의 VM은 CPU의 Intel의 VT-X같은 Virtualization Extension을 이용하지 못한다. 따라서 Compute Node는 KVM+QEMU 조합의 가상 머신을 이용하지 못하고 QEMU만을 이용하여 가상 머신을 구동한다.

* /etc/nova/nova-compute.conf을 다음과 같이 수정

~~~
[DEFAULT]
compute_driver=libvirt.LibvirtDriver
[libvirt]
virt_type=qemu
~~~

* Nova 시작

> \# service nova-compute restart

#### 5.3. 검증

* Controller Node에서 Nova 동작 확인

> \# . /root/admin-openrc <br>
> \# openstack compute service list

### 6. Neutron 설치

#### 6.1. Controller Node

* Neutron DB 초기화

> \# mysql -u root -p
> mysql> CREATE DATABASE neutron; <br>
> mysql> GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'root'; <br>
> mysql> GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'root'; <br>
> mysql> exit;

* Neutron User 생성 및 설정

> \# . /root/admin-openrc <br>
> \# openstack user create --domain default --password-prompt neutron <br>
> \# openstack role add --project service --user neutron admin <br>
> \# openstack service create --name neutron --description "OpenStack Networking" network

* Neutron Service API Endpoint 생성

> \# openstack endpoint create --region RegionOne network public http://controller:9696 <br>
> \# openstack endpoint create --region RegionOne network internal http://controller:9696 <br>
> \# openstack endpoint create --region RegionOne network admin http://controller:9696

* Neutron Package 설치

> \# apt install neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent <br>

* /etc/neutron/neutron.conf에 다음의 내용을 추가

~~~
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
~~~

* /etc/neutron/plugins/ml2/ml2_conf.ini에 다음의 내용을 추가

~~~
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
~~~

* /etc/neutron/plugins/ml2/linuxbridge_agent.ini에 다음의 내용을 추가

~~~
[linux_bridge]
physical_interface_mappings = provider:enp0s8

[vxlan]
enable_vxlan = True
local_ip = 10.0.0.11
l2_population = True

[securitygroup]
enable_security_group = True
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
~~~

* /etc/neutron/l3_agent.ini에 다음의 내용을 추가

~~~
[DEFAULT]
interface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver
~~~

* /etc/neutron/dhcp_agent.ini에 다음의 내용을 추가

~~~
[DEFAULT]
interface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
enable_isolated_metadata = True
~~~

* /etc/neutron/metadata_agent.ini에 다음의 내용을 추가

~~~
[DEFAULT]
nova_metadata_ip = controller
metadata_proxy_shared_secret = root
~~~

* /etc/nova/nova.conf에 다음의 내용을 추가

~~~
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
~~~

* Neutron 시작

> \# su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron <br>
> \# service nova-api restart <br>
> \# service neutron-server restart <br>
> \# service neutron-linuxbridge-agent restart <br>
> \# service neutron-dhcp-agent restart <br>
> \# service neutron-metadata-agent restart <br>
> \# service neutron-l3-agent restart

#### 6.2. Compute Node

* Neutron Package 설치

> \# apt install neutron-linuxbridge-agent

* /etc/neutron/neutron.conf에 다음의 내용 추가

~~~
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
~~~

* /etc/neutron/plugins/ml2/linuxbridge_agent.ini에 다음의 내용을 추가

~~~
[linux_bridge]
physical_interface_mappings = provider:enp0s8

[vxlan]
enable_vxlan = True
local_ip = 10.0.0.31
l2_population = True

[securitygroup]
enable_security_group = True
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
~~~

* /etc/nova/nova.conf에 다음의 내용을 추가

~~~
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
~~~

* Neutron 시작

> \# service nova-compute restart <br>
> \# service neutron-linuxbridge-agent restart

#### 6.3. 검증

* Compute Node에서 Neutron 동작 확인

> \# . /root/admin-openrc <br>
> \# neutron ext-list

~~~
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

### 7. Horizon 설치

#### 7.1. Controller Node

* Horizon Package 설치

> \# apt install openstack-dashboard

* /etc/openstack-dashboard/local_settings.py에 다음과 같이 수정

~~~
OPENSTACK_HOST = "127.0.0.1"
OPENSTACK_KEYSTONE_URL = "http://%s:5000/v2.0" % OPENSTACK_HOST
OPENSTACK_KEYSTONE_DEFAULT_ROLE = "_member_"
-->
OPENSTACK_HOST = "controller"
OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST
OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"

ALLOWED_HOSTS = '*'
-->
ALLOWED_HOSTS = ['*', ]

CACHES = {
   'default': {
       'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': '127.0.0.1:11211',
    },
}
-->
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'

CACHES = {
    'default': {
         'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
         'LOCATION': 'controller:11211',
    }
}

TIME_ZONE = "UTC"
-->
TIME_ZONE = "Asia/Seoul"
~~~

* /etc/openstack-dashboard/local_settings.py에 다음의 내용 추가

~~~
OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True
OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "default"
OPENSTACK_API_VERSIONS = {
    "identity": 3,
    "image": 2,
    "volume": 2,
}
~~~

* Horizon 시작

> \# service apache2 reload

#### 7.2. 검증

* Web Brower를 통해 http://192.168.77.170/horizon/auth/login/ 접속
* Login - Domain : default, 사용자 이름 - admin, 암호 - root

### 8. Cinder 설치

### 9. 참조

* [https://docs.openstack.org/ocata/install-guide-ubuntu/](https://docs.openstack.org/ocata/install-guide-ubuntu/)
* [https://docs.openstack.org/newton/ko_KR/install-guide-ubuntu/](https://docs.openstack.org/newton/ko_KR/install-guide-ubuntu/)
