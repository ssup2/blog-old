---
title: OpenStack Terraform 실습 / Kubernetes 환경 구축
category: Record
date: 2019-07-30T12:00:00Z
lastmod: 2019-07-30T12:00:00Z
comment: true
adsense: true
---

### 1. 실습, 구축 환경

![[그림 1] OpenStack Terraform 실습, 구축 환경]({{site.baseurl}}/images/record/OpenStack_Terraform_Practice_Kubernetes/Environment.PNG)

[그림 1]은 Terraform을 이용하여 OpenStack 위에 구축하려는 Kubernetes 환경을 나타내고 있다. External Network, externel-router, Ubuntu 18.04 Image는 미리 생성되어 있는 환경에서 진행하였다.

* Terraform : 0.12.5
* Node : Ubuntu 18.04
* OpenStack : Stein
  * User, Tenant, Password : admin
  * Auth URL : 
* Network :
  * Internal Network : Kubernetes Network, 30.0.0.0/24
* Flavor :
  * Standard : 4vCPU, 4GB RAM, 30GB Disk

### 2. Terraform 설치

~~~
(Deploy)# apt-get update
(Deploy)# apt-get install wget unzip
(Deploy)# wget https://releases.hashicorp.com/terraform/0.12.5/terraform_0.12.5_linux_amd64.zip
(Deploy)# unzip ./terraform_0.12.5_linux_amd64.zip -d /usr/local/bin/
~~~

Terraform을 설치한다.

### 3. Terraform 설정

{% highlight tf linenos %}
provider "openstack" {
  user_name = "admin"
  tenant_name = "admin"
  password  = "admin"
  auth_url  = "http://192.168.0.40:5000/v3"
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] ~/terraform/provider.tf</figcaption>
</figure>

{% highlight tf linenos %}
variable "router-external" {
  default = "[external-router ID]"
}

variable "secgroup-default" {
  default = "[default Security Group ID]"
}

variable "image-ubuntu" {
  default = "[ubuntu-18.04 Image ID]"
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] ~/terraform/00-params.tf</figcaption>
</figure>

{% highlight tf linenos %}
resource "openstack_compute_flavor_v2" "flavor" {
  name  = "m1.standard"
  ram   = "4096"
  vcpus = "4"
  disk  = "30"
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 3] ~/terraform/010-flavor.tf</figcaption>
</figure>

{% highlight tf linenos %}
resource "openstack_networking_network_v2" "network" {
  name = "internal-net"
}

resource "openstack_networking_subnet_v2" "subnet" {
  name = "internal-sub"
  network_id = "${openstack_networking_network_v2.network.id}"
  cidr = "30.0.0.0/24"
  dns_nameservers = ["8.8.8.8"]
}

resource "openstack_networking_router_interface_v2" "interface" {
  router_id = "${var.router-external}"
  subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 4] ~/terraform/020-network.tf</figcaption>
</figure>

{% highlight tf linenos %}
resource "openstack_networking_secgroup_rule_v2" "secgroup_tcp" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 1
  port_range_max = 65535
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${var.secgroup-default}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_udp" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "upd"
  port_range_min = 1
  port_range_max = 65535
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${var.secgroup-default}"
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 5] ~/terraform/030-secgroup.tf</figcaption>
</figure>

{% highlight tf linenos %}
resource "openstack_networking_floatingip_v2" "fip" {
  pool = "external-net"
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 6] ~/terraform/040-floating.tf</figcaption>
</figure>

{% highlight tf linenos %}
resource "openstack_compute_instance_v2" "vm01" {
  name  = "vm01"
  flavor_id = "${openstack_compute_flavor_v2.flavor.id}"

  network {
    name = "${openstack_networking_network_v2.network.name}"
  }

  block_device {
    uuid                  = "${var.image-ubuntu}"
    source_type           = "image"
    volume_size           = 30
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
}

resource "openstack_compute_instance_v2" "vm02" {
  name  = "vm02"
  flavor_id = "${openstack_compute_flavor_v2.flavor.id}"

  network {
    name = "${openstack_networking_network_v2.network.name}"
  }

  block_device {
    uuid                  = "${var.image-ubuntu}"
    source_type           = "image"
    volume_size           = 30
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
}

resource "openstack_compute_instance_v2" "vm03" {
  name  = "vm03"
  flavor_id = "${openstack_compute_flavor_v2.flavor.id}"

  network {
    name = "${openstack_networking_network_v2.network.name}"
  }

  block_device {
    uuid                  = "${var.image-ubuntu}"
    source_type           = "image"
    volume_size           = 30
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
}

resource "openstack_compute_instance_v2" "vm09" {
  name  = "vm09"
  flavor_id = "${openstack_compute_flavor_v2.flavor.id}"

  network {
    name = "${openstack_networking_network_v2.network.name}"
  }

  block_device {
    uuid                  = "${var.image-ubuntu}"
    source_type           = "image"
    volume_size           = 30
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
}

resource "openstack_compute_floatingip_associate_v2" "fip" {
  floating_ip = "${openstack_networking_floatingip_v2.fip.address}"
  instance_id = "${openstack_compute_instance_v2.vm09.id}"
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 7] ~/terraform/050-instance.tf</figcaption>
</figure>

[파일 1 ~ 7]을 작성한다. [파일 1,2]는 OpenStack 환경에 맞게 변경해야한다.

### 4. Terraform 적용, 초기화

~~~
(Deploy)# cd ~/terraform
(Deploy)# terraform init
(Deploy)# terraform apply
~~~

Terraform을 적용한다.

~~~
(Deploy)# cd ~/terraform
(Deploy)# terraform destroy
~~~

Terraform을 초기화 한다.

### 5. 참조

* [https://github.com/diodonfrost/terraform-openstack-examples](https://github.com/diodonfrost/terraform-openstack-examples)
* [https://github.com/ssup2/example-openstack-terraform-k8s](https://github.com/ssup2/example-openstack-terraform-k8s)