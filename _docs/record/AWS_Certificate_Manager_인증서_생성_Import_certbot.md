---
title: AWS Certificate Manager 인증서 생성, Import / certbot 이용
category: Record
date: 2022-12-04T12:00:00Z
lastmod: 2022-12-04T12:00:00Z
comment: true
adsense: true
---

### 1. 실행 환경

* Macbook, Monterey
* Domain
  * aws-playground.dev
  * *.aws-playground.dev

### 2. certbot, certbot-dns-route53 Plugin 설치

```
$ sudo python3 -m venv /opt/certbot/
$ sudo /opt/certbot/bin/pip install --upgrade pip
$ sudo /opt/certbot/bin/pip install certbot
$ sudo ln -s /opt/certbot/bin/certbot /usr/local/bin/certbot
$ sudo /opt/certbot/bin/pip install certbot-dns-route53
```

인증서 생성을 위해서 certbot 및 certbot-dns-route53 Plugin 설치한다.

### 3. letsencrypt IAM User 생성 & 설정, Access Key 생성

```
$ aws iam create-user --user-name letsencrypt
{
    "User": {
        "Path": "/",
        "UserName": "letsencrypt",
        "UserId": "AIDA2S2LVTEOIYTEXDCLM",
        "Arn": "arn:aws:iam::727618787612:user/letsencrypt",
        "CreateDate": "2022-12-05T03:37:20+00:00"
    }
}

$ aws iam create-access-key --user-name letsencrypt
{
    "AccessKey": {
        "UserName": "letsencrypt",
        "AccessKeyId": "{AWS_Access_ID"},
        "Status": "Active",
        "SecretAccessKey": "{AWS_Secret_Key}",
        "CreateDate": "2022-12-05T03:38:49+00:00"
    }
}
```

certbot이 이용하는 letsencrypt IAM 계정과 letsencrypt IAM 계정의 Access Key를 생성한다. 

### 4. letsencrypt IAM User에 Policy 적용

{% highlight json %}
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:GetChange",
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] letsencrypt-policy.json</figcaption>
</figure>

letsencrypt IAM 계정을 위한 Policy를 위해서 [파일 1]의 내용으로 letsencrypt-policy.json 파일을 생성한다.

```
$ aws iam create-policy --policy-name letsencrypt-policy --policy-document file://letsencrypt-policy.json
{
    "Policy": {
        "PolicyName": "letsencrypt-policy",
        "PolicyId": "ANPA2S2LVTEOK36NCEQX6",
        "Arn": "arn:aws:iam::727618787612:policy/letsencrypt-policy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2022-12-05T04:03:02+00:00",
        "UpdateDate": "2022-12-05T04:03:02+00:00"
    }
}

$ aws iam attach-user-policy --user-name letsencrypt --policy-arn arn:aws:iam::727618787612:policy/letsencrypt-policy
```

[파일 1]을 이용하여 Policy를 생성하고 letsencrypt IAM 계정에 설정한다.

### 5. certbot을 이용하여 인증서 생성

{% highlight text %}
[letsencrypt]
aws_access_key_id={AWS_Access_ID}
aws_secret_access_key={AWS_Secret_Key}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] ~/.aws/credentials</figcaption>
</figure>

certbot에서 이용하는 ~/.aws/credentials 파일을 [파일 2]의 내용으로 생성한다.

```
$ cd ~ && mkdir certbot && cd certbot
$ certbot certonly --dns-route53 -n -d "aws-playground.dev" -d "*.aws-playground.dev" --email supsup5642@gmail.com --agree-tos --config-dir . --work-dir . --logs-dir .
Saving debug log to /Users/ssup2/certbot/letsencrypt.log
Account registered.
Requesting a certificate for aws-playground.dev and *.aws-playground.dev

Successfully received certificate.
Certificate is saved at: /Users/ssup2/certbot/live/aws-playground.dev/fullchain.pem
Key is saved at:         /Users/ssup2/certbot/live/aws-playground.dev/privkey.pem
This certificate expires on 2023-03-05.
These files will be updated when the certificate renews.

NEXT STEPS:
- The certificate will need to be renewed before it expires. Certbot can automatically renew the certificate in the background, but you may need to take steps to enable that functionality. See https://certbot.org/renewal-setup for instructions.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
If you like Certbot, please consider supporting our work by:
 * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
 * Donating to EFF:                    https://eff.org/donate-le
```

certbot을 이용하여 인증서를 생성한다.

### 6. 생성한 인증서를 AWS Certificate Manager에 등록

```
$ cd ~/certbot/live/aws-playground.dev/live/aws-playground.dev
$ aws acm import-certificate --region ap-northeast-2 --certificate fileb://cert.pem --private-key fileb://privkey.pem --certificate-chain fileb://chain.pem
```

인증서를 AWS Certificate Manager에 등록한다.

### 7. 참조

* [https://certbot.eff.org/instructions?ws=other&os=pip](https://certbot.eff.org/instructions?ws=other&os=pip)
* [https://www.skyer9.pe.kr/wordpress/?p=823](https://www.skyer9.pe.kr/wordpress/?p=823)