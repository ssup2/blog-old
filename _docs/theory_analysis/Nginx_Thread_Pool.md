---
title: Nginx Thread Pool
category: Theory, Analysis
date: 2020-08-24T12:00:00Z
lastmod: 2020-08-24T12:00:00Z
comment: true
adsense: true
---

Nginx의 Thread Pool 기법을 분석한다.

### 1. Nginx Thread Pool

![[그림 1] Nginx Worker Process without Thread Pool]({{site.baseurl}}/images/theory_analysis/Nginx_Thread_Pool/Nginx_Worker_Process_Without_Thread_Pool.PNG){: width="400px"}

![[그림 2] Nginx Worker Process with Thread Pool]({{site.baseurl}}/images/theory_analysis/Nginx_Thread_Pool/Nginx_Worker_Process_With_Thread_Pool.PNG)

### 2. 참조

* [https://www.nginx.com/blog/thread-pools-boost-performance-9x/](https://www.nginx.com/blog/thread-pools-boost-performance-9x/)