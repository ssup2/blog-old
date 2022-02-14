---
title: PromQL Data Type
category: Theory, Analysis
date: 2022-02-14T12:00:00Z
lastmod: 2022-02-14T12:00:00Z
comment: true
adsense: true
---

PromQL의 Data Type을 정리한다.

### 1. PromQL Data Type

#### 1.1. String

![[그림 1] String Type]({{site.baseurl}}/images/theory_analysis/PromQL_Data_Type/PromQL_String_Type.PNG)

#### 1.2. Scalar

![[그림 2] Scalar Type, Integer]({{site.baseurl}}/images/theory_analysis/PromQL_Data_Type/PromQL_Scalar_Type1.PNG)

![[그림 3] Scalar Type, Float]({{site.baseurl}}/images/theory_analysis/PromQL_Data_Type/PromQL_Scalar_Type2.PNG)

#### 1.3. Instanct Vector

![[그림 4] Instanct Vector, node_memory_MemAvailable_bytes]({{site.baseurl}}/images/theory_analysis/PromQL_Data_Type/PromQL_Instant_Vector_Type1.PNG)

![[그림 5] Instanct Vector, node_memory_MemAvailable_bytes Graph]({{site.baseurl}}/images/theory_analysis/PromQL_Data_Type/PromQL_Instant_Vector_Type2.PNG)

![[그림 6] Instanct Vector, node_memory_MemAvailable_bytes Selector]({{site.baseurl}}/images/theory_analysis/PromQL_Data_Type/PromQL_Instant_Vector_Type3.PNG)

#### 1.4. Range Vector

![[그림 7] Range Vector, node_memory_MemAvailable_bytes[1m]]({{site.baseurl}}/images/theory_analysis/PromQL_Data_Type/PromQL_Range_Vector_Type.PNG)

### 2. 참조

* [https://prometheus.io/docs/prometheus/latest/querying/basics/#expression-language-data-types](https://prometheus.io/docs/prometheus/latest/querying/basics/#expression-language-data-types)
* [https://devthomas.tistory.com/15](https://devthomas.tistory.com/15)
* [https://gurumee92.tistory.com/244](https://gurumee92.tistory.com/244)