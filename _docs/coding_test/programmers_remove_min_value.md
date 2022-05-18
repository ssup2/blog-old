---
title: Programmers / 제일 작은 수 제거하기
category: Coding Test
date: 2022-05-16T12:00:00Z
lastmod: 2022-05-16T12:00:00Z
comment: true
adsense: true
---

### Problem

* Link
  * [https://programmers.co.kr/learn/courses/30/lessons/12935](https://programmers.co.kr/learn/courses/30/lessons/12935)

* Description
  * 숫자 배열에서 가장 작은 값을 제거한 배열을 반환

* Type
  * X

### Solution 1

{% highlight java linenos %}
class Solution {
    public int[] solution(int[] arr) {
        // Check array size and return -1
        if (arr.length == 0 || arr.length == 1) {
            return new int[] {-1};
        }
        
        // Find min value
        int min = Integer.MAX_VALUE;
        for (int i = 0; i < arr.length; i++) {
            if (min > arr[i]) {
                min = arr[i];
            }
        }
        
        // Set result
        int j = 0;
        int[] result = new int[arr.length-1];
        for (int i = 0; i < arr.length; i++) {
            if (min != arr[i]) {
                result[j] = arr[i];
                j++;
            }
        }
        
        return result;
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">Solution 1</figcaption>
</figure>

* Description
  * 가장 작은 값을 먼저 찾은 후에, 배열에서 제거

* Time Complexity
  * O(len(arr))
  * len(arr)의 크기만큼 for Loop 두번 수행

* Space Complexity
  * O(len(arr))
  * 함수의 입력값으로 len(arr)의 크기 만큼 Memory 이용
