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
   T& operator*() {  return *ptr; }

   // Overloding arrow operator
   T* operator->() { return ptr; }
};
{% endhighlight %}


Smart Pointer안의 실제 Pointer는 Smart Pointer의 생성자와 함께 초기화 및 할당되고, 소멸자 안에서 delete 문법과 함께 해제된다. 또한 *연산자와 ->연산자를 Overriding하여 개발자가 Smart Pointer를 일반 Pointer와 유사하게 이용할 수 있다.

{% highlight CPP %}
int main()
{
    SmartPtr<int> ptr(new int());
    *ptr = 20;
    cout << *ptr;

    return 0;
}
{% endhighlight %}

main함수 안에서 ptr Smart Pointer는 new int()을 통해 할당된 Instance를 가리킨다. ptr Smart Pointer는 Stack에 할당된 지역변수이기 때문에 main 함수가 종료되면서 ptr Smart Pointer의 소멸자가 호출된다. 소멸자가 호출되면서 delete를 호출하기 때문에 할당된 Instance는 해지된다.

### 1.1. auto_ptr

{% highlight CPP %}
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
0          
0x1b42c20
~~~

### 1.2. unique_ptr

{% highlight CPP %}
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
    unique_ptr<A> p2 = move(p1);
    p2 -> show();
    cout << p1.get() << endl;
    cout << p2.get() << endl;

    // transfers ownership to p3
    unique_ptr<A> p3 = move (p2);
    p3->show();
    cout << p1.get() << endl;
    cout << p2.get() << endl;
    cout << p3.get() << endl;

    return 0;
}
{% endhighlight %}

~~~
A::show()
0x1c4ac20
A::show()
0          // NULL
0x1c4ac20
A::show()
0          // NULL
0          // NULL
0x1c4ac20
~~~

### 1.3. shared_ptr

{% highlight CPP %}
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

### 1.4. weak_ptr

{% highlight CPP %}

{% endhighlight %}

### 2. 참조
* [http://www.geeksforgeeks.org/smart-pointers-cpp](http://www.geeksforgeeks.org/smart-pointers-cpp)
* [http://www.geeksforgeeks.org/auto_ptr-unique_ptr-shared_ptr-weak_ptr-2/](http://www.geeksforgeeks.org/auto_ptr-unique_ptr-shared_ptr-weak_ptr-2/)
