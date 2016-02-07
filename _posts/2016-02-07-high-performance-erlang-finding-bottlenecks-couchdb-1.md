---
layout: post
title: "High Performance Erlang - Finding Bottlenecks in a CouchDB Cluster #1"
description: "High Performance Erlang is a series where we will search bottlenecks Erlang applications."
category: ""
tags: [Erlang, CouchDB]
---
{% include JB/setup %}

Welcome to High Performance Erlang!

*High Performance Erlang* is a series for developers who already know the Erlang
syntax and have a basic knowledge of the Open Telecommunication Platform (OTP).
The series should be valuable to both beginners and advanced developers who want
to deliver the best user experience for their applications.

## Why Performance Matters

You might ask yourself: why should I care about performance? There are a lot of
reasons why we should care! When we are running an online shop the performance
of our shop will directly increase or decrease your revenue: Amazon found out
that 100ms of added latency cost them 1% of their profit. Google made a
similar observation in their tests:
[a page that took .5 seconds longer had 20% less traffic and revenue](http://glinden.blogspot.de/2006/11/marissa-mayer-at-web-20.html). Mozilla increased the page load time for their Firefox
download page and was able to
[increase their download conversion by 15% — which resulted in 60 million more downloads per year](https://blog.mozilla.org/metrics/2010/04/05/firefox-page-load-speed-%E2%80%93-part-ii/)! Better performance will also result in less
operational costs for our services as we need less servers and resources to
run our business, especially when our deployment got a decent size.

Other examples where milliseconds matter are Ad trading and High-frequency
trading. But even for a SAAS business with a freemium model performance is a
crucial feature, as a successful sale results from customer satisfaction over
time and a fast responsive service is an [important corner stone of satisfaction](http://services.google.com/fh/files/blogs/google_delayexp.pdf).
Google’s search service even takes the performance of a site into account when
[deciding on the rank of search results](http://googlewebmastercentral.blogspot.com/2010/04/using-site-speed-in-web-search-ranking.html).

## Performance optimising Erlang

Our sample application today will be Apache CouchDB. We will work through
hands-on exercises based with real live examples.

We will need to compile CouchDB in order to hack on it. I will list the
needed steps required for OSX and Ubuntu. If you already have compiled
CouchDB 2 on your system you can continue with the section [“Siege“](#Siege).

### Install Dependencies — Ubuntu

To compile CouchDB 2 on Ubuntu Trusty I had to install these dependencies:

```
$ sudo apt-get install build-essential erlang-base \
  erlang-dev erlang-manpages erlang-eunit erlang-nox \
  libicu-dev libmozjs185-dev libcurl4-openssl-dev \
  pkg-config
```

### Install Dependencies — OSX

OSX users have to install the Command Line Tools:

```
$ xcode-select --install
```

After installing the Command Line Tools we have to install the missing dependencies:

```
$ brew install autoconf autoconf-archive automake libtool \
  erlang icu4c spidermonkey curl pkg-config
```


<a id="Siege"></a>
### Siege

We’ll also install `siege` to run a benchmark later in the article:

```
$ brew install siege          # OSX users
$ sudo apt-get install siege  # Linux
```


### Setting up CouchDB


Clone the development repository with our development branch:

```
$ git clone -b high-perf-erlang-1 https://github.com/robertkowalski/couchdb
```

Go to the CouchDB repo:

```
$ cd couchdb
```

Run `./configure` with `--disable-docs --disable-fauxton` to pull
in all the sub-repositories:

```
$ ./configure --disable-docs --disable-fauxton
```

Compile the source with `make`:

```
$ make
```

We can try to boot a cluster now.

```
./dev/run --with-admin-party-please
```

CouchDB should output something like this:

```
[ * ] Setup environment ... ok
[ * ] Ensure CouchDB is built ... ok
[ * ] Prepare configuration files ... ok
[ * ] Start node node1 ... ok
[ * ] Start node node2 ... ok
[ * ] Start node node3 ... ok
[ * ] Check node at http://127.0.0.1:15984/ ... failed: [Errno socket error] [Errno 111] Connection refused
[ * ] Check node at http://127.0.0.1:25984/ ... ok
[ * ] Check node at http://127.0.0.1:35984/ ... ok
[ * ] Check node at http://127.0.0.1:15984/ ... ok
[ * ] Developers cluster is set up at http://127.0.0.1:15984.
Admin username: Admin Party!
Password: You do not need any password.
Time to hack! ...
```

Great! In another terminal window we can test our installation by sending a HTTP request to the database:

```
$ curl http://127.0.0.1:15984
{"couchdb":"Welcome","version":"a06d4c7","vendor":{"name":"The Apache Software Foundation"}}
```

Before we start analysing, we create a test database and document:

```
$ curl -XPUT http://127.0.0.1:15984/animals
{"ok":true}
$ curl -XPUT http://127.0.0.1:15984/animals/cat -d '{"name": "gizmo"}'
{"ok":true,"id":"cat","rev":"1-7becc1049568795707afe8c7d0c65aa3"}
```

Awesome! CouchDB is up and running! Don’t forget to stop the server as we are going to make
changes to CouchDB now.

## The Measure-Learn-Refactor-Loop

During the article we will follow an approach that I call the "Measure-Learn-Refactor-Loop".

<div style="text-align: center; margin: 40px;">
  <img src="/assets/data/high-perf-erlang-1/measure-learn-refactor.png" />
</div>

As a first step we will investigate — right after a short initial analysis. Compared to an approach where we would write
long and detailed test plans upfront we get immediate feedback on our assumptions. Instead of trying to solve our
performance issues in a waterfall-like way, we will keep on iterating on our insights and learnings. Based on our first
insights we can make first decisions and spend our time in the most efficient way.

You can’t fix problems you are not aware of. Just if we have identified a bottleneck in our application we are able to fix it. To confirm an improvement we will measure
again and are (hopefully!) be able to confirm a performance improvement. The new measurement will additionally lead to new
insights about new potential bottlenecks. The *Measure-Learn-Refactor-Loop*.

### Decide on a component

No one can take a look on everything at once in a large, grown application.
Most of the time we will look through a small window on specific parts of our
system. The more the specific components are used, the more overall impact we
will have. At the beginning it makes sense to start with the low-hanging
fruits which usually have this big overall impact.

Applications using CouchDB have probably a read-heavy usage pattern, because
that is a use case where CouchDB really shines. This might be different for
the applications you are trying to improve after reading the article, so you
should think a few moments about your application.

### Erlang in flames — Measuring with Flamegraphs

CPU Flamegraphs are an excellent way to visualise where a program spends the
most time and where the hot paths of the code are located. Here is an example
flamegraph showing a request of the Mochiweb webserver:

<a href="/assets/data/erlang-perf/mochi-flame-patched.svg">
  <img src="/assets/data/erlang-perf/mochi-flame-patched.svg" alt="Mochiweb">
</a>

100% of the width of the box equals 100% of the spent CPU time.

The y-axis
shows the stack depth: `bench_web_loop/2` calls two functions:
`mochiweb_request:get/2` and `mochiweb_request:respond/2`, which each call
other functions afterwards. The called functions are displayed on top.
We see in our example that `mochiweb_request:respond/2` calls
`mochiweb_request:format_response_header/2` which then calls four other functions.


Wide rectangles in the flamegraph signal functions
which consume more time. `mochiweb_request:respond/2` consumes more CPU time
than `mochiweb_request:get/2`.
To make sense of the shown flamegraph, it helps to take a look at the
[corresponding sourcecode of the sample app used](https://github.com/mochi/mochiweb/blob/f01872e2ac30e21a5bb41765fb14f49ec026be1e/support/templates/mochiwebapp_skel/src/mochiapp_web.erl#L26-L31) and the [underlying webserver code](https://github.com/mochi/mochiweb/blob/bd6ae7cbb371666a1f68115056f7b30d13765782/src/mochiweb_request.erl#L339).

We can also get additional data by hovering the boxes in the [SVG file](/assets/data/erlang-perf/mochi-flame-patched.svg) and
clicking on them: the flamegraph for Mochiweb shows that the most time is
spent in `mochiweb_request:respond/2`.

A nice module to get the data needed to create Flamegraphs for Erlang applications is [eflame](https://github.com/proger/eflame).

Let’s hook `eflame` into CouchDB by adding it to the file which defines our dependencies, `rebar.config.script`:

```diff
diff --git a/rebar.config.script b/rebar.config.script
index 9f47eeb..8620792 100644
--- a/rebar.config.script
+++ b/rebar.config.script
@@ -60,7 +60,8 @@ DepDescs = [
 {rexi,             "rexi",             "a327b7dbeb2b0050f7ca9072047bf8ef2d282833"},
 {snappy,           "snappy",           "ce24944752ff3a60ad2710f61d4cf709a1b31863"},
 {setup,            "setup",            "b9e1f3b5d5a78a706abb358e17130fb7344567d2"},
-{meck,             "meck",             {tag, "0.8.2"}}
+{meck,             "meck",             {tag, "0.8.2"}},
+{eflame,            {url, "https://github.com/proger/eflame"}, "b87703d65590f05069be42eb9ef74040d3c7ecdc"}
 ],

 BaseUrl = "https://git-wip-us.apache.org/repos/asf/",
```

We have to run `./configure` another time to pull in the new module:

```
$ ./configure --disable-docs --disable-fauxton
```

As database clients tend to read a lot from CouchDB, we will take a look at reading documents.
It sounds like a great area to have a big impact.

CouchDB’s HTTP handler for operations on databases and documents are located in `src/chttpd/src/chttpd_db.erl`. If a document is requested, it matches [this handler](https://github.com/apache/couchdb-chttpd/blob/417679a9cf2277693253d3f9c2ac0e52fa1ba75c/src/chttpd_db.erl#L607-L608):

```erlang
db_req(#httpd{path_parts=[_, DocId]}=Req, Db) ->
    db_doc_req(Req, Db, DocId);
```

The delegation in the handler `db_req/2` looks like a good place to create a flamegraph as we have a single entry point.

We use `eflame:apply`. Our data collection will start from this function:

```erlang
db_req(#httpd{path_parts=[_, DocId]}=Req, Db) ->
    eflame:apply(fun db_doc_req/3, [Req, Db, DocId]);
```

We should now verify that we have stopped any previously running CouchDB instances.

As we already set up a database `animals` and test-document `cat` we can now run some commands that will:

1. compile the modified CouchDB version
2. boot CouchDB
2. open a document that was saved in CouchDB (in a separate terminal window)
3. convert the output generated by `eflame` to an SVG-file
4. open the SVG in our browser to inspect it

```
$ make                                  # compile the patched version
$ ./dev/run --with-admin-party-please   # boot dev cluster
```

In another terminal window we enter now:

```
$ curl http://localhost:15984/animals/cat
```

CouchDB answers:

```
{"_id":"cat","_rev":"1-7becc1049568795707afe8c7d0c65aa3","name":"gizmo"}
```

Additionally we got a file called `stacks.out` in our CouchDB sourcecode directory. It contains the samples
which we will convert to the graph:

```
./src/eflame/stack_to_flame.sh < stacks.out > flame.svg
```

We can open the SVG file using our favourite browser and inspect the
different areas by clicking on them:

<a href="/assets/data/high-perf-erlang-1/flame-before.svg">
  <img src="/assets/data/high-perf-erlang-1/flame-before.svg" />
</a>

### Learn

On the left side of the graph we see the node of the cluster retrieving the requested document for us by calling
`chttpd_db:db_doc_req/3`. When we hover with our mouse over the horizontal bar we see how long it takes: it takes CouchDB 11.48% of the time to get the document that it will send back to the client soon.

The largest bar in the diagram is located in the middle in the diagram:
`couch_httpd:server_header/0` which calls `couch_server:get_version/0` takes 27.87% of the time.
Wait... `server_header` and `get_version`?

A short search verifies: [the function](https://github.com/robertkowalski/couchdb-couch/blob/a06d4c751491015c72520e62d89578b7290ea0ee/src/couch_httpd.erl#L980) adds the current version of CouchDB to the HTTP
header.


<a href="/assets/data/high-perf-erlang-1/terminal-header-arrow.png">
  <img src="/assets/data/high-perf-erlang-1/terminal-header-arrow.png" />
</a>

CouchDB currently takes more time to put its current version into the
response-header than for reading a doc from disk!

Let’s take a look at the `get_version/0` function, which is located in `couch/couch_server.erl`. The function receives
a full list of all loaded applications using `application:loaded_applications/0`:


```erlang
get_version() ->
    Apps = application:loaded_applications(),
    case lists:keysearch(couch, 1, Apps) of
    {value, {_, _, Vsn}} ->
        Vsn;
    false ->
        "0.0.0"
    end.
```

Behind the scenes `loaded_applications/0` uses an `ets:filter` which takes a lot of the time. As soon as we have received a result we are running a keysearch on all results.

### Refactor

One possible solution is to cache the version number, but there is an even simpler, very straightforward way: we can use
`application:get_key/2` to receive the version number. The modified `get_version/0` function looks like this now:

```erlang
get_version() ->
    case application:get_key(couch, vsn) of
        {ok, Version} -> Version;
        undefined -> "0.0.0"
    end.
```

**Important: before we will continue, we have to remove the `eflame:apply/2` call that we used to create the flamegraph
from our `db_req` handler!**


### Closing the circle: confirmation

Do you remember the graphic with the circle at the beginning of the article? We are now almost at the end of this
iteration.

I started with benchmarking using my laptop, which is OK in my opinion, especially if you just get started and are not
sure if you will keep optimising and profiling. But in the long term a separate, dedicated machine just for benchmarking really pays off.

To create reproducible benchmark results following this protocol has been very valuable to me:

1. Prevent all programs that run in the background from starting, e.g. Dropbox, Google Drive or also the
   indexer that runs on OSX for the file search
2. Compile the patched/unpatched version
3. Reboot system
4. Wait 60 seconds
5. Boot CouchDB Cluster, wait 120 seconds
6. Run Benchmarking tool
7. Wait 90 seconds
8. Repeat step 6 and 7 until I we have 10 benchmarks

In order to run the benchmarks I had to tweak my OSX system: OSX only has
16k available ports and sockets idle per default 15 seconds until they are
released. I created `/etc/sysctl.conf` set the timeout to 150ms:

```
net.inet.tcp.msl=150
```

I also had to raise the amount of the max open files. I had to create
`/Library/LaunchDaemons/limit.maxfiles.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
        "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>limit.maxfiles</string>
    <key>ProgramArguments</key>
    <array>
      <string>launchctl</string>
      <string>limit</string>
      <string>maxfiles</string>
      <string>524288</string>
      <string>524288</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>ServiceIPC</key>
    <false/>
  </dict>
</plist>
```

and reboot.

`ulimit -a` then shows after a reboot:

```
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
file size               (blocks, -f) unlimited
max locked memory       (kbytes, -l) unlimited
max memory size         (kbytes, -m) unlimited
open files                      (-n) 524288
pipe size            (512 bytes, -p) 1
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 709
virtual memory          (kbytes, -v) unlimited
```

(right now I use OSX El Capitan)

After running this protocol for the unpatched and modified version (without
the `eflame:apply` call of course!) we should have quite reproducible results,
as we disabled all background processes that can eat a lot of our CPU power.
We also don’t have any unfreed memory or zombie processes running as we reboot
between the benchmarks for the patched and unpatched version.

Running this protocol can be quite boring — so let’s automate most of it!

Automating most of the process has other great improvements next to the fact
that it makes benchmarking less boring for us: less human errors and most
parts of our benchmarking process is documented in code for our colleagues.

Here is the script:

```bash
#!/bin/sh

COUCHDB_PATH=$HOME/couchdb
BENCH_RUN="siege -q -c120 -r400 -b http://127.0.0.1:15984/animals/cat"

sleep 60;
$COUCHDB_PATH/dev/run --with-admin-party-please & pid=$!
sleep 120

echo ""
echo ""
for i in `seq 1 10`;
do
  echo "Runnig test #$i:"
  $BENCH_RUN
  sleep 90
done

kill $pid

printf '\a'  # beep to signal we are finished
```


We should get results for the [unpatched version](/assets/data/high-perf-erlang-1/bench-unoptimized.txt) and after a reboot and
a fresh run of the benchmark script the results for the
[patched version](/assets/data/high-perf-erlang-1/bench-optimized.txt). We can put the results into a table:


<table>
<thead>
<tr><td></td><td>optimized (secs)</td><td>unoptimized (secs)</td></tr>
</thead>
<tbody>
<tr><td>#1</td><td>38,47</td><td>44,61</td></tr>
<tr><td>#2</td><td>39,87</td><td>43,35</td></tr>
<tr><td>#3</td><td>39,76</td><td>44,53</td></tr>
<tr><td>#4</td><td>37,78</td><td>44,88</td></tr>
<tr><td>#5</td><td>38,16</td><td>44,47</td></tr>
<tr><td>#6</td><td>40,02</td><td>43,09</td></tr>
<tr><td>#7</td><td>40,00</td><td>43,37</td></tr>
<tr><td>#8</td><td>40,11</td><td>44,40</td></tr>
<tr><td>#9</td><td>39,97</td><td>43,48</td></tr>
<tr><td>#20</td><td>41,92</td><td>44,63</td></tr>
<tr><td>SUM (secs)</td><td>396,06</td><td>440,81</td></tr>
</tbody>
</table>


We can also visualise the results in a diagram:

<div style="text-align: center; margin: 40px;">
  <a href="/assets/data/high-perf-erlang-1/graph.png">
    <img src="/assets/data/high-perf-erlang-1/graph.png" />
  </a>
</div>

We see that every run of the patched, optimised version is faster.

Looks like the patched version is about 46 seconds faster if we sum up the times of the almost 500.000
requests. That’s a lot!

As a last step we also create a new flamegraph.
The [new flamegraph](/assets/data/high-perf-erlang-1/flame-after.svg) should look like this:

<a href="/assets/data/high-perf-erlang-1/flame-after.svg">
  <img src="/assets/data/high-perf-erlang-1/flame-after.svg" />
</a>

`couch_server:get_version/0` was consuming a lot of CPU time before our
optimisation and isn’t visible any more. As one of the main consumer of CPU
time got optimised, the graph shows other main consumer now. Creating the second
flamegraph allows us to verify our benchmark and assumptions on the
performance improvement. It also shows us immediately the next bottleneck,
which we will investigate in the next article.


## Wrapping up

Inefficient lookups are quite common, we often catch them early during a code
review. Sometimes they slip through the review process which isn’t necessarily
a problem, but in rare conditions they are located in the hot path, the code
that gets executed the most often and that makes them harmful. In this case we
are able to measure an **8%** improvement in performance after the refactor for
a reading operation. The bottleneck we have found basically affects every HTTP
request, as CouchDB reports its version not only in case of a read.

If we would have focussed on writing long detailed test plans instead of measuring we
probably would have focussed on the B-Tree or other parts of the system.
At least I would have never assumed that getting the version of the current
CouchDB release is a major performance issue in the project and additionally
has a very high overall impact.

The second flame graph we created immediately makes the
next bottleneck visible. We will take a look at it in the next article. The
original PR for this article is available at
[https://github.com/apache/couchdb-couch/pull/56](https://github.com/apache/couchdb-couch/pull/56).

Did you like the article? I wrote a book about successful CLI design:
[http://theclibook.com](http://theclibook.com)

Apache CouchDB is an Open Source Project under Apache 2.0 License. The code used in this article is from Apache CouchDB, licensed under Apache License, Version 2.0, January 2004. For details, see: [https://github.com/apache/couchdb/blob/master/LICENSE](https://github.com/apache/couchdb/blob/master/LICENSE).

<img src="http://vg07.met.vgwort.de/na/788b22edd5224023ad7136844cea158b" width="1" height="1" alt="">
