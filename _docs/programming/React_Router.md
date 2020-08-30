---
title: React Router
category: Programming
date: 2020-08-31T12:00:00Z
lastmod: 2020-08-31T12:00:00Z
comment: true
adsense: true
---

React Router를 간략하게 정리한다.

### 1. React Router

{% highlight javascript linenos %}
ReactDOM.render(
  <BrowserRouter>
    <App/>
  </BrowserRouter>,
  document.getElementById('root')
);
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] React Router Example - index.js</figcaption>
</figure>

{% highlight javascript linenos %}
class App extends Component {
    render() {
        return (
            <div>
                <Route exact path="/" component={Home}/>
                <Route path="/blog" component={Blog}/>
            </div>
        );
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] React Router Example - App.js</figcaption>
</figure>

{% highlight javascript linenos %}
const Home = () => {
    return (
        <div>
            <h2>
                Home
            </h2>
        </div>
    );
};
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] React Router Example - Home.js</figcaption>
</figure>

{% highlight javascript linenos %}
const Blog = () => {
    return (
        <div>
            <h2>
                Blog
            </h2>
        </div>
    );
};
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] React Router Example - Blog.js</figcaption>
</figure>

React Router는 React App을 SPA(Single Page Application)으로 구현할 수 있도록 도와주는 React Component이다. [Code 1-4]는 간단한 React Router Example을 나타내고 있다. "/" 경로로 이동할 경우 Home.js가 출력되고, "/blog" 경로로 이동할 경우 Blog.js가 출력된다. 중요한 Component는 **BrowserRouter** Component와 **Route** Component이다. BrowserRouter Component는 경로에 따라서 실제 Routing을 수행하는 Component이고, Route Component는 BrowserRouter에 Routing을 수행할 경로와 관련 Component를 등록하는 역활을 수행한다.

[Code 1]에서 BrowserRouter Component가 선언되어 있는것을 확인할 수 있다. [Code 2]에서 Route Component를 통해서 Routing 경로와 관련 Component를 등록하는것을 확인할 수 있다. "/" 경로에는 Home Component를 등록하고 있고, "blog" 경로에 Blog Component를 등록하고 있다.

### 2. 참조

* [https://velopert.com/3417](https://velopert.com/3417)
* [https://jeonghwan-kim.github.io/dev/2019/07/08/react-router-ts.html](https://jeonghwan-kim.github.io/dev/2019/07/08/react-router-ts.html)