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

* Ubuntu Server 16.04.2 64bit (VM)
* OpenStack Newton Version
  * Controller Node - 1대
  * Compute Node - 1대
  * Block Storage Node - 1대
  * Network - Self-service

### 2. Node 설정

![]({{site.baseurl}}/images/record/OpenStack_Newton_Install/Node_Setting.PNG)

* Virtual Box를 이용하여 위의 그림과 같이 가상의 Controller, Compute, Storage Node를 생성한다.
* NAT - Virtual Box에서 제공하는 "NAT 네트워크" 이용한다.

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

### 3.1. Controller Node

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

* Keystone 동작 확인

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

> \# mysql> CREATE DATABASE glance; <br>
> \# mysql> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'root'; <br>
> \# mysql> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'root';

* Glance User 생성 및 설정

> \# . /root/admin-openrc <br>
> \# openstack user create --domain default --password-prompt glance <br>
> \# openstack role add --project service --user glance admin <br>
> \# openstack service create --name glance --description "OpenStack Image" image

* Glance Service API Endpoint 생성

> \# openstack endpoint create --region RegionOne image public http://controller:9292 <br>
> \# openstack endpoint create --region RegionOne image internal http://controller:9292 <br>
> \# openstack endpoint create --region RegionOne image admin http://controller:9292

* Glance Package 설치

> \# apt install glance

* /etc/glance/glance-api.conf에 다음의 내용을 추가한다.

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

* /etc/glance/glance-registry.conf에 다음의 내용을 추가한다.

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

* Glance 동작 확인

> \# . admin-openrc <br>
> \# wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img <br>
> \# openstack image create "cirros" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --public <br>
> \# openstack image list

~~~

~~~

### 5. Neutron 설치

### 6. Horizon 설치

### 7. Cinder 설치

### 8. 참조

* [https://docs.openstack.org/ocata/install-guide-ubuntu/](https://docs.openstack.org/ocata/install-guide-ubuntu/)
* [https://docs.openstack.org/newton/ko_KR/install-guide-ubuntu/](https://docs.openstack.org/newton/ko_KR/install-guide-ubuntu/)
