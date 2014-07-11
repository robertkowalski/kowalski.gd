---
layout: post
title: "SEO: noindex für Octopress"
date: 2012-06-22 20:45
description: "Blogging Framework Octopress um noindex Option erweitern"
keywords: "Ocotpress, SEO, noindex, Framework, Robert Kowalski"
tags: [SEO, octopress]
---

Heute habe ich mein Blogging-Framework Octopress um noindex-Metatags erweitert.

Anwendungsfall ist meine Impressumsseite, die nicht indexiert werden soll.

<!-- more-->

In der Datei ```source/_includes/head.html``` von Octopress fügt man ein:

```
{{ "{% if page.noindex" }} %} <meta name="robots" content="noindex"> {{ "{% endif" }} %}
```

Ab jetzt kann man im Markdown der Seite / des Posts **noindex: true** setzen und die Seite wird nicht mehr indexiert, da im Head das entsprechende Metatag gesetzt wird.

![Screenshot noindex settings octopress](/assets/images/seo_noindex.png "Screenshot noindex settings octopress")
