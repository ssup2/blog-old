---
title: Theory, Analysis
category: Software
---

{% assign docs = site.docs | where: 'category','Theory, Analysis' | sort: 'title' %}
{% for doc in docs %}{% if doc.title != null %}
* [{{ doc.title }}]({{ site.baseurl }}{{ doc.url }})
{% endif %}{% endfor %}

