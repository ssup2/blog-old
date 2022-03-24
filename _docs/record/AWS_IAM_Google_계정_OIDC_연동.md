---
title: AWS IAM Google OIDC 연동 / aws CLI 이용 / Ubuntu 18.04
category: Record
date: 2022-03-22T12:00:00Z
lastmod: 2022-03-22T12:00:00Z
comment: true
adsense: true
---

### 1. 실행 환경

* Ubuntu 18.04 LTS 64bit, root user
* aws CLI
  * Region ap-northeast-2
  * Version 2.1.34

### 2. Google 프로젝트 생성, OIDC 설정

### 3. Role 생성, 설정

{% highlight json %}
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "accounts.google.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "accounts.google.com:aud": "448771483088-25fslbvr9thmmi3acvo3omu0v1j6lqab.apps.googleusercontent.com"
        }
      }
    }
  ]
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] google-oidc-trust-relationship.json</figcaption>
</figure>

~~~console
# aws iam create-policy --policy-name instance-describe --policy-document file://instance-describe-policy.json
{
    "Role": {
        "Path": "/",
        "RoleName": "google-oidc",
        "RoleId": "AROAUB2QWPR6SMALTAXA5",
        "Arn": "arn:aws:iam::278805249149:role/google-oidc",
        "CreateDate": "2022-03-24T15:11:16+00:00",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Federated": "accounts.google.com"
                    },
                    "Action": "sts:AssumeRoleWithWebIdentity",
                    "Condition": {
                        "StringEquals": {
                            "accounts.google.com:aud": "448771483088-25fslbvr9thmmi3acvo3omu0v1j6lqab.apps.googleusercontent.com"
                        }
                    }
                }
            ]
        }
    }
}
~~~

~~~console
# aws iam attach-role-policy --role-name google-oidc --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
~~~

### 4. User 생성, 설정

~~~console
# aws iam create-user --user-name google-oidc
{
    "User": {
        "Path": "/",
        "UserName": "google-oidc",
        "UserId": "AIDAUB2QWPR65NEONKNJ3",
        "Arn": "arn:aws:iam::278805249149:user/google-oidc",
        "CreateDate": "2022-03-24T15:46:40+00:00"
    }
}
~~~

~~~console
# aws iam create-access-key --user-name google-oidc
{
    "AccessKey": {
        "UserName": "google-oidc",
        "AccessKeyId": "XXXXXXXXXXXXXXXXXXXX",
        "Status": "Active",
        "SecretAccessKey": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        "CreateDate": "2022-03-24T15:49:37+00:00"
    }
}
~~~

~~~console
# aws iam create-access-key --user-name google-oidc
~~~

### 5. Role 이용

### 6. 참조

* [https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)