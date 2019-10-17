---
title: CNI (Container Network Interface)
category: Theory, Analysis
date: 2018-06-20T12:00:00Z
lastmod: 2018-06-20T12:00:00Z
comment: true
adsense: true
---

Container Network 설정시 이용되는 CNI (Container Network Interface)를 분석한다.

### 1. Container Network Interface (CNI)

![[그림 1] CNI]({{site.baseurl}}/images/theory_analysis/Container_Network_Interface/CNI.PNG){: width="700px"}

Container Network Interface (CNI)는 **Linux Container의 Network 설정 Spec**을 의미한다. Kubernetes, rkt, Openshift같은 많은 **Container Runtime**들은 CNI를 이용하여 Network 정의 및 Container를 해당 Network에 연결하거나 분리하는 작업을 수행한다. Container Runtime은 CNI에 맞추어 Container에 설정할 Network 정보를 **Conf (Configuration) 파일**에 정의한다. 그 후 **CNI Plugin**을 실행하여 Container를 Configuration 파일에 정의한 Network에 연결하거나 분리하는 작업을 수행한다. Container Runtime은 CNI Plugin의 교체만으로 다양한 형태의 Container Network를 쉽게 구축 할 수 있다.

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

Conf 파일은 Container가 연결될 Network를 구성하는데 필요한 정보가 저장되어 있는 파일이다. [파일 1]은 Conf 파일의 예시인 mynet.conf를 나타내고 있다. Network IP, Routing Rule 및 네트워크 구성에 필요한 Bridge 이름등이 포함되어 있다. Conf 파일의 기본 경로는 /etc/cni/net.d이다.

#### 1.2. Plugin

Plugin은 Conf 파일에 정의된 Container Network에 특정 Container를 붙이고, 해당 Network에 연결된 Container의 Network Interface 정보를 반환하는 역활을 수행한다. Plugin은 Shell에서 실행가능한 **Binary**이다. Plugin은 Conf 파일의 내용을 **stdin**으로 받고 CNI_COMMAND, CNI_CONTAINERID, CNI_NETNS, CNI_IFNAME 등의 환경변수를 Parameter로 이용한다. 아래는 중요 환경변수에 대한 설명이다.

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

Plugin이 잘 수행되어 Container의 Network Interface 조작이 성공했다면, Plugin은 관련 Network Interface의 MAC, IP, DNS 정보등을 stdout으로 출력한다. [Shell 1]은 [파일 1]의 mynet.conf 파일을 이용하여 Container에 Network Interface를 추가했을때 Plugin이 출력하는 내용이다. 추가된 Interface의 IP, Gateway 정보등을 확인 할 수 있다.

이처럼 CNI는 **conf 파일, plugin의 환경변수, plugin이 출력하는 Network Interface 정보**등의 Spec을 정의한다. Container Runtime은 CNI에 맞게 conf 파일 생성, Plugin을 수행, Plugin 출력 Parsing 과정을 통해 Container Network를 조작하고 Container Network 정보를 얻어온다. Plugin의 기본경로는 /opt/cni/bin이다.

### 2. 참조

* [https://github.com/containernetworking/cni/blob/master/SPEC.md](https://github.com/containernetworking/cni/blob/master/SPEC.md)
* [https://kubernetes-csi.github.io/docs/](https://kubernetes-csi.github.io/docs/)
* [https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)
