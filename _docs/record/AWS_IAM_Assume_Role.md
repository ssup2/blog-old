---
title: AWS IAM Assume Role / aws CLI 이용 / Ubuntu 18.04
category: Record
date: 2022-03-25T12:00:00Z
lastmod: 2022-03-25T12:00:00Z
comment: true
adsense: true
---

### 1. 실행 환경

* Ubuntu 18.04 LTS 64bit, root user
* aws CLI
  * Region ap-northeast-2
  * Version 2.1.34

### 2. Assume Role Policy 생성

{% highlight json %}
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "*"
    }
  ]
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] assume-role-policy.json</figcaption>
</figure>

[파일 1]의 내용과 같이 AssumeRole 권한만 갖고 있는 Policy 파일을 작성한다.

~~~console
# aws iam create-policy --policy-name assume-role-policy --policy-document file://assume-role-policy.json
{
    "Policy": {
        "PolicyName": "assume-role-policy",
        "PolicyId": "ANPAUB2QWPR6YRY6MHBEV",
        "Arn": "arn:aws:iam::278805249149:policy/assume-role-policy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2022-03-24T16:45:27+00:00",
        "UpdateDate": "2022-03-24T16:45:27+00:00"
    }
}
~~~

[파일 1]을 이용하여 assume-role-policy 이름을 갖는 Policy를 생성한다.

### 3. User 생성, 설정

~~~console
# aws iam create-user --user-name assume-role-user
{
    "User": {
        "Path": "/",
        "UserName": "assume-role-user",
        "UserId": "AIDAUB2QWPR6RY232NBJV",
        "Arn": "arn:aws:iam::278805249149:user/assume-role-user",
        "CreateDate": "2022-03-26T14:47:24+00:00"
    }
}
~~~

Role을 Assume을 수행할 assume-role-user User를 생성한다.

~~~console
# aws iam create-access-key --user-name assume-role-user
{
    "AccessKey": {
        "UserName": "assume-role-user",
        "AccessKeyId": "XXXXXXXXXXXXXXXXXXXX",
        "Status": "Active",
        "SecretAccessKey": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        "CreateDate": "2022-03-26T14:47:46+00:00"
    }
}
~~~

assume-role-user의 Access Key를 생성한다.

~~~console
# aws iam attach-user-policy --user-name assume-role-user --policy-arn arn:aws:iam::278805249149:policy/assume-role-policy
~~~

assume-role-user User에 assume-role-policy Policy를 부여한다.

### 4. Role 생성, 설정

{% highlight json %}
{
	"Version": "2012-10-17",
	"Statement": [{
		"Effect": "Allow",
		"Action": "sts:AssumeRole",
		"Principal": {
			"AWS": "278805249149"
		},
		"Condition": {}
	}]
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] assume-role-trust-relationship.json</figcaption>
</figure>

Role의 Trust Relationship을 설정하는 [파일 2]을 생성한다. Principal의 AWS는 **Role을 부여받는 계정의 ID**를 의미한다.

~~~console
# aws iam create-role --role-name assume-role-role --assume-role-policy-document file://assume-role-trust-relationship.json
{
    "Role": {
        "Path": "/",
        "RoleName": "assume-role-role",
        "RoleId": "AROAUB2QWPR6Y7YWJMVWY",
        "Arn": "arn:aws:iam::278805249149:role/assume-role-role",
        "CreateDate": "2022-03-26T14:50:41+00:00",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": "sts:AssumeRole",
                    "Principal": {
                        "AWS": "278805249149"
                    },
                    "Condition": {}
                }
            ]
        }
    }
}
~~~

Assume할 Role인 assume-role-role을 생성한다.

~~~console
# aws iam attach-role-policy --role-name assume-role-role --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
~~~

assume-role-role Role에 EC2 제어 권한을 부여한다.

### 5. Assume Role

~~~console
# aws configure
AWS Access Key ID [None]: <Access Key>
AWS Secret Access Key [None]: <Secret Access Key>
Default region name [None]: ap-northeast-2
Default output format [None]:

# aws ec2 describe-instances
An error occurred (UnauthorizedOperation) when calling the DescribeInstances operation: You are not authorized to perform this operation.
~~~

assume-role-user로 AWS CLI를 설정한 이후에, EC2 Instance Describe 동작을 수행한다. assume-role-user User는 Assume Role 권한만 가지고 있기 때문에, EC2 Desribe 동작이 수행되지 못하는 것을 확인 할 수 있다.

