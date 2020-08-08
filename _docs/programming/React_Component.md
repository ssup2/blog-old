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
    return <h1>Hello</h1>;
  }
}

ReactDOM.render(
  <Hello />,
  document.getElementById('root')
);

// Output
// Hello
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Hello Component</figcaption>
</figure>

React는 Component라고 불리는 UI의 조각들을 조합하여 전체 UI를 구성한다. React Component는 재사용이 가능하며, Component 상속을 통해서 Component의 기능을 확장 할 수도 있다. [Code 1]은 Hello Component를 정의하고 이용하는 방법을 보여주고 있다. React Component는 기본적으로 React.Component Class를 상속하여 구현한다. 모든 Component는 **render()** 함수를 갖고 있다. render() 함수는 해당 Component가 ReactDOM에 의해서 Rendering될 때 호출되는 함수이다. [Code 1]에서 ReactDom의 render() 함수에는 Hello 문자열을 갖는 제목(h1)을 반환하고 있다. 따라서 [Code 1]은 "Hello"라는 제목(h1)을 출력한다.

#### 1.1. Property

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
<figcaption class="caption">[Code 2] Hello Component name Property</figcaption>
</figure>

Component의 Property는 의미 그대로 Component의 속성을 저장하는 공간이다. Property는 Component 내부에서 **this.props**로 표현된다. Property는 **Read Only** 특징을 갖고 있다. Component가 선언 될때는 Property를 설정 할 수 있지만, 한번 설정된 Property는 Component 내부에서는 변경 할 수 없다. [Code 2]에서는 Hello Component가 name Property도 같이 출력하도록 변경되었다. ReactDom의 render() 함수에서 Hello Component는 ssup2 문자열을 name Property로 갖도록 선언되어 있다. 따라서 [Code 2]는 "Hello, ssup2"라는 제목(h1)을 출력한다.

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
<figcaption class="caption">[Code 3] Property Change</figcaption>
</figure>

[Code 3]에서 Hello Component는 Component 내부에서 name Property를 test 문자열로 설정하고 출력하도록 변경되었다. 하지만 Property는 Component 내부에서는 변경 할 수 없기 때문에 [Code 3]은 제대로 동작하지 않는다. [Code 3]을 실행하면 "TypeError: Cannot assign to read only property 'name' of object '#<Object>'"의 Error Message와 함께 Component가 제대로 동작하지 않는다.

#### 1.2. State

Component의 State는 의미 그대로 Component의 상태 정보를 저장하는 저장소이다. State는 Component 내부에서 **this.state**로 표현된다. State는 Component의 Constructor인 constructor() 함수 안에서만 초기화 될 수 있다. Property와 다르게 Component 내부에서도 변경이 가능하지만 반드시 **setState()** 함수를 통해서 변경해야 한다. setState() 함수를 통하지 않고 State를 변경하면, 변경 내용이 UI에 반영되지 않기 때문이다. setState()로 변경된 State는 UI에 바로 반영되지 않고 **비동기**로 처리될 수 있다. React가 성능을 위해 UI 변경 내용을 모았다가 한번에 처리할 수 있기 때문이다.

{% highlight javascript linenos %}
class Hello extends React.Component {
  constructor(props) {
    super(props);
    this.state = {date: new Date()};
    this.timerID = setInterval(() => this.tick(), 1000);
  }
  
  tick() {
    this.setState({
      date: new Date()
    });
  }
  
  render() {
    return <h1>Hello, {this.props.name}, {this.state.date.toLocaleTimeString()}</h1>;
  }
}

ReactDOM.render(
  <Hello name='ssup2' />,
  document.getElementById('root')
);

// Output
// Hello, ssup2, 오후 10:47:59
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] Hello Component State</figcaption>
</figure>

[Code 4]에서 Hello Component의 Constructor에는 State에 Data를 저장하고 있고, Timer를 동작시켜 1초마다 State의 Date 값을 갱신하도록 설정하고 있다. 또한 Hello Component는 State에 저장된 Date도 출력하도록 변경되었다. 따라서 [Code 4]는 "Hello, ssup2, <Date>"라는 제목(h1)을 출력하며, <Date>는 1초마다 갱신된다.

#### 1.3. Parent, Child Component

{% highlight javascript linenos %}
class Hello extends React.Component {
  constructor(props) {
    super(props);
    this.state = {date: new Date()};
    this.timerID = setInterval(() => this.tick(), 1000);
  }
  
  tick() {
    this.setState({
      date: new Date()
    });
  }
  
  render() {
    return (
      <div>
        <h1>Hello, {this.props.name}, {this.state.date.toLocaleTimeString()}</h1>
        <MyDate date={this.state.date.toLocaleTimeString()} />
      </div>
    );
  }
}

class MyDate extends React.Component {
  render() {
    return <h1>Date, {this.props.date}</h1>;
  }
}

ReactDOM.render(
  <Hello name='ssup2' />,
  document.getElementById('root')
);

