---
title: Kubernetes CSR (Certificate Signing Request)
category: Theory, Analysis
date: 2020-09-28T12:00:00Z
lastmod: 2020-09-28T12:00:00Z
comment: true
adsense: true
---

Kubernetes의 CSR (Certificate Signing Request)을 분석한다.

### 1. Kubernetes CSR (Certificate Signing Request)

#### 1.1. Example

{% highlight console %}
# openssl genrsa -out ssup2.key 2048
# openssl req -new -key ssup2.key -out ssup2.csr
...
Common Name (e.g. server FQDN or YOUR name) []:ssup2
...

# cat ssup2.csr | base64 | tr -d "\n"
LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ2tEQ0NBWGdDQVFBd1N6RUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdNQ2xOdmJXVXRVM1JoZEdVeApGekFWQmdOVkJBb01Ebk41YzNSbGJUcHRZWE4wWlhKek1RNHdEQVlEVlFRRERBVnpjM1Z3TWpDQ0FTSXdEUVlKCktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQU5wbEU1NXphYjl2Z0hZVUV0YlBhczlacTVESzI3L24KaWRhWHlQbmQzdjV0ZDQ3MjRUcU9kazU4bmcxSXUxbjZvaFpzc2dWNDVCQTE2WFE1YnVjc2I4K2EyZ2d4MEV3QwpQK2VVUnQwK2t1UnZMK1hLNWtQVHZnYXp4eWJNcE9KWFpFQjVBRVpnaFZYNkN6aGtzbGUyL3Q0SmZxWXFRclJaCm5pMTZqdE8yays5ZExsWlpqYytodVVMdElHVEV2WENmOEJ4bDlPd2xOL1RJQnp2NlNzejFpN1lPOS8xZzVkdncKcVRaK2lFaXNhNHdZQ3REUzcwMXl2QXhqVnNZaWZNVnIySTN4T2s5SytIM29SVHNNN3VqZFhtZTZyeTBlWkQ3Uwp2UmpkVzZYaEQ0WDlKZFJMQzAyK3J1ZmRScmlDajF3c3BVUXNVc2VRaDZxdUVDVlh0TDNBZ0pFQ0F3RUFBYUFBCk1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ1VETGZpdnFLVWRsbHlHQ2RzZjNFMnRSeHNzRmtjSnY5SHpHU1IKUFNObVpTeGpHTWlqK3VUakZ0TzIvWFBjRkErUnh3TjZCQ3phVlY3OVJrMlY5bmlDMUxmWVBIWkRpcTRNdFg1VQpBSXBydVdIbGhSd0FnK1NGaEx1MTg2WHFkMDBzdWlCZjVJNDdRMVROcVpHV3JvbXFrcHdVaVlyVUp2cEo3bk1oCm1qK0N5aTB4OTZGVUhJbzNoakIrRXVDWkdOOE00WWFqUlpVc2FwODQ0MU9LRlBqcTJsakdVR0tMeTNSYWk3M2cKb1pyZkhJYVBvdk1LRG43V1kyTW5iNGtvM3BvM1Q4V1FSMXdCczBiMW54RXR0WUtnaDB2b0RtQlhNQXVxRy9vUAo3QkwzVVQ2YkR2b2FRSy9WNFNQYmtQYnZmM3RFNGxDR1N1WDE2d0hPWUpOT3FkMEUKLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==

# cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: ssup2
spec:
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ2tEQ0NBWGdDQVFBd1N6RUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdNQ2xOdmJXVXRVM1JoZEdVeApGekFWQmdOVkJBb01Ebk41YzNSbGJUcHRZWE4wWlhKek1RNHdEQVlEVlFRRERBVnpjM1Z3TWpDQ0FTSXdEUVlKCktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQU5wbEU1NXphYjl2Z0hZVUV0YlBhczlacTVESzI3L24KaWRhWHlQbmQzdjV0ZDQ3MjRUcU9kazU4bmcxSXUxbjZvaFpzc2dWNDVCQTE2WFE1YnVjc2I4K2EyZ2d4MEV3QwpQK2VVUnQwK2t1UnZMK1hLNWtQVHZnYXp4eWJNcE9KWFpFQjVBRVpnaFZYNkN6aGtzbGUyL3Q0SmZxWXFRclJaCm5pMTZqdE8yays5ZExsWlpqYytodVVMdElHVEV2WENmOEJ4bDlPd2xOL1RJQnp2NlNzejFpN1lPOS8xZzVkdncKcVRaK2lFaXNhNHdZQ3REUzcwMXl2QXhqVnNZaWZNVnIySTN4T2s5SytIM29SVHNNN3VqZFhtZTZyeTBlWkQ3Uwp2UmpkVzZYaEQ0WDlKZFJMQzAyK3J1ZmRScmlDajF3c3BVUXNVc2VRaDZxdUVDVlh0TDNBZ0pFQ0F3RUFBYUFBCk1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ1VETGZpdnFLVWRsbHlHQ2RzZjNFMnRSeHNzRmtjSnY5SHpHU1IKUFNObVpTeGpHTWlqK3VUakZ0TzIvWFBjRkErUnh3TjZCQ3phVlY3OVJrMlY5bmlDMUxmWVBIWkRpcTRNdFg1VQpBSXBydVdIbGhSd0FnK1NGaEx1MTg2WHFkMDBzdWlCZjVJNDdRMVROcVpHV3JvbXFrcHdVaVlyVUp2cEo3bk1oCm1qK0N5aTB4OTZGVUhJbzNoakIrRXVDWkdOOE00WWFqUlpVc2FwODQ0MU9LRlBqcTJsakdVR0tMeTNSYWk3M2cKb1pyZkhJYVBvdk1LRG43V1kyTW5iNGtvM3BvM1Q4V1FSMXdCczBiMW54RXR0WUtnaDB2b0RtQlhNQXVxRy9vUAo3QkwzVVQ2YkR2b2FRSy9WNFNQYmtQYnZmM3RFNGxDR1N1WDE2d0hPWUpOT3FkMEUKLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==
  usages:
  - client auth
