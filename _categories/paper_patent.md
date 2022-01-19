---
title: Paper, Patent
category: Software
---

{% assign docs = site.docs | where: 'category','Paper, Patent' | sort: 'title' %}
{% for doc in docs %}{% if doc.title != null %}
* [{{ doc.title }}]({{ site.baseurl }}{{ doc.url }})
{% endif %}{% endfor %}

