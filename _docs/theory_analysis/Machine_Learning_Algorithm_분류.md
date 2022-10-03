---
title: Machine Learning Algorithm 분류
category: Theory, Analysis
date: 2022-10-01T12:00:00Z
lastmod: 2022-10-01T12:00:00Z
comment: true
adsense: true
---

Machine Learning Algorithm을 분류하고 정리한다.

### 1. Machine Learning Algorithm 분류

Machine Learning Algorithm은 일반적으로 지도 학습, 비지도 학습, 준지도 학습, 강화 학습 4가지로 구분할 수 있다.

#### 1.1. 지도 학습 (Supervised Learning)

지도 학습 방식은 **입력 Data와 이에 따른 정답**을 이용하는 학습 방식이다. 학습을 수행하는 사람이 정답을 기반으로 지도하며 학습을 수행시키기 때문에 지도 학습이라는 명칭이 붙었다. 학습이 완료된 지도 학습 Algorithm은 일반적으로 입력 Data에 대한 어떠한 **결과를 예측**하는데 이용되며, 예측한 결과를 기반으로 분류, 회귀의 동작을 수행한다.

##### 1.1.1. 분류 (Classification)

분류를 수행하는 Alogrithm은 의미 그대로 입력 Data가 **어떤 Class(Type)**인지 구분하는 Algorithm을 의미한다. 고양이 그림과 강아지 그림이 존재하는 상황에서 고양이 그림과 강아지 그림을 구분하는 기능이 필요한 경우 지도 학습의 분류 Algorithm을 이용하여 구현할 수 있다. 학습시 이용하는 그림들은 학습을 수행시키는 사람이 각 그림이 고양이인지 강아지인지 구분된 그림들을 이용한다.

##### 1.1.2. 회귀 (Regression)

##### 1.1.3. 예상 (Forecasting)

#### 1.2. 비지도 학습 (Unsupervised Learning)

비지도 학습 방식은 **입력 Data**만 이용하는 학습 방식이다. 학습을 수행하는 사람이 어떠한 결과를 예측하지 않고 학습을 수행시키기 때문에 비지도 학습이라는 명칭이 붙었다. 비지도 학습 Algorithm은 일반적으로 사람이 예측하지 못한 **Data의 연관성**을 찾는데 이용되며, Data의 연관성을 바탕으로 군집화, 차원 축소의 동작을 수행한다.

##### 1.2.1. 군집화 (Clustering)

##### 1.2.2. 차원 축소 (Dimension Reduction)

#### 1.3. 준지도 학습 (Semi-supervised Learning)

준지도 학습은 **일부의 입력 Data와 이에 따른 정답**을 이용하는 학습 방식이다. 모든 입력 Data에 대한 정답이 아닌 일부의 Data에 대해서한 정답을 갖고 있기 때문에 준지도 학습이라는 명칭이 붙었다. 준지도 학습 Algorithm은 일반적으로 Data Labeling을 수행하는데 이용한다.

##### 1.3.1. Data Labeling

Data Labeling은 의미 그대로 Label이 붙어 있지 않는 Data에 Label을 붙이는 작업을 의미한다. 일반적으로 Data의 양이 너무 방대하거나 사람이 빠르게 인지하기 힘든 정보에 대해서 Label을 붙일 경우, 준지도 학습 기반의 Data Labeling을 수행한다.

일부 Data에만 Label을 붙이고 Label이 붙지않는 Data와 함께 비지도 학습 기반의 Clustering을 수행하면 Label이 붙어있는 Data와 Label이 붙어있지 않는 Data가 특정 Cluster를 이루게 된다. 따라서 Label이 붙어 있지 않는 Data는 동일한 Cluster에 위치한 Label을 부여할 수 있게된다.

#### 1.4. 강화 학습 (Reinforcement Learning)

강화 학습 방식은 **입력 Data 및 결과를 판별하는 기준**을 이용하는 학습 방식이다. 결과를 판별하는 기준을 바탕으로 각 학습시 스스로 결과를 도출하고, 더 좋은 결과가 나오는 방향으로 학습을 반복하는 방식이다.

### 2. 참고

* [https://www.sas.com/en_gb/insights/articles/analytics/machine-learning-algorithms.html](https://www.sas.com/en_gb/insights/articles/analytics/machine-learning-algorithms.html)
* [https://opentutorials.org/module/4916/28934](https://opentutorials.org/module/4916/28934)
