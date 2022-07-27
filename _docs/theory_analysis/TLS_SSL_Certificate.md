---
title: TLS, SSL 인증서
category: Theory, Analysis
date: 2022-07-26T12:00:00Z
lastmod: 2022-08-26T12:00:00Z
comment: true
adsense: true
---

TLS, SSL 인증서를 분석한다.

### 1. Domain 적용 범위에 따른 인증서 분류

인증서가 적용되는 Domain의 범위에 따라서 다음과 같이 인증서가 분류된다.

#### 1.1. Single Domain

한개의 **단일 Domain**만 이용 가능한 인증서를 의미한다.

* aaa.ssup2.com
* bbb.ssup2.com

#### 1.2. Multi (SAN) Domain

하나의 **대표 Domain**과 다수의 **추가 Domain**이 이용 가능한 인증서를 의미한다.

* aaa.ssup2.com (대표) + bbb.ssup2.com (추가 1) + ccc.ssup2.com (추가 2)

#### 1.3. Wildcard Domain

의미 그대로 Wildcard(*) 문자가 포함되며, 하나의 Domain 또는 Subdomain 하위에 존재하는 **다수의 Subdomain**이 이용 가능한 인증서를 의미한다. Wildcard의 위치에 따라서 n차 인증서로 구분된다.

* *.ssup2.com / 2차
  * ssup2.com
  * aaa.ssup2.com
  * bbb.ssup2.com
* *.blog.ssup2.com / 3차
  * blog.ssup2.com
  * aaa.blog.ssup2.com
  * bbb.blog.ssup2.com

#### 1.4. Multi Wildcard Domain

다수의 Domain 또는 다수의 Subdomain 하위에 존재하는 다수의 Subdomain이 이용 가능한 인증서를 의미한다.

* *.blog.ssup2.com + *.git.ssup2.com
  * blog.ssup2.com
  * aaa.blog.ssup2.com
  * git.ssup2.com
  * aaa.git.ssup2.com

### 2. 참조

* [https://eunhyee.tistory.com/228](https://eunhyee.tistory.com/228)
* [https://knowledge.digicert.com/solution/SO9440.html](https://knowledge.digicert.com/solution/SO9440.html)
* [https://www.digicert.com/blog/how-to-choose-the-right-type-of-tls-ssl-certificate](https://www.digicert.com/blog/how-to-choose-the-right-type-of-tls-ssl-certificate)
