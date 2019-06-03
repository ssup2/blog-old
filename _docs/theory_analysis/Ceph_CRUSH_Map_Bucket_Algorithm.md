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

CRUSH는 CRUSH Map의 root Bucket부터 시작하여 하위 Bucket을 Replica 개수 만큼 선택하고, 선택한 Bucket에서 동일한 작업을 반복하여 Leaf에 있는 osd Bucket을 찾는다. Object의 Replica 개수는 Bucket Type에 설정한 Replica에 따라 정해진다. Rack Bucket Type에는 3개의 Replica를 설정하고 Row Bucket Type에는 2개의 Replica를 설정하였다면, CRUSH는 3개의 Rack Bucket을 선택하고 선택한 Rack Bucket의 하위 Bucket인 Row Bucket을 각 Rack Bucket당 2개씩 선택하기 때문에 Object의 Replica는 6이 된다. 하위 Bucket을 선택하는 기준은 각 Bucket Type에 설정한 Bucket 알고리즘에 따라 결정된다.  

### 2. Bucket 알고리즘

| | Uniform | List | Tree | Straw | Straw2 |
|----|----|----|----|----|----|
| Object 할당 | O(1) | O(n) | O(log n) | O (n) | O (n) |
| 하위 Bucket 추가 | Poor | Optimal | Good | Good | Optimal |
| 하위 Bucket 삭제 | Poor | Poor | Good | Good | Optimal |
| 하위 Bucket Weight 변경 | X | Poor | Good | Good | Optimal |

<figure>
<figcaption class="caption">[표 1] Bucket 알고리즘 성능 비교</figcaption>
</figure>

Bucket은 자신의 하위 Bucket을 선택하는 Bucket 알고리즘을 선택할 수 있다. 알고리즘에는 Uniform, List, Tree, Straw, Straw2가 있으며 각 알고리즘은 장단점을 갖고 있다. 기본 알고리즘은 Straw2를 이용한다. [표 1]은 각 알고리즘의 성능을 서로 비교하여 나타내고 있다.

#### 2.1. Uniform

{% highlight cpp %}
cbucket uniform(bucket, pg_id, replica) {
    return bucket->cbuckets[hash(pg_id, bucket->id, replica) % length(bucket->cbuckets)];
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] uniform() 함수</figcaption>
</figure>

* cbucket : Uniform 알고리즘을 통해서 선택된 하위 Bucket을 나타낸다.
* bucket : 상위 Bucket을 나타낸다.
* pg_id : 배치할 Object를 갖고있는 PG의 ID를 나타낸다.
* replica : Replica를 나타낸다. 0은 Primary Replica를 나타낸다.

Uniform 알고리즘은 하위 Bucket을 **Consistency Hashing**을 이용하여 선택한다. [Code 1]은 Uniform 알고리즘을 이용하여 하위 Bucket을 선택하는 uniform() 함수를 간략하게 나타내고 있다. 한번만 Hashing을 수행하면 되기 때문에 O(1) 시간에 하위 Bucket을 찾을 수 있다. 하지만 Consistency Hashing을 이용하더라도 하위 Bucket이 추가되거나 제거될 경우 많은 수의 PG들이 다른 하위 Bucket에 재배치된다. 따라서 많은 수의 Object들이 Rebalancing된다. Uniform 알고리즘의 모든 하위 Bucket들은 동일한 Weight를 갖는다. 즉 Uniform 알고리즘은 각 하위 Bucket마다 다른 Weight를 적용할 수 없다. Weight 값을 설정하더라도 무시된다. 각 하위 Bucket마다 다른 Weight를 적용하고 싶으면 다른 Bucket 알고리즘을 이용해야 한다.

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

* cbucket_weights : CRUSH Map에 설정된 하위 Bucket의 Weight 값들을 나타낸다.
* sum_weights : List 알고리즘에 따라서 cbucket_weights의 합들을 나타낸다.

