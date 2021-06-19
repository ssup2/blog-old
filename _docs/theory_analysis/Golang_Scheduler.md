---
title: Golang Scheduler
category: Theory, Analysis
date: 2021-01-18T12:00:00Z
lastmod: 2021-01-18T12:00:00Z
comment: true
adsense: true
---

Golang의 Scheduler를 분석한다.

### 1. Golang Scheduler

![[그림 1] Golang Scheduler]({{site.baseurl}}/images/theory_analysis/Golang_Scheduler/Golang_Scheduler.PNG){: width="700px"}

[그림 1]은 Golang의 Scheduler 및 Golang의 Scheduler와 연관된 Component를 나타내고 있다. 크게 **G (Goroutine), P (Processor), M (Thread)** 3가지의 Component로 구성되어 있다. 여기서 Process는 실제 CPU Core의 개수가 아닌 가상의 Processor (Virtual CPU Core)를 의미한다. Golang의 Scheduler는 각 Component들을 합쳐서 **GMP Scheduler**라고도 불린다.

[그림 1]에서는 4개의 **CPU Core**가 존재하고 있으며 **OS Scheduler**에 의해서 다수의 Thread가 Scheduling되어 동작하고 있는 모습을 나타내고 있다. **Net Poller**는 Network를 처리하는 별도의 Thread를 의미한다. **GRQ (Global Run Queue)**는 의미 그대로 전역 Goroutine Queue 역활을 수행하며, **LRQ (Local Run Queue)**는 의미 그대로 지역 Goroutine Queue 역활을 수행한다.

#### 1.2. Fairness

### 2. 참조

* [https://www.ardanlabs.com/blog/2018/08/scheduling-in-go-part2.html](https://www.ardanlabs.com/blog/2018/08/scheduling-in-go-part2.html)
* [https://www.youtube.com/watch?v=-K11rY57K7k](https://www.youtube.com/watch?v=-K11rY57K7k)
* [https://morsmachine.dk/netpoller](https://morsmachine.dk/netpoller)
* [https://www.timqi.com/2020/05/15/how-does-gmp-scheduler-work/](https://www.timqi.com/2020/05/15/how-does-gmp-scheduler-work/)
* [https://blog.puppyloper.com/menus/Golang/articles/Goroutine%EA%B3%BC%20Go%20scheduler](https://blog.puppyloper.com/menus/Golang/articles/Goroutine%EA%B3%BC%20Go%20scheduler)
* [https://rokrokss.com/post/2020/01/01/go-scheduler.html](https://rokrokss.com/post/2020/01/01/go-scheduler.html)
