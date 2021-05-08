---
title: AWS EKS Network, Load Balancer
category: Theory, Analysis
date: 2021-04-15T12:00:00Z
lastmod: 2021-04-15T12:00:00Z
comment: true
adsense: true
---

AWS EKS의 Network 및 Load Balancer를 분석한다.

### 1. AWS EKS Network

![[그림 1] AWS EKS Network]({{site.baseurl}}/images/theory_analysis/AWS_EKS_Network_Load_Balancer/AWS_EKS_Network.PNG){: width="700px"}

[그림 1]은 AWS EKS의 Network 구성을 나타내고 있다. EKS Control Plane과 Node는 별도의 VPC (Network)에 소속되어 있다. Control Plane의 VPC 외부에서의 Control Plane의 접근은 Control Plane에 존재하는 LB (VIP)를 통합 접근만 허용된다. Control Plane의 LB는 기본적으로는 Public Network에 노출되도록 설정된다. 따라서 Public Network에 연결된 일반 PC에서 Kubernetes Client (kubectl)를 통해서 Control Plane의 Kubernetes API Server에 접근할 수 있다.

Node에서 동작하는 kubelet, kube-proxy 같은 Kubernetes Component들도 Public Network를 통해서 Control Plane에 접근한다. 따라서 Node의 VPC에서도 Public Network를 이용할 수 있도록 설정되어 있어야 한다. 반대로 Control Plane의 LB가 AWS 내부의 Private Network에만 노출되도록 설정할 수도 있다. 이 경우 Public Network에서 Kubernetes Client를 이용할 수 없고, Node의 VPC와 Control Plane의 VPC가 서로 통신할 수 있도록 설정되어 있어야 한다.

Node의 VPC는 반드시 2개 이상의 서로 다른 Availability Zone에 소속되어 있는 Subnet 2개가 존재해야 한다. 그렇지 않으면 EKS Cluster를 생성할 수 없다. 동일한 Node Group에 소속되어 있어도 각 Node는 다수의 Subnet에 분배되어 생성된다. 따라서 특정 Availability Zone이 장애가 발생하여도 Node Group의 일부 Node는 여전히 이용할 수 있게 된다. [그림 1]에서도 Node Group A,B의 Node들이 서로 다른 Subnet에 소속되어 있는것을 확인할 수 있다.

EKS Cluster 외부에 존재하는 App Client가 EKS Cluster 내부에 존재하는 App Server에 접근하기 위해서는 EKS Load Balancer가 설정하는 AWS의 Load Balancer (NLB, CLB, ALB)를 통해야 한다.

![[그림 2] AWS EKS Pod, LB Network]({{site.baseurl}}/images/theory_analysis/AWS_EKS_Network_Load_Balancer/AWS_EKS_Pod_LB_Network.PNG)

[그림 2]는 EKS Cluster 내부에 존재하는 Pod 및 EKS Cluster의 Load Balancer 관점에서의 Network 구성을 나타내고 있다. EKS Clsuter 구성시 기본적으로 설치되는 **AWS VPC CNI**는 Pod를 위한 Overlay Network를 구성하지 않고 Node가 소속되어 있는 Subnet을 같이 이용한다. 따라서 Pod의 IP는 Pod가 위치하는 Node의 Subnet에 소속된다. [그림 2]에서 Node A는 "192.168.0.0/24" Subnet에 소속되어 있기 때문에 Node A에 존재하는 Pod도 "192.168.0.0/24" Subnet에 소속되어 있는것을 확인할 수 있다.

{% highlight console %}
# kubectl get node
NAME                                                STATUS   ROLES    AGE     VERSION              INTERNAL-IP      EXTERNAL-IP     OS-IMAGE         KERNEL-VERSION                  CONTAINER-RUNTIME
ip-192-168-46-6.ap-northeast-2.compute.internal     Ready    <none>   2d21h   v1.18.9-eks-d1db3c   192.168.46.6     52.79.236.233   Amazon Linux 2   4.14.225-169.362.amzn2.x86_64   docker://19.3.13
ip-192-168-48-175.ap-northeast-2.compute.internal   Ready    <none>   2d21h   v1.18.9-eks-d1db3c   192.168.48.175   3.35.24.235     Amazon Linux 2   4.14.225-169.362.amzn2.x86_64   docker://19.3.13
ip-192-168-75-136.ap-northeast-2.compute.internal   Ready    <none>   2d21h   v1.18.9-eks-d1db3c   192.168.75.136   52.78.17.141    Amazon Linux 2   4.14.225-169.362.amzn2.x86_64   docker://19.3.13
ip-192-168-90-3.ap-northeast-2.compute.internal     Ready    <none>   2d21h   v1.18.9-eks-d1db3c   192.168.90.3     3.36.73.81      Amazon Linux 2   4.14.225-169.362.amzn2.x86_64   docker://19.3.13

