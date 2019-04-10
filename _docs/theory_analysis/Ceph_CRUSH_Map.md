---
title: Ceph CRUSH Map
category: 
date: 2018-05-14T12:00:00Z
lastmod: 2018-05-15T12:00:00Z
comment: true
adsense: true
---

### 1. Ceph CRUSH Map

#### 1.1. Uniform

Uniform 알고리즘은 하위 Bucket들을 **Consistency Hashing**을 이용하여 관리한다. Hashing 기반이기 때문에 O(1) 시간에 하위 Bucket을 찾을 수 있다. 하지만 Bucket이 추가되거나 제거될 경우 Hashing 결과가 달라지기 때문에 Rebalancing에 많은 시간이 소요된다. Uniform Bucket은 모든 Bucket의 Weight가 동일하다는 가정에 진행된다. Bucket 마다 다른 Weight를 주고 싶으면 다른 Bucket Type을 이용해야 한다.

#### 1.2. List

List 알고리즘은 하위 Bucket들을 **Linked List**를 이용하여 관리한다. 하위 Bucket을 찾는 경우 Linked List를 순회 해야하기 때문에 O(n) 시간이 걸린다. 따라서 하위 Bucket의 개수가 많아질 경우 탐색시간이 느린 단점을 갖고 있다.

Linked List에 Bucket이 추가되는 경우 Linked List의 가장 앞에 추가된다. Bucket이 추가되는 경우, 기존 Bucket들의 하위 Bucket 중 일부만 추가된 Bucket의 하위 Bucket으로 옮기기만 하면 되기 때문에 비교적 빠른 Rebalancing이 가능하다. 하지만 Linked List의 중간이나 마지막 Bucket 제거 또는 Bucket의 Weight 변경이 발생하는 경우 하위 Bucket들을 전반적으로 옮겨야 하기 때문에 Rebalancing에 많은 시간이 소요된다.

#### 1.3. Tree

Tree 알고리즘은 하위 Bucket을 **Weighted Binary Search Tree**를 이용한다. Tree의 끝에 하위 Bucket들이 달려있다. Tree 기반이기 때문에 하위 Bucket 탐색에 O(log n) 시간이 걸린다. Tree의 Left/Right Weight는 Left/Write Subtree에 속한 모든 Bucket들의 Weight의 합과 동일하다.

Tree에 Bucket 추가,제거 또는 Bucket의 Weight 변경이 발생하는 경우 Weighted Binary Search Tree의 일부 Weight에만 영향을 주기 때문에 일부 Bucket의 하위 Bucket들만 Rebalancing에 참여해도 된다. 따라서 비교적 빠른 Rebalancing이 가능하다.

#### 1.4. Straw

알고리즘 Straw Bucket은 하위 Bucket별로 Straw를 뽑아 **Straw의 길이가 가장 긴 Bucket을 선택**하는 방식이다. Straw의 길이는 **각 Bucket의 Weight에 영향을 받는 Hashing**을 이용한다. Bucket의 Weight가 클수록 긴 길이의 Straw를 할당 받을 확률이 높아진다. 모든 하위 Bucket을 대상으로 Hashing을 수행해야 하기 때문에 하위 Bucket 선택에 O(n)의 시간이 걸린다.

Straw에 Bucket 추가,제거 또는 Bucket의 Weight가 변경되더라도 각 Bucket별로 수행한 Hashing을 이용하는 방식이기 때문에 영향받은 Bucket에 속한 하위 Bucket들만 Rebalancing을 수행하면 된다. 따라서 빠른 Rebalancing이 가능하다.

### 2. 참조

* [http://www.nminoru.jp/~nminoru/unix/ceph/rados-overview.html#mapping](http://www.nminoru.jp/~nminoru/unix/ceph/rados-overview.html#mapping)