---
title: Golang Receiver
category: Programming
date: 2021-01-17T12:00:00Z
lastmod: 2021-01-17T12:00:00Z
comment: true
adsense: true
---

Golang의 Receiver를 정리한다.

### 1. Golang Receiver

{% highlight golang linenos %}
type Point struct {
   x,y int
}

// Value Receiver
func (p Point) addValue(n int) {
   p.x += n
   p.y += n
}

// Pointer Receiver
func (p *Point) addPointer(n int) {
   p.x += n
   p.y += n
}

func main()  {
   p := Point{3,4}

   p.addValue(10)
   fmt.Println(p) // {3, 4}

   p.addPointer(10)
   fmt.Println(p) // {13, 14}
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Golang Receiver</figcaption>
</figure>

Receiver는 Struct의 Method를 생성하기 위해 쓰이는 문법이다. [Code 1]은 Golang Reciver의 예제를 나타내고 있다. Receiver가 붙은 함수는 해당 Struct의 Method로 간주되며, 함수 내부에서 Struct의 변수 및 Method에 접근이 가능하다. 

Receiver는 **Value Receiver**와 **Pointer Receiver**가 존재한다. Value Receiver는 Struct가 Call-by-value로 전달되며, Pointer Receiver는 Call-by-reference로 전달된다. 따라서 Value Receiver를 이용하는 함수에서 Receiver를 이용하여 Struct의 변수를 변경 하더라도 Struct의 변수는 변경되지 않는다. 반대로 Pointer Receiver를 이용하는 경우에는 Receiver를 이용하여 Struct의 변수를 변경하는 경우에는 Struct의 변수도 변경된다.

[Code 1]에서 Value Receiver를 이용하는 addValue() 함수를 이용하여 10을 더해도 Point 구조체의 Value 값이 변경되지 않는것을 확인할 수 있다. 이와 반대로 addPointer() 함수를 이용하여 10을 더하면 Point 구조체의 Value 값이 변경되는 것을 확인할 수 있다.

### 2. 참조

* [https://kamang-it.tistory.com/entry/Go15%EB%A9%94%EC%86%8C%EB%93%9CMethod%EC%99%80-%EB%A6%AC%EC%8B%9C%EB%B2%84Receiver](https://kamang-it.tistory.com/entry/Go15%EB%A9%94%EC%86%8C%EB%93%9CMethod%EC%99%80-%EB%A6%AC%EC%8B%9C%EB%B2%84Receiver)