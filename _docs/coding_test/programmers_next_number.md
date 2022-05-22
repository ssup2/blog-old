---
title: Programmers / 피보나치 수
category: Coding Test
date: 2022-05-16T12:00:00Z
lastmod: 2022-05-16T12:00:00Z
comment: true
adsense: true
---

### Problem

* Link
  * [https://programmers.co.kr/learn/courses/30/lessons/12911](https://programmers.co.kr/learn/courses/30/lessons/12911)

* Description
  * 이진수로 변경시 1의 숫자가 동일한 다음수를 찾아 반환

* Type
  * 완전 탐색

### Solution 1

{% highlight java linenos %}
class Solution {
    public int solution(int n) {
        // Get n's one count
        int nBinOneCount = getOneCount(n);
        
        // Find n's next
        for (int i = n + 1; i <= 1000000; i++) {
            if (nBinOneCount == getOneCount(i)) {
                return i;
            }
        }
        
        // Not found
        return 0;
    }
    
    private int getOneCount(int n) {
        String nBin = Integer.toBinaryString(n);
        int oneCount = 0;
        for (int i = 0; i < nBin.length(); i++) {
            if (nBin.charAt(i) == '1') {
                oneCount++;
            }
        }
        return oneCount;
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">Solution 1</figcaption>
</figure>

* Description
  * n을 2진수로 변환한 후에 1의 개수를 구함
  * 하나씩 증가시키면서 1의 개수를 구하고, n의 개수와 동일한지 검사

* Time Complexity
  * O(1)
  * n의 크기가 시간 복잡도에 영향을 주지 않음

* Space Complexity
  * O(1)
  * 함수의 Paramater 및 지역 변수