---
title: JavaScript Closure
category: Programming
date: 2020-08-04T12:00:00Z
lastmod: 2019-08-04T12:00:00Z
comment: true
adsense: true
---

React Component를 분석한다.

### 1. React Component

{% highlight javascript linenos %}
class Hello extends React.Component {
  render() {
    return <h1>Hello, {this.props.name}</h1>;
  }
}

ReactDOM.render(
  <Hello name='ssup2' />,
  document.getElementById('root')
);
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Hello Component</figcaption>
</figure>

React는 Component라고 불리는 UI의 조각들을 조합하여 전체 UI를 구성한다. React Component는 재사용이 가능하며, Component 상속을 통해서 Component의 기능을 확장 할 수도 있다. [Code 1]은 Hello Component를 정의하고 이용하는 방법을 보여주고 있다. Hello Component는 name Property를 Hello라는 문자열과 함께 출력한다. render() 함수에서 ssup2 name Property와 함께 Hello Component를 이용하고 있기 때문에 "Hello, ssup2"라는 제목(h1)이 출력된다.

#### 1.1. Property

#### 1.2. State

#### 1.3. Lifecycle

### 2. 참조

* [https://ko.reactjs.org/docs/components-and-props.html](https://ko.reactjs.org/docs/components-and-props.html)
* [https://ko.reactjs.org/docs/state-and-lifecycle.html](https://ko.reactjs.org/docs/state-and-lifecycle.html)