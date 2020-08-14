---
title: React Hook
category: Programming
date: 2020-08-09T12:00:00Z
lastmod: 2020-08-09T12:00:00Z
comment: true
adsense: true
---

React Hook을 분석한다.

### 1. React Hook

React Hook은 기존의 Component Class를 상속하여 React Component를 개발하는 대신, 순수 JavaScript 함수를 React Component로 이용할 수 있게 만드는 기능이다. 기존의 React Component를 상속하여 개발하는 방식은 Component 개발에 많은 Code가 필요하고, 불필요한 Code 중복도 발생하는 문제점을 갖고 있었다. React Hook은 순수 JavaScript 함수를 Component로 이용하는 방식이기 때문에, 적은량의 Code 작성 및 불필요한 Code 중복을 제거하여 빠르게 Component를 구현 할 수 있게 만든다. React Hook은 React 16.8에 추가되었다.

#### 1.1. useState()

{% highlight javascript linenos %}
function Hello(props) {
  const [date, setDate] = useState(new Date());
  setInterval(() => tick(), 1000);

  function tick() {
    setDate(new Date());
  }

  return (
    <div>
      <h1>Hello, {props.name}, {date.toLocaleTimeString()}</h1>
    </div>
  );
}

ReactDOM.render(
  <Hello name='ssup2' />,
  document.getElementById('root')
);

// Web Output
// Hello, ssup2, 오후 10:47:59
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] useState()</figcaption>
</figure>

usetState() Hook은 React Component의 State를 저장하는 용도로 이용되는 Hook이다. 기존의 React Component Class의 state Class 변수를 대체한다. useState() Hook의 Parameter로는 State의 초기값을 넘겨준다. useState() Hook은 초기값이 설정된 State와 State를 변경할 수 있는 State 변경 함수를 반환한다. [Code 1]에서는 useState() Hook를 이용해 Hello Component의 date State 초기화 하고, date State를 변경하는 함수를 이용하여 1초마다 date State를 변경하고 있다.

#### 1.2. useEffect()

{% highlight javascript linenos %}
function Hello(props) {
  const [date, setDate] = useState(new Date());
  setInterval(() => tick(), 1000);

  function tick() {
    setDate(new Date());
  }

  // first 
  useEffect(() => {
    console.log('After Rendering, Hello');
    return () => {
      console.log('Unmount, Hello')
    }
  });

  // second
  useEffect(() => {
    console.log('After Rendering, Only Rendering');
  });

  // third
  useEffect(() => {
    console.log('After Rendering, First');
    return () => {
      console.log('Unmount, First')
    }
  }, []);

  // fourth
  useEffect(() => {
    console.log('After Rendering, Date ' + date);
    return () => {
      console.log('Unmount, Date ' + date)
    }
  }, [date])

  return (
    <div>
      <h1>Hello, {props.name}, {date.toLocaleTimeString()}</h1>
    </div>
  );
}

ReactDOM.render(
  <Hello name='ssup2' />,
  document.getElementById('root')
);

// Web Output
// Hello, ssup2

// Console Ouput
// After Rendering, Hello
// After Rendering, Only Rendering
// After Rendering, Name ssup2
// After Rendering, Date Thu Aug 13 2020 22:32:38 GMT+0900 (대한민국 표준시)
// Unmount, Hello
// Unmount, Date Thu Aug 13 2020 22:32:38 GMT+0900 (대한민국 표준시)
// After Rendering, Hello
// After Rendering, Only Rendering
// After Rendering, Date Thu Aug 13 2020 22:32:39 GMT+0900 (대한민국 표준시)
// Unmount, Hello
// Unmount, Date Thu Aug 13 2020 22:32:39 GMT+0900 (대한민국 표준시)
// After Rendering, Hello
// After Rendering, Only Rendering
// After Rendering, Date Thu Aug 13 2020 22:32:40 GMT+0900 (대한민국 표준시)
// Unmount, Hello
// Unmount, Date Thu Aug 13 2020 22:32:40 GMT+0900 (대한민국 표준시)
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] useEffect()</figcaption>
</figure>

