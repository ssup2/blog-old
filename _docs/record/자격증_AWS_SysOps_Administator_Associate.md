---
title: 자격증 AWS SysOps Administrator Associate 시험 정리
category: Record
date: 2023-02-10T12:00:00Z
lastmod: 2023-02-10T12:00:00Z
comment: true
adsense: true
---

### 1. Base

아래의 정리된 내용을 바탕으로 부족한 내용 정리

* [AWS Solutions Architecture Assosicate](https://ssup2.github.io/record/%EC%9E%90%EA%B2%A9%EC%A6%9D_AWS_Solutions_Architect_Associate/)

### 2. EC2

* Placement Group
  * EC2 Instance를 어떻게 배치할지 결정
  * Cluster
    * 하나의 AZ에 가능하면 하나의 Server Rack에 모든 EC2 Instance 배치
    * EC2 Instance 사이의 낮은 Network Latency 발생 가능, 하지만 가용성 측면에서는 가장 불리
  * Spread
    * EC2 Instance를 AZ, Server까지 고려하여 분배
    * 높은 가용성 확보 가능, 하지만 높은 Network Latency 발생
    * 하나의 Placement Group에서 하나의 AZ당 최대 7개의 EC2 Instance만 생성 가능, AZ 개수 * 7 만큼 EC2 Instance 생성 가능
  * Partition
    * Partition 이라는 논리적 Group 단위로 배치
    * Partition 장애시 다른 Partition에 영향을 주지 않음
    * 각 AZ당 7개의 Partition이 존재하며, 각 Partition당 최대 100개의 EC2 Instance 존재 가능

  * Luanch Exception
    * InstanceLimitExcceded
      * Region에서 이용가능한 vCPU 개수 초과
      * Service Quota로 증설 요청 가능
    * InsufficientInstanceCapacity
      * AZ에 이용가능한 Instance가 존재하지 않음
      * AWS의 Resource 부족 문제
      * 다른 Instance Type, 다른 AZ로 선택 생성하여 문제 우회 가능
    * Instance Terminates Immediately
      * EBS Volume Limit에 도달, EBS Snapshot 충동, EBS Volume이 암호화 되어 있지만 KMS 접근 권한이 없을 경우

  * Metric
    * without CloudWatch Agent
      * 5분 간격으로 Metric 수집, 1분 간격으로 Metric 수집 변경 가능 하지만 추가 비용 발생
      * CPU 사용률, Network I/O, Disk I/O Instance 상태 정보 수집 가능
    * with CloudWatch Agent
      * Memory 사용륭, Disk 사용률, Process 상태 (procstat Plugin)

### 3. 참고

* [https://www.udemy.com/course/ultimate-aws-certified-sysops-administrator-associate](https://www.udemy.com/course/ultimate-aws-certified-sysops-administrator-associate)
