---
title: Golang Goroutine Scheduling
category: Theory, Analysis
date: 2021-06-24T12:00:00Z
lastmod: 2021-06-24T12:00:00Z
comment: true
adsense: true
---

Golang의 Goroutine Scheduling을 분석한다.

### 1. Goroutine Scheduling

![[그림 1] Goroutine Scheduling]({{site.baseurl}}/images/theory_analysis/Golang_Goroutine_Scheduling/Golang_Goroutine_Scheduling.PNG){: width="700px"}

Golang에서는 OS에서 제공하는 Thread보다 더 경량화된 Thread인 Goroutine을 제공하고 있다. Goroutine은 Golang Runtime에 포함되어 있는 **Golang Scheduler**가 수행하는 Thread Scheduling을 통해서 실행된다. 즉 다수의 Goroutine들이 소수의 Thread위에서 동작하게 된다. [그림 1]은 Goroutine Scheduling 과정을 나타내고 있다. **Goroutine은 G, Processor는 P, Thread는 M**으로 표현되었다. 여기서 Processor는 실제 CPU Core의 개수가 아닌 가상의 Processor (Virtual CPU Core)를 의미한다.

[그림 1]에서는 4개의 **CPU Core**가 존재하고 있으며 **OS Scheduler**에 의해서 다수의 Thread가 Scheduling되어 동작하고 있는 모습을 나타내고 있다. **Network Poller**는 Network를 처리하는 별도의 독립된 Thread를 의미한다. Run Queue에는 **GRQ (Global Run Queue)**와 **LRQ (Local Run Queue)**가 2가지가 존재한다. GRQ는 의미 그대로 전역 Goroutine Queue 역활을 수행하며, LRQ는 의미 그대로 지역 Goroutine Queue 역활을 수행한다.

#### 1.1. Goroutine State

Goroutine은 실제로 더욱 다양한 상태를 가지고 있지만 간략하게 나타내면 다음의 3가지 상태로 나타낼 수 있다.

* Waiting : Goroutine이 외부의 Event를 대기하고 있는 상태를 의미한다. 여기서 외부의 Event는 I/O Device 요청 처리 완료, Lock 해제와 같은 Goroutine이 실행 가능하다는걸 알려주는 OS의 Event를 의미한다.
* Runnable : Goroutine이 실행 가능한 상태를 의미한다.
* Executing : Goroutine이 실행되고 있는 상태를 의미한다.

[그림 1]에서 Network Poller에 존재하는 Goroutine과 Blocking 상태로 존재하는 Goroutine은 Waiting 상태의 Goroutine을 의미한다. GRQ, LRQ에 존재하는 Goroutine은 Runnable 상태의 Goroutine이다. Processor(P)와 Thread(M)과 같이 존재하는 Goroutine은 Executing 상태의 Goroutine이다.

Goroutine은 반드시 Processor(P)와 Thread(M)과 같이 존재할 경우에만 Executing 상태가 된다. 따라서 동시에 최대로 구동시킬수 있는 Goroutine의 개수는 Processor(P)의 개수에 따라서 정해진다. Processor(P)의 개수는 **GOMAXPROCS** 환경 변수의 값으로 결정할 수 있으며, GOMAXPROCS 환경 변수가 설정되지 않으면 기본 값으로는 CPU Core의 개수가 설정되어 모든 CPU Core에서 동시에 Goroutine을 구동시킬수 있도록 만든다. [그림 1]에서 GOMAXPROCS 값은 "3"이다.

#### 1.2. Run Queue

**LRQ**는 각 Processor(P)마다 존재하는 Run Queue이다. Processor는 자신이 소유하는 LRQ로부터 Goroutine을 하나씩 가져와 구동시킨다. LRQ를 통해서 GRQ에서 발생하는 Race Condition을 줄인다. LRQ가 Thread(M)에 존재하지 않는 이유는 Thread가 LRQ를 소유하게 되면 Thread(M)의 개수가 늘어날수록 LRQ의 개수도 같이 증가하기 때문이다. LRQ의 개수가 너무 많아지면 Work Stealing과 같은 과정의 Overhead도 커지기 때문에 Processor(P)가 LRQ를 소유한다. Processor(P)라는 개념이 도입된 이유가 LRQ의 개수를 줄이기 위해서이다.

![[그림 2] LRQ]({{site.baseurl}}/images/theory_analysis/Golang_Goroutine_Scheduling/LRQ.PNG){: width="600px"}

