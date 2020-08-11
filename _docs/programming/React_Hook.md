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

#### 1.1. State Hook

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

// Output
// Hello, ssup2, 오후 10:47:59
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] State Hook</figcaption>
</figure>

#### 1.2. Effect Hook

### 2. 참조

* [https://ko.reactjs.org/docs/hooks-overview.html](https://ko.reactjs.org/docs/hooks-overview.html)
* [https://gist.github.com/ninanung/25bdbf78a720846e4dc4c30ac1c9ec9b](https://gist.github.com/ninanung/25bdbf78a720846e4dc4c30ac1c9ec9b)