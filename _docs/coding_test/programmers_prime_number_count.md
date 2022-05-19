---
title: Programmers / 소수 찾기
category: Coding Test
date: 2022-05-17T12:00:00Z
lastmod: 2022-05-17T12:00:00Z
comment: true
adsense: true
---

### Problem

* Link
  * [https://programmers.co.kr/learn/courses/30/lessons/12921](https://programmers.co.kr/learn/courses/30/lessons/12921)

* Description
  * 소수의 개수를 반환

* Type
  * 완전 탐색

### Solution 1

{% highlight java linenos %}
import java.util.ArrayList;

class Solution {
    public int solution(int n) {
        ArrayList<Integer> primeList = new ArrayList<>(1000000);
        int answer = 0;
        
        // Find prime number
        for (int i = 2; i <= n; i++) {
            boolean isPrime = true;
            for (int j = 0; j < primeList.size(); j++) {
                if (i % primeList.get(j) == 0) {
                    isPrime = false;
                    break;
                }
            }
            
            if (isPrime) {
            	primeList.add(i);
            	answer++;
            }
        }
        
        return answer;
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">Solution 1</figcaption>
</figure>

* Description

* Time Complexity

* Space Complexity

### Solution 2

{% highlight java linenos %}
import java.util.Arrays;

class Solution {
    public int solution(int n) {
        // Init isPrime array
        boolean[] isPrime = new boolean[n+1];
        Arrays.fill(isPrime, true);
        isPrime[0] = false; // 0 is not prime
        isPrime[1] = false; // 1 is not prime
        
        // Find prime number
        for (int i = 2; i <= n; i++) {
            if (isPrime[i]) {
                for (int j = 2*i; j <= n; j = j + i) {
                    isPrime[j] = false;
                }
            }
        }
        
        // Get prime number count
        int count = 0;
        for (int i = 0; i < isPrime.length; i++) {
            if (isPrime[i]) {
                count++;
            }
        }
        return count;
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">Solution 2</figcaption>
</figure>

* Description

* Time Complexity

* Space Complexity