// Output
// Hello, ssup2
// Date, 오후 10:47:59
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 5] Parent, Child Component</figcaption>
</figure>

Component 사이에는 부모, 자식의 관계가 형성될 수 있다. [Code 5]에서 Hello Component는 render() 함수에서 MyDate Component를 호출하고 있다. 이 경우 Hello Component의 자식 Component는 MyDate Component가 된다. 반대로 MyDate Component의 부모 Component는 Hello Component가 된다. MyDate Component는 Hello Component의 date State를 date Property로 받아 Rendering 한다. 따라서 Hello Component의 date State가 1초마다 갱신 될때마다, MyDate의 date Property 값도 갱신된다.

**이처럼 부모 Component는 자식 Component의 Property를 변경 할 수 있다.** MyDate의 date Property가 갱신 될때마다 MyDate는 다시 Rendering되기 때문에, [Code 5]는 "Hello, ssup2\nDate, <Date>"라는 제목(h1)을 출력하며, <Date>는 1초마다 갱신된다.

#### 1.4. Lifecycle

Component들은 Lifecycle을 갖고 있으며 React는 Component의 Lifecycle에 따라서 Component의 함수를 실행한다. [Code 1~5] render(), constructor() 함수도 Component의 Lifecycle에 따라서 호출되는 Lifecycle 함수이다. React v16.3을 기준으로 주로 사용되는 Lifecycle 함수들은 다음과 같다.

##### 1.4.1. constructor(props) 

{% highlight javascript linenos %}
class Hello extends React.Component {
  constructor(props) {
    super(props);
    
    this.state = {date: new Date()};
    this.handleClick = this.handleClick.bind(this);

    // Don't call this.setState()
  }
}

{% endhighlight %}
<figure>
<figcaption class="caption">[Code 6] Component constructor(props)</figcaption>
</figure>

constructor() 함수는 Component가 생성될때 호출되는 생성자 함수이다. [Code 6]은 constructor()의 예제를 나타내고 있다. props Parameter는 Component의 Property를 의미한다. constructor() 함수는 반드시 호출되자 마자 super(props)를 호출하여 부모의 Class를 초기화 해야한다. constructor() 함수는 주로 Component의 State를 초기화 하거나, Event Handler를 등록하는 용도로 이용된다. State 초기화시에는 setState() 함수를 이용할 수 없다.

##### 1.4.2. render()

render() 함수는 Component가 Rendering 될때 호출되는 함수이다. Component의 Property과 State값에 따라서 적절하게 Component가 Rendering 될 수 있도록 한다.

##### 1.4.3. componentDidMount()

componentDidMount() 함수는 Component가 DOM에 Mount(생성)된 이후에 호출되는 함수이다. DOM에 Mount된 이후에 호출되기 때문에 DOM에 접근할 수 있다. DOM의 정보를 바탕으로 외부로부터 Data를 추가적으로 얻어와 Component를 설정할 경우 이용된다. 필요에 따라서 setState() 함수를 호출하여 Component의 State를 변경 및 Component가 다시 Rnedering 되도록 할 수 있다.

##### 1.4.4. componentDidUpdate(prevProps, prevState, snapshot)

componentDidUpdate() 함수는 Component가 부모 Component에 의해서 Property가 변경되거나, State가 변경된 이후에 호출되는 함수이다. DOM에 Mount된 이후에 호출되기 때문에 DOM에 접근할 수 있다. prevProps, prevState Parameter는 각각 변경되기 전의 Property와 State를 저장하고 있다. snaptshot Parameter는 getSnapshotBeforeUpdate() Lifecycle 함수를 통해서 저장한 Data를 저장하고 있다. DOM의 정보를 바탕으로 외부로부터 Data를 추가적으로 얻어와 Component를 설정할 경우 이용된다. 필요에 따라서 setState() 함수를 호출하여 Component의 State를 변경 및 Component가 다시 Rnedering 되도록 할 수 있다.

##### 1.4.5. componentWillUnmount()

componentWillUnmount() 함수는 Component가 DOM에 Unmount(제거)되기 전에 호출되는 함수이다. DOM에 Unmount되기 전에 호출되기 때문에 DOM에 접근할 수 있다. Component가 제거되기 전에 Component에서 이용중인 Resource들은 반환, 제거하는 용도로 이용된다. componentWillUnmount() 함수 이후에 Component는 Rendering 되지 않기 때문에, componentWillUnmount() 함수 내부에서는 setState() 함수를 호출하면 안된다.

### 2. 참조

* [https://ko.reactjs.org/docs/components-and-props.html](https://ko.reactjs.org/docs/components-and-props.html)
* [https://ko.reactjs.org/docs/state-and-lifecycle.html](https://ko.reactjs.org/docs/state-and-lifecycle.html)
* [https://projects.wojtekmaj.pl/react-lifecycle-methods-diagram/](https://projects.wojtekmaj.pl/react-lifecycle-methods-diagram/)