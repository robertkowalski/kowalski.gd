---
layout: post
title: "What happened while contributing to Open Source on a daily basis for one year"
description: ""
category: ""
tags: [Open Source]
---
{% include JB/setup %}

I recently achieved a 356 day GitHub streak and I wanted to blog why I started to commit every day and what it changed in my life.

[![streak]({{ site.url }}/assets/images/2015-03-02-what-happened-while-contributing-to-open-source-on-a-daily-basis-for-one-year/streak.png)](https://github.com/robertkowalski)

The rules I had for making a contribution were easy:

 - every contribution must make sense and must have an impact. I can make white-space fixing commits, but they don’t count as a contribution with impact
 - it must be Open Source

Starting a bit earlier in summer 2013 than John Resig who wrote on his [blog](http://ejohn.org/blog/write-code-every-day/) about contributing on a daily basis, my first attempts failed. His post definitely spured me and also showed me that I am not alone.

I had the same reasons like John: I love my side projects but I was unhappy trying to work on them the whole weekend to get them finished. Sometimes I also spent a full evening during the week, until deep in the night, but it did not help: the timeframe between the days I was working on my side project was too big, I often forgot what I was working on and what my next idea for the project was. It always took a long time to get back into the project. Additionally I didn’t want to work two full days during the weekend on side projects as I also want to spend time with my friends and have to relax from sitting in front of a laptop from time to time.

The other reason for starting to contribute on a daily basis was that I was assuming that it would probably improve my skills.


## The good

### Improved organizing of my spare time

The whole planning of my spare time changed. Better said I started to plan and organize my spare time. Before that I did not really think about the time after work. After finishing my day job I suddenly (surprise, surprise!) had some spare time and had no idea what to do with it. These days I have

### Skill improvement

Working every day with code that I did not see at my daily work really improved my skills. I added new languages to my portfolio as I learned Erlang and wrote my first program in Scheme. I still write Erlang.

I also learned a lot how larger Open Source projects work, organize themselves and why Open Source makes sense for companies (I would even say for every company, but that’s another blogpost). I am not saying developing your product without any parts that are open sourced is not earning money, but in my opinion it is possible for every product to have a large amount of Open Source components and make money anyway and benefit from better code in the long term.

Additionally I improved my knowledge and skills on countless topics, some of them are: parsing & lexing, distributed computing, architecture, security, fast switching between projects (and coding guidelines), understanding code and giving reviews. I was also able to improve my soft-skills as well: communication, teamwork, solving conflicts, mentoring and skills in dealing with difficult/unexpected situations are a few of them.

### A new job

When I started, I had many own small side projects that were fun, but at some point I wasn’t happy any more with them - no one forked it and it seemed nobody used them. As I was the only developer for them I had no buddies to discuss solutions or a way to get reviews which is a great way to improve the code and your skills.

I decided to submit code to bigger projects and as I was using node since 0.4 and was a daily npm user I submitted a patch to npm. Isaac Schlueter reviewed my first PR, was really nice and it resulted in me submitting a lot of more code for npm.

The npm registry is using CouchDB as a database but I did not know how to use it. I started to translate the CouchDB documentation to German, this way I could learn how to use CouchDB and help the project. One day I had the idea of hosting my own private registry, and at one point I had the CouchDB source code on my hard disk as I wasn’t sure why the registry did not boot. While clicking through the code I saw that CouchDB had a JavaScript MVC app which was not officially released. I started contributing to CouchDB on a day where my PRs for npm queued up and I did not want to submit more: I did not want to make it harder for the reviewers once they got time to take a look. I contributed more to CouchDB as they were really nice folks.

Sometimes npm had bugs and problems which where directly related to Node.js. So I started contributing to the Node.js project, too.

Joining all these projects, getting reviews, collaborating with many different other contributors, reading a lot of code others wrote, reviewing patches, talking with users and working on their issues really boosted my skills.

In 2014 I was lucky enough and got a job where I get paid for working on the Open Source project CouchDB.

### Making new friends

I made a ton of new friends from the tech community by working on Open Source. I met many other collaborators which were working on the same project or folks which were using the project I was working on. Many of them are much smarter than me and at least for the projects I worked on I can say that they are all incredibly nice, open-minded people.

They are the reason why I submitted more patches after sending my initial PR. I don’t think anyone is interested in spending their spare time (and even their work time) to join a hostile, bad environment.

## The bad

Contributing every day and really sticking to it wasn’t smooth sailing all the time. I think the most discouraging events are users with weird expectations regarding the Open Source product they consume for free that folks maintain in their spare time.

This example is from [an issue in npm](https://github.com/npm/npm/issues/2568) where I used to do a lot of stuff in my spare time, together with Domenic, who also spent many hours of his spare time on maintaining npm:

![user says work harder]({{ site.url }}/assets/images/2015-03-02-what-happened-while-contributing-to-open-source-on-a-daily-basis-for-one-year/work-harder.png)


## Conclusion

Deciding to contribute every day to Open Source Software changed my life in many ways. I get payed to work on Open Source now, made many new friends in a lot of projects and improved my skills.

I would love to see companies supporting their employees more for contributing to Open Source Software - 99.99% of them rely on Open Source Software, e.g. for their dev-tooling, directly for their products or in most cases even in both ways. Sadly it is quite hard for most employees to work on Open Source Software during their work time and not everyone is privileged enough to spend ~1hr of their spare time every day to work on Open Source Software.

Several other folks like [Kyle Simpson](http://blog.getify.com/learned-on-a-1-year-github-streak/) and [Mathias Lafeldt](http://mlafeldt.github.io/blog/write-every-day/) started similar projects - it seems it also changed their life and the way they see the world and I am eager for the future.


Update: there is now a [chinese translation](http://www.labazhou.net/2015/03/what-happened-while-contributing-to-open-source-on-a-daily-basis-for-one-year/) available!

<img src="http://vg09.met.vgwort.de/na/73a3ecc5b1564287922d511acb38a381" width="1" height="1" alt="">
