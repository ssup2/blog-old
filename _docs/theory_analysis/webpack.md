---
title: webpack
category: Theory, Analysis
date: 2020-08-02T12:00:00Z
lastmod: 2020-08-02T12:00:00Z
comment: true
adsense: true
---

### 1. webpack

webpack은 JavaScript Module Bundler 역할을 수행하는 도구이다. JavaScript의 기능과 역할이 확장되면서 JavaScript Code를 여러개의 Module (File)로 분리하고, 분리한 Module을 Import하여 개발하는 Module 단위의 개발이 JavaScript에서도 적용되고 있다. 문제는 JavaScript의 Module은 일부 Web Brower에서만 지원하고 있다는 점이다. 이러한 문제점을 해결하기 위해서 JavaScript Module Bundler는 다수의 JavaScript Module을 하나의 File로 묶어주는 역할을 수행한다. webpack은 현재 가장 많이 각광 받는 JavaScript Module Bundler이다.

![[그림 1] webpack]({{site.baseurl}}/images/theory_analysis/webpack/webpack.PNG)

JavaScript는 **CommonJS** 또는 **AMD(Asynchronous Module Definition)** 2가지의 Module 표준이 존재하는데, webpack은 두 표준 모두 지원한다. [그림 1]은 webpack의 동작 과정을 나타내고 있다. webpack은 JavaScript Module뿐만 아니라 TypeScript, CoffeeScript등 다양한 Script의 Module도 지원한다. 이러한 Script들은 webpack을 통해서 JavaScript로 **Transcompile**된다. 또한 webpack은 jpg, png 같은 이미지 파일의 의존성도 파악하여 Bundling을 수행한다.

### 2. 참조

* [https://ui.toast.com/fe-guide/ko_BUNDLER/](https://ui.toast.com/fe-guide/ko_BUNDLER/)
* [https://d2.naver.com/helloworld/0239818](https://d2.naver.com/helloworld/0239818)s