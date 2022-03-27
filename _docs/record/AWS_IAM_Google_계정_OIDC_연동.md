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

Google Cloud Platform에서 OIDC 기반의 ID Token을 얻기 위해서는 설정이 필요하다.

![[그림 1] Project 생성]({{site.baseurl}}/images/record/AWS_IAM_Google_OIDC_Interlock/Google_Create_Project.PNG){: width="700px"}

[그림 1]과 같이 [https://console.developers.google.com](https://console.developers.google.com/)에 접근하여 Project를 생성한다.

![[그림 2] OAuth 추가]({{site.baseurl}}/images/record/AWS_IAM_Google_OIDC_Interlock/Google_Create_OIDC_1.PNG){: width="700px"}

[그림 2]와 같이 "API 및 서비스" 항목으로 들어가 "OAuth 클라이언트 ID" 추가를 선택하여 OAuth 인증 방식을 추가한다.

![[그림 3] OAuth Client ID 생성]({{site.baseurl}}/images/record/AWS_IAM_Google_OIDC_Interlock/Google_Create_OIDC_2.PNG){: width="700px"}

[그림 3]과 같이 "웹 애플리케이션" 유형의 Client ID를 생성한다. "이름"은 임의로 지정하면 된다. "리다이렉션 URI"의 경우에는 "http://127.0.0.1:3000/auth/google/callback"으로 설정한다. 생성이 완료되면 **Client ID**와 **Client Secret**을 확인한다.

### 3. Role 생성, 설정

{% highlight json %}
{
  "Version": "2012-10-17",
  "Statement":
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
<figcaption class="caption">[파일 1] google-oidc-role-trust-relationship.json</figcaption>
</figure>

Assume할 Role인 google-oidc-role Role을 생성한다. [파일 1]의 내용처럼 google-oidc-role Role의 Trust Relationship을 설정한다. Condition의 accounts.google.com:aud 값은 반드시 **Client ID**로 설정해야 한다. Google Cloud Platform에서 발행되는 ID Token의 Audience Claim에 Client ID가 설정되기 때문이다.

~~~console
# aws iam create-role --role-name google-oidc-role --assume-role-policy-document file://google-oidc-role-trust-relationship.json
{
	"Role": {
		"Path": "/",
		"RoleName": "google-oidc-role",
		"RoleId": "AROAUB2QWPR6X3BYU2DG7",
		"Arn": "arn:aws:iam::278805249149:role/google-oidc-role",
		"CreateDate": "2022-03-27T14:46:36+00:00",
		"AssumeRolePolicyDocument": {
			"Version": "2012-10-17",
			"Statement": [{
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
			}]
		}
	}
}
~~~

google-oidc-role Role을 생성한다.

~~~console
# aws iam attach-role-policy --role-name google-oidc-role --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
~~~

생성한 google-oidc-role Role에 AmazonEC2FullAccess 권한을 부여한다.

### 4. User 생성, 설정

~~~console
# aws iam create-user --user-name no-policy-user
{
    "User": {
        "Path": "/",
        "UserName": "no-policy-user",
        "UserId": "AIDAUB2QWPR6TCGK6DHFZ",
        "Arn": "arn:aws:iam::278805249149:user/no-policy-user",
        "CreateDate": "2022-03-27T15:20:35+00:00"
    }
}
~~~

모든 권한을 갖고 있지 않는 no-policy-user User를 생성한다.

~~~console
# aws iam create-access-key --user-name no-policy-user
{
    "AccessKey": {
        "UserName": "no-policy-user",
        "AccessKeyId": "AKIAUB2QWPR62XXMIF5W",
        "Status": "Active",
        "SecretAccessKey": "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",
        "CreateDate": "2022-03-27T15:21:37+00:00"
    }
}
~~~

생성한 no-policy-user User에 Access Key를 생성한다.

### 5. ID Token 획득

아래 Repo의 Program을 실행하여 ID Token을 획득한다.

* [https://github.com/ssup2/golang-Google-OIDC](https://github.com/ssup2/golang-Google-OIDC)

~~~console
# export GOOGLE_OAUTH2_CLIENT_ID=XXX
# export GOOGLE_OAUTH2_CLIENT_SECRET=XXX
# go run main.go
~~~

{% highlight json %}
{
	"OAuth2Token": {
		"access_token": "ya29.A0ARrdaM_Y_JCmxefKPNfi8Q26hzrCu1nDKiV_UYKAjDud_N3MnksWdxS3SlfyTUwi9IB1z_N2KyZRTgBS_BdEXXrLKQi3ZQMrDvZOAx2dwXvkknN7dJS6HM1-gpB7JMHk2SzRTi23eldSqjEG8P4NueCamROX_w",
		"token_type": "Bearer",
		"expiry": "2022-03-28T01:17:07.510546947+09:00"
	},
	"IDToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjU4YjQyOTY2MmRiMDc4NmYyZWZlZmUxM2MxZWIxMmEyOGRjNDQyZDAiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI0NDg3NzE0ODMwODgtMjVmc2xidnI5dGhtbWkzYWN2bzNvbXUwdjFqNmxxYWIuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI0NDg3NzE0ODMwODgtMjVmc2xidnI5dGhtbWkzYWN2bzNvbXUwdjFqNmxxYWIuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTM2MzI0NTgzMjQwNTY4MzY2MjEiLCJlbWFpbCI6InN1cHN1cDU2NDJAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiJfaEo3RFREQmJORWlsX3E2S21WLWlBIiwibm9uY2UiOiJMZXpsQWNYTlZ6Y3R0bGVPV0hYaVVBIiwibmFtZSI6InNzcyBzc3MiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EtL0FPaDE0R2otLXUybVgtOEFITkNyeGJ4ZmJOR1R6YnJ4QmJSbExoT2dpM3M0dFE9czk2LWMiLCJnaXZlbl9uYW1lIjoic3NzIiwiZmFtaWx5X25hbWUiOiJzc3MiLCJsb2NhbGUiOiJrbyIsImlhdCI6MTY0ODM5NDIzMCwiZXhwIjoxNjQ4Mzk3ODMwfQ.lAikNJYXUJ7U1JEotxRK5_4OqODZX8tWBAEzBKKtze10nadkH3mu0JRHNhqdg6UMFKZdWMfp15iKghn5KxwBubKSn030cSWI8Y6trnkLNz7EZ-kNvVX6eetseloAzQmvxTCR188tz2baYFWguzIYAB0eCJx_qFePn3G2tirGJYrPaEwB8qdMxkFqYz5jQAAYYzPwjPS4MXFPlm2CcAS4da9k0eSmQ-nESPi2u_P-3NYVqRYhnpAxPruVd08S8mRLC9ljnOnqMx-tD3MbUWs0eOk8dkgL8Pfu92JfNAcaiaksHJ7dRENO0tEFEKpLaRr4-F7Ev2lGrA_7HbmN4eIHow",
	"IDTokenClaims": {
		"iss": "https://accounts.google.com",
		"azp": "448771483088-25fslbvr9thmmi3acvo3omu0v1j6lqab.apps.googleusercontent.com",
		"aud": "448771483088-25fslbvr9thmmi3acvo3omu0v1j6lqab.apps.googleusercontent.com",
		"sub": "113632458324056836621",
		"email": "supsup5642@gmail.com",
		"email_verified": true,
		"at_hash": "_hJ7DTDBbNEil_q6KmV-iA",
		"nonce": "LezlAcXNVzcttleOWHXiUA",
		"name": "sss sss",
		"picture": "https://lh3.googleusercontent.com/a-/AOh14Gj--u2mX-8AHNCrxbxfbNGTzbrxBbRlLhOgi3s4tQ=s96-c",
		"given_name": "sss",
		"family_name": "sss",
		"locale": "ko",
		"iat": 1648394230,
		"exp": 1648397830
	}
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 1] http://127.0.0.1:3000 Result</figcaption>
</figure>

"http://127.0.0.1:3000"에 접속하고 Google Login을 수행하면 [Text 1]의 내용과 같이 **ID Token**을 확인 할 수 있다.

### 6. Assume Role with Web Identity

~~~console
# aws configure
AWS Access Key ID [None]: <Access Key>
AWS Secret Access Key [None]: <Secret Access Key>
Default region name [None]: ap-northeast-2
Default output format [None]:

# aws ec2 describe-instances
An error occurred (UnauthorizedOperation) when calling the DescribeInstances operation: You are not authorized to perform this operation.
~~~

aws CLI를 no-policy-user User로 설정한다. no-policy-user User는 아무런 권한을 갖고 있지 않기 때문에 EC2 Describe 동작을 수행하지 못하는 것을 확인 할 수 있다.

~~~console
# aws sts assume-role-with-web-identity --role-arn arn:aws:iam::278805249149:role/google-oidc-role --role-session-name google-oidc-session --web-identity-token eyJhbGciOiJSUzI1NiIsImtpZCI6IjU4YjQyOTY2MmRiMDc4NmYyZWZlZmUxM2MxZWIxMmEyOGRjNDQyZDAiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI0NDg3NzE0ODMwODgtMjVmc2xidnI5dGhtbWkzYWN2bzNvbXUwdjFqNmxxYWIuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI0NDg3NzE0ODMwODgtMjVmc2xidnI5dGhtbWkzYWN2bzNvbXUwdjFqNmxxYWIuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTM2MzI0NTgzMjQwNTY4MzY2MjEiLCJlbWFpbCI6InN1cHN1cDU2NDJAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiJfaEo3RFREQmJORWlsX3E2S21WLWlBIiwibm9uY2UiOiJMZXpsQWNYTlZ6Y3R0bGVPV0hYaVVBIiwibmFtZSI6InNzcyBzc3MiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EtL0FPaDE0R2otLXUybVgtOEFITkNyeGJ4ZmJOR1R6YnJ4QmJSbExoT2dpM3M0dFE9czk2LWMiLCJnaXZlbl9uYW1lIjoic3NzIiwiZmFtaWx5X25hbWUiOiJzc3MiLCJsb2NhbGUiOiJrbyIsImlhdCI6MTY0ODM5NDIzMCwiZXhwIjoxNjQ4Mzk3ODMwfQ.lAikNJYXUJ7U1JEotxRK5_4OqODZX8tWBAEzBKKtze10nadkH3mu0JRHNhqdg6UMFKZdWMfp15iKghn5KxwBubKSn030cSWI8Y6trnkLNz7EZ-kNvVX6eetseloAzQmvxTCR188tz2baYFWguzIYAB0eCJx_qFePn3G2tirGJYrPaEwB8qdMxkFqYz5jQAAYYzPwjPS4MXFPlm2CcAS4da9k0eSmQ-nESPi2u_P-3NYVqRYhnpAxPruVd08S8mRLC9ljnOnqMx-tD3MbUWs0eOk8dkgL8Pfu92JfNAcaiaksHJ7dRENO0tEFEKpLaRr4-F7Ev2lGrA_7HbmN4eIHow

{
    "Credentials": {
        "AccessKeyId": "ASIAUB2QWPR6ZMNNER6X",
        "SecretAccessKey": "eCy8W3DtDFQ3H3s0GVKzeaaMDOmoJjsICkl5tXc9",
        "SessionToken": "IQoJb3JpZ2luX2VjECAaDmFwLW5vcnRoZWFzdC0yIkcwRQIgLFvzWmsRW+Hi6Wfvausj4AopclJ+N9S/1tWBowjQI1cCIQCHqPbWK61jnA9V1kZUIGVUzJd2MVms4wLbA3+zPSmEDCqBAwip//////////8BEAMaDDI3ODgwNTI0OTE0OSIMP8bP+U8sEuV8NkQDKtUC9/DPj4rz7hZDFgGUzpIGTmf1OQjkLQmSgCEdOXhWvIwzVPG2nq0YoeeZoEjiOWO2MoK2Dgi26f6AkOnUcffxnpCnil8zV+odFdMXX4+meOf2K40i8/4UQHYMf+CDJQbgNVNAT/5zxUcLdFn5QJwARnPusuNEZufiMs+TilN3j2fRrTOY+jWF2GRiCIZKVO55AH2naSFQukB5nXjKKlbJR2evZlhoEAm1TWPMjnW2KatDx/sGWgxD69uw6TWGe72WJQ+KerX4R2usLuTBfG08RrY6+QVuj3TXRmzL31k3lTeDhxgi7j2taTguehoyr33qRjObMzc57DQW7iDe4Gd15U9o30iNXuGHAK0M3t1E6dviyQ72+zFcrqqYFSU/F9MuZsWUCDB9T5EQ4g5Sk6cTRrK2Z+stPpxh3JPVAo4IAeNtXUNt30NXHVpN4Iz4S121IT+DfKswy4qCkgY6yAF80yMiCaF+42I93OBbtNPS9jkLkhpGNgMumssl+O1O6gv2lAd0kK82z9uYxhbAPmEkCWvvmPny0Y3Vr6jaAShSuqu0Yz3eG0ViAZseGUHb0OJMo7RwfsCpJEaGXUAB04RfbPu5Gd0SjEg5aLnBixUknnx2IoOaZLgnowq1GjS5grdI+9jeSFVl8vkPxIEVrsPvdFlQWdN3/ECMea+V1cTT0rjDnUGtTdYgHuNz+mEt/H/4WDin9k7g5X5xtQhnnWHrtFPhkdDCtA==",
        "Expiration": "2022-03-27T16:39:55+00:00"
    },
    "SubjectFromWebIdentityToken": "113632458324056836621",
    "AssumedRoleUser": {
        "AssumedRoleId": "AROAUB2QWPR6X3BYU2DG7:google-oidc-session",
        "Arn": "arn:aws:sts::278805249149:assumed-role/google-oidc-role/google-oidc-session"
    },
    "Provider": "accounts.google.com",
    "Audience": "448771483088-25fslbvr9thmmi3acvo3omu0v1j6lqab.apps.googleusercontent.com"
}
~~~

획득한 ID Token과 함께 Assume Role with Web Identity 동작을 수행하여 임시 AccessKeyID, SecretAccessKey, SessionToken을 얻는다.

~~~console
# export AWS_ACCESS_KEY_ID=ASIAUB2QWPR6ZMNNER6X
# export AWS_SECRET_ACCESS_KEY=eCy8W3DtDFQ3H3s0GVKzeaaMDOmoJjsICkl5tXc9
# export AWS_SESSION_TOKEN=IQoJb3JpZ2luX2VjECAaDmFwLW5vcnRoZWFzdC0yIkcwRQIgLFvzWmsRW+Hi6Wfvausj4AopclJ+N9S/1tWBowjQI1cCIQCHqPbWK61jnA9V1kZUIGVUzJd2MVms4wLbA3+zPSmEDCqBAwip//////////8BEAMaDDI3ODgwNTI0OTE0OSIMP8bP+U8sEuV8NkQDKtUC9/DPj4rz7hZDFgGUzpIGTmf1OQjkLQmSgCEdOXhWvIwzVPG2nq0YoeeZoEjiOWO2MoK2Dgi26f6AkOnUcffxnpCnil8zV+odFdMXX4+meOf2K40i8/4UQHYMf+CDJQbgNVNAT/5zxUcLdFn5QJwARnPusuNEZufiMs+TilN3j2fRrTOY+jWF2GRiCIZKVO55AH2naSFQukB5nXjKKlbJR2evZlhoEAm1TWPMjnW2KatDx/sGWgxD69uw6TWGe72WJQ+KerX4R2usLuTBfG08RrY6+QVuj3TXRmzL31k3lTeDhxgi7j2taTguehoyr33qRjObMzc57DQW7iDe4Gd15U9o30iNXuGHAK0M3t1E6dviyQ72+zFcrqqYFSU/F9MuZsWUCDB9T5EQ4g5Sk6cTRrK2Z+stPpxh3JPVAo4IAeNtXUNt30NXHVpN4Iz4S121IT+DfKswy4qCkgY6yAF80yMiCaF+42I93OBbtNPS9jkLkhpGNgMumssl+O1O6gv2lAd0kK82z9uYxhbAPmEkCWvvmPny0Y3Vr6jaAShSuqu0Yz3eG0ViAZseGUHb0OJMo7RwfsCpJEaGXUAB04RfbPu5Gd0SjEg5aLnBixUknnx2IoOaZLgnowq1GjS5grdI+9jeSFVl8vkPxIEVrsPvdFlQWdN3/ECMea+V1cTT0rjDnUGtTdYgHuNz+mEt/H/4WDin9k7g5X5xtQhnnWHrtFPhkdDCtA==

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
