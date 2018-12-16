---
title: Virtualization in Cloud
category: E.T.C
---

{% assign docs = site.docs | where: 'category','Virtualization Cloud' | sort: 'title' %}
{% for doc in docs %}{% if doc.title != null %}
* [{{ doc.title }}]({{ site.baseurl }}{{ doc.url }})
{% endif %}{% endfor %}
