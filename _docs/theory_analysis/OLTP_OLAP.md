---
title: OLTP, OLAP
category: Theory, Analysis
date: 2018-08-25T12:00:00Z
lastmod: 2018-08-25T12:00:00Z
comment: true
adsense: true
---

OLTP(Online Transactional Processing)과 OLAP(Online Analytical Processing)은 Data Processing의 특성에 따라 분류한 범주이다. OTLP과 OLAP을 분석한다.

### 1. OTLP (Online Transaction Processing)

OTLP은 Transaction Processing의 의미처럼, Data의 Insert, Update, Delete 같은 Transaction 처리가 주가되는 Data Processing 과정을 의미한다. 다수의 User로부터 적은 양의 Data들을 동시에 변경하는 특성을 갖는다. Online Banking, Online 책구입, Online 숙소 예약같은 처리과정이 OTLP으로 분류된다.

### 2. OLAP (Online Analytical Processing)

OLAP은 Analytical Processing의 의미처럼, Data의 분석이 주가되는 Data Processing 과정을 의미한다. 소수의 User로부터 많은 양의 Data들을 동시에 읽는 특성을 갖는다. Data 분석을 통해 가치있는 정보로 변환하는 과정은 OLAP으로 분류된다.

### 3. 참조

* OLTP - [https://database.guide/what-is-oltp/](https://database.guide/what-is-oltp/)
* OLAP - [https://database.guide/what-is-olap/](https://database.guide/what-is-olap/)
