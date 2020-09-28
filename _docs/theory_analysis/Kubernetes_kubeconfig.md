---
title: Kubernetes kubeconfig
category: Theory, Analysis
date: 2020-09-28T12:00:00Z
lastmod: 2020-09-28T12:00:00Z
comment: true
adsense: true
---

Kubernetes의 kubeconfig를 분석한다.

### 1. Kubernetes kubeconfig

![[그림 1] Nginx Ingress Controller]({{site.baseurl}}/images/theory_analysis/Kubernetes_kubeconfig/kubeconfig.PNG){: width="700px"}

kubeconfig는 Kubernetes의 Client인 kubectl 명렁어에서 이용하는 설정 파일이다. kubectl 명렁어가 접근해야할 Kubernetes API Server의 접속 정보와 kubectl 명령어가 이용하는 인증, 인가 정보가 포함되어 있다. kubeconfig는 yaml 형태를 갖고 있으며 크게 clusters, users, contexts 3가지 항목을 갖고 있다. [그림 1]은 kubeconfig 도식으로 나타내고 있다.

kubeconfig의 clusters 항목에는 다수의 Cluster 정보가 저장되어 있다. Cluster 정보에는 Cluster의 이름, Cluster의 API Server의 접속 경로 그리고 Cluster에서 이용하는 Base64로 Encoding된 CA (Certificate Authority) 인증서 정보가 저장되어 있다. kubeconfig의 users 항목에는 다수의 User 정보가 저장되어 있다. User 정보에는 User의 이름, Base64로 Encoding된 User의 Public 인증서 그리고 Base64로 Encoding된 User의 Private Key가 저장되어 있다. User의 Public 인증서의 정보를 바탕으로 Kubernetes는 인증, 인가를 수행한다.

kubeconfig의 contexts는 Context의 이름 및 정보 배열로 구성된다. 여기서 Context는 Cluster와 User의 조합을 의미한다. [그림 1]에서 Context-A는 User-A가 Cluster-A를 이용하는 상태를 의미한다. 이와 유사하게 [그림 1]에서 Context-C는 User-C가 Cluster-B를 이용하는 상태를 의미한다. kubeconfig의 current-context 항목에은 현재 이용중인 Context를 의미한다. [그림 1]에서 current-context 항목에 Context-B가 명시되어 있는걸 확인할 수 있다. 따라서 kubectl이 [그림 1]의 kubeconfig를 이용한다면, kubectl은 User-B User로 Cluster-B Cluster에 접속하여 Client 동작을 수행한다.

#### 1.1. Example

{% highlight yaml %}
apiVersion: v1
kind: Config
current-context: kubernetes-admin@kubernetes
preferences: {}
contexts:
- name: kubernetes-admin@kubernetes
  context:
    cluster: kubernetes
    user: kubernetes-admin
