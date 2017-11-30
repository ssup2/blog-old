---
title: C++ Smart Pointer
category: Language
date: 2017-11-27T12:00:00Z
lastmod: 2017-11-27T12:00:00Z
comment: true
adsense: true
---

C++의 Smart Pointer를 분석한다.

### 1. Smart Pointer

Smart Pointer는 일반 Pointer와 다르게 new 문법으로 생성한 Instance를 **delete 문법을 통해 명시적으로 삭제하지 않아도 자동으로 삭제해주는 Pointer**이다. 다음과 같이 간단한 Smart Pointer를 구현할 수 있다.

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

Smart Pointer안의 실제 Pointer는 Smart Pointer의 생성자와 함께 초기화 및 할당되고, 소멸자 안에서 delete 문법과 함께 해제된다. 또한 *연산자와 ->연산자를 Overriding하여 개발자가 Smart Pointer를 일반 Pointer와 유사하게 이용할 수 있다.

main함수 안에서 ptr Smart Pointer는 new int()을 통해 할당된 Instance를 가리킨다. ptr Smart Pointer는 Stack에 할당된 지역변수이기 때문에 main 함수가 종료되면서 ptr Smart Pointer의 소멸자가 호출된다. 소멸자가 호출되면서 delete를 호출하기 때문에 할당된 Instance는 해지된다.

#### 1.1. auto_ptr

auto_ptr는 **Exclusive Ownership Model**을 이용하는 Smart Pointer이다. 즉 하나의 auto_ptr이 가리키는 Instance는 다른 auto_ptr이 가리키지 못하는 특징을 갖고있다.

{% highlight CPP %}
#include <iostream>
#include <memory>
using namespace std;

class A
{
public:
    void show() {  cout << "A::show()" << endl; }
};

int main()
{
    // p1 is an auto_ptr of type A
    auto_ptr<A> p1(new A);
    p1 -> show();

    // returns the memory address of p1
    cout << p1.get() << endl;

    // copy constructor called, this makes p1 empty.
    auto_ptr <A> p2(p1);
    p2 -> show();

    // p1 is empty now
    cout << p1.get() << endl;

    // p1 gets copied in p2
    cout<< p2.get() << endl;

    return 0;
}
{% endhighlight %}

~~~
A::show()
0x1b42c20
A::show()
0          // NULL
0x1b42c20
~~~

위의 예제는 p1에게 Instance A를 할당한 후, 복사 연사자를 통해서 p1을 p2에 복사하는 예제이다. p1의 값을 p2에게 복사한 것 뿐이지만, p1의 값이 NULL으로 초기화 된것을 확인 할 수 있다. p1이 가지고 있던 Instance A의 소유권이 p2에게 넘어갔기 때문이다.

auto_ptr은 위의 예제처럼 복사 연산자의 호출만으로 NULL로 초기화 되는 특징을 갖고 있다. 복사 연산자를 호출 했지만 복사가 아닌 **이동 (move)** 연산을 수행하는 auto_ptr의 특징 때문에 auto_ptr은 STL에서 이용하지 못한다. 또한 auto_ptr을 통해 배열을 할당하면, 제대로 메모리를 해지하지 못하는 문제점을 갖고 있다. 따라서 현재 auto_ptr의 사용을 권장하지 않고 있다.

#### 1.2. unique_ptr

unique_ptr은 auto_ptr과 동일하게 **Exclusive Ownership Model**을 이용하지만 auto_ptr의 단점을 보안한 Smart Pointer이다. STL에서도 이용이 가능하고, 배열 할당시에도 문제가 없다. C++11 부터 이용 가능하다.

{% highlight CPP %}
#include <iostream>
#include <memory>
using namespace std;

class A
{
public:
    void show()
    {
        cout<<"A::show()"<<endl;
    }
};

int main()
{
    unique_ptr<A> p1 (new A);
    p1 -> show();

    // returns the memory address of p1
    cout << p1.get() << endl;

    // transfers ownership to p2
    // unique_ptr<A> p2 = p1 (Comile Error)
    unique_ptr<A> p2 = move(p1);
    p2 -> show();
    cout << p1.get() << endl;
    cout << p2.get() << endl;

    return 0;
}
{% endhighlight %}

~~~
A::show()
0x1c4ac20
A::show()
0          // NULL
0x1c4ac20
~~~

위의 예제는 unique_ptr의 이용법을 나타내고 있다. unique_ptr에서는 **복사 생성자와 복사 대입 연산자**를 이용할 수 없다. 이용 시 Compile Error가 발생한다. 그 대신 unique_ptr는 소유권 이동을 명시적으로 나타내는 std::move함수를 제공한다. unique_ptr은 std::move 함수를 통해서만 다른 unique_ptr에게 소유권을 이동 할 수 있다.

{% highlight CPP %}
unique_ptr<A> fun()
{
    unique_ptr<A> ptr(new A);

    /* ...
       ... */

    return ptr;
}
{% endhighlight %}

unique_ptr은 위의 예제처럼 함수의 return 인자로도 넘길 수 있다. Instance의 소유권은 return 결과를 받은 unique_ptr으로 이동한다.

#### 1.3. shared_ptr

