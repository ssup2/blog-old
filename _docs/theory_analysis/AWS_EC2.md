---
title: AWS EC2
category: Theory, Analysis
date: 2022-07-30T12:00:00Z
lastmod: 2022-07-30T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

Amazon EC2 Service를 정리한다. EC2 Service는 AWS에서 Instance(Server)를 생성하여 Computing 자원을 제공하는 Service이다.

### 1. Instance Type

{: .newline }
> [FamilyName][GenerationNumber].[Size] <br/>
> Ex) t3.large / c5.xlarge / p3.2xlarge <br/>
<figure>
<figcaption class="caption">[Format 1] EC2 Instance Type Format</figcaption>
</figure>

Instance Type은 Instance의 Spec을 의미한다. [Format 1]은 Instance Type의 Format을 나타낸다. Instance의 특정에 따라서 General Purpose, Compute Optimized, Memory Optimized, Storage Optimized, Accelerate Computing Type으로 구분된다.

#### 1.1. General Purpose

General Purpose Type은 CPU, Memory, Disk, Network 모두 평범한 성능과 크기를 갖는 Instance Type이다. 일반적인 용도로 가장 많이 이용되는 Instance Type이다. Bustable Performance Instance와 Fixed Performance Instance로 구분할 수 있다.

##### 1.1.1. Burstable Performance Instance

General Purpose Type중에서 Burstable Performance Instance는 의미 그대로 오직 **일시적으로 최대 성능의 CPU**를 활용할 수 있는 Instance를 의미한다. Fixed Performance Instnace에 비해서 저렴한 가격이 가장 큰 장점이다. 평상시에는 사용량이 높지 않지만 일시적으로 높은 CPU 성능이 필요한 경우 고려할 수 있는 Instance Type이다. 다음과 같이 "t"로 시작되는 Instance Side가 Burstable Performance를 지원하는 Instance Type을 의미한다.

* t4g, t3, t3a, t2...

Burstable Performance Instance는 **Credit**을 통해서 최대 성능의 CPU를 이용할 수 있는 시간이 달라진다. Credit은 EC2 Instance가 **Baseline**이라고 불리는 기준 CPU 사용률보다 더 많은 CPU를 이용하고 있다면 차감되며, Baseline CPU 사용률보다 적은 CPU를 이용하고 있다면 Credit은 축적된다. Credit이 모두 차감되면 해당 EC2 Instance는 Credit이 충전되기 전까지 성능 제한이 걸린다. Credit은 시간단위로 충전되며, Instance Type마다 Credit 충전량 및 최대로 충전할 수 있는 Credit의 개수도 다르다. Instance Type별 Credit량 및 Baseline CPU 사용률은 [Link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-credits-baseline-concepts.html#earning-CPU-credits)에서 확인 가능하다.

Burstable Performance Instance를 이용할경우 Instance 내부에서는 CPU 사용율에 **Steal Time**이 나타날 수 있다. 일반적인 Cloud 환경에서 Steal Time은 Noisy Neighbor로 인한 성능 간섭의 영향으로 분석하지만, AWS의 Burstable Performance의 경우에는 모든 Credit 소모로 인해서 성능 제한이 걸린다는 의미다.

###### 1.1.1.1. Unlimited Mode

Burstable Performance Instance는 Unlimited Mode를 제공한다. Unlimited Mode에서는 Credit이 모두 차감되더라도 CPU에 성능 제한이 걸리지 않는다. 대신에 24시간 동안의 평균 CPU 사용률이 Baseline를 초과하면, 초과한 만큼 추가 비용을 지불해야한다. 반대로 24시간 동안의 평균 CPU 사용률이 Baseline 미만이라면 추가 비용을 지불하지 않는다. 예를들어 "t3.large" Instance는 Baseline이 30%이기 때문에 24시간의 평균 CPU 사용률이 40%라면 10%만큼 추가 비용을 지불해야 한다.

Unlimited Mode를 이용하면 Burstable Performance Instance도 Fixed Performance Instance와 동일하게 고정된 성능을 이용할 수 있다. 하지만 평균 CPU 사용률이 100%에 근접할 수록 Unlimited Mode를 이용하는것 보다 Fixed Performance Instance를 이용하는게 비용적으로 유리하다. 따라서 Unlimited Mode를 도입시 Fixed Performance Instance를 이용도 고민해야 한다.

{: .newline }
> Per_vCPU_Cost * (CPU_Excess_Usage/100) * Instance_vCPU_Count * 24 <br/>
> Ex) t4g.large (2vCPU, Baseline CPU 30%), Average CPU 50%
> --> t4g.large : 0.05$ * (50-30/100) * 2 * 24 = 0.48$ <br/>
<figure>
<figcaption class="caption">[Formula 1] Unlimited Mode Instance Additional Cost per Day</figcaption>
</figure>

