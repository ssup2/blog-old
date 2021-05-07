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

![[그림 2] AWS EKS Pod, LB Network]({{site.baseurl}}/images/theory_analysis/AWS_EKS_Network_Load_Balancer/AWS_EKS_Pod_LB_Network.PNG)

#### 1.1. Network

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
<figcaption class="caption">[Console 2] Node, Pod Address</figcaption>
</figure>

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
