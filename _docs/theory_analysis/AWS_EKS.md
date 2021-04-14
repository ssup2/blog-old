---
title: AWS EKS (Elastic Kubernetes Service)
category: Theory, Analysis
date: 2021-04-15T12:00:00Z
lastmod: 2021-04-15T12:00:00Z
comment: true
adsense: true
---

AWS EKS(Elastic Kubernetes Service)를 분석한다.

### 1. AWS EKS (Elastic Kubernetes Service)

{% highlight console %}
$ kubectl -n kube-system get pod
NAME                                          READY   STATUS    RESTARTS   AGE
aws-load-balancer-controller-bc59445f-l4brz   1/1     Running   0          2d23h
aws-node-kwdxc                                1/1     Running   0          2d23h
aws-node-r475d                                1/1     Running   0          2d23h
aws-node-tmc8g                                1/1     Running   0          2d23h
aws-node-zpnjs                                1/1     Running   0          2d23h
coredns-6fb4cf484b-d8spf                      1/1     Running   0          2d23h
coredns-6fb4cf484b-wzfvp                      1/1     Running   0          2d23h
kube-proxy-ldxj4                              1/1     Running   0          2d23h
kube-proxy-p2hjg                              1/1     Running   0          2d23h
kube-proxy-pbgs4                              1/1     Running   0          2d23h
kube-proxy-vtf68                              1/1     Running   0          2d23h
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 1] Pods in kube-system namespace</figcaption>
</figure>

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

#### 1.2. Load Balancer

##### 1.2.1. CLB (Classic Load Balancer)

{% highlight console %}
# kubectl get service
NAME       TYPE           CLUSTER-IP     EXTERNAL-IP                                                                    PORT(S)        AGE
my-nginx   LoadBalancer   10.100.51.23   ad39ba2b8a05d44d2b88e3e11c9706b7-1845382141.ap-northeast-2.elb.amazonaws.com   80:30686/TCP   11m
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 3] Node, Pod Address</figcaption>
</figure>

##### 1.2.2. NLB (Network Load Balancer)

{% highlight console %}
# kubectl get service
NAME       TYPE           CLUSTER-IP     EXTERNAL-IP                                                                    PORT(S)        AGE
my-nginx   LoadBalancer   10.100.51.23   ad39ba2b8a05d44d2b88e3e11c9706b7-033c32321465326e.elb.ap-northeast-2.amazonaws.com   80:30686/TCP   22m
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 4] Node, Pod Address</figcaption>
</figure>

`service.beta.kubernetes.io/aws-load-balancer-type: nlb`

##### 1.2.3. ALB (Application Load Balancer)

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

#### 1.3. Storage

{% highlight console %}
# kubectl get sc
NAME            PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
gp2 (default)   kubernetes.io/aws-ebs   Delete          WaitForFirstConsumer   false                  3d1h
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 7] Ingress with Group</figcaption>
</figure>