List 알고리즘은 하위 Bucket들을 **Linked List**를 이용하여 관리한다. Link 알고리즘을 수행하기 위해서는 CRUSH Map에 있는 하위 Bucket의 Weight 정보를 바탕으로 [그림 3]과 같은 Linked List를 준비해 두어야한다. [Code 2]는 [그림 3]의 sum_weights Linked List를 초기화하는 init_sum_weights() 함수를 간략하게 나타내고 있다.

{% highlight cpp %}
cbucket list(bucket, pg_id, replica) {
    for (i = length(bucket->cbuckets) - 1; i > 0; i--) {
        tmp = hash(pg_id, bucket->cbuckets[i]->id, replica)
        if ( tmp < (cbucket_weights[i] / sum_weights[i]) ) {
            return bucket->cbuckets[i];
        }
    }

    return bucket->cbuckets[0];
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] list() 함수</figcaption>
</figure>

* cbucket : List 알고리즘을 통해서 선택된 하위 Bucket을 나타낸다.
* bucket : 상위 Bucket을 나타낸다.
* pg_id : 배치할 Object를 갖고있는 PG의 ID를 나타낸다.
* replica : Replica를 나타낸다. Primary Replica일 경우 0을 넣는다.

[Code 3]은 초기화된 cbucket_weights Linked List와 sum_weights Linked List를 이용하여 Link 알고리즘의 수행하는 list() 함수를 나타내고 있다. list() 함수는 Linked List의 마지막부터 처음으로 이동하면서 하위 Bucket의 Weight에 비례하여 PG를 할당한다. Hashing을 Linked List의 길이인 하위 Bucket의 개수만큼 수행해야하기 때문에 하위 Bucket을 찾는데 O(N) 시간이 걸린다.

![[그림 4] List에 하위 Bucket이 추가되는 경우]({{site.baseurl}}/images/theory_analysis/Ceph_CRUSH_Map_Bucket_Type/CRUSH_List_Bucket_Add.PNG){: width="650px"}

[그림 4]는 Linked List에 하위 Bucket이 추가되는 경우를 나타내고 있다. 추가된 Bucket은 Linked List의 마지막에 붙어 Link 알고리즘 수행시 가장 먼져 배치여부를 조사하는 Bucket이 된다. 하위 Bucket이 추가되면 **PG는 추가된 Bucket에 배치되거나 기존의 Bucket에 그대로 배치된다.** 하위 Bucket이 추가되어도 기존의 sum_weights 값은 변하지 않기 때문이다. 따라서 적은 수의 Object들만 Rebalancing된다.

![[그림 5] List에 하위 Bucket이 제거되는 경우]({{site.baseurl}}/images/theory_analysis/Ceph_CRUSH_Map_Bucket_Type/CRUSH_List_Bucket_Remove.PNG){: width="600px"}

[그림 5]는 Linked List에 하위 Bucket이 제거되는 경우를 나타내고 있다. [그림 5]에서는 1번 하위 Bucket이 제거 될때를 나타내고 있다. 하위 Bucket이 제거되면 기존의 sum_weights 값도 바뀌게되어 많은 수의 PG들이 다른 하위 Bucket에 배치된다. 따라서 많은 수의 Object들이 Rebalancing 된다. 하위 Bucket의 Weight를 변경하는 경우에도 sum_weights값이 바뀌기 때문에 많은 수의 Object들이 Rebalancing 된다.

#### 2.3. Tree

![[그림 6] Tree 알고리즘에 이용되는 Binary Tree]({{site.baseurl}}/images/theory_analysis/Ceph_CRUSH_Map_Bucket_Type/CRUSH_Tree.PNG){: width="750px"}

Tree 알고리즘은 하위 Bucket을 Binary Tree 형태로 관리한다. [그림 6]은 Tree 알고리즘에서 이용되는 Binary Tree를 나타내고 있다. 배열을 이용하여 Tree를 구성하지만 일반적인 Binary Search Tree처럼 구성되지는 않는다. 각 Tree의 Level의 Index는 **(Odd) * (2 ^ Level)**를 갖는다. Tree의 각 Leaf에는 하위 Bucket이 존재한다. 각 Tree의 Node는 자신의 모든 하위 Node에 존재하는 Weight의 합을 저장하고 있다.

