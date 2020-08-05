---
title: React Component
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

// Output
// Hello, ssup2
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Hello Component</figcaption>
</figure>

React는 Component라고 불리는 UI의 조각들을 조합하여 전체 UI를 구성한다. React Component는 재사용이 가능하며, Component 상속을 통해서 Component의 기능을 확장 할 수도 있다. [Code 1]은 Hello Component를 정의하고 이용하는 방법을 보여주고 있다. React Component는 기본적으로 React.Component Class를 상속하여 구현한다. 모든 Component는 **render()** 함수를 갖고 있다. render() 함수는 해당 Component가 ReactDOM에 의해서 Rendering될 때 호출되는 함수이다. **this.props**는 Component가 갖고 있는 속성(Property)을 의미한다. 따라서 Hello Component는 name Property를 Hello라는 문자열과 함께 제목(h1)으로 출력한다.

[Code 1]에서 ReactDom의 render() 함수에는 ssup2 문자열로 설정된 name Property를 갖는 Hello Component가 선언되어 있다. 따라서 Web Browser에는 "Hello, ssup2"라는 제목(h1)이 출력된다.

#### 1.1. Property

{% highlight javascript linenos %}
class Hello extends React.Component {
  render() {
    this.props.name='test'
    return <h1>Hello, {this.props.name}</h1>;
  }
}

ReactDOM.render(
  <Hello name='ssup2' />,
  document.getElementById('root')
);

// Error
// TypeError: Cannot assign to read only property 'name' of object '#<Object>'
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] Property Change Test</figcaption>
</figure>

Component의 Property는 **Read Only** 특징을 갖고 있다. 즉 Component가 선언 될때는 Property를 설정 할 수 있지만, 한번 설정된 Property는 변경 할 수 없다. [Code 2]의 Hello Component에는 render()에 name Property를 변경하는 Logic이 추가되었다. [Code 2]를 실행하면 `TypeError: Cannot assign to read only property 'name' of object '#<Object>'`와 같이 Error Message와 함께 Component가 제대로 동작하지 않는걸 확인 할 수 있다.

#### 1.2. State

#### 1.3. Lifecycle

### 2. 참조

* [https://ko.reactjs.org/docs/components-and-props.html](https://ko.reactjs.org/docs/components-and-props.html)
* [https://ko.reactjs.org/docs/state-and-lifecycle.html](https://ko.reactjs.org/docs/state-and-lifecycle.html)