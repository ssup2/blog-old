---
title: Programmers / 두 개 뽑아서 더하기
category: Coding Test
date: 2022-05-16T12:00:00Z
lastmod: 2022-05-16T12:00:00Z
comment: true
adsense: true
---

### Problem

* Link
  * [https://programmers.co.kr/learn/courses/30/lessons/68644](https://programmers.co.kr/learn/courses/30/lessons/68644)

* Description
  * 숫자 배열의 서로 다른 Index에 있는 두 개의 수를 뽑아서 만들 수 있는 모든 수를 오름차순으로 정렬

* Type
  * 완전 탐색

### Solution 1

{% highlight java linenos %}
import java.util.TreeSet;
import java.util.Iterator;

class Solution {
    public int[] solution(int[] numbers) {
        // Init treeset
        TreeSet<Integer> set = new TreeSet<>();
        
        // Add
        for (int i = 0; i < numbers.length - 1; i++) {
            for (int j = i + 1; j < numbers.length; j++) {
                int sum = numbers[i] + numbers[j];
           		set.add(sum);
            }
        }
        
        // Set result
        Iterator<Integer> it = set.iterator();
        int[] result = new int[set.size()];
        for (int i = 0; i < set.size(); i++) {
            result[i] = it.next();
        }
        return result;
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">Solution 1</figcaption>
</figure>

* Description
  * TreeSet을 활용한 중복 제거 및 정렬 기능 활용

* Time Complexity
  * O(len(numbers)^2)
  * len(numbers)의 크기만큼 두번의 중복 for Loop 수행

* Space Complexity
  * O(len(numbers))
  * 함수의 입력값으로 len(numbers)의 크기 만큼 Memory 이용