clusters:
- name: kubernetes
  cluster:
    server: https://192.168.0.61:6443
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJd01Ea3hNREUxTVRJeE5Gb1hEVE13TURrd09ERTFNVEl4TkZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTXNBCmhMaVcvNm43RmNwSmdDUmExSHBIaGIzY1NMNC9UWnBQcjYzcXZ3OC9DRG1Wd0dUTlZheXBIYkt4dmV1dGg5UFkKaGdpT3JtTHlaVG1SSTZ3VlhnSzdVMmtHQmgyKzR2YTVDWlViV0s2TGNZcEQxTW1weGhyd1VLR0JURms3eEVaZQprQ0U1VEhwWUpZZXprNG0vVVpTR2ViaG1saHQweXk2QjZTWStJeTlFM0EySkczOHEvRzZnLzFlMzNyajQvcDN6CmRnbXJ5cUZEUGQrbWlFeEFHN3pUSjV4Slo4Q2I4WldtWU9RQmp1eTlnNFFOSDYvVmRxd1lnNVI4eWhzV1dRY2cKczlndVlpSXNaRVFhc053d2lwOUFnR2xVcWNSbVBjbDh2b21rVjRFc01zRUhXb1k3SDVTWGNEL2lDSFh2eW9vKwpOU25NSGdSRmlNczc0NHA5QkxrQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFCNHVPL1FCM05KNTJhSTJFdlQ3YjNxVkVaUGsKaGpsTHZkNmdKZlhTdXJWZEV6M2hXVFp4S0RVa24wSDVaTUlLS1hlb1BFak1UcEJFNTFzV3NRZUx0QlBzSFNxOApVQkpJbUZwcmgwZVhjdC9vdStHUFpkbHZJTlFWdkg0NTRONTBvZzhTbTk0K09pdUlRSUlOWEVMcWVCWStWZ0h3CnIyT3JsZGQxQWtBZ3dyWG9ucmJzVnRVa2d0bzlTT2ZlellpeS9oU2NmVWlpRkF4S2t4eTVrWG5CamhkaVNvRnQKV1YrQ0M2REhSRU9uVU9wRU5BYWQvMHNOdmJKbEVVUmxQancrNUFGaEptSkpRK1NhckFleVZIdWkyQ0F3ak1WdQpKa1IycVllZjQ2VDRiQzlnNmMyd2J3SUZVUlIrVGlya3JqRjU2UjZLM3E0aGJ3R1FQdkNtOG1DRDZSTT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM4akNDQWRxZ0F3SUJBZ0lJUzd0V1UwMWtvSWd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TURBNU1UQXhOVEV5TVRSYUZ3MHlNVEE1TVRBeE5URXlNVFZhTURReApGekFWQmdOVkJBb1REbk41YzNSbGJUcHRZWE4wWlhKek1Sa3dGd1lEVlFRREV4QnJkV0psY201bGRHVnpMV0ZrCmJXbHVNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQW9YRGpXT0RnanRQMFd5dEoKbjFjOW1aK2RlaFdJck9IcEFkaVB1VVNRdVpyUkgxNlJud2xTQ0xoK3lRRUZiKzlJdFJuRFlvUGU0THAydUNFMgpSUStsaTF5emN6Yi9idkxHT2Y3dTI3ZE1BYTVNQmpreTcyaTZrSStaR0oxeDBvRXhXU29xTUdrWTB4dUFGeFNVCmUyQm1YTkFLV3FDS0grSVhDVnN6T2ZUZ2grUjBXZ0tJeTRDZFppcVNrY05HZHRHdUwxRW1wU1dUYlkxNG0yZWcKaW9HTDFHb3pOd2FWYW8zT1psMGE3TUJkSER4YWVTQlprRlhXRWlVZ1ZzMmpCa2pzaTFNNVdXL2t5R3dvY09zWQpCSWdKR2ExY2dEalZGK1M0aVFhdEpaM2lld3dnbFFnRGtwVTlwM2JtSHkwUHp5bTRBWVo5aXNubUFKZXdXQ3cwCkZ6cHViUUlEQVFBQm95Y3dKVEFPQmdOVkhROEJBZjhFQkFNQ0JhQXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUgKQXdJd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFFQ3kyeitjbm1mcnFsQmU2c1k4UCtsd1ZYMTdKNitWVjEzSApFdjl3NmNEK3FSYjNUQTMxSzFoQ1JsNG9pUzdxblpvdjZ5U3BhblN4cHRkdCtBVWpleW5RSkFoWkJwaFRnSkVYCkZIM01pVjQ0Zkd3MFNHQ3N6dUJCMWVWeWY4cFNSbjVSMk1ZVEdxQkdmTFpERThJN09oV3JBSkxZaTR6YjM4cWgKQ2hYNTZzUW1iYUxKNEpqd000dG1aNmhLM2NZR29uZkNrLzg2NHdMRnN4T3BzaDBwWFM1SUZ0ZjV0WFZnZWxINAowbDVxTlhzWDc1VXE2cm44NWc1alRPZjhnek5DekRNSmVsSk8rMUZoWHBIc3dxcW9GZ3g3dnVnamVlZEpuK1BMClQ0N0gzajAyNU5xMDBJS21qanZqMHljR2x5ZklIaGNaT2RVdDdMcEdwYllDc0lRRmp3Yz0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcFFJQkFBS0NBUUVBb1hEaldPRGdqdFAwV3l0Sm4xYzltWitkZWhXSXJPSHBBZGlQdVVTUXVaclJIMTZSCm53bFNDTGgreVFFRmIrOUl0Um5EWW9QZTRMcDJ1Q0UyUlErbGkxeXpjemIvYnZMR09mN3UyN2RNQWE1TUJqa3kKNzJpNmtJK1pHSjF4MG9FeFdTb3FNR2tZMHh1QUZ4U1VlMkJtWE5BS1dxQ0tIK0lYQ1Zzek9mVGdoK1IwV2dLSQp5NENkWmlxU2tjTkdkdEd1TDFFbXBTV1RiWTE0bTJlZ2lvR0wxR296TndhVmFvM09abDBhN01CZEhEeGFlU0JaCmtGWFdFaVVnVnMyakJranNpMU01V1cva3lHd29jT3NZQklnSkdhMWNnRGpWRitTNGlRYXRKWjNpZXd3Z2xRZ0QKa3BVOXAzYm1IeTBQenltNEFZWjlpc25tQUpld1dDdzBGenB1YlFJREFRQUJBb0lCQUJOQmpNeUlIaURMSlVWTwpsM3g3QW16MWZlb1c4WE4xaXI1ZW4xNEEwS1ppMGZqRTVlZXJTKzZnV3ZjTXVTSk56MFZTcWx4dzBEL0wzZWMrCmh1T2I1eW9GUjU1QmZCdzJ0dkFwK1VHWnptWVE3UjU4NmhkbVRZSjZyazhpVUhaRVZLZUhBUHMvUGVmSVN2SDEKMFhRWjNudkprTUtZallFYURaZGZHbkFhUmtIUERJL1k5T21HcmdnTnBhZUJxdkQrN29wdDArZEFrbWNncmVJZgpGNm5yY0RsanRqeGo4WHluSGNoaTIzdXFDMUVPVVRXQ3BFUWt1aittbjhKQXd1eitQN3Ira1FjcFFxNTlxU3RJCnZFUmlHTnFKNzVZcXNGRHpzQUNMK3RhbjFBelNuUkRkTXFsLzYwbTRzUmd2STRmOFF4ZlNHZGl4SU1PTmdrMkUKZHJkODU5MENnWUVBMGd1VWR1c1VtaCsrUmVxQm5ROU1TclBXMGtBQnN3eC84a1ZrK3VKOUpaY2wyYS8rNXlJNgp2T0VxMFROSS9MVWtHUWVzOFltT1VoSmh4RWp4dW1tWlZQY1ljUm1iRkNjeGFsNGdLR0h5WmJ6VmpwUUc2b3g3CkVnekdwQTNjeStLRlhabC9sa2lLeGZxaWNlalNiZE1BWXB3L1FCZ0pGYi9nQnNWMnUzdjJmZWNDZ1lFQXhNTUkKVzkrMi9YUlpEWEZHZm5MUzJ3RSsrak9LMmQ4ekp6VE5zdUwyV0dSZkhqY21KRG15Mkd3T2tCNDMyQWd6SWszcwpRZ3RscmwweldTUzd6d0tnMU0vYkoyMWdPN0hqTnhWUlNhaVpNelZ6NGZZMUMxYVdsV3BXUW5MT3lYdW5GclRhCkJVRlBnblliVkVEVGZJUVR2OVBkb28wM0h3WmgzVWg1WnNybEhvc0NnWUVBeEp6MlVnSm0vSVl1TTMvNTU2ekUKTzBEd0cwcXl6SWtzMHZsR050bi9UMHFXc1poZXdMaDN4d24yYkhEWEowWGdEbFh5K3YxSjdXVXJndkxNNHpPcAp4YkN1ZmwvN20vZTc5OWMzdnRWQWN4ODV3QWFzR3ExNUhrSTdScUY3UnBZNVJJNUVzY1loc0lTVnZvNnpPdjVCCjVBeGg0SHNmTmU2dm8yYi9aeXY0WlkwQ2dZRUF1QzlwajdjbmNMS00rZ3hqVk5MZmxxcmY3UTU2bCtCYjNnT0wKMmp5akpiTXZadlZ3K3RBWUhvZG9TbmcvQmpjR3hzSHl1eEE0S3JTTDhKSjJUQjNGdC9DcTBZbU5YOVB4UWdydQpnT2tXSDkyVmtKd01vNFIyaVg5MUo5YVl3L3JBT24wbzZXcHRwMDR2M3ZxZi9oc1U4YWk5Ky8vODdVbm9LbUJCClpIdmhabWtDZ1lFQXQzejhLSzVzTXJaNHdObEJ3WElqa0dzYlYxWDZya3o1aWxpTWU0Sk1MV3UyYVYwSzF3MGgKajBUbzRaTXJYYWRha2ZDUGg3UGV1SzlYVEk2TEJTNkFKOXJEaGZ5bEg4NFN0eWFOYWkzN0V5YjFwTDJWUGV0SAorVFFPOVhtR0NWNzc0RlpUR2gzSm1qalQ1QUpGbXJrYmtvUkU5TUJnKzE1eU44L0VaWjRPV3Q4PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Admin kubeconfig</figcaption>
</figure>

