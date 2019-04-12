---
title:
category:
date: 2017-01-14T12:00:00Z
lastmod: 2017-01-15T12:00:00Z
comment: true
adsense: true
---

### URL

![]({{site.baseurl}}/images/theory_analysis/Linux_LSM/Linux_LSM_Framework.PNG){: width="300px"}
![]({{site.baseurl}}/images/theory_analysis/KVM_QEMU/QEMU_non-iothread.PNG)

### Block Quote

{: .newline }
> a = G * x, b = G * y
> ---> L = G * x * y = (a * b) / G
<figure>
<figcaption class="caption">[파일 1] /etc/netplan/50-cloud-init.yaml</figcaption>
</figure>

### Table

| | Read Uncommitted | Read Committed | Repeatable-Read | Serializable |
|----|----|----|----|----|
| Lost Update | O | O | X | X |
| Dirty Read | O | X | X | X |
| Non-repeatable Read | O | O | X | X |
| Phantom Read | O | O | O | X |

<figure>
<figcaption class="caption">[표 1] DB Isolation Level에 따른 Issue</figcaption>
</figure>

### highligter

{% highlight cpp linenos %}
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
<figure>
<figcaption class="caption">[파일 1] /etc/netplan/50-cloud-init.yaml</figcaption>
</figure>

* QEMU - [http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html](http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html)
