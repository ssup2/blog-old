---
title: HyperV NAT 설정 - Windows 10
category:
date: 2019-03-14T12:00:00Z
lastmod: 2019-03-15T12:00:00Z
comment: true
adsense: true
---

New-VMSwitch -SwitchName "NAT" -SwitchType Internal
New-NetIPAddress -IPAddress 172.34.0.1 -PrefixLength 24 -InterfaceIndex 67
New-NetNat -Name MyNATnetwork -InternalIPInterfaceAddressPrefix 172.34.0.0/24