---
title: B Tree, B+ Tree
category: Theory, Analysis
date: 2018-01-30T12:00:00Z
lastmod: 2018-01-30T12:00:00Z
comment: true
adsense: true
---

Disk를 주로 이용하는 Filesystem이나 DB에 많이 이용되는 B Tree와 B+ Tree를 분석한다.

### 1. B Tree

![]({{site.baseurl}}/images/theory_analysis/B_Tree_B+_Tree/B_Tree.PNG)

B tree는 Binary Search Tree를 확장한 Tree로 각 Node는 여러개의 Key를 가질 수 있고, 여러개의 Child를 가질 수 있다. 또한 모든 Leaf Node는 동일한 Depth를 갖고 있다. Key는 B Tree 알고리즘에 따라 정렬되어 각 Node에 배치된다. 위의 그림은 3 Order B tree를 나타내고 있다. 각 Node는 최대 2개의 Key를 가질 수 있고, 최대 3개의 Child를 가질 수 있다.

각 Node에는 여러개의 Key를 갖고 있고 각 Key에 대응하는 Data도 함께 갖고 있다. 하나의 Node에 여러개의 Key를 갖기 때문에 Block 단위로 Data를 Read/Write하는 Disk 환경에서는 Binary Search Tree보다 B Tree를 이용하는 것이 유리하다.

### 2. B+ Tree

![]({{site.baseurl}}/images/theory_analysis/B_Tree_B+_Tree/B+_Tree.PNG)

B+ Tree는 B Tree를 개량한 Tree이다. B tree처럼 모든 Leaf Node는 동일한 Depth를 갖는다. B Tree와의 가장 큰 차이점은 Inner Node에는 Key만 저장이 되고 Leaf Node에 Key와 Data를 함께 저장한다는 점이다. Leaf Node에만 Data가 저장되기 때문에 Leaf Node간의 Pointer를 연결하여 B Tree에 비하여 쉬운 순회가 가능하다.

B+ Tree의 Inner Node는 Data가 없기 때문에 B Tree의 Inner Node에 비하여 용량작다. 하나의 Disk Block에 더 많은 Inner Node를 배치 할 수 있게 되어, Key 탐색시 B Tree에 비하여 상대적으로 적은 Disk Block만 읽어도 된다. 이러한 이점 때문에 B+ Tree는 Key 탐색시 B Tree보다 좀더 나은 성능을 보여준다.

### 3. 참조
* [https://www.slideshare.net/MahediMahfujAnik/database-management-system-chapter12](https://www.slideshare.net/MahediMahfujAnik/database-management-system-chapter12)
* [https://stackoverflow.com/questions/870218/differences-between-b-trees-and-b-trees](https://stackoverflow.com/questions/870218/differences-between-b-trees-and-b-trees)
* [http://potatoggg.tistory.com/174](http://potatoggg.tistory.com/174)
