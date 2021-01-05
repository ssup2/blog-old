---
title: Container Network Interface (CNI) 
category: Theory, Analysis
date: 2018-06-20T12:00:00Z
lastmod: 2018-06-20T12:00:00Z
comment: true
adsense: true
---

Container Network 설정시 이용되는 Container Network Interface (CNI)를 분석한다.

### 1. Container Network Interface (CNI)

![[그림 1] CNI]({{site.baseurl}}/images/theory_analysis/Container_Network_Interface/CNI.PNG){: width="700px"}

Container Network Interface (CNI)는 **Linux Container의 Network Interface**를 설정할때 이용되는 Interface이다. Kubernetes, rkt, Openshift과 같은 많은 Container Platform 또는 Container Runtime들은 CNI를 준수하는 **Conf (Configuration) 파일**과 **Plugin**을 실행하여 Container의 Network Interface를 설정하고 있다. 여기서 Conf File은 Container안에 설정될 Network Interface와 연결될 Network 정보를 담고 있는 설정 파일을 의미하며, Plugin은 Shell에서 실행 가능한 Binary(Command)를 의미한다.

#### 1.1 Conf (Configuration) 파일

{% highlight json %}
{
	"cniVersion": "0.2.0",
	"name": "mynet",
	"type": "bridge",
	"bridge": "cni0",
	"isGateway": true,
	"ipMasq": true,
	"ipam": {
		"type": "host-local",
		"subnet": "10.22.0.0/16",
		"routes": [
			{ "dst": "0.0.0.0/0" }
		]
	}
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] mynet.conf</figcaption>
</figure>

Conf 파일은 Container에 설정될 Network Interface와 연결될 Network 정보가 저장되어 있는 설정 파일이다. [파일 1]은 Conf 파일의 예시인 mynet.conf를 나타내고 있다. Network IP, Routing Rule 및 네트워크 구성에 필요한 Bridge 이름등이 포함되어 있다. Conf 파일의 기본 경로는 "/etc/cni/net.d"를 이용하고 있다. 이용할 Plugin에 따라서 Conf 파일의 형태는 달라질 수 있다.

#### 1.2. Plugin

Plugin은 Conf 파일에 설정된 Network과 연결되어 있는 Network Interface를 Container에 설정하고, 설정된 Container의 Network Interface 정보를 반환하는 역할을 수행한다. Plugin은 Shell에서 실행 가능한 Binary(Command)형태로 존재한다. Plugin은 Conf 파일의 내용을 **stdin**으로 받고 CNI_COMMAND, CNI_CONTAINERID, CNI_NETNS, CNI_IFNAME 등의 환경변수를 Parameter로 이용한다. 아래는 중요 환경변수에 대한 설명이다.

* CNI_COMMAND : Network Interface ADD(추가), DEL(삭제), GET(조회) 명령어
* CNI_CONTAINERID : Network Interface를 조작할 Target Container의 ID
* CNI_NETNS : Target Container의 Network Namespace File의 위치
* CNI_IFNAME : Network Interface 이름

{% highlight console %}
# export CNI_COMMAND=ADD; export CNI_CONTAINERID=...
# /opt/cni/bin/bridge < ~/test_cni/mynet.conf
{
    "ip4": {
        "ip": "10.22.0.3/16",
        "gateway": "10.22.0.1",
        "routes": [
            {
                "dst": "0.0.0.0/0",
                "gw": "10.22.0.1"
            }
        ]
    },
    "dns": {}
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] mynet.conf 적용</figcaption>
</figure>

Plugin이 잘 수행되어 Container의 Network Interface 조작이 성공했다면, Plugin은 관련 Network Interface의 MAC, IP, DNS 정보등을 **JSON 형태로 stdout**으로 출력한다. [Shell 1]은 [파일 1]의 mynet.conf 파일을 이용하여 Container에 Network Interface를 추가했을때 Plugin이 출력하는 내용이다. 추가된 Interface의 IP, Gateway 정보등을 확인 할 수 있다. Plugin의 기본 경로는 "/opt/cni/bin"을 이용한다.

Container Platform 또는 Container Runtime은 Conf 파일 생성, Plugin을 위한 환변경수 설정, Plugin 실행을 통해서 Container의 Network Interface를 설정하고, Plugin의 stdout으로 출력되는 설정된 Container Interface의 정보를 얻어 관리하는 동작을 수행한다.

### 2. 참조

* [https://github.com/containernetworking/cni/blob/master/SPEC.md](https://github.com/containernetworking/cni/blob/master/SPEC.md)
* [https://kubernetes-csi.github.io/docs/](https://kubernetes-csi.github.io/docs/)
* [https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)
