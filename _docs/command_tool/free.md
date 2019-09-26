---
title: free
category: Command, Tool
date: 2019-09-16T12:00:00Z
lastmod: 2019-09-16T12:00:00Z
comment: true
adsense: true
---

Memory 사용량을 출력하는 free의 사용법을 정리한다.

***

* TOC
{:toc}

***

### 1. free

#### 1.1. # free -m

{% highlight console %}
# free -m
              total        used        free      shared  buff/cache   available
Mem:           7977        1430        2455           1        4090        6249
Swap:          4095           0        4095
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] free -h</figcaption>
</figure>

MB 단위로 Memory 사용량을 출력한다. [Shell 1]은 "free -m"를 이용하여 Memory 사용량을 출력하는 Shell의 모습을 나타내고 있다. [Shell 1]에서 "Mem:"은 물리 Memory 사용량을 나타내고, "Swap:"은 Swap 사용량을 나타낸다. 각 행은 다음과 같은 의미를 갖는다.

* total : 전체 용량을 나타낸다.
* used : "total - free - buff/cache - cache"의 결과값을 나타낸다.
* free : 이용되고 있지 않은 용량을 나타낸다.
* shared : tmpfs이 이용하고 있는 용량이다.
* buff/cache : Kernel이 이용하고 있는 Buffer, Cache 용량의 합을 나타낸다. Cache에는 이용하고 있는 Page Cache, Slab, tmpfs의 용량이 포함되어 있다.
* available : 새로운 Process나 기존의 Process가 이용할 수 있는 Memory 용량을 나타낸다. "free + Page Cache + 반환가능한 Slab"의 용량으로 결정된다.

### 2. 참조

* [https://linux.die.net/man/1/free](https://linux.die.net/man/1/free)
* [https://serverfault.com/questions/23433/in-linux-what-is-the-difference-between-buffers-and-cache-reported-by-the-f](https://serverfault.com/questions/23433/in-linux-what-is-the-difference-between-buffers-and-cache-reported-by-the-f)


