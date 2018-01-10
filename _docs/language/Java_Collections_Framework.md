---
title: Java Collections Framework (JCF)
category: Language
date: 2018-01-10T12:00:00Z
lastmod: 2018-01-10T12:00:00Z
comment: true
adsense: true
---

Java Collections Framework에서 제공하는 Interface와 Class를 분석한다.

### 1. Collection Interface

![]({{site.baseurl}}/images/language/Java_Collections_Framework/Collection_Interface.PNG){: width="700px"}

Collection Interface는 Object Group을 관리하는 Interface를 제공하는 뼈대 역활을 수행한다. 위의 그림은 Collection Interface의 관계도를 나타내고 있다.

#### 1.1. Interface

##### 1.1.1. Collection

Collection Interface는 Object Group 관리에 필요한 **기본적**인 Interface를 제공한다. Group의 크기[size()], Object 추가[add()], Object 삭제[remove()], Iterator[Iterator()]등의 Method를 제공한다.

##### 1.1.2. Set

Set Interface는 **동일한 Object를 갖지 않는** Object Group 관리에 필요한 Interface를 제공한다. 현재 Collection Interface에서 상속받은 Interface만 제공하고 있기 때문에 Collection Interface와 동일한 Method를 가지고 있다.

##### 1.1.3. SortedSet

SortedSet Interface는 **동일한 Object를 갖지 않으면서 정렬된** Object Group 관리에 필요한 Interface를 제공한다. Set Interface의 Method와 더불어 정렬의 이점을 살린 추가 Method를 포함하고 있다. 가장 큰 Object[head()], 가장 작은 Object[tail()], 범위[subSet(), headSet(), tailSet()]등의 추가 Method를 가지고 있다.

##### 1.1.4. List

List Interface는 **Indexing된** Object Group 관리에 필요한 Interface를 제공한다. 중복 Object를 허용한다. Collection Interface의 Method와 더불어 Indexing의 이점을 살린 추가 Method를 포함하고 있다. 위치 기반 접근[get(index)], 검색[indexOf(), lastIndexOf()]등의 추가 Method를 가지고 있다.

##### 1.1.5. Queue

Queue Interface는 **Queueing을 수행하는** Object Group 관리에 필요한 Interface를 제공한다. 중복 Object를 허용한다. Collection Interface의 Method와 더불어 Queueing 동작을 수행하기 위한 추가 Method를 가지고 있다. Push[offer()], Pop[poll()]등의 추가 Method를 가지고 있다.

#### 1.2. Class

##### 1.2.1. HashSet

##### 1.2.2. LinkedHashSet

##### 1.2.3. TreeSet

##### 1.2.4. ArrayList

##### 1.2.5. Vector

##### 1.2.6. LinkedList

##### 1.2.7. PriorityQueue

### 2. Map Interface

#### 2.1. Interface

##### 2.1.1. Map

##### 2.1.1. Sorted Map

#### 2.2. Class

##### 2.2.1. HashTable

##### 2.2.2. LinkedHashMap

##### 2.2.3. HashMap

##### 2.2.4. TreeMap

![]({{site.baseurl}}/images/language/Java_Collections_Framework/Map_Interface.PNG){: width="400px"}

### 3. 참조

* [https://docs.oracle.com/javase/tutorial/collections/interfaces/index.html](https://docs.oracle.com/javase/tutorial/collections/interfaces/index.html)
