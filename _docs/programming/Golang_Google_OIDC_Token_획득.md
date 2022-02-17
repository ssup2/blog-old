---
title: Golang Google OIDC 이용
category: Programming
date: 2022-02-16T00:00:00Z
lastmod: 2022-02-16T00:00:00Z
comment: true
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

### 2. Code

{% highlight golang linenos %}
func main() {
	// Init variables
	ctx := context.Background()

	// Set OIDC, oauth provider
	provider, err := oidc.NewProvider(ctx, "https://accounts.google.com")
	if err != nil {
		log.Fatal(err)
	}
	oauth2Config := oauth2.Config{
		ClientID:     clientID,
		ClientSecret: clientSecret,
		Endpoint:     provider.Endpoint(),
		RedirectURL:  "http://127.0.0.1:3000/auth/google/callback",   // Set redirect url
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

		// Init ID token verifier
		oidcConfig := &oidc.Config{
			ClientID: clientID,
		}
		verifier := provider.Verifier(oidcConfig)

		// Get ID token from URL and validate it
		oauth2Token, err := oauth2Config.Exchange(ctx, r.URL.Query().Get("code"))
		if err != nil {
			http.Error(w, "Failed to exchange token: "+err.Error(), http.StatusInternalServerError)
			return
		}
		rawIDToken, ok := oauth2Token.Extra("id_token").(string)
		if !ok {
			http.Error(w, "No id_token field in oauth2 token.", http.StatusInternalServerError)
			return
		}
		idToken, err := verifier.Verify(ctx, rawIDToken)
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
			IDTokenClaims *json.RawMessage // ID Token payload is just JSON.
		}{oauth2Token, new(json.RawMessage)}
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
<figcaption class="caption">[Code 1] Golang Google OIDC Example</figcaption>
</figure>

* Code : https://github.com/coreos/go-oidc/blob/v3/example/idtoken/app.go

### 3. ID Token, Access Token

{% highlight text %}
http://127.0.0.1:3000/auth/google/callback?state=HeLK6b0uTARRKUaX4fLqsw&code=4%2F0AX4XfWj1XzuCgumNoRlYBfzzeCSBzszRvXMlt1uYohiQDOYJ61NrFKIgDmuuOrM5m6JDKw&scope=email+profile+openid+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email&authuser=0&prompt=none
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 1] Callback URL</figcaption>
</figure>

{% highlight json %}
{
    "OAuth2Token": {
        "access_token": "ya29.A0ARrdaM9ORJsRuSy9s7k63RvRZxpSQsC_1ufHuLiafxH0mN1JzTCqb0abZoF2VAMzESSMFk7ir0pdML9hCawtvo__sJvmvA671pk6cW_VztdG9fb_10S4QCKkmaf8IkcTE9dPTUolp7ZH89DDCO1FYWJfON6C-w",
        "token_type": "Bearer",
        "expiry": "2022-02-18T01:08:28.186549937+09:00"
    },
    "IDTokenClaims": {
        "iss": "https://accounts.google.com",
        "azp": "554362356429-cu4gcpn45gb3incmm2v32sofslliffg2.apps.googleusercontent.com",
        "aud": "554362356429-cu4gcpn45gb3incmm2v32sofslliffg2.apps.googleusercontent.com",
        "sub": "113632458324056836621",
        "email": "supsup5642@gmail.com",
        "email_verified": true,
        "at_hash": "DCPA9BEHbfPo4BN2_qlvug",
        "nonce": "jbcf4kkkyU0ZLXy_59OdOg",
        "name": "신정섭",
        "picture": "https://lh3.googleusercontent.com/a/AATXAJzlONqtNnSJ0Qez5wk_7m2aCZ_xtoFjcyLFgxWy=s96-c",
        "given_name": "정섭",
        "family_name": "신",
        "locale": "ko",
        "iat": 1645110509,
        "exp": 1645114109
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 2] Callback Result - Access Token, ID Token</figcaption>
</figure>

### 4. 참조

* [https://www.daleseo.com/google-oidc/](https://www.daleseo.com/google-oidc/)
* [https://www.daleseo.com/google-oauth/](https://www.daleseo.com/google-oauth/)
* [https://opentutorials.org/course/2473/16571](https://opentutorials.org/course/2473/16571)
* [https://github.com/coreos/go-oidc](https://github.com/coreos/go-oidc)