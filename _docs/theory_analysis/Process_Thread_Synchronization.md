---
title: Process/Thread Synchronization
category: Theory, Analysis
date: 2021-06-27T12:00:00Z
lastmod: 2021-06-27T12:00:00Z
comment: true
adsense: true
---

Process/Thread 동기화 기법을 분석한다.

### 1. Process/Thread Syncronization

#### 1.1. Mutex

{% highlight cpp %}
#include <pthread.h>  

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER; // mutex instance
int count; // shared resource

void IncreaseCount() {
    pthread_mutex_lock(&mutex); // lock
    count++;
    pthread_mutex_unlock(&mutex); // unlock
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Mutex CPP Example on Linux</figcaption>
</figure>

Mutex는 가장 기본적인 Process/Thread 동기화 기법이다. Shared Resource를 접근하는 영역인 Critical Section을 Mutex의 Lock 함수와 Unlock 함수로 감싸면 된다. [Code 1]은 Linux에서 동작하는 CPP 기반의 Mutex 예제를 나타내고 있다. pthread_mutex_lock() 함수가 Lock 함수 역활을 수행하고, pthread_mutex_unlock() 함수가 Unlock 함수 역활을 수행한다.

Mutex의 Lock 함수가 호출되면 해당 Mutex의 상태가 Lock/Unlock 상태인지 확인한다. 만약 Mutex가 Lock 상태라면 Lock 함수는 Mutex가 Unlock 상태가 될때까지 대기하다가 Unlock 상태가 되면 종료되고 Critical Section에 진입한다. 만약 Mutex가 Unlock 상태라면 Lock 함수는 바로 종료되고, Critical Section에 진입한다.

Mutex의 Lock 상태는 Mutex의 Unlock 함수의 호출을 통해서 Unlock 상태가 된다. 이때 Mutex의 Unlock 함수는 반드시 Mutex의 Lock 함수를 통해서 해당 Mutex를 Lock 상태로 만든 Thread에서 호출해야 한다. 즉 Mutex의 Lock 상태는 외부의 Thread에서 Unlock 상태로 변경할 수 없다. 이러한 특징은 Binary Semaphore와의 가장 큰 차이점이다.

Mutex가 Lock 상태에서 Mutex의 Lock 함수를 호출한 Thread는 Sleep 상태로 변경되고 Scheduling Out되어 Mutex가 Unlock 상태가 되기를 대기한다. 이후에 해당 Mutex가 Unlock 상태가 Sleep 상태의 Thread는 깨어나고, Lock 함수가 종료되면서 Critical Section에 진입하게 된다. 만약 동일한 Mutex에 다수의 Thread가 대기중이라면, Linux Mutex의 경우에는 우선순위가 가장 높은 Thread 하나만 깨어난다.

#### 1.2. Spinlock

Spinlock은 Mutex와 동일하게 Lock 함수와 Unlock 함수가 존재하는 Process/Thread 동기화 기법이다. Mutex와의 차이점은 Spinlock의 Lock 함수는 Sleep 상태로 변경되지 않으며, Spinlock이 Unlock 상태까지 계속 검사한다는 점이다. Thread가 Sleep 상태가 되지 않기 때문에 Process/Thread의 Context Switching Overhead가 발생하지 않는 다는 장점이 있지만, Lock 상태가 오래 지속될 경우 불필요한 CPU 낭비가 발생할 수 있다는 단점을 가지고 있다.

따라서 Spinlock은 Critical Section 부분의 실행시간이 매우 짧아 Lock 상태가 짧게 지속될수 있는 경우에만 이용해야 한다. 주로 App Level보다는 Kernel Level에서 이용된다. Linux Kernel의 Spinlock의 경우에는 일시적으로 모든 Interrupt를 Disable 시켜 Context Switching을 막는다.

#### 1.3. Condition Variable

{% highlight cpp %}
#include <pthread.h>  

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER; // mutex instance
pthread_cond_t cond = PTHREAD_COND_INITIALIZER; // condition variable instance
queue<request*> req_queue; // shared resource

void ProduceReqWakeupOne(request* req) {
    pthread_mutex_lock(&mutex); // lock
    req_queue.enqueue(req);
    pthread_mutex_unlock(&mutex); // unlock
    pthread_cond_signal(&cond); // wake up one thread
}

void ProduceReqWakeupAll(request* req) {
    pthread_mutex_lock(&mutex); // lock
    req_queue.enqueue(req);
    pthread_mutex_unlock(&mutex); // unlock
    pthread_cond_broadcast(&cond); // wake up all thread
}

request* ConsumeReq() {
    pthread_mutex_lock(&mutex); // lock
    while(req_queue.empty()) {
        pthread_cond_wait(&cond, &mutex);
    }
    request* req = req_queue.dequeue();
    pthread_mutex_unlock(&mutex); // unlock
    return req;
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] Condition Variable CPP Example on Linux</figcaption>
</figure>

Condition Variable은 Critical Section에서 진입한 Thread가 특정 조건이 될때까지 대기할때 이용된다. Mutex와 같이 이용되며, 단독으로는 이용되지 못한다. [Code 2]는 Linux에서 동작하는 CPP 기반 Condition Variable을 나타내고 있다. ConsumeReq() 함수에서 Request가 저장되는 Request Queue에 Request가 존재하지 않는다면 pthread_cond_wait() 함수를 통해서 대기 동작을 수행하는것을 확인할 수 있다.

Condition Variable을 이용하여 대기 동작을 수행하는 Thread는 Critical Section 진입시 이용한 Mutex를 Unlock 상태로 만들고 Sleep 상태가 된다. [Code 2]에서 pthread_cond_wait() 함수가 Condition Variable Instance 뿐만 아니라 Mutex Instance도 같이 Parameter로 받는 이유는 Parameter로 받은 Mutex를 Unlock 상태로 만들기 위해서 이다. Mutex를 Unlock 상태로 만들지 않으면 다른 Thread에서 Critical Section에 진입하지 못하기 때문이다.

Condition Variable에서 대기중인 Thread가 아닌 별도의 Process/Thread에서 특정 조건을 완성하면 대기중인 Thread를 깨워서 동작시킬수 있다. Condition Variable에서 대기중인 Thread는 깨어나면서 Critical Section 진입시 이용한 Mutex를 Lock 상태로 만들고 다시 Critical Section에 진입한다. Condition Variable에서 대기중인 Thread가 다수일 경우 하나의 Thread만 깨울수도 있고, 모든 Thread를 깨울수도 있다.

[Code 2]에서 pthread_cond_signal() 함수는 하나의 Thread만 깨우는 함수이고 pthread_cond_broadcast() 함수는 모든 Thread를 깨우는 함수이다. pthread_cond_signal() 함수는 가장 높은 Scheduling 우선순위가 높은 하나의 Thread를 깨운다.

#### 1.4. Monitor

{% highlight cpp %}
#include <pthread.h>  

class ReqQueue {
    pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER; // mutex instance
    pthread_cond_t cond = PTHREAD_COND_INITIALIZER; // condition variable instance
    queue<request*> req_queue; // shared resource

    void ProduceReq(request* req) {
        pthread_mutex_lock(&mutex); // lock
        req_queue.enqueue(req);
        pthread_mutex_unlock(&mutex); // unlock
        pthread_cond_signal(&cond); // wake up one thread
    }

    request* ConsumeReq() {
        pthread_mutex_lock(&mutex); // lock
        while(req_queue.empty()) {
            pthread_cond_wait(&cond, &mutex);
        }
        request* req = req_queue.dequeue();
        pthread_mutex_unlock(&mutex); // unlock
        return req;
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] Monitor CPP Example on Linux</figcaption>
</figure>

#### 1.5. Semaphore

{% highlight cpp %}
#include <semaphore.h>

queue<request*> req_queue; // shared resource
sem_t sem; // semaphore instance

void ProduceReq(request* req) {
    sem_wait(sem); // wait and decrease value
    req_queue.enqueue(req);
}

request* ConsumeReq() {
    request* req = req_queue.dequeue();
    sem_post(sem); // increase value
    return req;
}

int main() {
    sem_init(&sem, 0, 5); // initial value 5
    ...
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] Semaphore CPP Example on Linux</figcaption>
</figure>

### 2. 참조

* Mutex : [https://www.joinc.co.kr/w/Site/Thread/Beginning/Mutex](https://www.joinc.co.kr/w/Site/Thread/Beginning/Mutex)
* Mutex : [http://www.qnx.com/developers/docs/6.5.0/index.jsp?topic=%2Fcom.qnx.doc.neutrino_lib_ref%2Fp%2Fpthread_mutex_unlock.html](http://www.qnx.com/developers/docs/6.5.0/index.jsp?topic=%2Fcom.qnx.doc.neutrino_lib_ref%2Fp%2Fpthread_mutex_unlock.html)
* Spinlock : [https://seokbeomkim.github.io/posts/locks-in-the-kernel-1/](https://seokbeomkim.github.io/posts/locks-in-the-kernel-1/)
* Condition Variable : [https://stackoverflow.com/questions/49281906/which-thread-would-be-notified-by-pthread-cond-signal](https://stackoverflow.com/questions/49281906/which-thread-would-be-notified-by-pthread-cond-signal)
* Condition Variable : [https://elecs.tistory.com/135](https://elecs.tistory.com/135)
* Semaphore : [https://yebig.tistory.com/305](https://yebig.tistory.com/305)
* Semaphore : [https://www.joinc.co.kr/w/Site/system_programing/IPC/semaphores](https://www.joinc.co.kr/w/Site/system_programing/IPC/semaphores)
