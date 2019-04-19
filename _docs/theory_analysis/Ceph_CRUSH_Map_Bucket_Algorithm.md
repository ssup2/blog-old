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

![[그림 2] Ceph CRUSH Map]({{site.baseurl}}/images/theory_analysis/Ceph_CRUSH_Map_Bucket_Type/Ceph_CRUSH_Map.PNG){: width="700px"}

CRUSH는 **CRUSH Map**이라고 불리는 Storage Topology를 이용한다. [그림 2]은 CRUSH Map을 나타내고 있다. CRUSH Map은 **Bucket**이라는 논리적 단위의 계층으로 구성된다. Bucket은 root, region, datacentor, room, pod, pdu, row, rack, chassis, host, osd 11가지 type으로 구성되어 있다. CRUSH Map의 Leaf는 반드시 osd bucket이어야 한다.

각 Bucket은 **Weight**값을 가지고 있는데 Weight는 각 Bucket이 갖고있는 Object의 비율을 나타낸다. 만약 Bucket A의 Weight가 100이고 Bucket B의 Weight가 200이라면 Bucket B가 Bucket A보다 2배많은 Object를 갖는다는걸 의미한다. 따라서 일반적으로 osd Bucket Type의 Weight값은 OSD가 관리하는 Disk의 용량에 비례하여 설정한다. 나머지 Bucket Type의 weight는 모든 하위 Bucket의 Weight의 합이다. [그림 2]의 Bucket안에 있는 숫자는 Weight를 나타내고 있다.

CRUSH는 CRUSH Map의 root Bucket부터 시작하여 하위 Bucket을 Replica 개수 만큼 선택하고, 선택한 Bucket에서 동일한 작업을 반복하여 Leaf에 있는 osd Bucket을 찾는 알고리즘이다. 따라서 Object의 Replica 개수, 위치는 CRUSH Map과 Bucket Type에 설정된 Replica에 따라 정해진다. Rack Bucket Type에는 3개의 Replica를 설정하고 Row Bucket Type에는 2개의 Replica를 설정하였다면, CRUSH는 3개의 Rack Bucket을 선택하고 선택한 Rack Bucket의 하위 Bucket인 Row Bucket을 각 Rack Bucket당 2개씩 선택하기 때문에 Object의 Replica는 6이 된다.

### 2. Bucket 알고리즘

| | Uniform | List | Tree | Straw | Straw2 |
|----|----|----|----|----|----|
| Object 할당 | O(1) | O(n) | O(log n) | O (n) | O (n) |
| 하위 Bucket 추가 | Poor | Optimal | Good | Optimal | Optimal |
| 하위 Bucket 삭제 | Poor | Poor | Good | Optimal | Optimal |

<figure>
<figcaption class="caption">[표 1] Bucket 알고리즘 성능 비교</figcaption>
</figure>

Bucket은 자신의 하위 Bucket을 선택하는 Bucket 알고리즘을 선택할 수 있다. 알고리즘에는 Uniform, List, Tree, Straw, Straw2가 있으며 각 알고리즘은 장단점을 갖고 있다. 기본 알고리즘은 Straw2를 이용한다. [표 1]은 각 알고리즘의 성능을 서로 비교하여 나타내고 있다.

#### 2.1. Uniform

{% highlight cpp %}
uniform(bucket, pg_id, replica) {
    cbucket = bucket->cbuckets[hash(PG_ID, replica) % length(bucket->cbuckets)];
    return cbucket;
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] uniform() 함수</figcaption>
</figure>

* bucket - 상위 Bucket을 나타낸다.
* cbucket - Hashing을 통해서 선택된 하위 Bucket을 나타낸다.
* pg_id - 배치할 Object를 갖고있는 PG의 ID를 나타낸다.
* replica - Replica를 나타낸다. 0은 Primary Replica를 나타낸다.

Uniform 알고리즘은 하위 Bucket을 **Consistency Hashing**을 이용하여 선택한다. [Code 1]은 Uniform 알고리즘을 이용하여 하위 Bucket을 선택하는 uniform() 함수를 간략하게 나타내고 있다. 한번만 Hashing을 수행하면 되기 때문에 O(1) 시간에 하위 Bucket을 찾을 수 있다. 하지만 하위 Bucket이 추가되거나 제거될 경우 Consistency Hashing을 이용하더라도 많은 수의 PG들이 다른 Bucket에 배치되기 때문에, 많은 수의 Object들이 Rebalancing 된다. Uniform 알고리즘은 모든 하위 Bucket이 동일한 Weight를 갖는다. 즉 Uniform 알고리즘은 각 하위 Bucket마다 다른 Weight를 적용할 수 없다. Weight 값을 설정하더라도 무시된다. 각 하위 Bucket마다 다른 Weight를 적용하고 싶으면 다른 Bucket 알고리즘을 이용해야 한다.

