---
title: Golang Google OIDC 이용
category: Programming
date: 2022-02-16T00:00:00Z
lastmod: 2022-02-16T00:00:00Z
comment: tru득
adsense: true
---

Golang을 활용하여 Google OIDC 기반의 Token을 획득하고 분석한다.

### 1. OIDC 설정

Google Cloud Platform에서 OIDC 기반의 ID Token, OAuth 기반의 Access Token을 얻기 위해서는 설정이 필요하다.

![[그림 1] Project 생성]({{site.baseurl}}/images/programming/Golang_Google_OIDC/Project_생성.PNG){: width="700px"}

[그림 1]과 같이 [https://console.developers.google.com](https://console.developers.google.com/)에 접근하여 Project를 생성한다.

![[그림 2] OAuth 추가]({{site.baseurl}}/images/programming/Golang_Google_OIDC/OAuth_추가.PNG){: width="700px"}

[그림 2]와 같이 "API 및 서비스" 항목으로 들어가 "OAuth 클라이언트 ID" 추가를 선택하여 OAuth 인증 방식을 추가한다.

![[그림 3] OAuth ClientID 생성]({{site.baseurl}}/images/programming/Golang_Google_OIDC/OAuth_ClientID_생성.PNG){: width="700px"}

[그림 3]과 같이 "웹 애플리케이션" 유형의 Client ID를 생성한다. "이름"은 임의로 지정하면 된다. "리다이렉션 URI"의 경우에는 예제 Code에서 처리할 경로인 "/auth/google/callback"을 명시한다. 생성이 완료되면 **Client ID**와 **Client Secret**을 확인한다.

### 2. App Code

{% highlight golang linenos %}
// Code : https://github.com/ssup2/golang-Google-OIDC/blob/master/main.go

func main() {
	// Init variables
	ctx := context.Background()

	// Set OIDC, oauth oidcProvider
	oidcProvider, err := oidc.NewProvider(ctx, "https://accounts.google.com")
	if err != nil {
		log.Fatal(err)
	}
	oauth2Config := oauth2.Config{
		ClientID:     clientID,
		ClientSecret: clientSecret,
		Endpoint:     oidcProvider.Endpoint(),
		RedirectURL:  "http://127.0.0.1:3000/auth/google/callback",   // Set callback URL
		Scopes:       []string{oidc.ScopeOpenID, "profile", "email"}, // Set scope
	}

	// Define handler to redirect for login and permissions
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		state, err := randString(16)
		if err != nil {
			http.Error(w, "Internal error", http.StatusInternalServerError)
			return
		}
		nonce, err := randString(16)
		if err != nil {
			http.Error(w, "Internal error", http.StatusInternalServerError)
			return
		}
		setCallbackCookie(w, r, "state", state)
		setCallbackCookie(w, r, "nonce", nonce)

		// Redirect to Google login and permissions page
		http.Redirect(w, r, oauth2Config.AuthCodeURL(state, oidc.Nonce(nonce)), http.StatusFound)
	})

	// Define callback (redirect) handler
	http.HandleFunc("/auth/google/callback", func(w http.ResponseWriter, r *http.Request) {
		// Get state from URL and validate it
		state, err := r.Cookie("state")
		if err != nil {
			http.Error(w, "state not found", http.StatusBadRequest)
			return
		}
		if r.URL.Query().Get("state") != state.Value {
			http.Error(w, "state did not match", http.StatusBadRequest)
			return
		}

		// Get authorization code from URL
		authCode := r.URL.Query().Get("code")

		// Get ID token and access token through authorization code
		oauth2Token, err := oauth2Config.Exchange(ctx, authCode)
		if err != nil {
			http.Error(w, "Failed to exchange token: "+err.Error(), http.StatusInternalServerError)
			return
		}

		// Get and validate ID token
		oidcConfig := &oidc.Config{
			ClientID: clientID,
		}
		oidcVerifier := oidcProvider.Verifier(oidcConfig)
		rawIDToken, ok := oauth2Token.Extra("id_token").(string)
		if !ok {
			http.Error(w, "No id_token field in oauth2 token.", http.StatusInternalServerError)
			return
		}
		idToken, err := oidcVerifier.Verify(ctx, rawIDToken)
		if err != nil {
			http.Error(w, "Failed to verify ID Token: "+err.Error(), http.StatusInternalServerError)
			return
		}

		// Get nonce from ID token and validate it
		nonce, err := r.Cookie("nonce")
		if err != nil {
			http.Error(w, "nonce not found", http.StatusBadRequest)
			return
		}
		if idToken.Nonce != nonce.Value {
			http.Error(w, "nonce did not match", http.StatusBadRequest)
			return
		}

		// Marshal and make up response
		resp := struct {
			OAuth2Token   *oauth2.Token
			IDToken       string
			IDTokenClaims *json.RawMessage // ID Token payload is just JSON.
		}{oauth2Token, rawIDToken, new(json.RawMessage)}
		if err := idToken.Claims(&resp.IDTokenClaims); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		// Write response
		data, err := json.MarshalIndent(resp, "", "    ")
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		w.Write(data)
	})

	// Run HTTP server
	log.Printf("listening on http://%s/", "127.0.0.1:3000")
	log.Fatal(http.ListenAndServe("127.0.0.1:3000", nil))
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Golang Google OIDC Example App</figcaption>
</figure>