{% highlight cpp %}
cbucket tree(bucket, pg_id, replica) {
    level = log2(length(array));
    index = length(array) / 2;

    for(i = 0; i < level - 1; i++) {
        if (hash(pg_id, bucket->id, index, replica) < 
            (array[get_left(index)]->weight/array[index]->weight)) {
            index = get_left(index);
        } else {
            index = get_rigth(index);
        }
    }

    return array[index]->bucket;
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] tree() 함수</figcaption>
</figure>

* cbucket : Tree 알고리즘을 통해서 선택된 하위 Bucket을 나타낸다.
* bucket : 상위 Bucket을 나타낸다.
* array : 하위 Bucket들을 Binary Tree로 저장한 배열을 나타낸다.
* pg_id : 배치할 Object를 갖고있는 PG의 ID를 나타낸다.
* replica : Replica를 나타낸다. Primary Replica일 경우 0을 넣는다.

[Code 4]은 초기화된 Binary Tree를 이용하여 Tree 알고리즘을 수행하는 tree() 함수를 나타내고 있다. Root Node를 시작으로 Binaray Tree를 탐색하면서 Weight에 비례하여 PG를 배치한다. Hashing을 Binary Tree의 높이만큼 수행해야하기 때문에 하위 Bucket을 찾는데 O(log N) 시간이 걸린다.

![[그림 7] Tree에 하위 Bucket이 추가되는 경우]({{site.baseurl}}/images/theory_analysis/Ceph_CRUSH_Map_Bucket_Type/CRUSH_Tree_Add.PNG){: width="750px"}

[그림 7]은 Binary Tree에 하위 Bucket이 추가될때를 나타내고 있다. **Bucket이 Binary Tree에 추가되어도 일부 Node의 Weight만 변경되기 때문에 일부의 PG만 재배치되고 나머지 PG는 기존의 Bucket에 할당된다.** 따라서 적은 수의 Object들만 Rebalancing된다. 하위 Bucket이 삭제되거나 하위 Bucket의 Weight가 변경될때도 일부 Node의 Weight만 변경되기 때문에 적은 수의 Object들만 Rebalancing된다.

#### 2.4. Straw2

{% highlight cpp %}
cbucket straw2(bucket, pg_id, replica) {
    max_index = 0;
    max_draw = 0;

    for (i = 0; i < length(bucket->cbuckets); i++) {
        draw = dist(pg_id, bucket->cbuckets[i]->id, replica, bucket->cbuckets[i]->weight);
        if (draw > max_draw) {
            max_index = i;
            max_draw = draw;
        }
    }

    return bucket->cbuckets[max_index];
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 5] straw2() 함수</figcaption>
</figure>

* cbucket : Tree 알고리즘을 통해서 선택된 하위 Bucket을 나타낸다.
* bucket : 상위 Bucket을 나타낸다.
* pg_id : 배치할 Object를 갖고있는 PG의 ID를 나타낸다.
* replica : Replica를 나타낸다. Primary Replica일 경우 0을 넣는다.

straw2 알고리즘은 모든 하위 Bucket을 대상으로 하위 Bucket ID를 **dist()** 함수를 이용하여 얻은 값과 하위 Bucket의 Weight를 곱한 값을 구한다. 구한 값중에서 가장 값이 큰 Bucket에 PG를 할당한다. dist() 함수는 hash() 함수처럼 Random 값을 생성하지만, Weight 값이 클수록 큰 Random 값이 나올확률이 높아지는 함수이다. [Code 5]는 Straw2 알고리즘을 수행하는 straw2() 함수를 나타내고 있다. Hashing을 하위 Bucket의 개수만큼 수행해야하기 때문에 하위 Bucket을 찾는데 O(N) 시간이 걸린다.

![[그림 8] Straw2에 하위 Bucket이 추가되는 경우]({{site.baseurl}}/images/theory_analysis/Ceph_CRUSH_Map_Bucket_Type/CRUSH_Straw2_Add.PNG){: width="600px"}

