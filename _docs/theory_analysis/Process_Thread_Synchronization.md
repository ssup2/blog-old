---
title: Process/Thread Synchronization
category: Theory, Analysis
date: 2021-06-27T12:00:00Z
lastmod: 2021-06-27T12:00:00Z
comment: true
adsense: true
---

### 1. Process/Thread Syncronization

#### 1.1. Mutex

{% highlight cpp %}
#include <pthread.h>  

int count; // shared resource
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER; // mutex instance

void increase_count() {
    pthread_mutex_lock(&mutex);   // lock
    count++;
    pthread_mutex_unlock(&mutex); // unlock
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Mutex Example</figcaption>
</figure>

#### 1.2. Condition Variable

{% highlight cpp %}
#include <pthread.h>  

queue<request*> req_queue; // shared resource
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER; // mutex instance
pthread_cond_t cond = PTHREAD_COND_INITIALIZER;    // condition variable instance

void produce_req_wakeup_one(request* req) {
    pthread_mutex_lock(&mutex);   // lock
    req_queue.enqueue(req);
    pthread_mutex_unlock(&mutex); // unlock
    pthread_cond_signal(&cond);   // wake up one thread
}

void produce_req_wakeup_all(request* req) {
    pthread_mutex_lock(&mutex);    // lock
    req_queue.enqueue(req);
    pthread_mutex_unlock(&mutex);  // unlock
    pthread_cond_broadcast(&cond); // wake up all thread
}

request* consume_req() {
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
<figcaption class="caption">[Code 2] Condition Variable Example</figcaption>
</figure>

#### 1.3. Semaphore

#### 1.4. Monitor

### 2. 참조

* Mutex : [https://www.joinc.co.kr/w/Site/Thread/Beginning/Mutex](https://www.joinc.co.kr/w/Site/Thread/Beginning/Mutex)
* Semaphore : [https://yebig.tistory.com/305](https://yebig.tistory.com/305)
* Condition Variable : [https://elecs.tistory.com/135](https://elecs.tistory.com/135)