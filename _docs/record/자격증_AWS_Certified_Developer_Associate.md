---
title: 자격증 AWS Certified Developer Associate 이론 정리
category: Record
date: 2022-11-10T12:00:00Z
lastmod: 2022-11-10T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. Base

아래의 정리된 내용을 바탕으로 부족한 내용 정리

* [AWS Solutions Architecture Assosicate](https://ssup2.github.io/record/%EC%9E%90%EA%B2%A9%EC%A6%9D_AWS_Solutions_Architect_Associate/)

### 2. AWS API & CLI

#### 2.1. API Call Limit (Quota)

* API 호출에 제한이 걸려 있음
  * Ex) EC2 DescribeInstance : 100 Call Per Seconds
  * Ex) S3 GetObject 5500 : 5500 Call Per Seconds, Per Prefix
  * 제한을 넘길시 ThrottlingException 오류 발생
  * Exponential Backoff 수행
* Exponential Backoff
  * AWS SDK를 이용한 API 호출시 AWS SDK 내부적으로 Exponential Backoff Logic이 포함되어 있음
  * AWS API를 직접 호출시 Client에서 Exponential Backoff Logic을 직접 구현
    * 5XX Error 발생시에만 Backoff를 시도하도록 구현 필요
    * 4XX Error 발생시 Backoff 수행 X

#### 2.2. Credential Provider Chain

* 다음의 순서대로 Credential을 찾아 적용
  * CLI Option : "--region", "--output", "--profile"
  * Env : AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN
  * CLI Credential File : ~/.aws/credentials
  * CLI Configuration File : ~/.aws/config
  * Container Credential
  * Instance Profile Credential

#### 2.3. Signing Request

* 대부분의 API 호출시 Access Key, Secret Access key를 이용하여 요청에 Signing 필요
* SDK, CLI를 통한 AWS API 호출시 SDK, CLI 내부적으로 Signing을 알아서 수행
* AWS API를 직접 호출시 "SigV4" 방식으로 요청을 Signing하여 전송

### 3. CloudFront

### 4. Reference

* [https://www.udemy.com/course/best-aws-certified-developer-associate/](https://www.udemy.com/course/best-aws-certified-developer-associate/)