[Code 1]은 Google OIDC를 이용하여 ID Token과 Access Token을 얻는 Golang App의 일부분을 나타내고 있다. 전체 App Code는 다음의 Repo에서 확인 할 수 있다.

* [https://github.com/ssup2/golang-Google-OIDC](https://github.com/ssup2/golang-Google-OIDC)

동작 과정은 다음과 같다.

* User가 Golang App의 "/" Path에 접속하면 Golang App은 User를 Google 인증/인가 Web Page로 Redirect 한다.
* Google 인증/인가 Web Page는 User의 인증 및 인가 과정이 완료되면 Google 인증/인가 Web Page는 다시 Golang App의 "/auth/google/callback" Path로 Redirect 한다. 이 경우 Authorization Code를 URL Query로 같이 전달한다.
* User가 Golang App의 "/auth/google/callback" Path로 접속하면 Golang App은 URL에 있는 Authorization Code를 얻은 다음, 얻은 Authorization Code를 통해서 ID Token, Access Token을 얻고 출력한다.

[Code 1]의 각 Line별 설명은 다음과 같다.

* Line 16 : Scope는 ID Token 값에 포함되는 User의 정보 범위를 설정한다.
* Line 21, 41 : State는 User의 CSRF 공격을 막기 위한 임시 문자열이다. 인증/인가전에 State를 생성 및 Cookie에 저장하며, Redirect 이후에 URL의 State와 Cookie의 State가 일치하는지 확인한다.
* Line 26, 78 : Nonce는 ID Token이 유효한지 검증하는 용도로 이용되는 문자열이다. Nonce가 포함되도록 ID Token을 생성 및 Cookie에 저장하며, Redirect 이후에 얻은 ID Token의 Nonce와 Cookie의 Nonce가 일치하는지 확인한다.
* Line 52 : Authorization Code는 URL의 "code" Query에 존재한다.

### 3. Google 인증/인가

![[그림 3] Google 인증]({{site.baseurl}}/images/programming/Golang_Google_OIDC/Google_인증.PNG){: width="500px"}

{% highlight text %}
https://accounts.google.com/o/oauth2/v2/auth/identifier?
client_id=554362356429-cu4gcpn45gb3incmm2v32sofslliffg2.apps.googleusercontent.com&
nonce=at7kn_XhHFySNbXRelfLwQ&
redirect_uri=http%3A%2F%2F127.0.0.1%3A3000%2Fauth%2Fgoogle%2Fcallback&
response_type=code&
scope=openid%20profile%20email&
state=usovevjnYZYpCTOaalbSWw&flowName=GeneralOAuthFlow
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 1] Google 인증 URL</figcaption>
</figure>

[그림 3]은 Golang App의 "/" Path에 접속하면 Redirect 되어 접속되는 Google 인증 화면이다. [Text 1]은 Google 인증화면 접속시 이용되는 URL을 나타낸다. URL에 Query 형태로 Client ID, Nonce, Callback URL (Redirect URL), Scope, State 정보가 포함되어 있는것을 확인할 수 있다.

### 4. ID Token, Access Token

{% highlight text %}
http://127.0.0.1:3000/auth/google/callback?state=usovevjnYZYpCTOaalbSWw&
code=4%2F0AX4XfWgoC8l0tmZ9anfZVb9mgtiYquLKZekXouqAoFKSN4-BZimF7m8wa5nDUElbBD8Jhg&
scope=email+profile+openid+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email&
authuser=0&
prompt=consent
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 2] Callback URL</figcaption>
</figure>