LRQ는 일반적인 Queue가 아닌 FIFO (First In, First Out)과 LIFO (Least In, First Out)의 결합된 형태를 가지고 있다. LIFO 부분은 Size가 "1"이기 때문에 하나의 Goroutine만 저장된다. [그림 2]는 LRQ의 동작을 나타내고 있다. LRQ에 Goroutine Enqueue시 LIFO 부분에 먼저 Goroutine이 저장이 되고 이후에 FIFO 부분에 Goroutine이 저장된다. 반대로 LRQ에서 Goroutine Dequeue시 LIFO 부분의 Goroutine이 먼저 나오고 이후에 FIFO 부분의 Goroutine이 나온다.

이렇게 LRQ가 설계된 이유는 Goroutine의 Locality를 부여하기 위해서이다. Goroutine에서 새로 Goroutine을 생성하고 생성한 Goroutine이 종료되기를 기다리는 경우, 새로 생성된 Goroutine이 빠르게 실행되고 종료되어야 높은 성능을 얻을 수 있다. Cache 관점까지 고려해보면 새로 생성된 Goroutine은 동일한 Processor에서 실행되야 좋다. 새로 생성된 Goroutine은 기본적으로 Goroutine을 생성한 Processor의 LRQ에 저장된다. 따라서 LRQ의 LIFO 부분을 통해서 새로 생성된 Goroutine은 동일한 Processor에서 빠르게 실행될 수 있다.

**GRQ**는 LRQ에 할당되지 못한 대부분의 Goroutine이 모여있는 Run Queue이다. Executing 상태가 된 Goroutine은 한번에 최대 10ms까지 동작한다. 10ms동안 동작한 Goroutine은 Waiting 상태가되어 GRQ로 이동된다. 또한 Goroutine이 생성되었을때 Goroutine을 생성한 Processor의 LRQ가 가득찬 경우, 생성된 Goroutine은 GRQ에 저장된다.

#### 1.3. System Call

각각의 System Call은 Sync 방식과 Async 방식 2가지 방식으로 동작한다. App이 Sync System Call을 호출하는 경우 Sync System Call의 동작이 끝나기 전까지 App은 어떠한 동작도 수행하지 못하고 Blocking 된다. 즉 App을 동작시키는 Thread는 App 동작을 일시 중지하고 System Call 처리를 수행한다. 반대로 App이 Async System Call을 호출하는 경우 App은 Async System Call 호출 후 원하는 동작을 수행할 수 있다. 단 App은 호출한 Async System Call의 동작 완료 Event를 별도로 수신하여 처리해야 한다.

Goroutine 내부에서도 Sync System Call을 호출하는 경우 Goroutine을 동작시키던 Thread는 Goroutine 동작을 일시 중지하고 Sync System Call 처리를 수행한다. 따라서 Sync System Call을 처리하는 동안 해당 Thread는 다른 Goroutine도 동작시키지 못한다. 이는 CPU Core를 재대로 활용하지 못하게 만드는 원인이 된다. Golang Scheduler는 이러한 문제를 해결하기 위해서 별도의 Thread를 이용하고 있다.

![[그림 3] Sync System Call]({{site.baseurl}}/images/theory_analysis/Golang_Goroutine_Scheduling/Sync_System_Call.PNG){: width="500px"}

[그림 3]은 Goroutine에서 Sync System Call 호출시 Golang Scheduler에서 해당 Goroutine을 처리하는 방식을 나타내고 있다. Sync System Call을 호출한 Goroutine이 실행되었던 Processor(P)에는 새로운 Thread(M)가 할당이 되고, Processor(P)가 소유하고 있는 LRQ의 다음 Goroutine을 실행한다. 이후에 Goroutine의 Sync System Call이 완료 되었다면 해당 Goroutine은 다시 LRQ에 들어가 나중에 다시 실행되게 된다. 남은 Thread(M)는 다른 Goroutine에서 Sync System Call을 호출할 경우를 위해서 남겨둔다.

![[그림 4] Async System Call]({{site.baseurl}}/images/theory_analysis/Golang_Goroutine_Scheduling/Async_System_Call.PNG){: width="500px"}

[그림 4]는 Goroutine에서 Async System Call 호출시 Golang Scheduler에서 해당 Goroutine을 처리하는 방식을 나타내고 있다. Async System Call을 호출한 Goroutine은 **Network Poller**에 들어가서 Async System Call의 완료 Event를 대기한다. 이후에 Network Poller는 Async System Call의 완료 Event를 수신하고 Event의 대상이되는 Goroutine을 다시 LRQ로 들어가 나중에 다시 실행되게 된다. Network Poller는 별도의 Background Thread에서 동작하며 Linux 환경에서는 **epoll()** 함수를 통해서 Async System Call 완료 Event를 수신한다.

#### 1.4. Work Stealing

