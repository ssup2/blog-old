---
title: Kubernetes CSR (Certificate Signing Request)
category: Theory, Analysis
date: 2020-09-29T12:00:00Z
lastmod: 2020-09-29T12:00:00Z
comment: true
adsense: true
---

Kubernetes의 CSR (Certificate Signing Request)을 분석한다.

### 1. Kubernetes CSR (Certificate Signing Request)

대부분의 Kubernetes Cluster는 검증된 Root CA (Certificate Authority)를 이용하지 않고, Private Root CA를 이용하고 있다. Kubernetes는 CSR (Certificate Signing Request)을 통해서 Kubernetes Cluster가 이용중인 Private Root CA으로부터 인증서를 발급받는 기능을 제공하고 있다. Kubernetes CSR 기능을 통해서 인증서를 발급받는 과정은 다음과 같다.

* 인증서의 Private Key 생성 
* 생성한 인증서의 Private Key를 이용하여 csr 파일 생성
* 생성한 .csr 파일의 내용을 base64로 Encoding한 문자열을 이용하여 Kubernetes의 CertificateSigningRequest Manifest 작성 및 인증서 발급 요청
* 인증서 발급 요청 수락

#### 1.1. User Example

Kubernetes CSR을 통해서 ssup2 User의 인증서를 발급하고, kubectl에 설정하여 이용하는 과정은 다음과 같다.

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

# kubectl get csr
NAME    AGE   SIGNERNAME                     REQUESTOR          CONDITION
ssup2   4s    kubernetes.io/legacy-unknown   kubernetes-admin   Pending
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] CSR 생성</figcaption>
</figure>

[Shell 1]은 openssl 명령어를 이용하여 ssup2 User의 Private Key 및 csr 파일을 생성하고, 생성한 csr 파일을 이용하여 CertificateSigningRequest Manifest를 통해서 인증서 발급 요청을 진행하는 과정을 나타내고 있다. **csr 파일 생성시 Common Name에는 반드시 User의 이름이 설정되어야 한다.** "kubectl get csr" 명령어를 통해서 인증서 발급 상태를 확인할 수 있다. 아직 인증서를 발급하지 않았기 때문에 Pending 상태로 나타난다.

{% highlight console %}
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
<figcaption class="caption">[Shell 2] CSR 승인, 인증서 확인</figcaption>
</figure>

[Shell 2]는 인증서 발급을 승인하고, 생성된 인증서를 확인 및 파일로 저장하는 과정을 나타내고 있다. "kubectl certificate approve" 명령어를 통해서 인증서 발급을 승인한다.

{% highlight console %}
# kubectl create clusterrolebinding ssup2 --clusterrole=cluster-admin --user=ssup2

# kubectl config set-credentials ssup2 --client-key=./ssup2.key --client-certificate=./ssup2.crt --embed-certs=true
# kubectl config set-context ssup2 --cluster=kubernetes --user=ssup2
# kubectl config use-context ssup2
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] Rolebinding, Context 설정</figcaption>
</figure>

[Shell 3]은 발급한 ssup2 User의 인증서를 이용하여 kubectl의 Context를 설정하는 과정을 나타내고 있다. 먼저 ssup2 User가 Kubernetes Cluster의 모든 API를 이용할 수 있도록 "kubectl create clusterrolebinding" 명령어를 통해서 ssup2 User에게 cluster-admin Role을 할당한다. 이후 생성한 ssup2 User의 Private Key와 발급 받은 ssup2의 인증서를 "kubectl config" 명령어를 이용하여 Context를 설정하면 된다.

#### 1.2. Group Example

Kubernetes CSR을 통해서 "system:masters" Group에 소속되어 있는 ssup2 User의 인증서를 발급하고, kubectl에 설정하여 이용하는 과정은 다음과 같다. "system:masters" Group에 소속되어 있는 User는 기본적으로 cluster-admin Role이 할당되기 때문에  Kubernetes Cluster의 모든 API를 이용할 수 있게 된다.

{% highlight console %}
# openssl genrsa -out ssup2.key 2048
# openssl req -new -key ssup2.key -out ssup2.csr
...
Organization Name (eg, company) [Internet Widgits Pty Ltd]:system:masters
Common Name (e.g. server FQDN or YOUR name) []:ssup2
...

