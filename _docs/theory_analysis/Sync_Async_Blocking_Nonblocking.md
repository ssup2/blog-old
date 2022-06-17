---
title: Sync/Async, Blocking/Non-blocking
category: Theory, Analysis
date: 2022-06-17T00:34:00Z
lastmod: 2022-06-17T00:34:00Z
comment: true
adsense: true
---

Sync/Async, Blocking/Non-blocking 개념을 정리한다.

### 1. Sync/Async, Blocking/Non-blocking

#### 1.1. Sync/Async

Sync, Async는 요청을 전송한 주체가 요청 결과를 **어디서 처리**하는지에 따라서 결정된다.

* Sync - 요청 결과를 요청을 전송한 주체에서 처리한다.
* Async - 요청 결과를 요청을 전송한 주체가 아닌 다른 곳에서 처리될 수 있다.

#### 1.2. Blocking/Non-blocking

Blocking, Non-blocking은 요청을 전송한 주체가 요청 결과를 받을때 까지 **다른 일**을 할수 있는지, 없는지에 따라 결정된다.

* Blocking - 요청 결과를 받을때까지 요청을 전송한 주체는 다른일을 하지 못한다.
* Non-blocking - 요청 결과를 받지 않아도 다른일을 수행할 있다.

#### 1.3. Cases

Linux I/O 관련 함수들은 Sync/Async, Blocking/Non-blocking 인지에 따라서 4가지로 분류할 수 있다.

* Sync + Blocking
  * I/O 함수 - read(), write() without O_NONBLOCK
  * I/O 처리 결과를 함수를 호출한 곳에서 처리하며, I/O 처리가 완료될때까지 I/O 함수를 호출한 Thread는 다른일을 수행하지 못한다.

* Sync + Non-blocking
  * I/O 함수 - read(), write() with O_NONBLOCK
  * I/O 처리 결과를 함수를 호출한 곳에서 처리하지만, I/O 처리가 완료되지 않더라도 I/O 함수를 호출한 Thread는 다른일을 수행할 수 있다.
  * I/O 함수를 호출한 Thread는 계속 I/O 함수를 다시 호출하여 I/O 처리가 결과를 확인해야 한다.

* Async + Blocking
  * I/O 함수 - read(), write() with select(), epoll()
  * I/O 처리 결과는 별도의 Thread에서 처리될 수 있으며, I/O 처리가 완료될때까지 I/O 함수를 호출한 Thread는 다른일을 수행하지 못한다.

* Async + Non-blockin속
  * I/O 함수 - aio()
  * I/O 처리 결과는 별도의 Thread에서 처리될 수 있으며, I/O 처리가 완료되지 않더라도 I/O 함수를 호출한 Thread는 다른일을 수행할 수 있다.

### 2. 참조

* [https://developer.ibm.com/articles/l-async/](https://developer.ibm.com/articles/l-async/)
* [https://interconnection.tistory.com/141](https://interconnection.tistory.com/141)
* [https://jh-7.tistory.com/25](https://jh-7.tistory.com/25)
