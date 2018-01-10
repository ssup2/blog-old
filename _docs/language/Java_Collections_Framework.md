---
title: Java Collections Framework (JCF)
category: Language
date: 2018-01-10T12:00:00Z
lastmod: 2018-01-10T12:00:00Z
comment: true
adsense: true
---

Java Collections Framework에서 제공하는 Interface와 Class들을 분석한다.

### 1. Collection Interface

![]({{site.baseurl}}/images/language/Java_Collections_Framework/Collection_Interface.PNG){: width="700px"}

Collection

#### 1.1. Interface

##### 1.1.1. Collection

##### 1.1.2. Set

##### 1.1.3. SortedSet

##### 1.1.4. List

##### 1.1.5. Queue

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


{: .newline }
> a = G * x, b = G * y
> ---> L = G * x * y = (a * b) / G

![]({{site.baseurl}}/images/theory_analysis/Linux_LSM/Linux_LSM_Framework.PNG){: width="300px"}
![]({{site.baseurl}}/images/theory_analysis/KVM_QEMU/QEMU_non-iothread.PNG)

{% highlight CPP %}
#include <iostream>
using namespace std;

template <class T>
class SmartPtr
{
   T *ptr;  // Actual pointer
public:
   // Constructor
   explicit SmartPtr(T *p = NULL) { ptr = p; }

   // Destructor
   ~SmartPtr() { delete(ptr); }

   // Overloading dereferncing operator
   T& operator*() { return *ptr; }

   // Overloding arrow operator
   T* operator->() { return ptr; }
};

int main()
{
    SmartPtr<int> ptr(new int());
    *ptr = 20;
    cout << *ptr;

    return 0;
}
{% endhighlight %}

* QEMU - [http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html](http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html)