# kubectl get pod -o wide
NAME                        READY   STATUS    RESTARTS   AGE     IP               NODE                                                NOMINATED NODE   READINESS GATES
my-nginx-5dc4865748-6pr9g   1/1     Running   0          7m51s   192.168.68.109   ip-192-168-90-3.ap-northeast-2.compute.internal     <none>           <none>
my-nginx-5dc4865748-8snkt   1/1     Running   0          7m51s   192.168.73.93    ip-192-168-75-136.ap-northeast-2.compute.internal   <none>           <none>
my-nginx-5dc4865748-g2xzk   1/1     Running   0          7m51s   192.168.36.89    ip-192-168-46-6.ap-northeast-2.compute.internal     <none>           <none>
my-nginx-5dc4865748-m5fhq   1/1     Running   0          7m51s   192.168.63.206   ip-192-168-48-175.ap-northeast-2.compute.internal   <none>           <none>
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 1] Node, Pod Address</figcaption>
</figure>

[Console 1]은 실제 EKS Cluster Node의 IP와 EKS Cluster Pod의 IP를 나타내고 있다. ip-192-168-46-6.ap-northeast-2.compute.internal, ip-192-168-48-175.ap-northeast-2.compute.internal Node는 "192.168.32.0/19" Subnet에 소속되어 있고, ip-192-168-75-136.ap-northeast-2.compute.internal, ip-192-168-90-3.ap-northeast-2.compute.internal Node는 "192.168.64.0/19" Subnet에 소속되어 있다. 각 Node에 존재하는 Pod들도 해당 Subnet에 소속되어 있는것을 확인할 수 있다.

### 2. AWS EKS Load Balancer

##### 2.1. CLB (Classic Load Balancer)

{% highlight console %}
# kubectl get service
NAME       TYPE           CLUSTER-IP     EXTERNAL-IP                                                                    PORT(S)        AGE
my-nginx   LoadBalancer   10.100.51.23   ad39ba2b8a05d44d2b88e3e11c9706b7-1845382141.ap-northeast-2.elb.amazonaws.com   80:30686/TCP   11m
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 3] Node, Pod Address</figcaption>
</figure>

##### 2.2. NLB (Network Load Balancer)

{% highlight console %}
# kubectl get service
NAME       TYPE           CLUSTER-IP     EXTERNAL-IP                                                                    PORT(S)        AGE
my-nginx   LoadBalancer   10.100.51.23   ad39ba2b8a05d44d2b88e3e11c9706b7-033c32321465326e.elb.ap-northeast-2.amazonaws.com   80:30686/TCP   22m
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 4] Node, Pod Address</figcaption>
</figure>

`service.beta.kubernetes.io/aws-load-balancer-type: nlb`

##### 2.3. ALB (Application Load Balancer)

{% highlight console %}
# kubectl get ingress
NAME       CLASS    HOSTS   ADDRESS                                                                      PORTS   AGE
my-nginx   <none>   *       k8s-default-mynginx-290ac4e9b9-1853125440.ap-northeast-2.elb.amazonaws.com   80      3m37s
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 5] Ingress without Group</figcaption>
</figure>

{% highlight console %}
# kubectl get ingress
NAME       CLASS    HOSTS   ADDRESS                                                             PORTS   AGE
my-nginx   <none>   *       k8s-mygroup-9758714285-724452701.ap-northeast-2.elb.amazonaws.com   80      12m
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 6] Ingress with Group</figcaption>
</figure>

`kubernetes.io/ingress.class: alb`
`alb.ingress.kubernetes.io/scheme: internet-facing`
`alb.ingress.kubernetes.io/target-type: ip`
`alb.ingress.kubernetes.io/group.name: my-group`

### 2. 참조

* [https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/what-is-eks.html](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/what-is-eks.html)
* [https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/eks-networking.html](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/eks-networking.html)
* [https://docs.aws.amazon.com/eks/latest/userguide/pod-networking.html](https://docs.aws.amazon.com/eks/latest/userguide/pod-networking.html)
