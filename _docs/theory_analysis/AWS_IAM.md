---
title: AWS IAM (Identity and Access Management)
category: 
date: 2022-07-30T12:00:00Z
lastmod: 2022-07-30T12:00:00Z
comment: true
adsense: true
---

AWS의 AWS IAM (Identity and Access Management) Service를 정리힌다. AWS IAM은 AWS Service의 인증, 인가를 담당한다.

### 1. Policy

{% highlight json linenos %}
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:DetachVolume"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:instance/*"
            ],
            "Condition": {
                "ArnEquals": {"ec2:SourceInstanceARN": "arn:aws:ec2:*:*:instance/instance-id"}
            }
        }
    ]
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 1] IAM Policy</figcaption>
</figure>

Policy는 인가 규칙을 정의하는 Service이다. [Text 1]은 간단한 IAM Policy를 나타내고 있다. IAM Policy는 다음과 같은 구성요소로 이루어져 있다.

* Effect :
* Principal :
* Action :
* Resource :
* Condition :
* Sid : 

### 2. User

### 3. Group

### 4. Role

#### 4.1. Trust Policy

### 5. Id-Based Policy, Resource Based Policy

### 6. 참조

* [https://www.youtube.com/watch?v=iPKaylieTV8](https://www.youtube.com/watch?v=iPKaylieTV8)
* Policy : [https://musma.github.io/2019/11/05/about-aws-iam-policy.html](https://musma.github.io/2019/11/05/about-aws-iam-policy.html)
* Policy Examples : [https://github.com/awsdocs/iam-user-guide/blob/main/doc_source/access_policies_examples.md](https://github.com/awsdocs/iam-user-guide/blob/main/doc_source/access_policies_examples.md)