[Formula 1]은 Unlimited Mode시 추가 비용이 계산하는 공식을 나타내고 있다. Baseline보다 더 많이 CPU 사용량이 높을수록 비용도 같이 증가하는 것을 확인할 수 있다. Instance Type별 시간당 vCPU의 비용은 [Link](https://aws.amazon.com/ec2/pricing/on-demand/#T2.2FT3.2FT4g_Unlimited_Mode_Pricing)에서 확인 가능하다. Unlimited Mode는 Instance가 동작, 정지시에 언제든지 설정 및 설정 해제가 가능한 특징을 가지고 있다. 따라서 필요에 따라서 쉬운 적용 및 해지가 가능하다.

##### 1.2.1. Fixed Performance Instance

General Purpose Type중에서 Fixed Perforamnce Instance는 의미 그대로 고정된 성능을 이용할 수 있는 Instnace를 의미한다. Burstable Performance Instane와 달리 Instance 내부에서 Steal Time이 발생하지 않는다. 다음과 같이 "m"으로 시작되는 Instance Type이 Fixed Performance를 Instance Type을 의미한다.

* m6g, m6i, m5...

#### 1.2. Compute Optimized

Compute Optimized Type은 vCPU 성능에 최적화된 Instance Type이다. Instance의 Spec 중에서 vCPU의 비율이 높은 특징을 가지고 있다. 즉 vCPU Core 개수당 가격은 가장 저렴한 특징을 가지고 있다. 다음과 같이 "c"로 시작되는 Instance Type이 Compute Optimized Instance Type을 의미한다.

* c7g, c6i, c6gn...

#### 1.3. Memory Optimized

Memory Optimized Type은 Memory 용량에 최적화된 Instance Type이다. Instance Spec 중에서 Memory의 비율이 높은 특징을 가지고 있다. 즉 Memory 용량당 가장 저렴한 특징을 가지고고 있다. 다음과 같이 "r", "x", "z"로 시작되는 Instance Type이 Memory Optimized Instance Type을 의미한다.

* r6a, r6g, x2gd, x2idn, z1d...

#### 1.4. Storage Optimized

Storage Optimized Type은 특정 Instance에 종속된는 Instance Store 성능에 최적화된 Instance Type이다. Instance의 Spec 중에서 Instance Store 성능의 비율이 높은 특징을 가지고 있다. 다음과 같이 "i", "d", "h"로 시작되는 Instance Type이 Storage Optimized Type을 의미한다.

* i4i, im4gn, d3, h1...

#### 1.5. Accelerated Computing

Accelerated Computing Type은 GPU, FPGA, AWS Inferentia와 같은 별도의 Co-processor를 갖는 Instance Type이다. 일반적으로 Machine Learning Training 및 Serving을 위해서 많이 이용된다.

### 2. Network

#### 2.1. Network Interface

모든 EC2 Instance는 **Primary Network Interface**가 존재한다. Primary Network Interface는 EC2 Instance로부터 땔수 없다. Primary Network Interface를 제외한 나머지 Network Interface는 **Secondary Network Interface**라고 불리며, Secondary Network Interface는 EC2 Interface에 언제든지 붙이고 때는것이 가능하다. EC2 Instance에 붙일 수 있는 최대 Secondary Network Interface의 개수는 일반적으로 Instance의 Spec이 높을수록 같이 높아진다.

Primary Network Interface, Secondary Network Interface 모두 다수의 Private IP를 갖을수 있으며, 일반적으로 Instance의 Spec이 높을수록 하나의 Network Interface에 할당할 수 있는 Private IP의 개수도 증가한다. Instance Type별 최대 Network Interface 개수 및 Network Interface별 최대 Private IP의 개수는 다음의 [Link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html)에서 확인 가능하다.

#### 2.2. Network Bandwidth

EC2 Instance의 Bandwidth는 일반적으로 vCPU의 개수에 비례한다. 각 EC2 Instance의 Network Bandwidth는 각 Instance Type마다 아래의 Link에서 확인할 수 있다.

* General Purpose : [Link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/general-purpose-instances.html#general-purpose-network-performance)
* Compute Optimized : [Link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/compute-optimized-instances.html)
* Memory Optimized : [Link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/memory-optimized-instances.html)
* Storage Optimized : [Link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/storage-optimized-instances.html)
* Accelerated Computing : [Link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/accelerated-computing-instances.html#gpu-network-performance)

Instance Spec의 Network Bandwith를 보면 고정된 "25Gbps"와 같이 Network Bandwidth가 명시되어 있는 경우가 있고, "Up to 25Gbps"와 같이 최대 Network Bandwidth가 명시되어 있는 경우 2가지로 나누어진다. 고정된 Network Bandwidth의 경우에는 언제나 고정된 Network Bandwith를 이용할 수 있다.

"Up to"로 명시된 Network Bandwidth는 Credit 기반으로 동작하며 일시적으로는 최대 명시된 최대 Network Bandwidth까지 이용할 수 있지만 평균적으로는 명시된 Baseline Bandwidth 정도로 이용할 수 있다. 이용중인 Network Bandwidth가 Baseline보다 적게 이용하면 Credit이 충전되며, Network Bandwidth가 Baseline보다 많게 이용한다면 Credit이 소모된다. Credit이 다 소모되면 Network Bandwidth는 Baseline Bandwith로 제한된다. Credit이 남아 있더라도 다른 EC2 Instance의 영향으로 인해서 최대 Network Bandwidth를 다 이용하지 못할 수 있다. Baseline Network Bandwidth는 Credit에 관계 없이 언제나 보장받으며 이용할 수 있다.

### 3. Storage

#### 3.1. Amazon EBS

Amazon EBS는 AWS에서 제공하는 Volume Storage Service이다. Network 기반 원격 Storage이다. 따라서 EC2 Instance의 Host(Hypervisor) Storage를 이용하는 Instance Store에 비해서 느린 성능을 갖고 있지만, EC2 Instance와 별개의 Life-Cycle을 갖기 때문에 다양한 EC2 Instance에 붙여서 이용이 가능하다. 또한 고가용성의 특징을 갖고 있으며 Amazon EBS의 Snapshot 기능도 이용 가능하다. Amazone EBS를 이용하는 EC2 Instance의 Volume 성능은 Instance Type이 아니라 Amazon EBS에 따라서 결정된다. Amazon EBS는 대부분의 Instance Type에 붙일 수 있다는 장점도 가지고 있다.

#### 3.2. Instance Store

Instance Store는 EC2 Instance가 이용 가능한 임시 Store이다. EC Instance의 Host(Hypervisor)의 Storage를 이용하기 때문에, Amazon EBS에 비해서 빠른 성능이 가장 큰 장점이다. 하지만 Instance Store에 저장된 Data는 고가용성을 제공하지 않으며 하나의 EC2 Instance에만 붙일 수 있기 때문에 민첩성이 떨어지는 단점을 가지고 있다. 따라서 임시로 Data 저장이 필요한 경우에만 Instance Store를 이용해야 한다.

Storage Optimized Instance Type의 Instance Store의 성능이 가격대비 가장 높은 특징을 가지고 있다. Instance Store는 일부 지원하는 Instance Type의 EC2 Instance에만 붙일 수 있으며, Instance Type마다 다른 성능을 보여준다. 자세한 내용은 아래의 링크에서 확인할 수 있다.

* General Purpose : [Link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/general-purpose-instances.html#general-purpose-ssd-perf)
* Compute Optimized : [Link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/compute-optimized-instances.html#compute-ssd-perf)
* Memory Optimized : [Link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/memory-optimized-instances.html#instances-ssd-perf)
* Storage Optimized : [Link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/storage-optimized-instances.html#storage-instances-diskperf)
* Accelerated Computing : [Link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/accelerated-computing-instances.html#accelerated-computing-ssd-perf)

### 4. Pricing

EC2 Instance에는 다양한 가격 정책이 존재한다. 각 가격 정책의 특징을 파악하여 적절한 가격 정책을 선택해야 비용 절감 효과를 얻을 수 있다.

#### 4.1. On-Demand

On-Demand 방식은 사용자의 요청에 따라서 즉시 EC2 Instance를 생성하고 이용하는 정책을 의미한다. 사용자는 EC2 Instance를 이용한 만큼 비용을 지불한다. 가장 간편하게 EC2 Instance를 이용할 수 있는 방법이지만 가장 비용이 높다는 단점을 가지고 있다. 따라서 비용적 측면 때문에 오랜 시간동안 이용하기에는 적합하지 않으며, 일반적으로 예측하지 못한 짧은 수행 시간을 갖는 Workload를 구동하는데 이용한다.

#### 4.2. Reserved Instance

Reserved Instance 방식은 Instance를 특정 기간동안 이용하겠다라는 약정을 틍해서 할인을 받는 방식이다. 약정 기간은 1년 또는 3년 단위로 계약할 수 있으며, 한번 약정하면 취소는 불가능 하며, 지불 방식에 따라서 아래와 같은 3가지의 Option이 존재한다.

* All Upfront : 약정 기긴의 비용을 한번에 지불하는 방식이다. 가장 많은 비용을 절감할 수 있다.
* Partial Upfront : 약정 기간의 비용을 일부를 먼저 지불하고, 나머지 비용은 EC2 Instance의 이용 유무에 관계없이 할안된 시간당 요금을 지불하는 방식이다.
* No Upfront : 약정 기간의 비용을 처음에는 지불하지 않고, EC2 Instance 이용 유무에 관계없이 할인되니 시간당 요금을 지불하는 방식이다. 가장 적게 비용을 절감할 수 있다.

약정 방식에 따라서 Standard, Convertible 2가지의 Option이 존재한다.

* Standard : Instance Type의 Family를 교체할 수 없지만 Convertible 대비 더 많은 할인이 제공된다. Instance의 Size 변경도 가능하다. 만약 4vCPU/8GB Instance를 구입했다면 2개의 2vCPU/4GB Instance 또는 4개의 1vCPU/2GB Instance를 구동할 수 있다. 또한 8vCPU/16GB Instance를 구동한다면 8vCPU/16GB Instance 비용의 절반을 Reserved Instance로 대체할 수 있다. 남은 약정 기간은 AWS Marketplace에서 판매할 수도 있다.
* Convertible : Instance Type의 Family를 교체할 수 있지만 Standard 대비 적은 할인이 제공된다. Family 교체시 비용은 이전과 동일하거나 더 높을 경우에만 교체가 가능하다. 남은 약정 기간을 AWS Marketplace에 판매할 수 없다.

#### 4.3. Spot Instance

Spot Instance는 AWS에서 관리되는 예비 EC2 Instance를 저렴하게 이용하는 방식이다. 예비 EC2 Instance의 상황에 따라서 Spot Instance의 가격이 실시간으로 변동된다. 현재의 Spot Instance의 비용이 사용자가 설정한 최대 Spot Instance 비용보다 낮은 경우 Spot Instance는 동작하며, 반대로 높은 경우 Spot Instance는 정지된다. 따라서 사용자는 Spot Instance가 언제 구동 및 정지 될지 정확히 파악할수 없으며, 이러한 특징 때문에 언제든지 실행해도 문제가 없는 Batch Job과 같은 Workload에 적합하다.

Spot Instance는 중단되기 2분전에 CloudWatch Event로 부터 중단 Event를 수신할 수 있다. 따라서 Spot Instance 내부에서 동작하는 Workload의 우아한 종료를 위해서는 중단 Event를 처리해야 한다. 중단 Event를 활용하는 대표적인 예는 중단될 Spot Instance를 Autoscaling Group에서 제거하여 ELB로부터 더이상 Traffic을 받지 못하도록 설정할 수 있다.

#### 4.4. Dedicated Hosts

Dedicated Hosts는 특정 Account가 특정 Host(Hypervisor)를 독점하여 이용하는 방식이다. 일반적인 Host 위에서는 다양한 Account의 EC2 Instance가 동작하지만, Dedicated Host 위에서는 Host를 독점한 Account의 다수의 EC2 Instance들만 동작한다. Dedicated Hosts를 이용하는 이유는 Windows Server, SQL server와 같은 per-socket, per-core, per-VM과 같은 License를 이용하기 위해서 이다.

#### 4.5. Dedicated Instances

Dedicated Instance는 특정 Host 전체를 독점하여 이용하는 방식이다. 다른 EC2 Instance는 Dedicated Instance가 동작하는 Host위에서 동작할 수 없다. Dedicated Instance를 이용하는 이유는 일반적으로 Compliance 충족을 위해서 이용한다. Dedicated Host를 통해서 사용자가 EC2 Instance 하나만 동작시켜도 Compliance 충족이 가능하지만, 비용적 측면에서는 Dedicated Host보다 저렴하기 때문에 Compliance 충족을 위해서라면 Dedicated Instance를 이용하는 것이 권장된다.

Dedicated Instance는 일반적으로 특정 Host 전체를 독점하여 동작하지만 한가지 예외가 존재한다. 동일 Account의 Dedicated Instance가 아닌 일반 EC2 Instance는 같이 동작할 수 있다. 이외의 동일 Account의 다른 Dedicated Instnace 또는 다른 Account의 EC2 Instance와는 같이 동작하지 않는다.

#### 4.6. On-Demand Capacity Reservations

On-Demand Capacity Reservation은 현재부터 특정 기간까지 특정 Instance Type을 예약하고 이용하는 방식이다. 실제 EC2 Instance를 이용하지 안더라도 예약한 시점부터 예약 종료 시점까지 비용이 발생한다.

Reserved Instance와 차이점은 Reserved Instance는 1년 또는 3년 2가지만 약정 기간을 설정할 수 있지만, On-Demand Capacity Reservation은 현재부터 특정 날짜까지 자유롭게 예약이 가능하다. 또한 Reserved Instance는 약정 기간까지 EC2 Instance를 이용하겠다라는 계약이지 실제 EC2 Instance 예약하고 선점하지 않는다. 반면 On-Demand Capacity Reservation는 계약 기간만큼 실제 EC2 Instance를 예약하고 선점하여 다른 사용자가 이용하지 못하도록 한다.

### 3. 참조

* EC2 Instance Type : [https://aws.amazon.com/ec2/instance-types/](https://aws.amazon.com/ec2/instance-types/)
* Steal Time : [https://stackoverflow.com/questions/20133739/amazon-aws-micro-instance-with-100-cpu-and-unresponsive](https://stackoverflow.com/questions/20133739/amazon-aws-micro-instance-with-100-cpu-and-unresponsive)
* Pricing : [https://aws.amazon.com/ec2/pricing/](https://aws.amazon.com/ec2/pricing/)
* RI Standard, Convertible : [https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/ri-convertible-exchange.html](https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/ri-convertible-exchange.html)
* RI Standard, Convertible : [https://www.reddit.com/r/aws/comments/ivjhde/aws_pricing_reserved_instances_standard_vs/](https://www.reddit.com/r/aws/comments/ivjhde/aws_pricing_reserved_instances_standard_vs/)
* Dedicated Host, Instance : [https://www.hava.io/blog/what-are-dedicated-aws-ec2-instances](https://www.hava.io/blog/what-are-dedicated-aws-ec2-instances)