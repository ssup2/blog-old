---
title: B-Tree, B+ Tree
category: Theory, Analysis
date: 2018-01-30T12:00:00Z
lastmod: 2018-01-30T12:00:00Z
comment: true
adsense: true
---

Disk를 주로 이용하는 Filesystem이나 DB에 많이 이용되는 B-Tree와 B+ Tree를 분석한다.

### 1. B-Tree

![[그림 1] B-Tree]({{site.baseurl}}/images/theory_analysis/B_Tree_B+_Tree/B_Tree.PNG)

B-tree는 Binary Search Tree를 확장한 Tree로 각 Node는 여러개의 Key를 가질 수 있고, 여러개의 Child를 가질 수 있다. 또한 모든 Leaf Node는 동일한 Depth를 갖고 있다. [그림 1]은 3 Order B-Tree를 나타내고 있다. N Order B-Tree의 경우 각 Node는 N-1개의 Key를 가질 수 있고, 최대 N개의 Child를 가질 수 있다. 따라서 3 Order B-Tree에서 각 Node는 최대 2개의 Key를 가질 수 있고, 최대 3개의 Child를 가질 수 있다.

각 Node에는 여러개의 Key를 갖고 있고 각 Key에 대응하는 Data도 함께 갖고 있다. Key는 Binary Search와 유사한 형태로 정렬되어 각 Node에 배치된다. Binary Search에서 오른쪽 Child Node의 Key는 자신보다 작고 왼쪽 Child Node의 Key는 자신보다 큰데, B-Tree에서도 각 Key에 대해서 유사한 규칙이 적용된다. 

[그림 1]에서 11, 25 Key를 갖고 있는 Node의 왼쪽 Node에는 11보다 작은 Key들만 저장되어 있는것을 확인 할 수 있다. 또한 가운데 Child는 11, 25 Key의 사이의 Key들만 가지고 있다. 마지막으로 오른쪽 Node에는 25 Key보다 큰 Key들만 저장되어 있는것을 확인할 수 있다. 하나의 Node에 여러개의 Key를 갖는 특성 때문에 용량이 큰 Block 단위로 Data를 Read/Write하는 Disk 환경에서는 Binary Search Tree보다 B-Tree를 이용하는 것이 유리하다.

### 2. B+ Tree

![[그림 2] B+ Tree ]({{site.baseurl}}/images/theory_analysis/B_Tree_B+_Tree/B+_Tree.PNG)

B+ Tree는 B-Tree를 개량한 자료구조 이다. B-tree처럼 모든 Leaf Node는 동일한 Depth를 갖는다. B-Tree와의 가장 큰 차이점은 Inner Node에는 Key만 저장이 되고 Leaf Node에 Key와 Data를 함께 저장한다는 점이다. Leaf Node에만 Data가 저장되기 때문에 Leaf Node 사이를 Link (Pointer)로 연결하여 B-Tree에 비하여 쉬운 순회가 가능하도록 만든점도 B+ Tree의 특징이다.

[그림 2]는 4 Order B+ Tree를 나타내고 있다. Inner Node에는 Key만 존재하고, Leaf Node에는 Key와 Data가 존재하는 것을 나타내고 있다. 또한 Leaf Node 사이에 Link가 연결되어 있는것도 확인할 수 있다. N Order B+ Tree의 경우 각 Node는 N-2개의 Key를 가질 수 있고, N-1개의 Child를 가질 수 있다. 따라서 4 Order B+ Tree의 경우 각 Node는 최대 2개의 Key를 가질 수 있고, 최대 3개의 Child를 가질 수 있다.

Key는 B-Tree와 유사한 형태로 정렬되어 각 Node에 배치된다. 단 B+ Tree Node는 Leaf Node에만 Data가 저장되기 때문에 Leaf Node의 부모 Node에는 Leaf Node의 Key가 일부 저장되는 특징을 갖는다. [그림 2]에서 11 Key를 갖는 Node 및 25 Key를 갖는 Node의 부모 Node는 11, 25 Key를 가지고 있는것을 확인할 수 있다.

B+ Tree의 Inner Node는 Data가 없기 때문에 B-Tree의 Inner Node에 비하여 용량작다. 하나의 Disk Block에 더 많은 Inner Node를 배치 할 수 있게 되어, Key 탐색시 B-Tree에 비하여 상대적으로 적은 Disk Block만 읽어도 된다. 이러한 이점 때문에 일반적으로 B+ Tree는 Key 탐색시 B-Tree보다 좀더 나은 성능을 보여준다.

### 3. 참조
* [https://www.slideshare.net/MahediMahfujAnik/database-management-system-chapter12](https://www.slideshare.net/MahediMahfujAnik/database-management-system-chapter12)
* [https://stackoverflow.com/questions/870218/differences-between-b-trees-and-b-trees](https://stackoverflow.com/questions/870218/differences-between-b-trees-and-b-trees)
* [http://potatoggg.tistory.com/174](http://potatoggg.tistory.com/174)