{% highlight console %}
Apr 09 15:55:32 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:32.183634    3801 topology_manager.go:233] [topologymanager] Topology Admit Handler
Apr 09 15:55:32 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:32.336844    3801 reconciler.go:224] operationExecutor.VerifyControllerAttachedVolume started for volume "pvc-1b5dd043-40fc-4924-b1af-03bfa9630751" (UniqueName: "kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837")
Apr 09 15:55:32 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:32.336896    3801 reconciler.go:224] operationExecutor.VerifyControllerAttachedVolume started for volume "default-token-7m864" (UniqueName: "kubernetes.io/secret/6681c826-f599-4549-b2e1-707c69c26837-default-token-7m864") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837")
Apr 09 15:55:32 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: E0409 15:55:32.337007    3801 nestedpendingoperations.go:301] Operation for "{volumeName:kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89 podName: nodeName:}" failed. No retries permitted until 2021-04-09 15:55:32.836974851 +0000 UTC m=+263922.787528156 (durationBeforeRetry 500ms). Error: "Volume has not been added to the list of VolumesInUse in the node's volume status for volume \"pvc-1b5dd043-40fc-4924-b1af-03bfa9630751\" (UniqueName: \"kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89\") pod \"web-1\" (UID: \"6681c826-f599-4549-b2e1-707c69c26837\") "
Apr 09 15:55:32 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:32.841678    3801 reconciler.go:224] operationExecutor.VerifyControllerAttachedVolume started for volume "pvc-1b5dd043-40fc-4924-b1af-03bfa9630751" (UniqueName: "kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837")
Apr 09 15:55:32 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: E0409 15:55:32.841780    3801 nestedpendingoperations.go:301] Operation for "{volumeName:kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89 podName: nodeName:}" failed. No retries permitted until 2021-04-09 15:55:33.841752915 +0000 UTC m=+263923.792306216 (durationBeforeRetry 1s). Error: "Volume has not been added to the list of VolumesInUse in the node's volume status for volume \"pvc-1b5dd043-40fc-4924-b1af-03bfa9630751\" (UniqueName: \"kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89\") pod \"web-1\" (UID: \"6681c826-f599-4549-b2e1-707c69c26837\") "
Apr 09 15:55:33 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:33.844677    3801 reconciler.go:224] operationExecutor.VerifyControllerAttachedVolume started for volume "pvc-1b5dd043-40fc-4924-b1af-03bfa9630751" (UniqueName: "kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837")
Apr 09 15:55:33 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: E0409 15:55:33.850478    3801 nestedpendingoperations.go:301] Operation for "{volumeName:kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89 podName: nodeName:}" failed. No retries permitted until 2021-04-09 15:55:35.850450415 +0000 UTC m=+263925.801003754 (durationBeforeRetry 2s). Error: "Volume not attached according to node status for volume \"pvc-1b5dd043-40fc-4924-b1af-03bfa9630751\" (UniqueName: \"kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89\") pod \"web-1\" (UID: \"6681c826-f599-4549-b2e1-707c69c26837\") "
Apr 09 15:55:34 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: {"level":"info","ts":"2021-04-09T15:55:34.244Z","caller":"/usr/local/go/src/runtime/proc.go:203","msg":"CNI Plugin version: v1.7.5 ..."}
Apr 09 15:55:35 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:35.949997    3801 reconciler.go:224] operationExecutor.VerifyControllerAttachedVolume started for volume "pvc-1b5dd043-40fc-4924-b1af-03bfa9630751" (UniqueName: "kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837")
Apr 09 15:55:35 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:35.955735    3801 operation_generator.go:1332] Controller attach succeeded for volume "pvc-1b5dd043-40fc-4924-b1af-03bfa9630751" (UniqueName: "kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837") device path: "/dev/xvdbw"
Apr 09 15:55:36 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:36.050389    3801 operation_generator.go:558] MountVolume.WaitForAttach entering for volume "pvc-1b5dd043-40fc-4924-b1af-03bfa9630751" (UniqueName: "kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837") DevicePath "/dev/xvdbw"
Apr 09 15:55:37 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:37.050635    3801 attacher.go:189] Successfully found attached AWS Volume "aws://ap-northeast-2a/vol-0c6206285b4820d89" at path "/dev/xvdbw".
Apr 09 15:55:37 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:37.050689    3801 operation_generator.go:567] MountVolume.WaitForAttach succeeded for volume "pvc-1b5dd043-40fc-4924-b1af-03bfa9630751" (UniqueName: "kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837") DevicePath "/dev/xvdbw"
Apr 09 15:55:37 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:37.068352    3801 mount_linux.go:366] Disk "/dev/xvdbw" appears to be unformatted, attempting to format as type: "ext4" with options: [-F -m0 /dev/xvdbw]
Apr 09 15:55:37 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:37.286426    3801 mount_linux.go:376] Disk successfully formatted (mkfs): ext4 - /dev/xvdbw /var/lib/kubelet/plugins/kubernetes.io/aws-ebs/mounts/aws/ap-northeast-2a/vol-0c6206285b4820d89
Apr 09 15:55:37 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: I0409 15:55:37.447140    3801 operation_generator.go:596] MountVolume.MountDevice succeeded for volume "pvc-1b5dd043-40fc-4924-b1af-03bfa9630751" (UniqueName: "kubernetes.io/aws-ebs/aws://ap-northeast-2a/vol-0c6206285b4820d89") pod "web-1" (UID: "6681c826-f599-4549-b2e1-707c69c26837") device mount path "/var/lib/kubelet/plugins/kubernetes.io/aws-ebs/mounts/aws/ap-northeast-2a/vol-0c6206285b4820d89"
Apr 09 15:55:38 ip-192-168-75-136.ap-northeast-2.compute.internal kubelet[3801]: W0409 15:55:38.128905    3801 pod_container_deletor.go:77] Container "d9165d9862d7d713871f40be45cf4f11224597a85edf68e893a6b3df36e313f9" not found in pod's containers
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 8] kubelet mount log</figcaption>
</figure>

{% highlight console %}
# ls -l /dev/ | grep xvda
lrwxrwxrwx 1 root root           7 Apr  6 14:36 xvda -> nvme0n1
lrwxrwxrwx 1 root root           9 Apr  6 14:36 xvda1 -> nvme0n1p1
lrwxrwxrwx 1 root root          11 Apr  6 14:36 xvda128 -> nvme0n1p128
lrwxrwxrwx 1 root root           7 Apr  9 15:55 xvdbw -> nvme1n1
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 9] EBS Mount</figcaption>
</figure>

#### 1.4. Authentication, Authorization

##### 1.4.1. kubeconfig

