---
title: Hyper-V NAT 설정 - Windows 10
category: Record
date: 2019-03-14T12:00:00Z
lastmod: 2019-03-15T12:00:00Z
comment: true
adsense: true
---

### 1. 설정 환경

* NAT Network
  * Network - 172.34.0.0/24
  * Gateway - 172.34.0.1
  * Switch Name - NAT-Switch
  * Network Name - NAT-Network
* VM
  * Address - 172.34.0.100

### 2. Switch 생성 및 NAT 설정

* Powershell 관리자 권한에서 아래의 명령어 수행한다.

~~~
> New-VMSwitch -SwitchName "NAT-Swtich" -SwitchType Internal
> $AdapterName=(Get-NetAdapter -Name "vEthernet (NAT-Swtich)").Name
> New-NetIPAddress -IPAddress 172.34.0.1 -PrefixLength 24 -InterfaceAlias $AdapterName
> New-NetNat -Name NAT-Network -InternalIPInterfaceAddressPrefix 172.34.0.0/24
~~~

### 3. VM

* NAT로 구성한 Network 안에는 DHCP Server가 없기 때문에 수동으로 IP 설정이 필요하다.
  * /etc/netplan/50-cloud-init.yaml 파일에 아래와 같이 설정한다.

{% highlight yaml %}
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        eth0:
            addresses:
            - 172.34.0.100/24
            dhcp4: false
            gateway4: 172.34.0.1
            nameservers:
                addresses:
                - 8.8.8.8
                search: []
    version: 2
{% endhighlight %}

* 변경된 Network를 적용한다.

~~~
# netplan apply
~~~

### 4. 참조
* [https://deploywindows.com/2017/06/01/missing-nat-in-windows-10-hyper-v/](https://deploywindows.com/2017/06/01/missing-nat-in-windows-10-hyper-v/)