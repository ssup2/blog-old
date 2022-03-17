---
title: AWS IAM Admin Group, User 생성 / aws CLI 이용 / Ubuntu 18.04
category: Record
date: 2022-03-17T12:00:00Z
lastmod: 2022-03-17T12:00:00Z
comment: true
adsense: true
---

### 1. 실행 환경

* Ubuntu 18.04 LTS 64bit, root user
* aws CLI
  * Region ap-northeast-2
  * Version 2.1.34

### 2. Admin Group 생성, 설정

admins 이름을 갖는 Admin Group을 생성한다.

~~~console
# aws iam create-group --group-name admins
{
    "Group": {
        "Path": "/",
        "GroupName": "admins",
        "GroupId": "AGPAUB2QWPR6TMUEMIBQI",
        "Arn": "arn:aws:iam::278805249149:group/admins",
        "CreateDate": "2022-03-17T15:51:18+00:00"
    }
}
~~~

admins Group에 AdministratorAccess Policy를 붙여 admins Group에 소속된 user들이 Admin 권한을 갖도록 설정한다.

~~~console
# aws iam attach-group-policy --group-name Admins --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
~~~

### 3. Admin User 생성, 설정

admin User를 생성한다.

~~~console
# aws iam create-user --user-name admin
{
    "User": {
        "Path": "/",
        "UserName": "admin",
        "UserId": "AIDAUB2QWPR6T3VCZQUUD",
        "Arn": "arn:aws:iam::278805249149:user/admin",
        "CreateDate": "2022-03-17T15:52:39+00:00"
    }
}
~~~

생성한 admin User를 admin Group에 추가한다.

~~~console
# aws iam add-user-to-group --group-name admins --user-name admin
~~~

생성한 admin User의 Access Key를 생성한다.

~~~console
# aws iam create-access-key --user-name admin
{
    "AccessKey": {
        "UserName": "admin",
        "AccessKeyId": "XXXXXXXXXXXXXXXXXXXX",
        "Status": "Active",
        "SecretAccessKey": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        "CreateDate": "2022-03-17T16:06:25+00:00"
    }
}
~~~

### 4. 참조

* [https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html)