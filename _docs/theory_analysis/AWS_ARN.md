---
title: AWS ARN (Amazon Resource Number)
category: 
date: 2022-07-30T12:00:00Z
lastmod: 2022-07-30T12:00:00Z
comment: true
adsense: true
---

AWS의 ARN (Amazon Resource Number)을 정리한다.

### 1. AWS ARN

{: .newline }
> arn:partition:service:region:account-id:resource-id
> arn:partition:service:region:account-id:resource-type/resource-id <br/>
> arn:partition:service:region:account-id:resource-type:resource-id <br/>
<figure>
<figcaption class="caption">[Text 1] AWS ARN Format</figcaption>
</figure>

AWS ARN은 AWS에서 관리하는 Resource의 이름을 의미한다. [Text 1]은 AWS ARN의 Format들을 나타내고 있다. 총 3가지의 Format이 존재하며 resource-id만 존재하는 한가지의 Format과 resource-type, resource-id만 존재하는 2가지의 Format이 존재한다. 필요에 따라서 몇몇 ARN의 경우에는 region, account-id 가 생략될 수 있다. AWS ARN Format의 각 구성 요소들은 다음과 같다.

* partition : 

* service : 

* region : 

* account-id : 

* resource-type : 

* resource-id : 

#### 1.1. Wildcard

### 2. 참조

* [https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html)
* [https://medium.com/harrythegreat/aws%EC%9D%98-arn-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0-8c20d0ccbbfd](https://medium.com/harrythegreat/aws%EC%9D%98-arn-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0-8c20d0ccbbfd)