---
title: JavaScript Arrow 함수
category: Programming
date: 2020-07-04T12:00:00Z
lastmod: 2019-07-04T12:00:00Z
comment: true
adsense: true
---

JavaScript Arrow 함수를 정리한다.

### 1. Arrow 함수

{% highlight javascript %}
// Parameter
() => { ... }      // No parameter
x => { ... }       // One parameter
(x, y) => { ... }  // Multi parameters

// Body
(x, y) => { return x + y }  // Single line body
(x, y) => x + y             // Single line body without parentheses and return
(x, y) => {                 // Multi lines body
  z = x + y
  return z + z;
};

// Call
((x, y) => x + y)(10, 20)      // Define and call
const adder = (x, y) => x + y; // Define, assign and call
adder(10, 20)
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] JavaScript Arrow Function</figcaption>
</figure>

Arrow Function은 간략하게 익명함수를 정의하고 이용할 수 있는 문법이다. Javscript ES6에서 정의된 문법이다. Arrow Function을 이용하여 간단하게 Logic을 Javascript Object에 넣고 이용할 수 있다. [Code 1]은 Allow Function의 정의 및 호출하는 방법을 나타내고 있다.

#### 1.1. this

{% highlight javascript %}
// Regular function
var regularObject = {
  value: "regular",
  callFunction: function() {
    (function() {console.log(this)})()
  }
}
regularObject.callFunction()
// Print windows object

// Arrow Function
var arrowObject = {
  value: "arrow",
  callFunction: function() {
    (() => console.log(this))()
  }
}
arrowObject.callFunction()
// Print object ojbect
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] this with regular function and arrow function</figcaption>
</figure>

일반 함수안에서의 this와 Arrow 함수안에서의 this는 다른 값을 의미한다. [Code 2]는 일반 함수에서의 this와 Arrow 함수에서의 this를 출력하여, this가 어떤 값을 나타내는지를 알아보는 Code이다. regularObject의 callFunction() 함수 내부에서는 일반 함수를 이용하여 this의 정보를 출력하고 있다. arrowObject의 callFunction() 함수 내부에서는 Arrow 함수를 이용하여 this의 정보를 출력하고 있다.

일반 함수에서의 this는 함수를 호출한 Object의 정보를 저장하고 있다. 따라서 regularObject의 callFuncton() 함수를 통해서 출력하는 this는 callFuncton() 함수를 호출하는 Window Object의 정보를 출력한다. 반면 Arrow 함수에서 this는 함수를 소유하고 있는 Object의 정보를 저장하고 있다. 따라서 arrowObject의 callFuncton() 함수를 통해서 출력하는 this는 callFuncton() 함수를 소유하고 있는 arrowObject의 정보를 출력한다.

### 2. 참고

* [https://poiemaweb.com/es6-arrow-function](https://poiemaweb.com/es6-arrow-function)
* [https://www.w3schools.com/js/js_arrow_function.asp](https://www.w3schools.com/js/js_arrow_function.asp)