useEffect() Hook은 React Component의 Lifecycle에 따라서 호출되는 Hook이다. 기존의 React Component Class의 Lifecycle 함수를 대체한다. [Code 2]에서 1번째 useEffect() Hook은 기본적으로 useEffect() Hook을 이용하는 방법을 보여준다. useEffect() Hook의 Parameter로 함수를 Return하는 함수를 넘긴다. 넘긴 함수는 React Component가 Mount(생성), State 변경으로 인해서 다시 Rendering이 될 경우, Rendering이 된 이후에 호출이 된다. 기존 React Component Lifecycle 함수중에서 componentDidMount() 함수와 componentDidUpdate() 함수의 역활을 같이 수행한다고 보면 된다.

useEffect() Hook으로 넘긴 함수가 Return하는 함수는 React Component가 Umount(제거)되기 전에 호출된다. 기존 React Component Lifecycle 함수중에서 componentWillUnmount() 함수의 역활을 수행한다. React Component가 Unmount 될때 아무런 동작도 하고 싶지 않다면, useEffect() Hook으로 넘긴 함수가 아무것도 Return하지 않으면 된다. [Code 2]에서 2번째 2번째 useEffect() Hook이 이에 해당한다. React Component가 처음 Mount 될때만 useEffect() Hook으로 넘긴 함수가 호출되기 원한다면, useEffect() Hook의 두번째 Parameter로 빈 Array를 넘기면 된다. [Code 2]에서 3번째 useEffect() Hook이 이에 해당한다.

useEffect() Hook으로 넘긴 함수가 React Component가 특정 State가 변경 되었을때만 호출하게 만들 수 있다. useEffect() Hook의 두번째 Parameter로 변경을 감지할 State를 넘겨주면 된다. [Code 2]에서 4번째 useEffect() Hook이 이에 해당한다. useEffect() Hook에 넘겨진 함수에서도 Component의 지역 변수나 useState() Hook을 통해 생성한 State를 이용할 수 있다.

#### 1.3. useReducer()

{% highlight javascript linenos %}
const initialState = {count: 0};

function reducer(state, action) {
  switch (action.type) {
    case 'add':
      return {count: state.count + 1};
    default:
      throw new Error();
  }
}

function Hello(props) {
  const [state, dispatch] = useReducer(reducer, initialState);

  return (
    <div>
      <h1>Hello, {props.name}, {state.count}</h1>
      <button onClick={() => dispatch({type: 'add'})}>+</button>
    </div>
  );
}

ReactDOM.render(
  <Hello name='ssup2' />,
  document.getElementById('root')
);

// Web Output
// Hello, ssup2, 0
// + button
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] useReducer()</figcaption>
</figure>

useReducer() Hook은 React App의 Global State를 저장하는 용도로 이용하는 Hook이다. 기존의 React Redux를 대체하기 위해서 추가된 Hook이다. useReducer() Hook의 Parameter로는 Global State를 Action에 따라 변경하는 Reducer 함수와 Global State의 초기값을 넘겨준다. useReducer() Hook은 초기값이 설정된 Global State와 State를 변경할 수 있는 Dispatch() 함수를 반환한다. [Code 3]은 Hello Component에서 Button을 생성한다. 생성한 Button을 누르면 Dispatch() 함수를 통해서 add Action이 발생하고 Count 값을 증가 시킨다.

### 2. 참조

* [https://ko.reactjs.org/docs/hooks-overview.html](https://ko.reactjs.org/docs/hooks-overview.html)
* [https://gist.github.com/ninanung/25bdbf78a720846e4dc4c30ac1c9ec9b](https://gist.github.com/ninanung/25bdbf78a720846e4dc4c30ac1c9ec9b)