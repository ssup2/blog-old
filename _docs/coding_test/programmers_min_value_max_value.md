---
title: Programmers / 최댓값과 최소값
category: Coding Test
date: 2022-05-16T12:00:00Z
lastmod: 2022-05-16T12:00:00Z
comment: true
adsense: true
---

### Problem

* Link
  * [https://programmers.co.kr/learn/courses/30/lessons/12939?language=java](https://programmers.co.kr/learn/courses/30/lessons/12939?language=java)

* Description
  * 공백으로 구문되는 문자열안의 숫자들 중에서 최대값, 최소값을 각각 찾아 반환

* Type
  * X

### Solution 1

{% highlight java linenos %}
class Solution {
    public String solution(String s) {
        // Convert string to int
        String[] splits = s.split(" ");
        int[] integers = new int[splits.length];
        for (int i = 0; i < splits.length; i++) {
            integers[i] = Integer.parseInt(splits[i]);
        }
        
        // Find min
        int min = Integer.MAX_VALUE;
        for (int i = 0; i < integers.length; i++) {
            if (integers[i] < min) {
                min = integers[i];
            }
        }
        
        // Find max
        int max = Integer.MIN_VALUE;
        for (int i = 0; i < integers.length; i++) {
            if (integers[i] > max) {
                max = integers[i];
            }
        }
        
        return min + " " + max;
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">Solution 1</figcaption>
</figure>

* Description
  * 문자열을 공백으로 분리후 정수로 변환
  * 정수로 변환한 숫자의 최댓값, 최솟값을 반환

* Time Complexity
  * O(spaceCount(s))
  * 문자열에 포함되어 있는 숫자의 개수 만큼 For Loop 반복

* Space Complexity
  * O(spaceCount(s))
  * 문자열에 포함되어 있는 숫자의 개수 만큼 배열크기 할당
