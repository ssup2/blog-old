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

React Hook은 기존의 Component Class를 상속하여 React Component를 개발하는 대신, JavaScript 함수를 React Component로 이용할 수 있게 만드는 기능이다. React Hook은 React 16.8에 추가되었다.

#### 1.1. useState

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
<figcaption class="caption">[Code 1] useState</figcaption>
</figure>

#### 1.2. useEffect

{% highlight javascript linenos %}
function Hello(props) {
  const [date, setDate] = useState(new Date());
  setInterval(() => tick(), 1000);

  function tick() {
    setDate(new Date());
  }

  useEffect(() => {
    console.log('After Rendering, Hello');
    return () => {
      console.log('Umount, Hello')
    }
  });

  useEffect(() => {
    console.log('After Rendering, First');
    return () => {
      console.log('Unmount, First')
    }
  }, []);

  useEffect(() => {
    console.log('After Rendering, Name ' + props.name);
    return () => {
      console.log('Unmount, Name ' + props.name)
    }
  }, [props.name]);

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
// After Rendering, First
// After Rendering, Name ssup2
// After Rendering, Date Thu Aug 13 2020 22:32:38 GMT+0900 (대한민국 표준시)
// Umount, Hello
// Unmount, Date Thu Aug 13 2020 22:32:38 GMT+0900 (대한민국 표준시)
// After Rendering, Hello
// After Rendering, Date Thu Aug 13 2020 22:32:39 GMT+0900 (대한민국 표준시)
// Umount, Hello
// Unmount, Date Thu Aug 13 2020 22:32:39 GMT+0900 (대한민국 표준시)
// After Rendering, Hello
// After Rendering, Date Thu Aug 13 2020 22:32:40 GMT+0900 (대한민국 표준시)
// Umount, Hello
// Unmount, Date Thu Aug 13 2020 22:32:40 GMT+0900 (대한민국 표준시)
...
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] useEffect</figcaption>
</figure>

#### 1.3. useReducer

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
<figcaption class="caption">[Code 3] useReducer</figcaption>
</figure>

### 2. 참조

* [https://ko.reactjs.org/docs/hooks-overview.html](https://ko.reactjs.org/docs/hooks-overview.html)
* [https://gist.github.com/ninanung/25bdbf78a720846e4dc4c30ac1c9ec9b](https://gist.github.com/ninanung/25bdbf78a720846e4dc4c30ac1c9ec9b)