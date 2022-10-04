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

분류를 Algorithm은 **어떤 Class(Type)**인지를 판별(예측)하는 Algorithm을 의미한다. 고양이 사진과 강아지 사진이 존재하는 상황에서 입력 사진이 고양이인지 강아지인지 판별해야 한다면, 분류 Algorithm을 이용하면 된다. 고양이 사진, 강아지 사진 분류 Algorithm을 학습시키기 위해서는다미리 분류된 고양이 사진들과 강아지 사진들을 이용해야 한다.

##### 1.1.2. 회귀 (Regression)

회귀를 Algorithm은 **연속적인 값중에서 하나의 값**을 예측하는 Algorithm을 의미한다. 여러 환경요소에 따른 집값을 예측해야 한다면 집값은 연속적인 값을 갖을 수 있기 때문에 회귀 Algorithm을 이용하면 된다. 집값 예측 회귀 Algorithm을 학습시키기 위해서는 여러 환경요소 정보가 포함된 집값 정보를 이용해야 한다.

#### 1.2. 비지도 학습 (Unsupervised Learning)

비지도 학습 방식은 **입력 Data**만 이용하는 학습 방식이다. 학습을 수행하는 사람이 어떠한 결과를 예측하지 않고 학습을 수행시키기 때문에 비지도 학습이라는 명칭이 붙었다. 비지도 학습 Algorithm은 일반적으로 사람이 예측하지 못한 **Data의 연관성**을 찾는데 이용되며, Data의 연관성을 바탕으로 군집화, 차원 축소의 동작을 수행한다.

##### 1.2.1. 군집화 (Clustering)

군집화 Algorithm은 유사한 Data들을 Grouping하는 Algorithm을 의미한다. 사람 얼굴을 특징에 따라서 Grouping하기 위해서는 군집화 Algorithm을 이용하면 된다.

##### 1.2.2. 차원 축소 (Dimension Reduction)

차원 축소는 다수의 차원으로 이루어진 Data의 차원을 줄이는 Algorithm을 의미한다. Data의 연관성 파악을 통해서 차원 축소가 가능해진다. 일반적으로 Data의 차원이 줄어들면 학습 시간이 줄어들며 Algorithm의 성능도 증가하기 때문에, 학습에 필요한 Data의 차원을 줄이는 용도로 많이 이용한다. 차원을 줄이는 방법에 따라서 Feature 선택 방법과 Feature 추출 방법이 존재한다. 여기서 Feature는 차원과 동일하다.

* Feature 선택 (Selection) : 불필요한 Feature를 제거한다.
* Feature 추출 (Extraction) : 다수의 Feature를 대변하는 새로운 Feature를 정의한다.

#### 1.3. 준지도 학습 (Semi-supervised Learning)

준지도 학습은 **일부의 입력 Data와 이에 따른 정답**을 이용하는 학습 방식이다. 모든 입력 Data에 대한 정답이 아닌 일부의 Data에 대해서한 정답을 갖고 있기 때문에 준지도 학습이라는 명칭이 붙었다. 준지도 학습 Algorithm은 일반적으로 Data Labeling을 수행하는데 이용한다.

##### 1.3.1. Data Labeling

Data Labeling은 의미 그대로 Label이 붙어 있지 않는 Data에 Label을 붙이는 작업을 의미한다. 일반적으로 Data의 양이 너무 방대하거나 사람이 빠르게 인지하기 힘든 정보에 대해서 Label을 붙일 경우, 준지도 학습 기반의 Data Labeling을 수행한다.

일부 Data에만 Label을 붙이고 Label이 붙지않는 Data와 함께 비지도 학습 기반의 Clustering을 수행하면 Label이 붙어있는 Data와 Label이 붙어있지 않는 Data가 특정 Cluster를 이루게 된다. 따라서 Label이 붙어 있지 않는 Data는 동일한 Cluster에 위치한 Label을 부여할 수 있게된다.

#### 1.4. 강화 학습 (Reinforcement Learning)

강화 학습 방식은 **입력 Data 및 결과를 판별하는 기준**을 이용하는 학습 방식이다. 결과를 판별하는 기준을 바탕으로 각 학습시 스스로 결과를 도출하고, 더 좋은 결과가 나오는 방향으로 학습을 반복하는 방식이다. 반복 학습을 통해서 강화시키는 방식 때문에 강화 학습이라는 명칭이 붙었다.

### 2. 참고

* [https://www.sas.com/en_gb/insights/articles/analytics/machine-learning-algorithms.html](https://www.sas.com/en_gb/insights/articles/analytics/machine-learning-algorithms.html)
* [https://opentutorials.org/module/4916/28934](https://opentutorials.org/module/4916/28934)
* 지도 학습 : [https://aimb.tistory.com/149](https://aimb.tistory.com/149)
* 차원 축소 : [https://docs.sangyunlee.com/ml/analysis/undefined-1](https://docs.sangyunlee.com/ml/analysis/undefined-1)
