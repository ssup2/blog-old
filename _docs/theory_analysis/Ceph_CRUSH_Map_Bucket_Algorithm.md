---
title: Ceph CRUSH Map, Bucket 알고리즘
category: Theory, Analysis
date: 2018-05-14T12:00:00Z
lastmod: 2018-05-15T12:00:00Z
comment: true
adsense: true
---

Ceph에서 Storage Topology를 나타내는 CRUSH Map을 분석하고 CRUSH Map을 구성하는 요소인 Bucket이 하위 Bucket을 선택할때 이용하는 Bucket 알고리즘을 분석한다.

### 1. Ceph CRUSH Map

![[그림 1] Ceph PG, CRUSH]({{site.baseurl}}/images/theory_analysis/Ceph_CRUSH_Map_Bucket_Type/Ceph_PG_CRUSH.PNG){: width="600px"}

Ceph는 RADOS Cluster의 OSD (Object Storage Daemon)에 Object를 배치하는 알고리즘으로 **CRUSH**를 이용한다. [그림 1]은 CRUSH를 통해서 Object가 OSD에 배치되는 과정을 나타내고 있다. Object는 Object ID의 Hashing을 통해 특정 PG (Placement Group)에 할당된다. 그리고 PG는 다시 PG ID와 CRUSH를 통해서 특정 OSD에 할당된다. [그림 1]은 Replica가 3으로 설정되어 있다고 가정하고 있다. 따라서 CRUSH는 Object 하나당 3개의 OSD를 할당한다.

![[그림 2] Ceph CRUSH Map]({{site.baseurl}}/images/theory_analysis/Ceph_CRUSH_Map_Bucket_Type/Ceph_CRUSH_Map.PNG){: width="600px"}

CRUSH는 **CRUSH Map**이라고 불리는 Storage Topology를 이용한다. [그림 2]은 CRUSH Map을 나타내고 있다. CRUSH Map은 **Bucket**이라는 논리적 단위의 계층으로 구성된다. Bucket은 root, region, datacentor, room, pod, pdu, row, rack, chassis, host, osd 11가지 type으로 구성되어 있다. CRUSH Map의 Leaf는 반드시 osd bucket이어야 한다.

각 Bucket은 **Weight**값을 가지고 있는데 Weight는 각 Bucket이 갖고있는 Object의 비율을 나타낸다. 만약 Bucket A의 Weight가 100이고 Bucket B의 Weight가 200이라면 Bucket B가 Bucket A보다 2배많은 Object를 갖는다는걸 의미한다. 따라서 일반적으로 osd Bucket Type의 Weight값은 OSD가 관리하는 Disk의 용량에 비례하여 설정한다. 나머지 Bucket Type의 weight는 모든 하위 Bucket의 Weight의 합이다.

CRUSH는 CRUSH Map의 root Bucket부터 시작하여 하위 Bucket을 Replica 개수 만큼 선택하고, 선택한 Bucket에서 동일한 작업을 반복하여 Leaf에 있는 osd Bucket을 찾는 알고리즘이다. 따라서 Object의 Replica 개수, 위치는 CRUSH Map에 따라 정해진다. Rack Bucket에 3개의 Replica를 설정해 놓으면 3개의 Replica는 CRUSH에 의해 선택된 3개의 Rack에 하나씩 존재하게 된다.

### 2. Bucket 알고리즘

Bucket은 자신의 하위 Bucket을 선택하는 다양한 알고리즘을 제공한다. 각 알고리즘은 장단점을 갖고 있으며 알고리즘에는 Uniform, List, Tree, Straw가 있다.

#### 2.1. Uniform

Uniform 알고리즘은 하위 Bucket들을 **Consistency Hashing**을 이용하여 관리한다. Hashing 기반이기 때문에 O(1) 시간에 하위 Bucket을 찾을 수 있다. 하지만 Bucket이 추가되거나 제거될 경우 Hashing 결과가 달라지기 때문에 Rebalancing에 많은 시간이 소요된다. Uniform Bucket은 모든 Bucket의 Weight가 동일하다는 가정에 진행된다. Bucket 마다 다른 Weight를 주고 싶으면 다른 Bucket Type을 이용해야 한다.

#### 2.2. List

List 알고리즘은 하위 Bucket들을 **Linked List**를 이용하여 관리한다. 하위 Bucket을 찾는 경우 Linked List를 순회 해야하기 때문에 O(n) 시간이 걸린다. 따라서 하위 Bucket의 개수가 많아질 경우 탐색시간이 느린 단점을 갖고 있다. Linked List에 Bucket이 추가되는 경우 Linked List의 가장 앞에 추가된다. Bucket이 추가되는 경우, 기존 Bucket들의 하위 Bucket 중 일부만 추가된 Bucket의 하위 Bucket으로 옮기기만 하면 되기 때문에 비교적 빠른 Rebalancing이 가능하다. 하지만 Linked List의 중간이나 마지막 Bucket 제거 또는 Bucket의 Weight 변경이 발생하는 경우 하위 Bucket들을 전반적으로 옮겨야 하기 때문에 Rebalancing에 많은 시간이 소요된다.

#### 2.3. Tree

Tree 알고리즘은 하위 Bucket을 **Weighted Binary Search Tree**를 이용한다. Tree의 끝에 하위 Bucket들이 달려있다. Tree 기반이기 때문에 하위 Bucket 탐색에 O(log n) 시간이 걸린다. Tree의 Left/Right Weight는 Left/Write Subtree에 속한 모든 Bucket들의 Weight의 합과 동일하다. Tree에 Bucket 추가,제거 또는 Bucket의 Weight 변경이 발생하는 경우 Weighted Binary Search Tree의 일부 Weight에만 영향을 주기 때문에 일부 Bucket의 하위 Bucket들만 Rebalancing에 참여해도 된다. 따라서 비교적 빠른 Rebalancing이 가능하다.

#### 2.4. Straw

알고리즘 Straw Bucket은 하위 Bucket별로 Straw를 뽑아 **Straw의 길이가 가장 긴 Bucket을 선택**하는 방식이다. Straw의 길이는 **각 Bucket의 Weight에 영향을 받는 Hashing**을 이용한다. Bucket의 Weight가 클수록 긴 길이의 Straw를 할당 받을 확률이 높아진다. 모든 하위 Bucket을 대상으로 Hashing을 수행해야 하기 때문에 하위 Bucket 선택에 O(n)의 시간이 걸린다. Straw에 Bucket 추가,제거 또는 Bucket의 Weight가 변경되더라도 각 Bucket별로 수행한 Hashing을 이용하는 방식이기 때문에 영향받은 Bucket에 속한 하위 Bucket들만 Rebalancing을 수행하면 된다. 따라서 빠른 Rebalancing이 가능하다.

### 3. 참조

* [http://www.nminoru.jp/~nminoru/unix/ceph/rados-overview.html#mapping](http://www.nminoru.jp/~nminoru/unix/ceph/rados-overview.html#mapping)