[파일 1]은 kubeadm 명령어로 Cluster를 구성하였을때 kubeadm이 구성한 Cluster의 Admin을 위해서 생성하는 실제 kubeconfig 파일을 나타내고 있다. [파일 1]에서 clusters 항목에 "kubernetes" 이름의 Cluster 정보가 저장되어 있다. server에는 "kubernetes" Cluster의 API Server의 접속 정보가 저장되어 있고, certificate-authority-data에는 "kubernetes" Cluster에서 이용하는 CA (Certificate Authority) 인증서 정보가 Base64로 Encoding되어 저장되어 있다. "kubernetes" Cluster의 CA 인증서 정보를 보면 Cluster의 이름인 kubernetes 문자열을 Common Name 항목에 저장하고 있다.

[파일 1]에서 users 항목에 "kubernetes-admin" 이름의 User의 정보가 저장되어 있다. client-certificate-data에는 Base64로 Encoding된 "kubernetes-admin" User의 Public 인증서가 저장되어 있고, client-key-data에는 Base64로 Encoding된 "kubernetes-admin" User의 Private Key가 저장되어 있다. "kubernetes-admin" User의 Public 인증서 정보를 보면 User의 이름인 kubernetes-admin 문자열을 Common Name 항목에 저장하고 있고, system:masters 문자열을 Organization 항목에 저장하고 있다. "system:masters"는 "kubernetes-admin" User가 소속되어 있는 Group을 의미한다.