{% highlight console %}
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeE1EUXdOakUwTWpneU5Wb1hEVE14TURRd05ERTBNamd5TlZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBSzZqCjliUkZndjFZTWtVSXg3dXlnOTUyRVRkRXlQbzR4Z2hyakwyQjBpazBhUXFVQU5uL21hV0JCUmpNc2RHM3dLdmsKSVZQYnRNcG9DSTY3WnhSOSsvdFhDZGJEZm1GMVhKRllzSld3aTdiNVloQzZXcXNTU3N1TXBpa3JSZTh6UlNGcwpwL3JrNzNmUGs4Z2pOR2pUcWE1ZFlJOFJJcjBpaS9NckZ6eDhqTFl2cGR5cHdsZ3NBTEl4eUF1MEdTajhXb3ZmClErKytwcGh6aU95K2luclBicUI0ZndqWHczeWhGVEJDUHNKSDRuY3JsTHZvWXM2MndJMm5lTlc3VDAzMGhPa04KMzFmOVVmOGdRQlZZTjNnTFhyUE5KTng1Y1dndFR1TFpmQU9FMjZYVkY3dzM1YXhodmRuRWZqRDFad3h4Smg1aAovZEdMR2N4LzJzZjRPZ0Ixb01jQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFDeEZuVGVLUmcrV3JZTVJWNzJScFVkbVVBdTgKdFN4ZHVxVjNIeHFLUXFHdWE2OEhDNkxmQWROcWQ5bWd2Zi9JTzgvdHFocVFNbkxKWXB1bGFDNk01WEFBYk5BdQpxZjJHTFVIaC9JS1ZSMmJUeG1EejFYbEhIaFJuMWhOdnpOZlFycGhJaHBWWG1KbWtGeURINnZjT2lMT2hvQko1CllOUkxpeEN1ei85WCtxcEZsa0lhaUNqcjNZMnNtN0dpMkIyakN6N3FKc3FFT1gralhTNHh0enEvc3NJK0pSL2MKejdvRXJjdnlsVGpCcXVabXF2RnlJYU1kNmlPQk9UQTF2cDFBNE11aVViSktFYWY2ZU4xM0JOanZFMXAxRXJtVgowRVNRWEhvVEg0YnhKNGw1Zmt0VlJ4VFJkTHc0Z0dBSTc5MWlEM0RWQi83ZHF4Vld0cGRIelFNb2VwZz0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=            server: https://B0678ED568FC12BBC37256BBA2A4BB53.yl4.ap-northeast-2.eks.amazonaws.com
  name: ssup2-eks-cluster.ap-northeast-2.eksctl.io
contexts:
- context:
    cluster: ssup2-eks-cluster.ap-northeast-2.eksctl.io
    user: kakao_ccc@ssup2-eks-cluster.ap-northeast-2.eksctl.io
  name: kakao_ccc@ssup2-eks-cluster.ap-northeast-2.eksctl.io
current-context: kakao_ccc@ssup2-eks-cluster.ap-northeast-2.eksctl.io
kind: Config
preferences: {}
users:
- name: kakao_ccc@ssup2-eks-cluster.ap-northeast-2.eksctl.io
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - eks
      - get-token
      - --cluster-name
      - ssup2-eks-cluster
      - --region
      - ap-northeast-2
      command: aws
      env:
      - name: AWS_STS_REGIONAL_ENDPOINTS
        value: regional
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 10] kubeconfig</figcaption>
</figure>

##### 1.4.2. kubelet

{% highlight console %}
# cat /etc/eksctl/kubeconfig.yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /etc/eksctl/ca.crt
    server: https://B0678ED568FC12BBC37256BBA2A4BB53.yl4.ap-northeast-2.eks.amazonaws.com
  name: ssup2-eks-cluster.ap-northeast-2.eksctl.io
contexts:
- context:
    cluster: ssup2-eks-cluster.ap-northeast-2.eksctl.io
    user: kubelet@ssup2-eks-cluster.ap-northeast-2.eksctl.io
  name: kubelet@ssup2-eks-cluster.ap-northeast-2.eksctl.io
current-context: kubelet@ssup2-eks-cluster.ap-northeast-2.eksctl.io
kind: Config
preferences: {}
users:
- name: kubelet@ssup2-eks-cluster.ap-northeast-2.eksctl.io
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - eks
      - get-token
      - --cluster-name
      - ssup2-eks-cluster
      - --region
      - ap-northeast-2
      command: aws
      env:
      - name: AWS_STS_REGIONAL_ENDPOINTS
        value: regional
{% endhighlight %}
<figure>
<figcaption class="caption">[Console 11] kubelet</figcaption>
</figure>

##### 1.4.3. OIDC Provider

`arn:aws:iam::<account-id>:oidc-provider/oidc.eks.<region>.amazonaws.com/id/<id>`

### 2. 참조

* [https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/what-is-eks.html](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/what-is-eks.html)
* [https://www.blog-dreamus.com/post/flo-tech-aws-eks%EC%97%90%EC%84%9C%EC%9D%98-iam-%EC%97%AD%ED%95%A0-%EB%B6%84%EB%A6%AC](https://www.blog-dreamus.com/post/flo-tech-aws-eks%EC%97%90%EC%84%9C%EC%9D%98-iam-%EC%97%AD%ED%95%A0-%EB%B6%84%EB%A6%AC)