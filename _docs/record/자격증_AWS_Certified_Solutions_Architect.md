---
title: 자격증 AWS Certified Solutions Architect
category: Record
date: 2019-11-01T12:00:00Z
lastmod: 2020-07-14T12:00:00Z
comment: true
adsense: true
---

### 1. IAM

### 2. EC2

#### 2.1. User Data

* EC2 Instance가 **처음 부팅**될때 딱 한번만 실행되는 Script를 의미한다.
* root User로 실행된다.

#### 2.2. Lunch Type Type

* On-Demand Instance : 예상하지 못한 Event 발생을 대처하기 위해서 예약없이 투입된 Instance를 의미한다. 가장 높은 이용비를 갖는다.

* Reserved Instance
  * Reserved Instance : 예약된 Instance를 의미한다. On-Demand Instance에 비해서 최대 75% 저렴하다. 1~3년 단위로 예약이 가능하다.
  * Convertible Reserved : 예약된 Instance이지만 Type을 변경할 수 있다. On-Demand Instance에 비해서 최대 54% 저렴하다.
  * Scheduled Reserved : 날짜, 주, 월 주기로 예약된 Instance를 의미한다.

* Spot Instance : 언제든지 중단될수 있는 Instance를 의미한다. 가장 저렴한 Instacnce이다. On-Demand Instance에 비해서 최대 90% 저렴하다.

* Dedicated Instance : ??

* Dedicated Host : ??

### 3. Security Group

* Default 정책 : 모든 Inboud Traffic은 거부, 모든 Outbound Traffic은 허용한다.
* Src IP, Dest IP, Security Group 단위로 허용 여부를 설정할 수 있다.