{% highlight yaml %}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:masters
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] cluster-admin ClusterRoleBinding</figcaption>
</figure>

[파일 2]는 Cluster에 적용되어있는 "cluster-admin" 이름의 ClusterRoleBinding을 나타내고 있다. "cluster-admin" 이름의 ClusterRole은 모든 API에 대해서 권한을 갖고 있는 Role이다. "cluster-admin" ClusterRole이 적용(Binding)되는 대상은 "system:masters" 이름의 Group인걸 확인할 수 있다. 따라서 "kubernetes-admin" User는 "system:masters" Group에 소속되기 때문에 모든 API에 대한 권한을 갖게된다.

[파일 1]에서 contexts 항목에 "kubernetes-admin@kubernetes" 이름의 Context 정보가 저장되어 있다. "kubernetes-admin@kubernetes" Context는 "kubernetes-admin" User가 "kubernetes" Cluster를 이용하는 것을 의미한다. current-context 항목에는 "kubernetes-admin@kubernetes" Context가 명시되어 있는걸 확인할 수 있다. 즉 현재 kubectl 명령어는 kubernetes-admin 이름의 User로 kubernetes 이름의 Cluster에 접속한다는 의미이다.

### 2. 참조

* [https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/)
* [https://jamesdefabia.github.io/docs/user-guide/kubectl/kubectl_config_set-cluster/](https://jamesdefabia.github.io/docs/user-guide/kubectl/kubectl_config_set-cluster/)
