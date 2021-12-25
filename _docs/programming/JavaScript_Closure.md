---
title: JavaScript Closure
category: Programming
date: 2020-07-04T12:00:00Z
lastmod: 2019-07-04T12:00:00Z
comment: true
adsense: true
---

JavaScript Closure를 분석한다.

### 1. JavaScript Closure

Closure는 함수를 객체화하여 **함수가 상태**를 갖게하는 기법을 의미한다. 함수의 상태가 저장되는 곳은 외부에서 절대로 접근 할 수 없는 공간이기 때문에 의미 그대로 Closure라고 명칭한다. Closure는 일반적으로 함수형 언어에서 지원하는 기법이지만 JavaScript에서도 Closure를 지원한다.

{% highlight javascript %}
function outerFunc(x) {
    var y = 10;

    var innerFunc = function () { 
        return x + y  
    };
    return innerFunc;
}
  
var add10 = outerFunc(10);
var add20 = outerFunc(20);
var add30 = outerFunc(30);

console.log(add10()); // 20
console.log(add20()); // 30
console.log(add30()); // 40
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] JavaScript Closure</figcaption>
</figure>

[Code 1]은 JavaScript Closure 예제를 나타내고 있다. 함수 outerFunc()는 자신이 넘겨받은 Parameter x와 지역변수 y(10)을 더하는 함수 innerFunc()를 반환한다. Closure를 지원하지 일반적인 언어에서는 동작할 수 없는 함수이다. Stack에 저장되는 Parameter x와 지역변수 y는 outerFunc이 종료되는 순간 해제되기 때문에 innerFunc에서는 이용할 수 없기 때문이다. 하지만 JavaScript는 Closure를 지원하기 때문에 함수 innerFunc()가 함수 outerFunc()의 종료와 함께 객채화가 되는 순간 Closure가 구성되고 Parameter x와 지역변수 y는 Closure에 저장된다. 그리고 객체화된 innerFunc는 Closure에 저장된 Parameter x와 지역변수 y를 이용하여 동작하게 된다.

[Code 1]에서 add10, add20, add30은 함수 outerFunc()에 의해서 객체화된 함수 innerFunc()를 저장하고 있다. 3개의 객채화된 innerFunc가 존재하기 때문에 3개의 Clousre가 구성된다. 각 Closure에는 지역변수 y의 값인 10을 공통적으로 갖고 있고 Parameter x에 따라서 10, 20, 30을 저장하고 있다. 따라서 add10은 20, add20은 30, add30은 40을 반환한다. Closuer에 저장된 값은 명시적으로 참조할 수 없을 뿐만 아니라 변경도 할 수 없다. 따라서 Closure는 **정보 은닉화**가 필요할 경우에도 이용한다. [Code 1]에서 객채화된 함수 innerFunc()를 저장하고 있는 add10, add20, add30는 Closure에 저장된 값을 이용할 뿐이지, Closure에 저장된 값을 명시적으로 접근하지 않는걸 알 수 있다.

{% highlight javascript %}
function outerFunc() {
    var funcs = [];

    for (var i = 0; i < 5; i++) {
      funcs[i] = function () {
        return i;
      };
    }

    return funcs;
}

var innerFuncs = outerFunc();
for (var j = 0; j < innerFuncs.length; j++) {
  console.log(innerFuncs[j]()); // 5, 5, 5, 5, 5
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] JavaScript Shared Closure</figcaption>
</figure>

Closure는 외부에서는 접근할 수 없는 공간이기 때문에 Closure는 공유할 수 없는것처럼 생각할 수 있다. 하지만 Closure는 다수의 객체화된 함수에 의해서 공유될 수 있다. [Code 2]는 공유되는 Closure의 예제를 나타내고 있다. 함수 outerFunc()는 1씩 증가하는 지역변수 i를 반환하는 5개의 함수를 반환한다. 변수 innerFuncs에는 함수 outerFunc()를 통해서 객채화된 5개의 함수가 저장된다. 그 후 변수 innerFuncs에 저장된 함수는 하나씩 차례대로 호출된다. 지역변수 i는 1씩 증가하면서 함수 객채화에 이용되었기 때문에 "1, 2, 3, 4, 5"를 출력할거라 예상하지만 실제로는 "5, 5, 5, 5, 5"를 출력한다. 5개의 객체화된 함수들은 하나의 Closure를 공유하고 있기 때문에, 5개의 객채화된 함수들은 모두 같은 지역변수 i를 이용한다. 5개의 객채화된 함수가 실행될때 Closure에 저장된 지역변수 i는 for문을 수행하면서 5가 되었기 때문에 5만 5번 출력되는 것이다.

### 2. 참조

* [https://developer.mozilla.org/ko/docs/Web/JavaScript/Guide/Closures](https://developer.mozilla.org/ko/docs/Web/JavaScript/Guide/Closures)
* [https://hyunseob.github.io/2016/08/30/javascript-closure/](https://hyunseob.github.io/2016/08/30/javascript-closure/)
* [https://poiemaweb.com/js-closure](https://poiemaweb.com/js-closure)
* [https://www.w3schools.com/js/js_function_closures.asp](https://www.w3schools.com/js/js_function_closures.asp)
* [https://stackoverflow.com/questions/750486/javascript-closure-inside-loops-simple-practical-example](https://stackoverflow.com/questions/750486/javascript-closure-inside-loops-simple-practical-example)