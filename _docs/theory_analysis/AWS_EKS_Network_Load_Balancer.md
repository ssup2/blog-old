---
title: AWS EKS Network, Load Balancer
category: Theory, Analysis
date: 2021-04-15T12:00:00Z
lastmod: 2021-04-15T12:00:00Z
comment: true
adsense: true
---

AWS EKS의 Network 및 Load Balancer를 분석한다.

### 1. Amazon EKS Network

![[그림 1] Amazon EKS Network]({{site.baseurl}}/images/theory_analysis/AWS_EKS_Network_Load_Balancer/AWS_EKS_Network.PNG){: width="700px"}

[그림 1]은 Amazon EKS의 Network 구성을 나타내고 있다. EKS Control Plane과 Node는 별도의 VPC (Network)에 소속되어 있다. Control Plane의 VPC 외부에서의 Control Plane의 접근은 Control Plane에 존재하는 LB (VIP)를 통합 접근만 허용된다. Control Plane의 LB는 기본적으로는 Public Network에 노출되도록 설정된다. 따라서 Public Network에 연결된 일반 PC에서 Kubernetes Client (kubectl)를 통해서 Control Plane의 Kubernetes API Server에 접근할 수 있다.

Node에서 동작하는 kubelet, kube-proxy 같은 Kubernetes Component들도 Public Network를 통해서 Control Plane에 접근한다. 따라서 Node의 VPC에서도 Public Network를 이용할 수 있도록 설정되어 있어야 한다. 반대로 Control Plane의 LB가 AWS 내부의 Private Network에만 노출되도록 설정할 수도 있다. 이 경우 Public Network에서 Kubernetes Client를 이용할 수 없고, Node의 VPC와 Control Plane의 VPC가 서로 통신할 수 있도록 설정되어 있어야 한다.

Node의 VPC는 반드시 2개 이상의 서로 다른 Availability Zone에 소속되어 있는 Subnet 2개가 존재해야 한다. 그렇지 않으면 EKS Cluster를 생성할 수 없다. 동일한 Node Group에 소속되어 있어도 각 Node는 다수의 Subnet에 분배되어 생성된다. 따라서 특정 Availability Zone이 장애가 발생하여도 Node Group의 일부 Node는 여전히 이용할 수 있게 된다. [그림 1]에서도 Node Group A,B의 Node들이 서로 다른 Subnet에 소속되어 있는것을 확인할 수 있다.

EKS Cluster 외부에 존재하는 App Client가 EKS Cluster 내부에 존재하는 App Server에 접근하기 위해서는 EKS Load Balancer가 설정하는 AWS의 Load Balancer (NLB, CLB, ALB)를 통해야 한다.

![[그림 2] Amazon EKS Pod Network]({{site.baseurl}}/images/theory_analysis/AWS_EKS_Network_Load_Balancer/AWS_EKS_Pod_Network.PNG){: width="500px"}

[그림 2]는 EKS Cluster 내부에 존재하는 Pod의 Network를 나타내고 있다. EKS Clsuter 구성시 기본적으로 설치되는 **AWS VPC CNI**는 Pod를 위한 Overlay Network를 구성하지 않고 Node가 소속되어 있는 Subnet을 같이 이용한다. 따라서 Pod의 IP는 Pod가 위치하는 Node의 Subnet에 소속된다. [그림 2]에서 Node A는 "192.168.0.0/24" Subnet에 소속되어 있기 때문에 Node A에 존재하는 Pod도 "192.168.0.0/24" Subnet에 소속되어 있는것을 확인할 수 있다.

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

![[그림 3] Amazon EKS Pod Network in Node]({{site.baseurl}}/images/theory_analysis/AWS_EKS_Network_Load_Balancer/AWS_EKS_Pod_Network_Node.PNG){: width="600px"}

[그림 3]은 Node 내부에서 Pod Network가 어떻게 구성되는지를 나타내고 있다. Node 내부에서 Pod Network 구성은 EKS CNI (Container Network Interface) Plugin이 담당한다. Node에 할당되어 있는 eth0는 Node가 생성될때 Node가 기본적으로 이용하는 Network Interface이다. eth1, eth2는 EKS CNI Plugin이 AWS에게 요청하여 동적으로 생성하는 ENI (Elastic Network Interface)이다. 여기에는 Pod의 IP가 **Secondary IP**로 할당이 된다. 따라서 Subnet에서 Dest IP가 Pod IP인 Packet이 전송되는 경우 해당 Packet은 목적지 Pod가 존재하는 Node로 Packet이 전송된다. 이후에 해당 Packet은 Node의 Routing Table에 따라서 다시 Pod로 전송된다.

