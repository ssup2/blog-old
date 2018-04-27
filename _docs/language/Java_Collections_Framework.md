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

Collection Interface는 **Object Group** 관리에 필요한 **기본적**인 Interface를 제공한다. Group의 크기[size()], Object 추가[add()], Object 삭제[remove()], Iterator[Iterator()]등의 Method를 제공한다.

##### 1.1.2. Set

Set Interface는 **동일한 Object를 갖지 않는** Object Group 관리에 필요한 Interface를 제공한다. 현재 Collection Interface에서 상속받은 Method만 제공하고 있기 때문에 Collection Interface와 동일한 Method를 가지고 있다.

##### 1.1.3. SortedSet, NavigableSet

SortedSet, NavigableSet Interface는 **동일한 Object를 갖지 않으면서 정렬된** Object Group 관리에 필요한 Interface를 제공한다. 상속받은 Set Interface의 Method와 더불어 정렬의 이점을 살린 추가 Method를 포함하고 있다. 가장 큰 Object[head()], 가장 작은 Object[tail()], 범위[subSet(), headSet(), tailSet()]등의 추가 Method를 가지고 있다.

##### 1.1.4. List

List Interface는 **Indexing된** Object Group 관리에 필요한 Interface를 제공한다. 중복 Object를 허용한다. 상속받은 Collection Interface의 Method와 더불어 Indexing의 이점을 살린 추가 Method를 포함하고 있다. 위치 기반 접근[get(index)], 검색[indexOf(), lastIndexOf()]등의 추가 Method를 가지고 있다.

##### 1.1.5. Queue

Queue Interface는 **Queue 자료구조 동작을 수행하는** Object Group 관리에 필요한 Interface를 제공한다. 중복 Object를 허용한다. 상속받은 Collection Interface의 Method와 더불어 Queueing 동작을 수행하기 위한 추가 Method를 가지고 있다. Push[offer()], Pop[poll()]등의 추가 Method를 가지고 있다.

##### 1.1.6. Dequeue

Dequeue Interface는 **Dequeue 자료구조 동작을 수행하는** Object Group 관리에 필요한 Interface를 제공한다. 중복 Object를 허용한다. Queue의 앞에 Object를 삽입[addFirst()], 삭제[removeFirst()], Queue의 뒤에 Object를 삽입[addLast()], 삭제[removeLast()] 등의 추가 Method를 가지고 있다.

#### 1.2. Class

##### 1.2.1. HashSet

**Hashtable + Chaining**을 이용하여 Set Interface를 구현한 Class이다. 빠른 Object 삽입/삭제 속도를 보인다. HashSet은 순회시 Object의 삽입 순서순으로 순회를 보장하지 않는다.

##### 1.2.2. LinkedHashSet

LinkedHashSet은 HashSet과 달리 순회시 Object의 삽입 순서대로 순회를 수행한다. **Double Linked List**를 추가적으로 이용하여 Object의 삽입 순서를 관리한다. 하지만 Double Linked List에 따른 Overhead로 인하여 HashSet에 비교하여 상대적으로 느린 Object 삽입/삭제 속도를 보인다.

##### 1.2.3. TreeSet

**Red-Black Tree**를 이용하여 SortedSet Interface를 구현한 Class이다. Red-Black Tree에 따른 Object 삽입/제거시 많은 Overhead가 발생하지만 빠른 Object 검색 속도를 보인다.

##### 1.2.4. ArrayList

**Array**를 이용하여 List Interface를 구현한 Class이다. Array 기반이기 때문에 Index 기반의 Object 접근이 매우 빠르지만, Object 삽입/삭제시 Object Shift 연산으로 인해 느리다는 단점이 존재한다. 또한 Array의 크기 변경시에도 Object Copy 연산으로 인해 느리다.

##### 1.2.5. Vector
Vector는 ArrayList와 유사하지만 모든 Method에 동기화를 위한 **synchronized** keyword가 붙어 있기 때문에 Single Thread 환경에서 비효율적이다. ArrayList가 나오기 전에 등장한 Class로 현재는 잘 이용되지 않고 있고 하위 호환을 위해 존재한다.

##### 1.2.6. LinkedList

**LinkedList**를 이용하여 List Inteface, Queue Interface, Dequeue Interface를 구현한 Class이다. LinkedList 기반이기 때문에 ArrayList와 비교하여 Object 삽입/삭제가 빠르다. 하지만 Index 기반의 Object 접근이나 Object 검색시 순회 동작으로 인해 느리다.

##### 1.2.7. PriorityQueue

**Heap**을 이용하여 Queue Interface를 구현한 Class이다. Heap의 정렬 기능을 이용하여 Priority가 가장 높은 Object를 빠르게 얻을 수 있다.

##### 1.2.8. ArrayDequeue

