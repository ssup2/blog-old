---
title: Golang Keycloak SAML 이용
category: Programming
date: 2022-02-20T00:00:00Z
lastmod: 2022-02-20T00:00:00Z
comment: true
adsense: true
---

Golang을 활용하여 Keycloak의 SAML을 이용하고 분석한다.

### 1. 인증서 생성

SAML의 Service Provider는 인증서가 필요하다. 다음의 명령어로 인증서를 생성한다.

~~~console
# openssl req -x509 -newkey rsa:2048 -keyout myservice.key -out myservice.cert -days 365 -nodes -subj "/CN=myservice.example.com"
~~~

### 2. Service Provider Code

{% highlight golang linenos %}
// https://github.com/ssup2/golang-Google-SAML/blob/master/main.go
// Print SAML request
func samlRequestPrinter(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Printf("Header : %+v\n", r.Header)
		fmt.Printf("Body : %+v\n", r.Body)
		next.ServeHTTP(w, r)
	})
}

// Echo session info
func echoSession(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "%v\n", samlsp.SessionFromContext(r.Context()))
}

func main() {
	// Load certificate keypair
	keyPair, err := tls.LoadX509KeyPair("myservice.cert", "myservice.key")
	if err != nil {
		panic(err)
	}
	keyPair.Leaf, err = x509.ParseCertificate(keyPair.Certificate[0])
	if err != nil {
		panic(err)
	}

	// Get identity provider info from identity provider meta URL
	idpMetadataURL, err := url.Parse("http://localhost:8080/realms/ssup2/protocol/saml/descriptor")
	if err != nil {
		panic(err)
	}
	idpMetadata, err := samlsp.FetchMetadata(context.Background(), http.DefaultClient,
		*idpMetadataURL)
	if err != nil {
		panic(err)
	}

	// Get SAML service provider middleware
	rootURL, err := url.Parse("http://localhost:8000")
	if err != nil {
		panic(err)
	}
	samlSP, _ := samlsp.New(samlsp.Options{
		URL:         *rootURL,
		Key:         keyPair.PrivateKey.(*rsa.PrivateKey),
		Certificate: keyPair.Leaf,
		IDPMetadata: idpMetadata,
	})

	// Set SAML's metadata and ACS (Assertion Consumer Service) endpoint with SAML request printer
	http.Handle("/saml/", samlRequestPrinter(samlSP))

	// Set session handler to print session info
	app := http.HandlerFunc(echoSession)
	http.Handle("/session", samlSP.RequireAccount(app))

	// Serve HTTP
	http.ListenAndServe(":8000", nil)
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Golang SAML Service Provider Example</figcaption>
</figure>

[Code 1]은 SAML Identity Provider를 통해서 User를 인증하고, 인증 과정을 통해서 얻은 SAML Session 정보를 출력하는 SAML Service Provider App이다. 동작 과정은 다음과 같다.

* User가 Service Provider의 "/session" Path에 접속하면 Service Provider는 RequireAccount() Middleware 함수에 의해서 Identity Provider에게 User가 인증을 할 수 있도록 Redirect한다.
* Identity Provider를 통해서 인증이 완료되면 Identity Provider는 이전에 등록된 Service Provider의 ACS Endpoint인 "/saml/acs"로 User를 다시 Redirect하고, 인증 정보인 SAML Response도 ACS Endpoint에 같이 전송한다.

### 3. Service Provider Metadata 추출

[Code 1]의 Service Provider의 Metadata를 추출해야 한다. 추출한 Metadata는 Identity Provider에 Service Provider를 등록하는데 이용된다. 다음의 명령어로 Service Provider의 Metadata를 추출한다. [Code 1]의 Service Provider는 "/saml/metadata" 경로를 통해서 추출할 수 있다.

~~~console
# go run main.go
# curl localhost:8000/saml/metadata > metadata
~~~

### 4. Keycloak 설치, 설정

Docker를 이용하여 Keycloak을 설치한다. Keycloak의 Admin ID/Password는 admin/admin으로 설정한다.

~~~console
# docker run --name keycloak -p 8080:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin -d quay.io/keycloak/keycloak:17.0.0 start-dev
~~~

![[그림 1] Realm 생성]({{site.baseurl}}/images/programming/Golang_Keycloak_SAML/Keycloak_Create_Realm.PNG){: width="700px"}

"localhost:8080"에 접속하여 Admin 계정으로 Login을 진행한 이후에 [그림 1]과 같이 "ssup2" Realm을 생성한다. Keycloak의 Realm은 인증 범위를 의미한다. 하나의 Realm에 다수의 Service Provider가 등록될 수 있다.

![[그림 2] Client 생성]({{site.baseurl}}/images/programming/Golang_Keycloak_SAML/Keycloak_Create_Client.PNG){: width="700px"}

Service Provider로부터 추출한 Metadata를 Load하여 [그림 2]와 같이 Client를 생성한다.

![[그림 3] Client Signature Off]({{site.baseurl}}/images/programming/Golang_Keycloak_SAML/Keycloak_Create_Client_Signature.PNG){: width="700px"}

[그림 3]과 같이 생성한 Client에 들어가서 Client Signature Required를 Off한다. Service Provider가 이용하는 인증서가 임의의 인증서이기 때문에 Off가 필요하다.

![[그림 4] User Password 설정]({{site.baseurl}}/images/programming/Golang_Keycloak_SAML/Keycloak_User_Role.PNG){: width="700px"}

"users" Group을 생성하고 "users" Group 하위에 "user" User를 생성한다. 이후 [그림 4]와 같이 생성한 "user" User의 Password를 "user"로 설정한다.

![[그림 5] User Role 확인]({{site.baseurl}}/images/programming/Golang_Keycloak_SAML/Keycloak_User_Role.PNG){: width="700px"}

이후 생성한 "user" User의 Role을 [그림 5]와 같이 확인 한다.

### 5. Service Provider 실행

![[그림 6] User Login]({{site.baseurl}}/images/programming/Golang_Keycloak_SAML/Keycloak_User_Role.PNG){: width="700px"}

{% highlight text %}
{{http://localhost:8000 1645785920  1645782320 http://localhost:8000 1645782320 G-fbdd108e-94c3-476f-b7c8-02bfd485b3de} map[Role:[manage-account manage-account-links uma_authorization default-roles-ssup2 offline_access view-profile] SessionIndex:[7f326d03-4635-423b-9477-5c82883920ee::1c978e61-f5b1-4350-8edc-d6618296ab59]] true}
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 1] Session 정보</figcaption>
</figure>

Service Provider를 실행하고 "/session" Path에 접근하면 [그림 6]과 같은 Login 화면을 확인할 수 있다. "user/user"로 Login을 수행하면 [Text 1]과 같이 현재의 Session 정보를 확인할 수 있다. Role에 [그림 5]의 Role이 포함되어 있는것을 확인할 수 있다.

```
&{Method:POST URL:/saml/acs Proto:HTTP/1.1 ProtoMajor:1 ProtoMinor:1 Header:map[Accept:[text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9] Accept-Encoding:[gzip, deflate, br] Accept-Language:[ko] Cache-Control:[max-age=0] Connection:[keep-alive] Content-Length:[16013] Content-Type:[application/x-www-form-urlencoded] Cookie:[saml_ZeKzq7vzQ7Oghy3cnCf7IpW51dwRQ7gdYRVwPcS0U6DSfwQypZxKn6g9=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJodHRwOi8vbG9jYWxob3N0OjgwMDAiLCJleHAiOjE2NDU3ODI0MDYsImlhdCI6MTY0NTc4MjMxNiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDAwIiwibmJmIjoxNjQ1NzgyMzE2LCJzdWIiOiJaZUt6cTd2elE3T2doeTNjbkNmN0lwVzUxZHdSUTdnZFlSVndQY1MwVTZEU2Z3UXlwWnhLbjZnOSIsImlkIjoiaWQtMWMxY2QyMWVlODZlOTdlNmY4Yzg5Y2FkMTU0MmQwNjVlYTQ1NzdhMSIsInVyaSI6Ii9zZXNzaW9uIiwic2FtbC1hdXRobi1yZXF1ZXN0Ijp0cnVlfQ.P49VO5w6WNvXHrQKfL9ZhxJGgNdEFxAQiu3fA-2s8gIUKQXlXpCAEfGXPPWwILtsSMLxjoeTYUsrM9R6LtcvAorn-QKSMVbnhk6BeUK0UxSoi7aVM9TdlpsShmNvs_T9lL3LRoYgH1n2FQVUBXwG0iGk6-5dfLTy4GMabh-463P0ErO-9IP28fOdDuH9fPOgInYwo0-qtFUn1rgxi_G2lqZzqJtpVe9NcAx1mQFttjVBXK1X4Ry_-Uf9aVNEVplXQG0z0B0RKcqh900MWBdKvYS6sSuYnnbzrY8jo-9OAA9pyxZ8B8yamTtppXfhsZYtrGmYLZ8sSWEVnGU1rjmO5Q] Origin:[null] Sec-Ch-Ua:[" Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"] Sec-Ch-Ua-Mobile:[?0] Sec-Ch-Ua-Platform:["Windows"] Sec-Fetch-Dest:[document] Sec-Fetch-Mode:[navigate] Sec-Fetch-Site:[same-site] Upgrade-Insecure-Requests:[1] User-Agent:[Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36]] Body:0xc000318100 GetBody:<nil> ContentLength:16013 TransferEncoding:[] Close:false Host:localhost:8000 Form:map[] PostForm:map[] MultipartForm:<nil> Trailer:map[] RemoteAddr:[::1]:41652 RequestURI:/saml/acs TLS:<nil> Cancel:<nil> Response:<nil> ctx:0xc000318140}
```

### 6. 참조

* [https://www.keycloak.org/getting-started/getting-started-docker](https://www.keycloak.org/getting-started/getting-started-docker)
* [https://docs.anchore.com/3.0/docs/overview/sso/examples/keycloak/](https://docs.anchore.com/3.0/docs/overview/sso/examples/keycloak/)
* [https://github.com/crewjam/saml](https://github.com/crewjam/saml)
* [https://goteleport.com/blog/how-saml-authentication-works/](https://goteleport.com/blog/how-saml-authentication-works/)
* [https://www.rancher.co.jp/docs/rancher/v2.x/en/admin-settings/authentication/keycloak/](https://www.rancher.co.jp/docs/rancher/v2.x/en/admin-settings/authentication/keycloak/)