[그림 8]은 Straw2에 하위 Bucket이 추가되는 경우를 나타내고 있다. 하위 Bucket이 추가되어도 **PG는 새로운 Bucket에 배치되거나 기존의 Bucket에 그대로 배치된다.** 따라서 적은 수의 Object들만 Rebalancing된다. 기존의 Bucket이 삭제되어도 삭제된 Bucket에 배치되었던 PG들만 재배치되고 기존의 PG는 그대로 유지되기 때문에 적은 수의 Object들만 Rebalancing된다. Bucket의 Weight를 변경하면 Weight를 변경한 Bucket에 배치된 PG가 다른 Bucket으로 재배치되거나, 다른 Bucket에 배치되었던 PG가 Weight를 변경한 PG로 재배치 될 수 있다. 하지만 PG는 Weight를 변경하지 않은 Bucket 사이에서는 재배치 되지않기 때문에, Bucket의 Weight를 변경하여도 적은 수의 Object들만 Rebalancing된다.

#### 2.5. Straw

{% highlight cpp %}
cbucket straw(bucket, pg_id, replica) {
    max_index = 0;
    max_draw = 0;

    for (i = 0; i < length(bucket->cbuckets); i++) {
        draw = hash(pg_id, bucket->cbuckets[i]->id, replica) * 
            bucket->cbuckets[i]->straw;
        if (draw > max_draw) {
            max_index = i;
            max_draw = draw;
        }
    }

    return bucket->cbuckets[max_index];
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 6] straw() 함수</figcaption>
</figure>

* cbucket : Tree 알고리즘을 통해서 선택된 하위 Bucket을 나타낸다.
* bucket : 상위 Bucket을 나타낸다.
* pg_id : 배치할 Object를 갖고있는 PG의 ID를 나타낸다.
* replica : Replica를 나타낸다. Primary Replica일 경우 0을 넣는다.

Straw 알고리즘은 모든 하위 Bucket을 대상으로 하위 Bucket ID를 Hasing하여 얻은 값과 하위 Bucket의 **Straw**를 곱한 값을 구한다. 구한 값중에서 가장 값이 큰 Bucket에 PG를 할당한다. [Code 6]은 Straw 알고리즘을 수행하는 straw() 함수를 나타내고 있다. Straw 값은 하위 Bucket들을 Weight순으로 오름차순으로 정렬한 다음, Straw 값을 구하려는 하위 Bucket의 Weight 값과 바로 앞의 하위 Bucket의 Weight 값을 이용하여 구한다. 예를들어 A/1.0, B/3.0, C/2.5 3개의 하위 Bucket들이 있을때 Weight에 따라서 A, C, B 순으로 정렬이된다. 그 후 C Bucket의 Straw값을 구하기 위해서 C Bucket의 Weight 값과 A Bucket의 Weight 값을 이용한다.

하위 Bucket의 Straw 값을 구할때 해당 Bucket의 Weight 뿐만아니라 다른 하위 Bucket의 Weight를 이용한다는 의미는, 하위 Bucket의 추가, 삭제 또는 기존 Bucket의 Weight가 변경될 경우 최대 3개의 Straw 값이 바뀔 수 있다는 의미이다. Straw 알고리즘은 하위 Bucket의 변경에도 Object Rebalancing을 최소화 하기위해서 설계된 알고리즘이지만, Straw 값을 구하는 과정의 Side Effect 때문에 목표를 제대로 달성하지 못하였다. 이러한 문제를 해결하기 위해서 나온 알고리즘이 straw2이다.

### 3. 참조

* [http://www.nminoru.jp/~nminoru/unix/ceph/rados-overview.html#mapping](http://www.nminoru.jp/~nminoru/unix/ceph/rados-overview.html#mapping)
* [https://github.com/ceph/ceph/blob/master/src/crush/mapper.c](https://github.com/ceph/ceph/blob/master/src/crush/mapper.c)
* [https://github.com/ceph/ceph/blob/master/src/crush/builder.c](https://github.com/ceph/ceph/blob/master/src/crush/builder.c)
* [https://my.oschina.net/linuxhunter/blog/639016](https://my.oschina.net/linuxhunter/blog/639016)