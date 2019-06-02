---
title: SSL Self-signed Certificate 생성
category: Record
date: 2018-10-18T12:00:00Z
lastmod: 2018-10-18T12:00:00Z
comment: true
adsense: true
---

### 1. 생성 환경, 특징

* Ubuntu 18.04 LTS
* Chrome 58+ Version 이후 발생하는 missing_subjectAltName 문제를 해결하였다.

### 2. Root CA Key, Root Certificate 생성

* rootca.key, rootca.crt 파일을 생성한다.
  * Key : RSA기반 2048 Byte
  * CN : ssup2 (임의 변경 가능)

~~~
# openssl genrsa -out rootca.key 2048
# openssl req -x509 -new -nodes -key rootca.key -sha256 -days 356 -subj /C=KO/ST=None/L=None/O=None/CN=192.168.0.100 -out rootca.crt
~~~

### 3. Server Certificate 생성

* CN (Common Name) : Server의 IP 또는 Domain Name을 넣어준다.
  * Example : 192.168.0.100, ssup2.com, www.ssup2.com, *.ssup2.com (wildcard)
  * Domain Name은 정확한 일치가 필요하다. 예를들어 CN이 ssup2.com일 경우 www.ssup2.com에서 이용 불가능하다.

#### 3.1. v3.ext 파일 생성

* v3.ext 파일 생성 및 아래의 내용으로 작성한다.
  * CN (Common Name) : 192.168.0.100

{% highlight text %}
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
IP.1 = 192.168.0.100
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] v3.ext</figcaption>
</figure>

#### 3.2. Server Key, Server Certificate, Server pem 파일 생성

* server.key, server.crt, server.pem 파일을 생성한다.
  * CN (Common Name) : 192.168.0.100

~~~
# openssl req -new -newkey rsa:2048 -sha256 -nodes -keyout server.key -subj /C=KO/ST=None/L=None/O=None/CN=192.168.0.100 -out server.csr
# openssl x509 -req -in server.csr -CA rootca.crt -CAkey rootca.key -CAcreateserial -out server.crt -days 356 -sha256 -extfile ./v3.ext
# cat server.crt server.key > server.pem
~~~

### 4. 참조

* [https://alexanderzeitler.com/articles/Fixing-Chrome-missing_subjectAltName-selfsigned-cert-openssl/](https://alexanderzeitler.com/articles/Fixing-Chrome-missing_subjectAltName-selfsigned-cert-openssl/)
* [https://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate](https://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate)
