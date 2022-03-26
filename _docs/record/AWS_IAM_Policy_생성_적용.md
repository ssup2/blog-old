---
title: AWS IAM Policy 생성, 적용 / aws CLI 이용 / Ubuntu 18.04
category: Record
date: 2022-03-16T12:00:00Z
lastmod: 2022-03-16T12:00:00Z
comment: true
adsense: true
---

### 1. 실행 환경

* Ubuntu 18.04 LTS 64bit, root user
* aws CLI
  * Region ap-northeast-2
  * Version 2.1.34

### 2. Policy 생성

{% highlight json %}
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
  ]
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] instance-describe-policy.json</figcaption>
</figure>

~~~console
# aws iam create-policy --policy-name instance-describe-policy --policy-document file://instance-describe-policy.json
{
    "Policy": {
        "PolicyName": "instance-describe-policy",
        "PolicyId": "ANPAUB2QWPR63Z4G22AZE",
        "Arn": "arn:aws:iam::278805249149:policy/instance-describe-policy",/
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2022-03-18T13:08:18+00:00",
        "UpdateDate": "2022-03-18T13:08:18+00:00"
    }
}
~~~

### 3. Policy 적용

~~~console
# aws iam create-user --user-name instance-describe-user
{
    "User": {
        "Path": "/",
        "UserName": "instance-describe-user",
        "UserId": "AIDAUB2QWPR6Y2ZWFY6HT",
        "Arn": "arn:aws:iam::278805249149:user/instance-describe-user",
        "CreateDate": "2022-03-26T16:11:16+00:00"
    }
}
~~~

instance-describe-user User를 생성하고 Secret을 생성한다.

~~~console
# aws iam attach-user-policy --user-name instance-describe-user --policy-arn arn:aws:iam::278805249149:policy/instance-describe
~~~

생성한 instance-describe-user User에 생성한 instance-describe-policy/ Policy를 붙인다.

### 4. Policy 동작 확인

~~~console
# aws configure
AWS Access Key ID [None]: <Access Key>
AWS Secret Access Key [None]: <Secret Access Key>
Default region name [None]: ap-northeast-2
Default output format [None]:
~~~

생성한 instance-describe-user User로 aws CLI를 설정한다.

~~~console
# aws ec2 describe-instances
{
    "Reservations": [
        {
            "Groups": [],
            "Instances": [
                {
                    "AmiLaunchIndex": 0,
                    "ImageId": "ami-033a6a056910d1137",
                    "InstanceId": "i-07f4fc518eb984bd9",
                    "InstanceType": "t2.micro",
                    "KeyName": "ssup2",
                    "LaunchTime": "2022-03-18T14:08:53+00:00",
...

# aws ec2 describe-vpcs
An error occurred (UnauthorizedOperation) when calling the DescribeVpcs operation: You are not authorized to perform this operation.
~~~

Describe Instance 동작은 가능하지만 Describe VPC 동작은 권한이 없어 실행하지 못하는것을 확인 할 수 있다.

### 5. 참조

* [https://www.youtube.com/watch?v=iPKaylieTV8](https://www.youtube.com/watch?v=iPKaylieTV8)