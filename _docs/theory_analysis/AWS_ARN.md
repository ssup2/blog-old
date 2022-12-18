---
title: AWS ARN (Amazon Resource Number)
category: Theory, Analysis
date: 2022-12-16T12:00:00Z
lastmod: 2022-12-16T12:00:00Z
comment: true
adsense: true
---

AWS의 ARN (Amazon Resource Number)을 정리한다.

### 1. AWS ARN

{: .newline }
> arn:[Partition]:[Service]:[Region]:[Account-ID]:[Resource-ID]
> arn:[Partition]:[Service]:[Region]:[Account-ID]:[Resource-Type]/[Resource-ID]
> arn:[Partition]:[Service]:[Region]:[Account-ID]:[Resource-Type]:[Resource-ID]
<figure>
<figcaption class="caption">[Text 1] AWS ARN Format</figcaption>
</figure>

AWS ARN은 AWS에서 관리하는 Resource의 이름을 의미한다. [Text 1]은 AWS ARN의 Format들을 나타내고 있다. 총 3가지의 Format이 존재하며 Resource-ID만 존재하는 한가지의 Format과 Resource-Type, Resource-ID만 존재하는 2가지의 Format이 존재한다. 필요에 따라서 몇몇 ARN의 경우에는 Region, Account-ID가 생략될 수 있다. AWS ARN Format의 각 구성 요소들은 다음과 같다.

* Partition : AWS Region의 Group을 의미한다. "aws", "aws-cn" (중국), "aws-us-gov" (미국 정부) 3개의 Partiton이 존재하며, 대부분의 경우에는 "aws" Partition에 소속된다.
* Service : AWS Service들을 분류하기 위한 Namespace를 의미한다. 일반적으로 "iam", "sns", "ec2"와 같이 AWS Service 이름을 소문자로 변환하여 이용한다.
* Region : AWS의 Region을 의미한다. "us-east-2"와 같이 Region Code가 들어간다.
* Account-ID : 각 AWS Account마다 부여되는 공유의 Account ID를 의미한다.
* Resource-Type : AWS Resource의 Type을 의미한다. "user", "vpc"와 같이 AWS Resource를 소문자로 변환하여 이용한다.
* Resource-ID : AWS Resource에게 부여되는 고유 ID를 의미한다.

{: .newline }
> IAM User : arn:aws:iam::123456789012:user/ssup2
> SNS Topic : arn:aws:sns:us-east-1:123456789012:example-sns-topic-name
> VPC : arn:aws:ec2:us-east-1:123456789012:vpc/vpc-0e9801d129EXAMPLE
<figure>
<figcaption class="caption">[Text 2] AWS ARN Examples</figcaption>
</figure>

[Text 2]는 AWS ARN의 예제들을 나타내고 있다.

#### 1.1. Wildcard

{: .newline }
> ALL EC2 Volumes : arn:aws:ec2:*:*:volume/*
> ALL EC2 Instances : arn:aws:ec2:*:*:instance/*
<figure>
<figcaption class="caption">[Text 3] AWS ARN Wildcard Examples</figcaption>
</figure>

AWS ARN은 Wildcard 문법을 지원하며, Wildcard 문법을 통해서 다수의 ARN을 표현할 수 있다. [Text 3]은 Wildcard의 사용 예제를 나타내고 있다. 주로 AWS IAM Policy 설정시 많이 이용된다. "arn:aws:ec2:*:*:instance/s*"와 같이 특정 구성요소의 일부에만 Wildcard를 적용할 수 없다.

### 2. 참조

* [https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html)
* [https://medium.com/harrythegreat/aws%EC%9D%98-arn-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0-8c20d0ccbbfd](https://medium.com/harrythegreat/aws%EC%9D%98-arn-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0-8c20d0ccbbfd)