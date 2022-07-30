---
title: URI, URL, URN
category: Theory, Analysis
date: 2022-07-29T12:00:00Z
lastmod: 2022-07-29T12:00:00Z
comment: true
adsense: true
---

URI, URL, URN을 분석한다.

### 1. URI (Uniform Resource Identifier)

![[그림 1] URI, URL, URN 관계]({{site.baseurl}}/images/theory_analysis/URI_URL_URN/URI_URL_URN.PNG){: width="300px"}

URI는 의미 그대로 Resource에게 붙이는 고유한 **식별자**를 의미한다. 여기서 Resource는 주로 인터넷에서 이용되는 **Web Resource**를 의미한다. URI는 Web Resource의 위치를 나타내는데 이용하는 URL과 Web Resource의 이름을 나타내는 URN으로 구성되어 있다. [그림 1]은 URI, URL, URN의 관계를 나타내고 있다.

### 2. URL (Uniform Resource Locator)

![[그림 2] URL]({{site.baseurl}}/images/theory_analysis/URI_URL_URN/URL.PNG){: width="700px"}

URL은 의미 그대로 Web Resource에게 고유한 위치 정보를 부여하는데 이용한다. [그림 2]는 URL의 예제를 나타낸다. URL의 구성요소는 다음과 같다.

* Scheme : 일반적으로 Web Resource에 접근하기 위한 Protocol을 의미한다.
* Root Domain : 최상위 Domain을 의미한다. 일반적으로 생략하여 이용한다.
* Top-level Domain : 최상위 Domain 바로 하위의 Domain을 의미한다. ".kr", ".us"와 같은 ccTLD(country code TLD)와 ".com", ".net"과 같은 gTLD(generic TLD)가 존재한다.
* Second-level Domain : Top-level Domain 하위의 Domain을 의미한다.
* Subdomain : Second-level 하위 Domain을 의미한다. Subdomain 여러개를 구성하여 다수의 Depth를 갖는 Domain 구성도 가능하다.
* Port : Web Resource에 접근하기 위한 Port를 의미하며 각 Scheme마다 이용되는 Default Port를 이용하는 경우 생략 가능하다. ex) HTTP/80, HTTPS/443
* Subdirectory : Domain 하위의 Path를 의미한다. "/" 문자를 이용하여 Depth 표현이 가능하다.
* Query String : URL을 통해서 Parameter를 Web Resource에게 전달할때 이용한다. "?" 문자로 URL 마지막부터 시작하며 "<key>=<value>" 형태를 갖는다. 다수의 "&" 문자를 이용하여 다수의 Key-Value를 설정할 수 있다.

### 3. URN (Uniform Resource Name)

![[그림 3] URN]({{site.baseurl}}/images/theory_analysis/URI_URL_URN/URN.PNG){: width="550px"}

URN은 의미 그대로 Web Resource에게 고유한 이름을 부여하는데 이용한다. [그림 3]은 URN의 예제를 나타낸다. URN의 구성 요소는 다음과 같다.

* NID (Namespace Identifier) : Namespace를 나타낸다.
* NSS (Namespace Specific String) : Namespace 내부에서 고유한 String 값을 의미한다. URL의 Subdirectory 처럼 Depth를 나타내기 위해서 URN에서 ":" 문자를 통해서 Depth를 나타내는 경우가 있는데, 이 경우에도 NID 부분을 제외한 나머지 모든 부분은 NSS로 간주한다.

{: .newline }
> urn:isbn:0451450523a (Book Number)
> urn:isan:0000-0000-2CEA-0000-1-0000-0000-Y (Move Number)
> urn:uuid:6e8bc430-9c3a-11d9-9669-0800200c9a66 (UUID)
> urn:mpeg:mpeg7:schema:2001<br/>
<figure>
<figcaption class="caption">[Text 1] URN Example</figcaption>
</figure>

[Text 1]은 URN의 예제를 나타내고 있다.

### 4. 참조

* [https://auth0.com/blog/url-uri-urn-differences/](https://auth0.com/blog/url-uri-urn-differences/)
* [https://blog.itcode.dev/posts/2021/05/29/uri-url-urn](https://blog.itcode.dev/posts/2021/05/29/uri-url-urn)
* URI : [https://en.wikipedia.org/wiki/Uniform_Resource_Identifier](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier)
* URL : [https://raventools.com/marketing-glossary/root-domain/](https://raventools.com/marketing-glossary/root-domain/)
* URN : [https://en.wikipedia.org/wiki/Uniform_Resource_Name](https://en.wikipedia.org/wiki/Uniform_Resource_Name)
* URN : [https://datatracker.ietf.org/doc/html/rfc8141#page-10](https://datatracker.ietf.org/doc/html/rfc8141#page-10)