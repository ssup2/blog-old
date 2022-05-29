---
title: Golang pprof Profiling
category: Programming
date: 2022-05-18T12:00:00Z
lastmod: 2022-05-18T12:00:00Z
comment: true
adsense: true
---

Golang의 Profiling 기법을 정리한다.

### 1. Profiling 방법

#### 1.1. net/http/pprof Package

#### 1.2. github.com/pkg/profile Package

#### 1.3. Unit Test

### 2. Profiling 종류

#### 2.1. CPU

#### 2.2. Heap

#### 2.3. Thread Create

#### 2.4. Goroutine

#### 2.5. Block

#### 2.6. Mutex

### 3. 참조

* [https://github.com/DataDog/go-profiler-notes/blob/main/guide/README.md](https://github.com/DataDog/go-profiler-notes/blob/main/guide/README.md)
* [https://hackernoon.com/go-the-complete-guide-to-profiling-your-code-h51r3waz](https://hackernoon.com/go-the-complete-guide-to-profiling-your-code-h51r3waz)
* [https://github.com/pkg/profile](https://github.com/pkg/profile) 
* [https://go.dev/doc/diagnostics](https://go.dev/doc/diagnostics)
* [https://github.com/google/pprof](https://github.com/google/pprof)
* [https://jvns.ca/blog/2017/09/24/profiling-go-with-pprof/](https://jvns.ca/blog/2017/09/24/profiling-go-with-pprof/)
* [https://medium.com/a-journey-with-go/go-how-does-gops-interact-with-the-runtime-778d7f9d7c18](https://medium.com/a-journey-with-go/go-how-does-gops-interact-with-the-runtime-778d7f9d7c18)