Pod Network가 ENI 및 ENI에 할당되는 Secondary IP를 이용하는 방식이기 때문에, 하나의 Node에 생성될 수 있는 최대 Pod의 개수는 Node에 생성 될수 있는 ENI의 개수 및 각 ENI에 할당할 수 있는 Secondary IP의 개수에 따라서 결정된다. Node에 생성될 수 있는 ENI의 개수 및 각 ENI에 할당할 수 있는 Secondary IP의 개수는 Node의 사양(Flavor)에 따라서 달라진다. 사양이 높을 수록 생성될 수 있는 ENI의 개수 및 각 ENI에 할당할 수 있는 Secondary IP의 개수가 많아지기 때문에 생성 할수 있는 Pod의 개수도 늘어난다.

> Node의 최대 ENI 개수 × (ENI에 설정될 수 있는 최대 IP 개수 - 1)

Node의 사양에 따른 ENI의 개수 및 각 ENI에 할당할 수 있는 Secondary IP의 개수는 [가이드](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html)에서 확인할 수 있으며, 최대로 할당할 수 있는 Pod의 개수는 위의 공식에 의해서 계산할 수 있다. Node에 Pod가 하나도 존재하지 않더라도 EKS CNI Plugin은 무조건 하나의 ENI를 Node에 생성해 둔다.

### 2. Amazon EKS Load Balancer

EKS Cluster 외부에 존재하는 App Clinet에서 EKS Cluster 내부의 App Server에 접근하기 위해서는 EKS Load Balancer를 이용해야한다. EKS Cluster에서는 AWS에서 제공하는 Load Balancer인 CLB, NLB, ALB 모든 Load Balancer를 이용할 수 있다.

##### 2.1. CLB (Classic Load Balancer), NLB (Network Load Balancer)

![[그림 4] Amazon EKS CLB, NLB]({{site.baseurl}}/images/theory_analysis/AWS_EKS_Network_Load_Balancer/AWS_EKS_CLB_NLB.PNG)

EKS Cluster에서는 **LoadBalancer Service**를 생성하면 CLB 또는 NLB를 이용하여 EKS Cluster 외부에서 Service에 접근할 수 있게 된다. CLB, NLB 이용시 Packet의 경로는 **Target Type**이라고 불리는 설정과 LoadBalancer Service의 **ExternalTrafficPolicy** 설정에 따라 변경된다. [그림 4]는 EKS Cluster에서 CLB, NLB 이용시 설정에 따른 Packet의 경로를 나타내고 있다.

Target Type은 CLB, NLB에서 전송하는 Packet의 Dst IP/Port를 어떻게 설정할지 결정하는 설정이다. Target Type에는 **Instance Type**과 **IP Type**이 존재한다. Instance Type은 CLB, NLB 모두 이용가능하다. Instance Type의 경우에는 CLB, NLB가 전송하는 Packet의 Dst IP/Port를 LoadBalancer Service의 **NodePort**로 설정하고 전송한다. 이후에 Node가 LoadBalancer Service의 NodePort를 통해서 수신한 Packet은 kube-proxy가 설정한 iptables/IPVS Rule에 의해서 Packet은 Pod로 전달된다.

Instance Type의 경우에는 LoadBalancer Service의 ExternalTrafficPolicy 설정에 따라서 CLB, NLB가 전송하는 Packet의 Target Node가 달라진다. **Cluster**로 설정되어 있는 경우에 CLB, NLB는 모든 Node를 대상으로 LoadBalancer Service의 NodePort를 이용하여 Worker Node의 Health Check를 수행한다. 이후에 정상 상태의 모든 Node들에게 Packet을 분배하여 전송한다. **Local**로 설정되어 있는 경우 모든 Node를 대상으로 LoadBalancer Service의 **HealthCheckNodePort**를 통해서 Node에 Target Pod가 동작하는지 점검한다. 이후에 Target Pod가 동작하는 Node들에게만 Packet을 분배하여 전송한다.

IP Type의 경우에는 NLB만 이용 가능하다. IP Type의 경우에는 NLB가 전송하는 Packet의 Dst IP/Port를 Target Pod로 설정하고 전송한다. 이후에 Node가 Target Pod의 IP/Port를 Dst IP/Port로 갖고 있는 Packet을 수신한다면, AWS VPC CNI가 설정한 Routing Table에 의해서 Node는 해당 Packet을 Pod로 바로 전송한다.

{% highlight console %}
# kubectl get service
NAME       TYPE           CLUSTER-IP     EXTERNAL-IP                                                                    PORT(S)        AGE
my-nginx   LoadBalancer   10.100.51.23   ad39ba2b8a05d44d2b88e3e11c9706b7-1845382141.ap-northeast-2.elb.amazonaws.com   80:30686/TCP   11m
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 2] CLB, Instance Target Example</figcaption>
</figure>

{% highlight console %}
# kubectl get service
NAME       TYPE           CLUSTER-IP     EXTERNAL-IP                                                                    PORT(S)        AGE
my-nginx   LoadBalancer   10.100.51.23   ad39ba2b8a05d44d2b88e3e11c9706b7-033c32321465326e.elb.ap-northeast-2.amazonaws.com   80:30686/TCP   22m
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 3] NLB, Instance Target Example</figcaption>
</figure>