**Array**를 이용하여 Dequeue Interface를 구현한 Class이다. Array 기반인 ArrayList와 동일한 특징을 갖는다.

### 2. Map Interface

![]({{site.baseurl}}/images/language/Java_Collections_Framework/Map_Interface.PNG){: width="400px"}

Map Interface는 Key-Value Group을 관리하는 Interface를 제공하는 뼈대 역활을 수행한다. 위의 그림은 Map Interface의 관계도를 나타내고 있다.

#### 2.1. Interface

##### 2.1.1. Map

Map Interface는 **key-Value Group** 관리에 필요한 **기본적**인 Interface를 제공한다. Key는 중복될 수 없다. Group의 크기[size()], Key-Value 추가[put()], Value 얻기[get()], Key-Value 삭제[remove()], Set Interface 얻기[entrySet(), keySet()]등의 Method를 제공한다. Map Interface에서는 Iterator를 제공하지 않는다. entrySet(), ketSet() Method를 통해 얻은 Set Interface의 Iterator를 이용한다.

##### 2.1.1. SortedMap, NavigableMap

SortedMap, NavigableMap Interface는 **동일한 Key를 갖지 않으면서 Key를 기준으로 정렬된** Key-Value Group 관리에 필요한 Interface를 제공한다. 상속받은 Map Interface의 Method와 더불어 정렬의 이점을 살린 추가 Method를 포함하고 있다. 가장 큰 Key[firstKey()], 가장 작은 Key[lastKey()], 범위[subMap(), headMap(), tailMap()]등의 추가 Method를 가지고 있다.

#### 2.2. Class

##### 2.2.1. HashMap

Key를 기준으로 **Hashtable + Chaining**을 이용하여 Map Interface를 구현한 Class이다. Key에 한개의 Null이 들어 갈 수 있고, Value에도 Null이 들어갈 수 있다. 또한 HashMap은 순회시 Object의 삽입 순서순으로 순회를 보장하지 않는다.

HashMap의 Method은 synchronized 하지 않는다. 따라서 Multi-Thread 환경에서 이용시 문제가 발생한다. Multi-Thread 환경에서는 ConcurrentHashMap Class를 이용하면 된다.

##### 2.2.2. LinkedHashMap

LinkedHashMap은 HashMap과 달리 순회시 Key-Value의 삽입 순서대로 순회를 수행한다. **Double Linked List**를 추가적으로 이용하여 Key-Value의 삽입 순서를 관리한다. 하지만 Double Linked List에 따른 Overhead로 인하여 HashMap에 비교하여 상대적으로 느린 Key-Value 삽입/삭제 속도를 보인다.

##### 2.2.3. HashTable

HashTable는 HashMap와 유사하지만 모든 Method에 동기화를 위한 synchronized keyword가 붙어 있기 때문에 Single Thread 환경에서 비효율적이다. Key와 Value에 Null이 들어갈 수 없다. ConcurrentHashMap보다도 Lock Granularity가 크기 때문에 성능이 느리다. HashMap과 ConcurrentHashMap이 나오기 전에 등장한 Class로 현재는 잘 이용되지 않고 있고 하위 호환을 위해 존재한다.

##### 2.2.4. EnumMap

Key를 **Enum**으로 이용하여 Map Interface를 구현한 Class이다. Key가 Enum이기 때문에 들어갈 수 있는 Key의 값이 매우 한정적이다. 따라서 EnumMap은 Enum 개수와 동일한 길이의 **Array**를 할당하고 이용한다. 고정된 길이의 Array를 이용하기 때문에 Resize가 발생하지 않고, 언제나 O(1)의 복잡도를 보장한다.

##### 2.2.5. TreeMap

Key를 기준으로 **Red-Black Tree**를 이용하여 SortedMap Interface를 구현한 Class이다. Red-Black Tree에 따른 Key-Value 삽입/제거시 많은 Overhead가 발생하지만 빠른 Key 검색 속도를 보인다.

### 3. 참조

* Java Collection Cheat Sheet -  [http://pierrchen.blogspot.kr/2014/03/java-collections-framework-cheat-sheet.html](http://pierrchen.blogspot.kr/2014/03/java-collections-framework-cheat-sheet.html)

* [http://java-latte.blogspot.kr/2013/09/java-collection-arraylistvectorlinkedli.html](http://java-latte.blogspot.kr/2013/09/java-collection-arraylistvectorlinkedli.html)
* [https://docs.oracle.com/javase/tutorial/collections/interfaces/index.html](https://docs.oracle.com/javase/tutorial/collections/interfaces/index.html)
* [https://stackoverflow.com/questions/12646404/concurrenthashmap-and-hashtable-in-java](https://stackoverflow.com/questions/12646404/concurrenthashmap-and-hashtable-in-java)
* [http://www.programering.com/a/MDMyMzMwATQ.html](http://www.programering.com/a/MDMyMzMwATQ.html)