# cat ssup2.csr | base64 | tr -d "\n"
LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ2tEQ0NBWGdDQVFBd1N6RUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdNQ2xOdmJXVXRVM1JoZEdVeApGekFWQmdOVkJBb01Ebk41YzNSbGJUcHRZWE4wWlhKek1RNHdEQVlEVlFRRERBVnpjM1Z3TWpDQ0FTSXdEUVlKCktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQU1KMHVaQndUVEgzWHBtV1JtMnpaU3luVDNTSXhvQkUKQnZMUG5IaENYSkVJcEM1cUxsY00wQWNQd2RiKzNMeEdiRWFTdlF4NzViVXFaOWZYQWF5SHFzcTRuTFVlbTNRSQpiSlJMTkVCbHBnUFh3SlVnT0hZUmpMczhUdW9EcmtrMlZrWTRKdkcwL015QTZ6V3FXVzBya3pXYTRZYVdEeDJlCmtOcW95bXJUMklESVhnYVFndUlOcVNjM3luK0FIcUZYUWFlcEVqS0NCN2lxSnlhcEk0SmhZNmtBbzZScmdpdGMKaGRLWHdTOVR6S0xPYmVMaUk5aTJhcVdJWVc2Tk9teVpPMkJrQVp1NHUweXlyVXJ4STVicHg3dFgvVVJsK2hucgp0bDJnMFloRS9RMndtenRoVmk4c004WUJsV1Y4aHpORDFESlQrekcrMk1KcmdpNlVrZXFrRVMwQ0F3RUFBYUFBCk1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ09KTnZSZmNQdHdYZUVYL1ZpV1dSYjB0K1Z6UDJQWDBFTkJycHYKTnd3Y2VaWnVhZUpJT0p1clRGK3JQdDYwYm5qc0MvN3N3N0xjSTQwWUpncjdybGZjZTAvT0Foamt0YmU0Mm1JVwprc1RKWkdvdEhEOVpRV1FlUVlFYWtsdVhydjJicFZQMlFkTTg1eXZwT0pKV3NQOGxUQ0VOaHlPZW8wQkF5MHN1Cit3YlBkSEZvUGw0cnJ5clliS2xkejQwYVIxL1Yxb1VLTDF2NXJiZElNRHdaODZZTTJ4MSt3c29SUkpkcFV2dUUKQ3c5STdLRjZ5cEpWUlR1eFhPQVprTHZRM2pVZDNLTmc0a1ZINCtQaDg0a3BHUG5CQ1Jva3h4cDVkN2pzUnNrSwpzKzBVd2lJYUtsU1ZQa2JrSGJzczVwQjJIVVZNN2cxUUZwMlFtT2hQb0lybE5yS2IKLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==

# cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: ssup2
spec:
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ2tEQ0NBWGdDQVFBd1N6RUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdNQ2xOdmJXVXRVM1JoZEdVeApGekFWQmdOVkJBb01Ebk41YzNSbGJUcHRZWE4wWlhKek1RNHdEQVlEVlFRRERBVnpjM1Z3TWpDQ0FTSXdEUVlKCktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ0VCQU9mbFZJUldkaXpYSkQ0aXBFRlg5RlV2aDArOFU5aUsKeDFGaTNOcHVTTnhkVDlyMmVxc2hXbEQ0Y0ZPK0E5eUJ1MzJDTm41dE1QbXFGN1ZnZm1oemNHQjJYeERsc1IrdApVcE1FalJHSnNuUnA5WnUrNTZXbzhFZ3dWNzdMQnExRVBuTjd0WHk4Vmg5Sm50RHFraWZjUGhmbXR6Ui8rNklUCndWNHFRanNaQWlzREdnams4QlVLQURpTlYzMVI4VEt1TmVRVE9vWlBBM0RMb2tZK3pRYWxwVHJQcVphTld5YmwKb0RjbHlRZCtJcGdITnIxcHc5M2tPa2loY3V2VlQzWEpNV2NWaUl3cGRpT3YvcExTem9YaG1EZC9adERsVmhxdgp0bGxFT3A1ZW4zbUtDVXMvbHVQWTJaajJjVnNjZHp2VWxBOGJKWmlLUnV3S3hnTEo3WWhOeUg4Q0F3RUFBYUFBCk1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQVFDZGZsOFNWbmQ1WjJpZW43SS9TeXZSWlBzakVvdTgyT2pRK2sKczJkeS9FczRBcFNMT2psTkJYUEdnZkZIQWlEUmFpRDFMM0FEbk0vSDFyTUFENStrNU92NnVQa0dUUGtvZ1hSaQpxT0FxekMzaUFGTHJWZENERnQ3d1Y0a25ZN3RTQkFkd1krc1VJdlV2RTB1UEJMOUY4dzZGR1NxeHpHemZ0V3o2CmEvZUtEZ0ZQZGVNNDFTbWhDcFFlVGJmZXdQM1FwL1JWamhTQXlzRW4xMkppQmppTmtHZEZMYTRaOUR3RzJXODcKSWJuSzBUS3lSR1QwajVxVEtHQ3JSY0Z6T0lZY05rTnQ0aHBVbHdoMXY3MHZnM0hIQ2dZOGRmcnBHSThmVkt2bApsdUE4YzA5Mk5GS2kzVnh4UkwzbnpzTGhvbE8rSmkxOVdGL3Z0dXdsQ3g2Sndlb2MKLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==
  usages:
  - client auth
EOF

