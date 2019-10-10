---
title: ip
category: Command, Tool
date: 2019-10-10T12:00:00Z
lastmod: 2019-10-10T12:00:00Z
comment: true
adsense: true
---

Linux에서 Network를 제어하고 조회하는 ip의 사용법을 정리한다.

***

* TOC
{:toc}

***

### 1. ip

#### 1.1. Address (L2, L3)

* ip addr : 모든 Interface의 Address 정보를 출력한다.
* ip addr show [Interface] : [Interface] 이름을 갖는 Interface의 Address 정보를 출력한다.
* ip addr add [IP/CIDR] dev [Interface] : [Interface] 이름을 갖는 Interface에 IP/CIDR 설정을 추가한다.
* ip addr del [IP/CIDR] dev [Interface] : [Interface] 이름을 갖는 Interface에 설정된 IP/CIDR를 삭제한다.

#### 1.2. Link (L2)

* ip link : 모든 Interface의 Link 정보를 출력한다.
* ip link show (dev) [Interface] : [Interface] 이름을 갖는 Interface의 Link 정보를 출력한다.
* ip link set (dev) [Interface] up : [Interface] 이름을 갖는 Interface를 Online 상태로 변경한다.
* ip link set (dev) [Interface] down : [Interface] 이름을 갖는 Interface를 Offline 상태로 변경한다.

#### 1.3. Route

* ip route : Routing Table 정보를 출력한다.
* ip route add default via [IP] dev [Interface] : Local Default Gateway의 IP 주소를 [IP]로 설정하고 Interface는 [Interface]를 이용하도록 설정한다.

#### 1.4. Neighbour (ARP)

* ip neigh : Host와 동일 Network에 있는 외부 Host의 Interface 정보를 출력한다.
* ip neigh show dev [Interface] : Host와 [Interface]를 통해서 연결된 Network에 있는 외부 Host의 Interface 정보를 출력한다.

### 2. 참조

* [https://access.redhat.com/sites/default/files/attachments/rh_ip_command_cheatsheet_1214_jcs_print.pdf](https://access.redhat.com/sites/default/files/attachments/rh_ip_command_cheatsheet_1214_jcs_print.pdf)