{% highlight console %}
# kubectl get service
NAME            TYPE           CLUSTER-IP     EXTERNAL-IP                                                                         PORT(S)          AGE
my-nginx-ipv4   LoadBalancer   10.100.51.23   k8s-default-mynginxi-f9350243cc-a75a0e7eb684cc04.elb.ap-northeast-2.amazonaws.com   8080:30686/TCP   22m
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 4] NLB, IP Target Example</figcaption>
</figure>

[Console 2]는 CLB와 Instance Target을 이용할 경우, [Console 3]는 NLB와 Instance Target 이용할 경우, [Console 4]는 NLB와 IP Target을 이용할 경우의 LoadBalancer Service를 나타내고 있다. LoadBalancer Service에 다음과 같은 Annotation 설정을 통해서 어떤 LB를 이용할지와 어떤 Target Type을 이용할지 설정할 수 있다.

* CLB + Instance Type : "service.beta.kubernetes.io/aws-load-balancer-type: clb"
* NLB + Instance Type : "service.beta.kubernetes.io/aws-load-balancer-type: nlb"
* NLB + IP Type : "service.beta.kubernetes.io/aws-load-balancer-type: nlb-ip"

##### 2.2. ALB (Application Load Balancer)

![[그림 5] Amazon EKS ALB]({{site.baseurl}}/images/theory_analysis/AWS_EKS_Network_Load_Balancer/AWS_EKS_ALB.PNG)

EKS Cluster에서는 **Ingress**를 생성하면 ALB를 이용하여 EKS Cluster 외부에서 Service에 접근할 수 있게 된다. CLB, NLB와 동일하게 Target Type이 존재하며, Packet의 경로도 동일하다. 단 Instance Type을 이용할 경우 Ingress에 연결된 Service를 NodePort 또는 LoadBalancer Type으로 설정하여 Service에 NodePort가 반드시 할당되어야 한다. Instance Type의 경우 ALB에서 Serivce의 NodePort로 Packet을 전송하기 때문이다. [그림 5]는 EKS Cluster에서 ALB 이용시 설정에 따른 Packet의 경로를 나타내고 있다.

{% highlight console %}
# kubectl get ingress
NAME       CLASS    HOSTS   ADDRESS                                                                      PORTS   AGE
my-nginx   <none>   *       k8s-default-mynginx-290ac4e9b9-1853125440.ap-northeast-2.elb.amazonaws.com   80      3m37s
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 5] Ingress without Group</figcaption>
</figure>

[Console 5]는 Ingress는 ALB를 이용하는 Ingress의 상태를 나타내고 있다. Ingress가 ALB를 이용하도록 설정하기 위해서는 Ingress에 다음과 같은 Annotation을 설정해야 한다.

* ALB Class 설정 (필수) : "kubernetes.io/ingress.class: alb"
* ALB Public Network 연결 : "alb.ingress.kubernetes.io/scheme: internet-facing"
* ALB Instance Target Type : "alb.ingress.kubernetes.io/target-type: instance"
* ALB IP Target Type : "alb.ingress.kubernetes.io/target-type: ip"

{% highlight console %}
# kubectl get ingress
NAME       CLASS    HOSTS   ADDRESS                                                             PORTS   AGE
my-nginx   <none>   *       k8s-mygroup-9758714285-724452701.ap-northeast-2.elb.amazonaws.com   80      12m
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 6] Ingress with Group</figcaption>
</figure>

ALB는 여러 Ingress를 하나의 VIP로 이용할 수 있는 Group 기능을 제공한다. [Console 6]는 Group 기능을 이용한 Ingress의 상태를 나타내고 있다. Group 기능을 이용하기 위해서는 아래의 Annotation을 설정해야 한다.

* ALB Group 이름 : "alb.ingress.kubernetes.io/group.name: <group-name>"

### 2. 참조

* [https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/what-is-eks.html](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/what-is-eks.html)
* [https://aws.amazon.com/blogs/containers/de-mystifying-cluster-networking-for-amazon-eks-worker-nodes/](https://aws.amazon.com/blogs/containers/de-mystifying-cluster-networking-for-amazon-eks-worker-nodes/)
* [https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/eks-networking.html](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/eks-networking.html)
* [https://docs.aws.amazon.com/eks/latest/userguide/pod-networking.html](https://docs.aws.amazon.com/eks/latest/userguide/pod-networking.html)
* [https://docs.aws.amazon.com/eks/latest/userguide/load-balancing.html](https://docs.aws.amazon.com/eks/latest/userguide/load-balancing.html)
* [https://github.com/aws/amazon-vpc-cni-k8s](https://github.com/aws/amazon-vpc-cni-k8s)