shared_ptr은 **Reference Counting Ownership Model**을 이용한다. 따라서 auto_ptr, unique_ptr과는 다르게 여러개의 shared_ptr가 하나의 Instance를 가리킬 수 있다. Instance를 가리키는 shared_ptr의 개수는 각 shared_ptr에 저장되어 관리된다. Instance를 가리키는 shared_ptr의 개수가 감소하다가 0이 되면 Instance를 해제한다.

{% highlight CPP %}
#include <iostream>
#include <memory>
using namespace std;

class A
{
public:
    void show()
    {
        cout<<"A::show()"<<endl;
    }
};

int main()
{
    shared_ptr<A> p1 (new A);
    cout << p1.get() << endl;
    p1->show();
    shared_ptr<A> p2 (p1);
    p2->show();
    cout << p1.get() << endl;
    cout << p2.get() << endl;

    // Returns the number of shared_ptr objects
    //referring to the same managed object.
    cout << p1.use_count() << endl;
    cout << p2.use_count() << endl;

    // Relinquishes ownership of p1 on the object
    //and pointer becomes NULL
    p1.reset();
    cout << p1.get() << endl;
    cout << p2.use_count() << endl;
    cout << p2.get() << endl;

    return 0;
}
{% endhighlight %}

~~~
0x1c41c20
A::show()
A::show()
0x1c41c20
0x1c41c20
2
2
0          // NULL
1
0x1c41c20
~~~

위의 예제에서 shared_ptr인 p1과 p2가 같은 A Instance를 가리키게 설정되어 있다. p1, p2의  Count값이 2로 동일하다가 p1을 reset 함수로 초기화 한 뒤 p2의 값이 1로 줄어든 것을 확인 할 수 있다.

#### 1.4. weak_ptr

weak_ptr은 **shared_ptr이 가리키는 Instance를 참조**만 하는 참조자 역활을 수행한다. weak_ptr은 Reference Count를 관리하지 않는다. Instace의 생명주기에 영향을 주지 않는다. 따라서 weak_ptr이 가리키는 Instance는 실제 존재하지 않을 수 있다.

{% highlight CPP %}
#include <iostream>
#include <memory>
using namespace std;

class A
{
};

int main()
{
    // weak_ptr initialize with shared_ptr
    shared_ptr<A> sp1(new A);
    weak_ptr<A> wp1 = sp1;

    // weak_ptr convert to shared_ptr
    shared_ptr<A> sp2 = wp1.lock();
    cout << sp2.get() << endl;

    // Reset sp1, sp2
    sp1.reset();
    sp2.reset();

    // weak_ptr convert to shared_ptr
    shared_ptr<A> sp3 = wp1.lock();
    cout << sp3.get() << endl;

    return 0;
}
{% endhighlight %}

~~~
0x746c20
0         // NULL
~~~

위의 예제는 weak_ptr의 사용법을 나타내고 있다. weak_ptr은 shared_ptr을 통해 shared_ptr이 가리키는 Instance를 가리키게 된다. 위의 예제에서 wp1은 sp1을 통해서 초기화 되기 때문에 wp1은 sp1이 가리키는 Instance A를 가리키게 된다.

weak_ptr은 반드시 lock() 함수를 통해서 shared_ptr로 변환 뒤에 Instance를 접근 할 수 있다. lock() 함수 호출시 weak_ptr이 가리키는 Instance가 존재하면 변환된 shared_ptr은 동일한 Instance를 가리키고 있게 된다. weak_ptr이 가리키는 Instance가 존재하지 않으면 변환된 shared_ptr은 NULL값을 갖게 된다. 위의 예제에서 첫번째 lock() 함수를 호출 하였을때는 sp1이 Instance A를 가리고 있기 때문에 Instance A가 존재하고 있는 상태이다. 따라서 sp2는 NULL이 아니이다. 두번째 lock() 함수를 호출 하였을때는 sp1, sp2가 reset() 함수를 호출하여 모두 Instance A를 가리키지 않는 상태이기 때문에 Instance A는 존재하지 않는 상태이다. 따라서 sp3은 NULL값을 갖게 된다.

![]({{site.baseurl}}/images/language/C++_Smart_Pointer/Circular_Reference.PNG){: width="700px"}

weak_ptr를 이용하여 shared_ptr의 **Circular Reference**를 문제를 제거할 수 있다. 위의 그림은 Circular Reference 문제를 나타내고 있다. shared_ptr는 Reference Count 기반으로 Instance를 관리하기 때문에, 위의 그림처럼 shared_ptr을 이용하여 서로의 Instance를 참조하면 Reference Count값이 줄어들지 않아 Instance가 해지되지 않는 문제가 발생한다. shared_ptr중 하나를 weak_ptr로 교체하면 weak_ptr은 Instance의 생명 주기에 영향을 주지 않기 때문에 Circular Reference 문제를 해결 할 수 있다.

### 2. 참조
* [http://www.geeksforgeeks.org/smart-pointers-cpp](http://www.geeksforgeeks.org/smart-pointers-cpp)
* [http://www.geeksforgeeks.org/auto_ptr-unique_ptr-shared_ptr-weak_ptr-2/](http://www.geeksforgeeks.org/auto_ptr-unique_ptr-shared_ptr-weak_ptr-2/)
* [http://egloos.zum.com/sweeper/v/3059940](http://egloos.zum.com/sweeper/v/3059940)
