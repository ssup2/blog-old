---
title: CRUSH Controlled, Scalable, Decentralized Placement of Replicated Data
category: Paper, Patent
date: 2018-05-20T12:00:00Z
lastmod: 2018-05-20T12:00:00Z
comment: true
adsense: true
---

### 1. 요약

CEPH에서 Object(Data)를 Storage Device에 분산하는 알고리즘으로 이용하는 CRUSH를 설명하고 있다.

### 2. CRUSH

CRUSH는 Object들을 각 Storage Device의 Weight에 비례하여 각 Storage Device에 분배하는 알고리즘이다. 여기서 Ojbect의 분배의 의미는 Object의 Replica도 포함한다. 만약 CEPH가 3개의 Replica를 유지해야 한다면 CRUSH를 통해 Object가 저장될 3개의 Storage Device가 정해진다. CRUSH는 **Cluster Map**이라는 논리적인 Storage Device의 계층을 표현하는 지도를 바탕으로 Object를 분산한다.

#### 2.1. Cluster Map

Cluster Map은 논리적인 Storage Device의 **계층**을 표현하는 지도이다. Storage Server실이 있다면 Storage Server실에는 여러개의 Server 캐비넷이 있고, 각 Server 캐비넷에는 Disk 선반이 있고, 각 Disk 선반에는 Disk 선반에는 여러개의 Disk가 존재할 것이다. 이러한 물리적인 Storage Device의 구조를 논리적으로 표현한 것이 Cluster Map이다.

| Action | Resulting |
|---|---|
| take(root) | root |
| select(1, row) | row2 |
| select(3, cabinet) | cab21 cab23 cab24 |
| select(1, disk) | disk2107 disk2313 disk2437 |
| emit |  |

Cluster Map의 계층 정보를 바탕으로 CEPH 관리자는 Replica의 배치를 자유롭게 설정할 수 있다. Replica를 같은 Disk 선반에 위치 시킬 수도 있고, 다른 Disk 선반에 위치 시킬 수도 있고, 다른 Server 캐비넷에 위치 시킬 수도 있다. 이러한 Replica 배치 설정은 좀더 물리적으로 Replica를 안전하게 보관할 수 있게 한다. Replica를 같은 전원을 이용하는 Disk 선반에 위치시키는 것 보다는, 다른 전원을 이용하는 Server 캐비넷에 위치시키는 것이 좀더 안전하게 Replica를 보존 할 수 있을것이다. 위의 예제는 CRUSH이 Server 캐비넷 단위로 3개의 Replica를 선택하는 과정을 나타내고 있다.

Cluster Map은 **Bucket**과 **Device**로 구성된다. Bucket은 논리적인 그룹으로 위의 예제에서 Server 캐비넷, Disk 선반이 될 수 있다. Bucket은 하위 Bucket을 가지거나 하위 Device를 갖을 수 있다. Device는 실제 Disk를 의미하며 Disk는 Cluster Map의 Leaf에만 위치 할 수 있다. Bucket과 Device는 각각 Weight를 가질 수 있다. Bucket의 Weight는 하위 Bucket들이나 하위 Disk들의 Weight의 합이다.

각 Bucket에서 하위 Bucket이나 하위 Device를 선택하는 기준은 하위 Bucket이나 하위 Device이 갖고 있는 **Weight**와 하위 **Bucket Type**에 따라 달리진다.

#### 2.2. Bucket Type

Bucket Type에는 Uniform, List, Tree, Straw 4가지 Type이 존재한다.

* Uniform

* List

* Tree

* Straw

### 3. 참조

* [https://ceph.com/wp-content/uploads/2016/08/weil-crush-sc06.pdf](https://ceph.com/wp-content/uploads/2016/08/weil-crush-sc06.pdf)
* [http://docs.ceph.com/docs/jewel/rados/operations/crush-map/](http://docs.ceph.com/docs/jewel/rados/operations/crush-map/)