~~~console
# aws sts assume-role --role-arn arn:aws:iam::278805249149:role/assume-role-role --role-session-name assume-role-session
{
    "Credentials": {
        "AccessKeyId": "ASIAUB2QWPR6VMAKPPWY",
        "SecretAccessKey": "hKdCa9Yhuzw8sDwLrvEyQBiMKgxAE+jFMlxyhCrA",
        "SessionToken": "IQoJb3JpZ2luX2VjEAcaDmFwLW5vcnRoZWFzdC0yIkgwRgIhAKJB+BDs7eXi1fmjcsakA6v/rmdZ4Tg7iFoUZ//AoygPAiEAqnt7lmN+h1rKzC1NENhs/h1y20UAoCa4Ugjhf4WZnhQqqQIIkf//////////ARADGgwyNzg4MDUyNDkxNDkiDJuUZDVGrlPkCYzFACr9AXgmS/T0GUfzKhb+u6cKaghRpHTLs+AAujyLbYX8R+jrLZiyKYCof6lgGr1PCuvO+3nFBIAtNQ5iRS9jAdAuQwf6rDQlabXqkKa10xKyD8WWtnMxsY98DDfBzpOpGbVUYSJ+Z1yvHcU7EYrUtRTEaEIaGVqyUZ6Znyv9g5PBiZNKu0MNSXhYDnbEoxBK65t8u80RQyvJGYt0e7Lumkx6WRdw0uZNfMzdFAkAEM9yY6loL/Cs78zNmKKqeb3UWcbwpxPv/XgImvgBnnxnPI/xHSV7bEmvtUdYel/5jtSUlLy7plI3NtGoCmpwoEnH6rkNcInjmVtKaXg+9pDt9AIwtd/8kQY6nAH35DEKtLWmWmjqqu9DHFNy/fsciABekdQ0dhgic3GcDwM3cAiGDBF1fkpuSG92281ZzpD4y0OcB5l0tSOUFidFbFeZ1+c1Hz7iQNQImeQUXz/+DdAJF/L1v4vvx55T0Gw5IAdVB+x6gVfnCfWjUnqzv/I7nyVBVdScX8S3Obtv6i53BJuEn1FaP1BOA1actx/a/YVsKpmmXasZ+JQ=",
        "Expiration": "2022-03-26T16:22:29+00:00"
    },
    "AssumedRoleUser": {
        "AssumedRoleId": "AROAUB2QWPR6Y7YWJMVWY:assume-role-session",
        "Arn": "arn:aws:sts::278805249149:assumed-role/assume-role-role/assume-role-session"
    }
}
~~~

Assume Role 동작을 수행하여 임시 AccessKeyID, SecretAccessKey, SessionToken을 얻는다.

~~~console
# export AWS_ACCESS_KEY_ID=ASIAUB2QWPR6VMAKPPWY
# export AWS_SECRET_ACCESS_KEY=hKdCa9Yhuzw8sDwLrvEyQBiMKgxAE+jFMlxyhCrA
# export AWS_SESSION_TOKEN=IQoJb3JpZ2luX2VjEAcaDmFwLW5vcnRoZWFzdC0yIkgwRgIhAKJB+BDs7eXi1fmjcsakA6v/rmdZ4Tg7iFoUZ//AoygPAiEAqnt7lmN+h1rKzC1NENhs/h1y20UAoCa4Ugjhf4WZnhQqqQIIkf//////////ARADGgwyNzg4MDUyNDkxNDkiDJuUZDVGrlPkCYzFACr9AXgmS/T0GUfzKhb+u6cKaghRpHTLs+AAujyLbYX8R+jrLZiyKYCof6lgGr1PCuvO+3nFBIAtNQ5iRS9jAdAuQwf6rDQlabXqkKa10xKyD8WWtnMxsY98DDfBzpOpGbVUYSJ+Z1yvHcU7EYrUtRTEaEIaGVqyUZ6Znyv9g5PBiZNKu0MNSXhYDnbEoxBK65t8u80RQyvJGYt0e7Lumkx6WRdw0uZNfMzdFAkAEM9yY6loL/Cs78zNmKKqeb3UWcbwpxPv/XgImvgBnnxnPI/xHSV7bEmvtUdYel/5jtSUlLy7plI3NtGoCmpwoEnH6rkNcInjmVtKaXg+9pDt9AIwtd/8kQY6nAH35DEKtLWmWmjqqu9DHFNy/fsciABekdQ0dhgic3GcDwM3cAiGDBF1fkpuSG92281ZzpD4y0OcB5l0tSOUFidFbFeZ1+c1Hz7iQNQImeQUXz/+DdAJF/L1v4vvx55T0Gw5IAdVB+x6gVfnCfWjUnqzv/I7nyVBVdScX8S3Obtv6i53BJuEn1FaP1BOA1actx/a/YVsKpmmXasZ+JQ=RoleSessionToken

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
~~~

획득한 AccessKeyID, SecretAccessKey, SessionToken을 이용하여 aws CLI를 설정한다. 이후에 EC2 Describe 동작을 수행하면, 동작하는 것을 확인 할 수 있다.

### 6. 참조

* [https://aws.amazon.com/ko/premiumsupport/knowledge-center/iam-assume-role-cli/](https://aws.amazon.com/ko/premiumsupport/knowledge-center/iam-assume-role-cli/)