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

Cluster Map은 **Bucket**과 **Device**로 구성된다. Bucket은 논리적인 그룹으로 위의 예제에서 Server 캐비넷, Disk 선반이 될 수 있다. Bucket은 하위 Bucket을 가지거나 하위 Device를 갖을 수 있다. Device는 실제 Disk를 의미하며 Disk는 Cluster Map의 Leaf에만 위치 할 수 있다. Bucket과 Device는 각각 **Weight**를 가질 수 있다. Bucket의 Weight는 하위 Bucket들이나 하위 Disk들의 Weight의 합이다. 일반적으로 하위 Device의 용량에 비례하여 Weight를 설정한다. 따라서 Bucket의 Weight값은 Bucket에 속한 Disk 용량에 비례하게 된다.

각 Bucket에서 하위 Bucket이나 하위 Device를 선택하는 기준은 하위 Bucket이나 하위 Device이 갖고 있는 **Weight**와 하위 **Bucket Type**에 따라 달리진다.

#### 2.2. Bucket Type

Bucket Type은 Item(하위 Bucket, 하위 Device)을 관리하는 방식을 의미한다. Bucket Type에는 Uniform, List, Tree, Straw 4가지 Type이 존재한다.

##### 2.2.1. Uniform

Uniform Bucket은 하위 Item들을 **Consistency Hashing**을 이용하여 관리한다. Hashing 기반이기 때문에 O(1) 시간에 하위 Item을 찾을 수 있다. 하지만 Item이 추가되거나 제거될 경우 Hashing 결과가 달라지기 때문에 Rebalancing에 많은 시간이 소요된다. Uniform Bucket은 모든 Bucket의 Weight가 동일하다는 가정에 진행된다. Bucket 마다 다른 Weight를 주고 싶으면 다른 Bucket Type을 이용해야 한다.

##### 2.2.2. List

List Bucket은 하위 Item들을 **Linked List**를 이용하여 관리한다. 하위 Item을 찾는 경우 Linked List를 순회 해야하기 때문에 O(n) 시간이 걸린다. 따라서 하위 Item의 개수가 많아질 경우 탐색시간이 느린 단점을 갖고 있다. 순회는 Linked List의 앞에부터 시작한다. 선택된 Item의 Weight와 선택된 Item의 뒤에 있는 모든 Weight의 합을 기반으로 선택된 Item을 이용할지 결정한다. 만약 선택한 Item을 이용하지 않으면 다음 Linked List의 다음 Item을 선택하고 동일한 알고리즘을 반복한다.

Linked List에 Item이 추가되는 경우 Linked List의 가장 앞에 추가된다. Item이 추가되는 경우, 기존 Item들의 하위 Item 중 일부만 추가된 Item의 하위 Item으로 옮기기만 하면 되기 때문에 비교적 빠른 Rebalancing이 가능하다. 하지만 Linked List의 중간이나 마지막 Item 제거 또는 Item의 Weight 변경이 발생하는 경우 하위 Item들을 전반적으로 옮겨야 하기 때문에 Rebalancing에 많은 시간이 소요된다.

##### 2.2.3. Tree

Tree Bucket은 하위 Item을 **Weighted Binary Search Tree**를 이용한다. Tree의 끝에 하위 Item들이 달려있다. Tree 기반이기 때문에 하위 Item 탐색에 O(log n) 시간이 걸린다. Tree의 Left/Right Weight는 Left/Write Subtree에 속한 모든 Item들의 Weight의 합과 동일하다.

Tree에 Item 추가,제거 또는 Item의 Weight 변경이 발생하는 경우 Weighted Binary Search Tree의 일부 Weight에만 영향을 주기 때문에 일부 Item의 하위 Item들만 Rebalancing에 참여해도 된다. 따라서 비교적 빠른 Rebalancing이 가능하다.

##### 2.2.4. Straw

Straw Bucket은 하위 Item별로 Straw를 뽑아 **Straw의 길이가 가장 긴 Item을 선택**하는 방식이다. Straw의 길이는 **각 Item의 Weight에 영향을 받는 Hashing**을 이용한다. Item의 Weight가 클수록 긴 길이의 Straw를 할당 받을 확률이 높아진다. 모든 하위 Item을 대상으로 Hashing을 수행해야 하기 때문에 하위 Item 선택에 O(n)의 시간이 걸린다.

Straw에 Item 추가,제거 또는 Item의 Weight가 변경되더라도 각 Item별로 수행한 Hashing을 이용하는 방식이기 때문에 영향받은 Item에 속한 하위 Item들만 Rebalancing을 수행하면 된다. 따라서 빠른 Rebalancing이 가능하다.

### 3. 참조

* [https://ceph.com/wp-content/uploads/2016/08/weil-crush-sc06.pdf](https://ceph.com/wp-content/uploads/2016/08/weil-crush-sc06.pdf)
* [http://docs.ceph.com/docs/jewel/rados/operations/crush-map/](http://docs.ceph.com/docs/jewel/rados/operations/crush-map/)
* [http://www.lamsade.dauphine.fr/~litwin/cours98/Doc-cours-clouds/ceph-2009-02%5B1%5D.pdf](http://www.lamsade.dauphine.fr/~litwin/cours98/Doc-cours-clouds/ceph-2009-02%5B1%5D.pdf)