{% highlight cpp%}
runtime.schedule() {
    // only 1/61 of the time, check the global runnable queue for a G.
    // if not found, check the local queue.
    // if not found,
    //     try to steal from other Ps.
    //     if not, check the global runnable queue.
    //     if not found, poll network.
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Goroutine Scheduling Algorithm</figcaption>
</figure>

Golang Scheduler는 LRQ에 Goroutine이 존재하지 않을 경우 다른 곳으로부터 Goroutine을 가져온다. [Code 1]은 Golang Scheduler가 수행하는 Goroutine Scheduling Algorithm을 나타내고 있다. LRQ에 Goroutine이 없다면 다른 LRQ의 Goroutine이 존재하는지 확인하고, LRQ에 Goroutine이 존재한다면 절반의 Goroutine을 가져온다.

다른 LRQ에도 Goroutine이 존재하지 않는다면, GRC에 Goroutine이 존재하는지 확인하고 존재하면 Goroutine을 가져온다. GRC에도 Goroutine이 존재하지 않는다면 Net Poller에 Goroutine이 존재하는지 확인하고 존재하면 Goroutine을 가져온다. 단 Goroutine의 Locality를 위해서 새로 생성된 Goroutine의 경우에는 3ms동안 Stealing 되지 않도록 제한한다.

#### 1.5. Fairness

Goroutine Scheduling에서 중요한 요소중 하나는 모든 Goroutine이 공평하게 실행되어야 한다는 점이다. 이러한 특성을 Fairness라고 명칭한다. Golang Scheduler는 Goroutine Fairness 보장을 위해서 여러가지 기법들을 적용하고 있다.

* Thread : Goroutine이 이용중인 Thread를 반환하지 않고 계속해서 이용할 수 있다. 이러한 Goroutine의 Thread 독점을 막기 위해서 Golang Scheduler는 Goroutine이 한번 실행될때 10ms이상 실행되는 경우 해당 Goroutine Timeout 시키고 선점(Premption)하여 강제로 GRQ로 이동시킨다.
* LRQ : 2개의 Goroutine이 LRQ에 번갈아가면서 저장되고 실행된다면, LRQ의 LIFO 부분에 의해서 FIFO 부분에 들어가 있는 Goroutine이 실행되지 않을 수 있다. 이러한 문제를 막기 위해서 Golang Scheduler는 LIFO 부분에 저장되어 있는 Goroutine은 10ms Timeout이 초기화 되지 않고 상속 되도록 만들었다. 따라서 LRQ의 LIFO 부분을 하나의 Goroutine이 10ms이상 점유하지 못한다.
* GRQ : LRQ에 존재하는 Goroutine만을 실행하면 GRQ에 존재하는 Goroutine이 실행되지 않을 수 있다. 이러한 문제를 막기 위해서 Golang Scheduler는 "61번" Goroutine Scheduling을 수행할때 LRQ보다 GRQ에 있는 Gorutine을 먼저 확인하고 실행하도록 만들었다. [Code 1]의 윗부분이 이러한 내용을 나타내고 있다. 
* Network Poller : Network Poller는 독립된 Background Thread이다. 따라서 OS Scheduler에 따라서 동작을 보장받는다.

### 2. 참조

* [https://developpaper.com/deep-decryption-of-the-scheduler-of-go-language/](https://developpaper.com/deep-decryption-of-the-scheduler-of-go-language/)
* [https://www.ardanlabs.com/blog/2018/08/scheduling-in-go-part2.html](https://www.ardanlabs.com/blog/2018/08/scheduling-in-go-part2.html)
* [https://www.youtube.com/watch?v=-K11rY57K7k](https://www.youtube.com/watch?v=-K11rY57K7k)
* [https://morsmachine.dk/netpoller](https://morsmachine.dk/netpoller)
* [https://www.timqi.com/2020/05/15/how-does-gmp-scheduler-work/](https://www.timqi.com/2020/05/15/how-does-gmp-scheduler-work/)
* [https://rakyll.org/scheduler/](https://rakyll.org/scheduler/)
* [https://www.programmersought.com/article/42797781960/](https://www.programmersought.com/article/42797781960/)
* [https://livebook.manning.com/book/go-in-action/chapter-6/11](https://livebook.manning.com/book/go-in-action/chapter-6/11)
* [https://blog.puppyloper.com/menus/Golang/articles/Goroutine%EA%B3%BC%20Go%20scheduler](https://blog.puppyloper.com/menus/Golang/articles/Goroutine%EA%B3%BC%20Go%20scheduler)
* [https://rokrokss.com/post/2020/01/01/go-scheduler.html](https://rokrokss.com/post/2020/01/01/go-scheduler.html)
