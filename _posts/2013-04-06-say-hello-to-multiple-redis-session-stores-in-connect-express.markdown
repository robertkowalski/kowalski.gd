---
layout: post
title: "Say hello to multiple Redis session stores in Connect/Express"
date: 2013-04-06 14:47
keywords: "Connect, Express, Node.js, Nodejitsu, Middleware, Redis, Robert Kowalski, JavaScript"
tags: [JavaScript, Node.js, Open Source]
---

I am happily hosting an open source side project at Nodejitsu, a [JavaScript Job Board](http://javascriptjob.de/) mainly for the german market. The project itself uses Redis (provided by Iris Couch Redis) and MongoDB. One morning I discovered that my app was not available, throwing a 500 error.

<!-- more -->

What happenened?

I am using a free instance of the Iris Couch Redis accounts one can use with a Nodejitsu account for my session handling. This day the connection between Nodejitsu and Iris Couch was out of order and the result was my Express app crashing.

So, with my volunteer side project, which is Open Source I can not afford a High Availablity Infrastructure. I have to use the free instances from Iris Couch for example. I would bet there are alot of other very small projects around like my Job Board, which also depend on free or very cheap infrastructure.

To prevent my app crashing I created a free account at RedisToGo - but I still had no way to switch between my hosts. So I started to develop <a href="https://github.com/robertkowalski/connect-multi-redis">connect-multi-redis</a>, a middleware for Connect and Express which checks the connection state to the Redis hosts and switches to the next one, once the current host is down.

Surely the old sessions will be lost, but everyone is able to work further with the app, and the app is not having a downtime.

If all Redis hosts are down connect-multi-redis will choose the builtin MemoryStore for sessions as a last resort.

It's very easy to use, but you have to inject the current app instance to get it work with connect (Express has the instance of the app glued on every `res` object and I need to access the app.stack Array).

I would love to get some feedback (Comments here, email, twitter), especially if you know a solution for Connect without injecting the Connect instance.
