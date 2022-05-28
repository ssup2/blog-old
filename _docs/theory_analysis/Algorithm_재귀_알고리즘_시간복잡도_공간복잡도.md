---
title: Algorithm 재귀 알고리즘 시간 복잡도, 공간 복잡도
category: Theory, Analysis
date: 2022-05-25T12:00:00Z
lastmod: 2022-05-25T12:00:00Z
comment: true
adsense: true
---

재귀 알고리즘의 시간복잡도, 공간복잡도 계산법을 정리한다.

### 1. 재귀 알고리즘 시간 복잡도, 공간 복잡도

#### 1.1. Factorial

{: .newline }
> f(0) = 1
> f(n) = n * f(n - 1) <br/>
<figure>
<figcaption class="caption">[함수 1] Factorial</figcaption>
</figure>

{: .newline }
> T(n) = T(n - 1) + 1C
>      = T(n - 2) + 2C
>      = T(n - (n - 1)) + (n - 1)C
>      = T(1) + (n - 1)C
>      <= C + (n - 1)C
>      <= nC
>      = O(n) <br/>
<figure>
<figcaption class="caption">[수식 1] Factorial 시간복잡도</figcaption>
</figure>

* 시간 복잡도
  * O(n)
  * 함수 호출이 (n - 1)번 발생하고 함수 내부적으로는 곱셈 연산이 한번만 수행되기 때문에, 별도의 수식 계산을 수행하지 않더라도  대략적으로 O(n)의 시간 복잡도를 갖는다는 것을 추정할 수 있다.
* 공간 복잡도
  * O(n)
  * 함수 호출이 (n - 1)번 발생하고 함수 내부적으로도 별도의 Memory를 이용하지 않기 때문에, 별도의 수식 계산을 수행하지 않더라도 함수 호출로 인해서 대략적으로 O(n)의 공간 복잡도를 갖는다는 것을 추정할 수 있다.

#### 1.2. 피보나치 수열

{: .newline }
> f(0) = 1
> f(1) = 1
> f(n) = f(n - 1) + f(n - 2) <br/>
<figure>
<figcaption class="caption">[함수 2] 피보나치 수열</figcaption>
</figure>

### 2. 참조

* [https://m.blog.naver.com/PostView.naver?isHttpsRedirect=true&blogId=wns7756&logNo=221568348621](https://m.blog.naver.com/PostView.naver?isHttpsRedirect=true&blogId=wns7756&logNo=221568348621)
* [https://justicehui.github.io/easy-algorithm/2018/03/11/TimeComplexity4/](https://justicehui.github.io/easy-algorithm/2018/03/11/TimeComplexity4/)