[Text 2]은 Redirect URL의 예제를 나타내고 있다. "code" Query에는 Authorization Code, "scope" Query에는 Scope 정보등이 포함되어 있는것을 확인할 수 있다.

{% highlight json %}
{
    "OAuth2Token": {
        "access_token": "ya29.A0ARrdaM8GQORQw-hKwlyNHfVB1cyGkmwRmWZiYOC_AEj8xV8QMEs35nfmVXtGDNrORxvcm9WCSBbujzEX2P-EeTeYmzJyrufai9QttcHQAgq1hfkGjQv7Gd3ZI4aZNl6GiY6fBSToILzPgF1dB-iXwymDVk3F",
        "token_type": "Bearer",
        "expiry": "2022-03-26T01:30:17.032547872+09:00"
    },
    "IDToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjU4YjQyOTY2MmRiMDc4NmYyZWZlZmUxM2MxZWIxMmEyOGRjNDQyZDAiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI1NTQzNjIzNTY0MjktY3U0Z2NwbjQ1Z2IzaW5jbW0ydjMyc29mc2xsaWZmZzIuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI1NTQzNjIzNTY0MjktY3U0Z2NwbjQ1Z2IzaW5jbW0ydjMyc29mc2xsaWZmZzIuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTM2MzI0NTgzMjQwNTY4MzY2MjEiLCJlbWFpbCI6InN1cHN1cDU2NDJAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiJndDNndXI5c3VkUmpXNHRsazJQVnl3Iiwibm9uY2UiOiJhdDdrbl9YaEhGeVNOYlhSZWxmTHdRIiwibmFtZSI6InNzcyBzc3MiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EtL0FPaDE0R2otLXUybVgtOEFITkNyeGJ4ZmJOR1R6YnJ4QmJSbExoT2dpM3M0dFE9czk2LWMiLCJnaXZlbl9uYW1lIjoic3NzIiwiZmFtaWx5X25hbWUiOiJzc3MiLCJsb2NhbGUiOiJrbyIsImlhdCI6MTY0ODIyMjIyMCwiZXhwIjoxNjQ4MjI1ODIwfQ.rpv5ZonWufD9CSDZi9hn3tjBEMDrwMTEW7BwXilvPGa2U1pzzvGZhiY6Qxjbs4rqoJaaVu4vPdd5iob1oxloeY7e5s4I2mIaVxONpvOdeO3yj1FzWAnVgwZ7zRHEk0J2PVgwcXG-InWOX4TwFE8ZgWHnQD1WLQTQvB-PzQF7OUCy_0SYEz2qU5YCA2tYj7u59oMI1aWdLQXEhJwFlXyIdh3lTlWXLAXP04NSO9w5M7kQfk480nqk9kTyo29aZtnSM_c-uvxP4z95HHq9pBaktDiptZtOMf5EoLrQYDG1UQzQylozTWsw5GOeFlRsOfsvMOZDV8uwCGR648Qn6eME2A",
    "IDTokenClaims": {
        "iss": "https://accounts.google.com",
        "azp": "554362356429-cu4gcpn45gb3incmm2v32sofslliffg2.apps.googleusercontent.com",
        "aud": "554362356429-cu4gcpn45gb3incmm2v32sofslliffg2.apps.googleusercontent.com",
        "sub": "113632458324056836621",
        "email": "supsup5642@gmail.com",
        "email_verified": true,
        "at_hash": "gt3gur9sudRjW4tlk2PVyw",
        "nonce": "at7kn_XhHFySNbXRelfLwQ",
        "name": "sss sss",
        "picture": "https://lh3.googleusercontent.com/a-/AOh14Gj--u2mX-8AHNCrxbxfbNGTzbrxBbRlLhOgi3s4tQ=s96-c",
        "given_name": "sss",
        "family_name": "sss",
        "locale": "ko",
        "iat": 1648222220,
        "exp": 1648225820
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 2] Callback Result - Access Token, ID Token</figcaption>
</figure>

[Text 3]는 ID Token의 Claim과 Access Token의 예제를 나타내고 있다.

### 5. 참조

* [https://www.daleseo.com/google-oidc/](https://www.daleseo.com/google-oidc/)
* [https://www.daleseo.com/google-oauth/](https://www.daleseo.com/google-oauth/)
* [https://opentutorials.org/course/2473/16571](https://opentutorials.org/course/2473/16571)
* [https://github.com/coreos/go-oidc](https://github.com/coreos/go-oidc)