#### 2.2. List

![[그림 3] List 알고리즘에 이용되는 Weight Linked List]({{site.baseurl}}/images/theory_analysis/Ceph_CRUSH_Map_Bucket_Type/CRUSH_List_Bucket.PNG){: width="600px"}

{% highlight cpp %}
init_sum_weights(cbucket_weights, sum_weights) {
    sum_weights[0] = cbucket_weights[0];

    for (i = 1; i < length(cbucket_weights); i++) {
        sum_weights[i] = sum_weights[i - i] + cbucket_weights[i];
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] init_sum_weights() 함수</figcaption>
</figure>

* cbucket_weights - CRUSH Map에 설정된 하위 Bucket의 Weight 값들을 나타낸다.
* sum_weights - List 알고리즘에 따라서 cbucket_weights의 합들을 나타낸다.

List 알고리즘은 하위 Bucket들을 **Linked-list**를 이용하여 관리한다. Link 알고리즘을 수행하기 위해서는 CRUSH Map에 있는 하위 Bucket의 Weight 정보를 바탕으로 [그림 3]과 같은 Linked List를 준비해 두어야한다. [Code 2]는 [그림 3]의 sum_weights Linked-list를 초기화하는 init_cbucket_weights() 함수를 간략하게 나타내고 있다.

{% highlight cpp %}
list(bucket, pg_id, replica) {
    for (i = length(bucket->cbuckets) - 1; i >= 0; i--) {
        tmp = hash(pg_id, bucket->cbuckets[i]->id, replica)
        if ( tmp < (cbucket_weights[i] / sum_weigths[i]) ) {
            cbucket = bucket->cbuckets[i];
            return cbucket;
        }
    }

    cbucket = bucket->cbuckets[0];
    return cbucket;
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] list() 함수</figcaption>
</figure>

* bucket - 상위 Bucket의 구조체를 나타낸다.
* cbucket - Hashing을 통해서 선택된 하위 Bucket의 구조체를 나타낸다.
* pg_id - 배치할 Object를 갖고있는 PG의 ID를 나타낸다.
* replica - Replica를 나타낸다. Primary Replica일 경우 0을 넣는다.

[Code 3]은 초기화된 cbucket_weights Linked-list와 sum_weigths Linked-list를 이용하여 Link 알고리즘의 수행하는 list() 함수를 나타내고 있다. list() 함수는 Linked-list의 마지막부터 처음으로 이동하면서 하위 Bucket의 Weight에 비례하여 Object를 할당한다. Hashing을 Linked-list만큼 수행해야하기 때문에 하위 Bucket을 찾는데 O(N) 시간이 걸린다.

![[그림 4] List에 하위 Bucket이 추가되는 경우]({{site.baseurl}}/images/theory_analysis/Ceph_CRUSH_Map_Bucket_Type/CRUSH_List_Bucket_Add.PNG){: width="650px"}

[그림 4]는 Linked-list에 하위 Bucket이 추가되는 경우를 나타내고 있다. 추가된 Bucket은 Linked-list의 마지막에 붙어 Link 알고리즘 수행시 가장 먼져 배치여부를 조사하는 Bucket이 된다. PG가 추가된 Bucket에 배치되는경우 해당 PG에 소속되어 있던 Object들은 Rebalancing 된다. **하지만 PG가 추가된 Bucket에 배치되지 않을경우 PG는 반드시 기존의 Bucket에 배치된다.** Bucket이 추가되어도 기존의 sum_weigths 값은 변하지 않기 때문이다. 따라서 Linked 알고리즘은 하위 Bucket이 추가되어도 Object Rebalancing을 최소화 할 수 있다.

![[그림 5] List에 하위 Bucket이 제거되는 경우]({{site.baseurl}}/images/theory_analysis/Ceph_CRUSH_Map_Bucket_Type/CRUSH_List_Bucket_Remove.PNG){: width="600px"}

[그림 5]는 Linked-list에 하위 Bucket이 제거되는 경우를 나타내고 있다. [그림 5]에서는 1번 하위 Bucket이 제거 될때를 나타내고 있다. Bucket이 제거되면 기존의 sum_weigths 값도 바뀌게되어 많은 수의 PG들이 다른 Bucket에 배치되기 때문에, 많은 수의 Object들이 Rebalancing 된다.

#### 2.3. Tree

#### 2.4. Straw

#### 2.5. Straw2

### 3. 참조

* [http://www.nminoru.jp/~nminoru/unix/ceph/rados-overview.html#mapping](http://www.nminoru.jp/~nminoru/unix/ceph/rados-overview.html#mapping)