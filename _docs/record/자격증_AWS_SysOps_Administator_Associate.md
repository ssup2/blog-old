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

### 3. 참고

* [https://www.udemy.com/course/ultimate-aws-certified-sysops-administrator-associate](https://www.udemy.com/course/ultimate-aws-certified-sysops-administrator-associate)
