---
layout: post
title: "Analysis of the package.json data in the npm registry"
description: ""
category: ""
tags: [JavaScript, Node.js, Open Source, npm]
---
{% include JB/setup %}

Today I had a look on the metadata in the npm registry which currently contains 48248 modules.

I was interested in the most used licenses and if there are many modules which do not reference a repository in their package.json


The most used licenses in the npm registry are the less permissive ones:

![Chart]({{ site.url }}/assets/images/analysis-npm-licenses.png)

Around 2% of the packages seem to be dual licensed.


Most modules reference a repository in their `package.json`, I expected much more from the things that I hear from twitter:

![Chart]({{ site.url }}/assets/images/analysis-npm-repository-field.png)

7496 do not provide a reference to a repository vs. 40752 modules that provide one.

If you are interested in the raw data of the repository values, here is the
[gist](https://gist.github.com/robertkowalski/7620849)