EOF
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] ssup2 CSR 생성</figcaption>
</figure>

{% highlight console %}
# kubectl get csr
NAME    AGE   SIGNERNAME                     REQUESTOR          CONDITION
ssup2   4s    kubernetes.io/legacy-unknown   kubernetes-admin   Pending

# kubectl certificate approve ssup2
certificatesigningrequest.certificates.k8s.io/ssup2 approved
# kubectl get csr
NAME    AGE     SIGNERNAME                     REQUESTOR          CONDITION
ssup2   5m6s    kubernetes.io/legacy-unknown   kubernetes-admin   Approved,Issue

# kubectl get csr/ssup2 -o json | jq -r .status.certificate | base64 --decode
-----BEGIN CERTIFICATE-----
MIIDDzCCAfegAwIBAgIQFqfvLdPIQwZQ6Xz2CAkcnjANBgkqhkiG9w0BAQsFADAV
MRMwEQYDVQQDEwprdWJlcm5ldGVzMB4XDTIwMDkyODE0MjUwOFoXDTIxMDkyODE0
MjUwOFowSzELMAkGA1UEBhMCQVUxEzARBgNVBAgTClNvbWUtU3RhdGUxFzAVBgNV
BAoTDnN5c3RlbTptYXN0ZXJzMQ4wDAYDVQQDEwVzc3VwMjCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBANplE55zab9vgHYUEtbPas9Zq5DK27/nidaXyPnd
3v5td4724TqOdk58ng1Iu1n6ohZssgV45BA16XQ5bucsb8+a2ggx0EwCP+eURt0+
kuRvL+XK5kPTvgazxybMpOJXZEB5AEZghVX6Czhksle2/t4JfqYqQrRZni16jtO2
k+9dLlZZjc+huULtIGTEvXCf8Bxl9OwlN/TIBzv6Ssz1i7YO9/1g5dvwqTZ+iEis
a4wYCtDS701yvAxjVsYifMVr2I3xOk9K+H3oRTsM7ujdXme6ry0eZD7SvRjdW6Xh
D4X9JdRLC02+rufdRriCj1wspUQsUseQh6quECVXtL3AgJECAwEAAaMlMCMwEwYD
VR0lBAwwCgYIKwYBBQUHAwIwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOC
AQEAOomhW3H8UC+ENw8trejECsHzvKR5vXwNxNoz50Rwen7RXj1j3AvKja0zsHlV
lmhX/BT2mIfdujgoqAYEcUJ4+1wi+I/555fw8CoGTA208zOXA5SZwSuFIpfPyizn
N9mFOIP5uKhqFLIU2NOKGYgkFFjzg7it/qq63lQZU9usurWwHSl+5BXlFu+5P5St
pFGPL+nDDQ3C4zqysxJr0WQjHI4HOI6t4O2G9/MlFyh4AruE76bHA+EHEtLCGZsi
Or5xkWaQ02vJ3dU51XiwUT0t2V1Ap4WwCNcn0G0580rBy7AHWhYdqfzO90yXQqP0
FEOMhduBhigs9tyUSlRwu/9BJg==
-----END CERTIFICATE-----
# kubectl get csr/ssup2 -o json | jq -r .status.certificate | base64 --decode > ssup2.crt
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] ssup2 CSR 승인, ssup2 인증서 확인</figcaption>
</figure>

{% highlight console %}
# kubectl create clusterrolebinding ssup2 --clusterrole=cluster-admin --user=ssup2
# kubectl config set-credentials ssup2 --client-key=./ssup2.key --client-certificate=./ssup2.crt --embed-certs=true
# kubectl config set-context ssup2 --cluster=kubernetes --user=ssup2
# kubectl config use-context ssup2
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] ssup2 인증서 설정</figcaption>
</figure>

### 2. 참조

* [https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/)