# kubectl get csr
NAME    AGE   SIGNERNAME                     REQUESTOR          CONDITION
ssup2   4s    kubernetes.io/legacy-unknown   kubernetes-admin   Pending
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] CSR 생성</figcaption>
</figure>

[Shell 4]는 [Shell 1]의 과정처럼 openssl 명령어를 이용하여 ssup2 User의 Private Key 및 csr 파일을 생성하고, 생성한 csr 파일을 이용하여 CertificateSigningRequest Manifest를 통해서 인증서 발급 요청을 진행하는 과정을 나타내고 있다. 차이점은   **csr 파일 생성시 Organization Name에는 반드시 Group의 이름이 설정이 되어야 한다는 점이다.**

{% highlight console %}
# kubectl certificate approve ssup2
certificatesigningrequest.certificates.k8s.io/ssup2 approved
# kubectl get csr
NAME    AGE     SIGNERNAME                     REQUESTOR          CONDITION
ssup2   5m6s    kubernetes.io/legacy-unknown   kubernetes-admin   Approved,Issue

# kubectl get csr/ssup2 -o json | jq -r .status.certificate | base64 --decode
-----BEGIN CERTIFICATE-----
MIIDDzCCAfegAwIBAgIQLj9J/3jO5Cuz42A0YgwiMjANBgkqhkiG9w0BAQsFADAV
MRMwEQYDVQQDEwprdWJlcm5ldGVzMB4XDTIwMDkyOTEzMjExNloXDTIxMDkyOTEz
MjExNlowSzELMAkGA1UEBhMCQVUxEzARBgNVBAgTClNvbWUtU3RhdGUxFzAVBgNV
BAoTDnN5c3RlbTptYXN0ZXJzMQ4wDAYDVQQDEwVzc3VwMjCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAOflVIRWdizXJD4ipEFX9FUvh0+8U9iKx1Fi3Npu
SNxdT9r2eqshWlD4cFO+A9yBu32CNn5tMPmqF7VgfmhzcGB2XxDlsR+tUpMEjRGJ
snRp9Zu+56Wo8EgwV77LBq1EPnN7tXy8Vh9JntDqkifcPhfmtzR/+6ITwV4qQjsZ
AisDGgjk8BUKADiNV31R8TKuNeQTOoZPA3DLokY+zQalpTrPqZaNWybloDclyQd+
IpgHNr1pw93kOkihcuvVT3XJMWcViIwpdiOv/pLSzoXhmDd/ZtDlVhqvtllEOp5e
n3mKCUs/luPY2Zj2cVscdzvUlA8bJZiKRuwKxgLJ7YhNyH8CAwEAAaMlMCMwEwYD
VR0lBAwwCgYIKwYBBQUHAwIwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOC
AQEAj8BxaFooOCWx+8BCsOm4Zxdn/UE0jWRvLlgxNMHvNSWoIfHRoCxSLIECMrxQ
SHRG47YcZMDJATBQ5TRNgGO7WuBos2MYMEzVc3E1/IjYIyazC6vWZ/6PkM6h7IkX
UqTI3swOqfOvvOZpv2oRCMq5PLtasVNHdIUJyzTUgb9GgYiipgtA1fluXb5aFRd8
xH0NHI0nOgFZvoKGbwjX8uGmnFwM20OEDMb3WBUg2D0YGjzw5Mp4UpzDVF6PChsI
d3Mohd4bJoYkuiWgQFhSPdfCCihBwto6jcx+JQSK5UaUjlMGOOaYY/GDkYBpklux
B5fPsCHS37uxQKe+t+uQZCDOgg==
-----END CERTIFICATE-----
# kubectl get csr/ssup2 -o json | jq -r .status.certificate | base64 --decode > ssup2.crt
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 5] CSR 승인, 인증서 확인</figcaption>
</figure>

[Shell 5]는 [Shell 2]의 과정처럼 인증서 발급을 승인하고, 생성된 인증서를 확인 및 파일로 저장하는 과정을 나타내고 있다. "kubectl certificate approve" 명령어를 통해서 인증서 발급을 승인한다.

{% highlight console %}
# kubectl config set-credentials ssup2 --client-key=./ssup2.key --client-certificate=./ssup2.crt --embed-certs=true
# kubectl config set-context ssup2 --cluster=kubernetes --user=ssup2
# kubectl config use-context ssup2
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 6] Context 설정</figcaption>
</figure>

[Shell 6]은 [Shell 3]의 과정처럼 발급한 ssup2 User의 인증서를 이용하여 kubectl의 Context를 설정하는 과정을 나타내고 있다. [Shell 3]과의 차이점은 ssup2 User에게 "kubectl create clusterrolebinding" 명령어를 cluster-admin Role을 할당하는 과정이 없다는 점이다. 이유는 앞에서 설명했던것 처럼 "system:masters" Group에 소속되어 있는 User는 기본적으로 cluster-admin Role이 할당되는데, ssup2 User가 "system:masters" Group에 소속되어있기 때문이다.

### 2. 참조

* [https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/)
