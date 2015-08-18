---
layout: post
title: "Let’s learn Erlang and fix a bug on a CouchDB Cluster #1"
description: "Let’s learn Erlang is a series where I will try to teach some Erlang by explaining patches that we will write together. CouchDB 2.0 is a database that got clustering based on Amazon’s Dynamo Paper which allows horizontal scaling of CouchDB by adding nodes to the cluster."
category: ""
tags: [Erlang, CouchDB]
---
{% include JB/setup %}

Let’s learn Erlang is a series where I will try to teach some Erlang by explaining patches that we will write together. I am trying to explain everything but feel free to check out [http://learnyousomeerlang.com/content](http://learnyousomeerlang.com/content) which is an excellent book to start learning Erlang.

CouchDB 2.0 is a database that got clustering based on Amazon’s Dynamo Paper which allows horizontal scaling of CouchDB by adding nodes to the cluster. At the time of writing, it is not officially released yet, but we can already use it and fix bugs on it to learn Erlang.

Today we will write a patch for CouchDB in Erlang.

I often added GitHub links but I suggest you’ll open a text editor and follow the steps.

## Getting started

Clone CouchDB - to fix this bug with me you will need a CouchDB version where the bug is not fixed yet:

```
git clone https://github.com/robertkowalski/couchdb.git
cd couchdb && git fetch origin
git checkout article-auth-session-COUCHDB-1356
```

To compile CouchDB on OSX (if you don’t use OSX, please read [https://github.com/apache/couchdb/blob/master/INSTALL.Unix](https://github.com/apache/couchdb/blob/master/INSTALL.Unix)) you will need to have the OSX commandline-tools installed. You can install them via terminal:

```
xcode-select --install
```

You will also need to install these dependencies (brew on OSX is used here):

```
brew install autoconf
brew install autoconf-archive
brew install automake
brew install libtool
brew install erlang
brew install icu4c
brew install spidermonkey
brew install curl
brew install pkg-config
brew install rebar
brew install haproxy
```

After we installed everything we will need to check out the CouchDB source and run:

```
./configure
make
```

CouchDB is split into smaller sub-repositories. The `./configure` kicks off rebar which will pull each sub-repo down into the folder `src`.

Calling `./dev/run` from the CouchDB directory now allows us to spin up a three node development cluster. In another terminal, run: `haproxy -f rel/haproxy.cfg`. We now have a haproxy running in front of our three nodes on port 5984.

## Hunting the bug

### Verifying it exists

Todays bug is COUCHDB-1356 ([https://issues.apache.org/jira/browse/COUCHDB-1356](https://issues.apache.org/jira/browse/COUCHDB-1356)). It says:

```
When logging in with admin credentials (and no corresponding _users doc, if
that is important), the response of the POST to _session has the name
property set to null:

{"ok":true,"name":null,"roles":["_admin"]}

It should be the name of the admin instead, like it does when logging in with
a standard user: {"ok":true,"name":"standarduser","roles":[]}

Requesting the _session object after logging in with an admin, the name is
proper set:

{"ok":true,"userCtx":
{"name":"adminuser","roles":["_admin"]},"info":{"authentication_db":"_users",
"authentication_handlers":["oauth","cookie","default"],
"authenticated":"cookie"}}

```

Let’s verify that bug after pulling down our repository and installing the dependencies. According to [http://docs.couchdb.org/en/latest/api/server/authn.html#post--_session](http://docs.couchdb.org/en/latest/api/server/authn.html#post--_session) we can post JSON or x-www-form-urlencoded data, so let’s try to reproduce the bug:

```
#spin up a dev-cluster with username foo and password bar
./dev/run --admin=foo:bar
#post to a node
curl -X POST http://localhost:15984/_session -d 'name=foo&password=bar'
```

returns:

```
{"ok":true,"name":null,"roles":["_admin"]}
```

Ok, that was easy. Seems like we were able to reproduce the bug.

### Searching the broken code

Let’s see how far we can go by searching for `_session` which is the endpoint from the bug-report where the error is happening:

<a href="/assets/images/erlang-1/search-route.png">
    <img width="500" src="/assets/images/erlang-1/search-route.png" alt="Search results for _session" />
</a>

One of the first results is this snippet of code in `chttpd.erl`:

```erlang
url_handler("_sleep") ->        fun chttpd_misc:handle_sleep_req/1;
url_handler("_session") ->      fun chttpd_auth:handle_session_req/1;
url_handler("_oauth") ->        fun couch_httpd_oauth:handle_oauth_req/1;
```

[https://github.com/apache/couchdb-chttpd/blob/b44515f1c137994f5278f42106ecf720e2c35011/src/chttpd.erl#L360-375](https://github.com/apache/couchdb-chttpd/blob/b44515f1c137994f5278f42106ecf720e2c35011/src/chttpd.erl#L360-375)

What does that snippet of code mean? One of the core features of Erlang is called pattern-matching. These functions are called function clauses, which take different arguments. Together they form a function declaration. The code for the `url_handler("_session")` shows the path for the code in case of `url_handler` being called with the argument `"_session"`. The other functions are invoked by other arguments, like `"oauth"`. If we call the function `url_handler` with the argument `session` - which is a String - a new function is returned.  The last clause shows a catch-all using `_` as argument:

```erlang
url_handler(_) -> fun chttpd_db:handle_request/1.
```

Anything called with one parameter which does not match the other patterns will end in `chttpd_db:handle_request/1`.

Erlang functions return implicit and the value from the last statement is always returned (in this case another function: the function `chttpd_auth:handle_session_req` which takes 1 argument).

It seems that http-requests going to the cluster-nodes are handled by a component called `chttpd`. Ok, so it seems CouchDB has elements that are quite similar to a traditional web server as it accepts requests over HTTP.

Let’s have a look at `chttpd` in general, when we open `src/chttpd`, we’ll see this directory structure:

```
├── ebin
├── priv
└── src
```


 - `ebin` contains our compiled source which is compiled to bytecode which runs on the Erlang VM
 - `priv` contains other dependencies that chttpd has ????
 - `src` contains the source code that we are interested in


When we open the src folder we see that there is a file called `chttpd_auth.erl`. That one looks promising!

When we open the file we’ll see that the file is an Erlang module:

```erlang
-module(module_name)
```

[https://github.com/apache/couchdb-chttpd/blob/b44515f1c137994f5278f42106ecf720e2c35011/src/chttpd_auth.erl#L13](https://github.com/apache/couchdb-chttpd/blob/b44515f1c137994f5278f42106ecf720e2c35011/src/chttpd_auth.erl#L13)

A module can export several functions, in that case `default_authentication_handler` `cookie_authentication_handler` and `handle_session_req` are exported.

**Some background info on exports**:
an exported function is usable outside of a module. The `/1` in the export means that the function with this name is taking one argument. Erlang functions can have the same name, but take different arguments — and you can export them depending on how many arguments they take - Example:

if we wanted to additionally export a fictional function that has the same name and takes two arguments we would probably write:

```erlang
handle_session_req(_Req, _Foo) ->
    ok.
```

and would additionally export:

```erlang
-export([handle_session_req/2]).
```

But back to our code: if we look at `handle_session_req` we’ll see that it is delegating to another module and function: it seems there is a module called `couch_httpd_auth` which has a function `handle_session_req` with an arity of two (which is indicated by a `handle_session_req/2`).

[https://github.com/apache/couchdb-chttpd/blob/b44515f1c137994f5278f42106ecf720e2c35011/src/chttpd_auth.erl#L25-26](https://github.com/apache/couchdb-chttpd/blob/b44515f1c137994f5278f42106ecf720e2c35011/src/chttpd_auth.erl#L25-26)

The function in question seems to be in the folder `couch` - as you might have noticed the CouchDB modules have their component as a prefix of their filename (`chttpd_auth.erl` will lead you to the folder `chttpd` and `couch_httpd_auth.erl` leads you to the folder `couch`). So let’s open that file in `src/couch/src`.

There are multiple definitions of `handle_session_req` but as we do a POST-request to the endpoint there is just one which fits for us:

```erlang
handle_session_req(#httpd{method='POST', mochi_req=MochiReq}=Req, AuthModule)
```

[https://github.com/apache/couchdb-couch/blob/master/src/couch_httpd_auth.erl#L270](https://github.com/apache/couchdb-couch/blob/master/src/couch_httpd_auth.erl#L270)


If you remember the CouchDB docs ([http://docs.couchdb.org/en/latest/api/server/authn.html#post--_session](http://docs.couchdb.org/en/latest/api/server/authn.html#post--_session)) we can POST with different Content-Types. In the beginning of the handler we see the handling for it, it seems we are on a good path.

[https://github.com/apache/couchdb-couch/blob/master/src/couch_httpd_auth.erl#L272-283](https://github.com/apache/couchdb-couch/blob/master/src/couch_httpd_auth.erl#L272-283)


```erlang
send_json(Req#httpd{req_body=ReqBody}, Code, Headers,
    {[
        {ok, true},
        {name, couch_util:get_value(<<"name">>, UserProps2, null)},
        {roles, couch_util:get_value(<<"roles">>, UserProps2, [])}
    ]});
```

It seems that this code is sends the buggy response to the user - time for me to introduce `io:format`: with `io:format` we can log things to the console, example:

```
io:format("demoprint: ~s", ["foo"]).
```
results in `demoprint: foo` on the stdout.

The bug report says the name value is not set, strange.

A short look at `couch_util:get_value` says us that it returns the value of a key/value structure and if it does not find it, it returns a default value ([https://github.com/apache/couchdb-couch/blob/cb52507c1ced478e6900cae529584461c3d4910b/src/couch_util.erl#L154](https://github.com/apache/couchdb-couch/blob/cb52507c1ced478e6900cae529584461c3d4910b/src/couch_util.erl#L154))

We will add `io:format` with a comma at , as other statements are following that we want to execute (`send_json`):

```erlang
io:format("~s", [UserProps2]),
send_json(Req#httpd{req_body=ReqBody}, Code, Headers,
    {[
        {ok, true},
        {name, couch_util:get_value(<<"name">>, UserProps2, null)},
        {roles, couch_util:get_value(<<"roles">>, UserProps2, [])}
    ]});
```

Ok, we'll stop the cluster (crtl+c) and run make again from our project root directory.

After the compile we redo the steps to boot the cluster from the first part of the article:

```
#spin up a dev-cluster with username foo and password bar
./dev/run --admin=foo:bar
#post to a node
curl -X POST http://localhost:15984/_session -d 'name=foo&password=bar'
```

CouchDB returns:

```
{"error":"badarg","reason":null,"ref":2510570082}
```

Let's have a look at the Erlang docs at [http://erlang.org/doc/man/io.html#format-2](http://erlang.org/doc/man/io.html#format-2) - let's try if `~p` is the right fit for our needs as it is used print Erlang terms.

We change our code to:

```erlang
io:format("~p", [UserProps2]),
send_json(Req#httpd{req_body=ReqBody}, Code, Headers,
    {[
        {ok, true},
        {name, couch_util:get_value(<<"name">>, UserProps2, null)},
        {roles, couch_util:get_value(<<"roles">>, UserProps2, [])}
    ]});
```

and after the stop of the cluster, compile and start of the cluster we get a nice message from CouchDB:

```
{"ok":true,"name":null,"roles":["_admin"]}

```

But where is our debug logging output?

The dev-cluster nodes are logging each on their own. In a production setup they would be on different machines. In our development setup they log to `./dev/logs/`. `15984` is node1 so we enter in the terminal:

```
cat ./dev/logs/node1.log
```

and we will see something like this in the log:

```
2014-11-27 00:43:41.374 [debug] node1@127.0.0.1 <0.259.0> adding shards/80000
  000-9fffffff/_users.1416085356 -> 'node2@127.0.0.1' to mem3_sync queue
2014-11-27 00:43:41.406 [debug] node1@127.0.0.1 <0.478.0> Attempt Login: foo
2014-11-27 00:43:41.406 [warning] node1@127.0.0.1 <0.478.0> no record of user
  foo
2014-11-27 00:43:41.406 [debug] node1@127.0.0.1 <0.478.0> cache miss for foo
[{<<"roles">>,[<<"_admin">>]},
 {<<"salt">>,<<"194439690d43ce9c2720acb4db907723">>},
 {<<"iterations">>,10},
 {<<"password_scheme">>,<<"pbkdf2">>},
 {<<"derived_key">>,<<"e6de659df04ca1db5050bb6747fb039a30836a01">>}]
   2014-11-27 00:43:41.407 [notice] node1@127.0.0.1 <0.478.0> 776ee413
   127.0.0.1 localhost:15984 POST /_session 200 ok 2
```
I think we are now able to confirm that our structure, which is a list does not contain the key we are searching for.

### Write a failing test

CouchDB uses EUnit which is included in Erlang. A good start for a test is to copy another test to have the boilerplate already added. `src/couch/test/couchdb_csp_tests.erl` look like a nice template as they already make HTTP-requests.

We run:

```
cp src/couch/test/couchdb_csp_tests.erl src/couch/test/couchdb_auth_tests.erl
```

If we take a look at our copied testfiles each test in the file has an assertion.

[https://github.com/apache/couchdb-couch/blob/cb52507c1ced478e6900cae529584461c3d4910b/test/couchdb_csp_tests.erl#L68-74](https://github.com/apache/couchdb-couch/blob/cb52507c1ced478e6900cae529584461c3d4910b/test/couchdb_csp_tests.erl#L68-74)

EUnit uses so called Macros which are called with a `?` in front of the name, like `?_assertEqual`. Everyone can define macros, and it is quite easy:

```erlang
-define(MACRONAME, "Value").
```
Would return `"Value"` on `?MACRONAME().`

We can also delete the TIMEOUT-Macro at the top of our file, we will not need it.

[https://github.com/apache/couchdb-couch/blob/cb52507c1ced478e6900cae529584461c3d4910b/test/couchdb_csp_tests.erl#L17](https://github.com/apache/couchdb-couch/blob/cb52507c1ced478e6900cae529584461c3d4910b/test/couchdb_csp_tests.erl#L17)

The `setup` and `teardown` functions are running before and after the tests. The copied version of our test says:

```erlang
setup() ->
    ok = config:set("csp", "enable", "true", false),
    Addr = config:get("httpd", "bind_address", "127.0.0.1"),
    Port = integer_to_list(mochiweb_socket_server:get(couch_httpd, port)),
    lists:concat(["http://", Addr, ":", Port, "/_utils/"]).
```

[https://github.com/apache/couchdb-couch/blob/cb52507c1ced478e6900cae529584461c3d4910b/test/couchdb_csp_tests.erl#L20-24](https://github.com/apache/couchdb-couch/blob/cb52507c1ced478e6900cae529584461c3d4910b/test/couchdb_csp_tests.erl#L20-24)

which we can modify to:

```erlang
setup() ->
    Addr = config:get("httpd", "bind_address", "127.0.0.1"),
    Port = integer_to_list(mochiweb_socket_server:get(couch_httpd, port)),
    lists:concat(["http://", Addr, ":", Port, "/_session"]).
```

As Erlang implicitly returns, we are returning the address to our session endpoint. This will get passed to our test (the section beginning with the `should`).

In the middle of our file we will find a loop which iterates over our tests.

[https://github.com/apache/couchdb-couch/blob/cb52507c1ced478e6900cae529584461c3d4910b/test/couchdb_csp_tests.erl#L30-L47](https://github.com/apache/couchdb-couch/blob/cb52507c1ced478e6900cae529584461c3d4910b/test/couchdb_csp_tests.erl#L30-L47)

We can rename the Headline from `"Content Security Policy tests"` to `"Auth tests"` and delete the last three tests. `should_not_return_any_csp_headers_when_disabled` can get renamed to `should_not_return_username_on_post_to_session`. We also have to rename the test declaration and delete the other three declarations - if we would not delete them, we would get a compiler warning, that the functions are not used.

Our renamed test that was not deleted should look like this:

```erlang
should_not_return_username_on_post_to_session(Url) ->
    ?_assertEqual(undefined,
        begin
            ok = config:set("csp", "enable", "false", false),
            {ok, _, Headers, _} = test_request:get(Url),
            proplists:get_value("Content-Security-Policy", Headers)
        end).
```

it tests for the atom `undefined`. The test says it should be returned at the end of the block marked by `begin` and `end`. Before that it  changes the config value for the csp section and makes a GET-request. The author is just interested in the headers here, so other values are not assigned to a variable (`_`). By the way: in Erlang every variable has to start with an uppercase letter.

Changing this snippet to our needs is quite easy: admins are also defined in the config (see also: [http://docs.couchdb.org/en/1.6.1/config/auth.html](http://docs.couchdb.org/en/1.6.1/config/auth.html)). So our call to setup the user `rocko` with password `artischocko` would be:

```erlang
ok = config:set("admins", "rocko", "artischocko", false),
```

Looking at the next line

```erlang
{ok, _, Headers, _} = test_request:get(Url),
```

it turns out that we need a POST-request and the body, not the headers.

The `get`-functions in `test_request.erl` just wrap a request function for convenience: [https://github.com/apache/couchdb-couch/blob/cb52507c1ced478e6900cae529584461c3d4910b/test/test_request.erl#L23-26](https://github.com/apache/couchdb-couch/blob/cb52507c1ced478e6900cae529584461c3d4910b/test/test_request.erl#L23-26)

As functions for a POST is missing, we have to add it:

```erlang
post(Url, Body) ->
    request(post, Url, [], Body).
post(Url, Headers, Body) ->
    request(post, Url, Headers, Body).

```

and we also have to export the functions to use it from outside:

```erlang
-export([post/2, post/3]).
```

Now we can fire a POST request in our test:

```erlang
{ok, _, _, Body} = test_request:post(Url,
    [{"Content-Type", "application/json"}],
    "{\"name\":\"rocko\", \"password\":\"artischocko\"}"),
```

We have to decode the JSON that is coming back, let's use jiffy (jiffy is a JSON parser included in CouchDB) for that:

```erlang
{Json} = jiffy:decode(Body),
```

and then get the value for the name field:

```
proplists:get_value(<<"name">>, Json)
```

The funky `<<"name">>` notation means that we are using an Erlang binary. `proplists:get_value(<<"name">>, Json)` will return a binary so we change the undefined, which was an Erlang atom to the binary `<<"rocko">>`.

Our whole test, which tests for the binary `<<"rocko">>`:

```erlang
should_not_return_username_on_post_to_session(Url) ->
    ?_assertEqual(<<"rocko">>,
        begin
            ok = config:set("admins", "rocko", "artischocko", false),
            {ok, _, _, Body} = test_request:post(Url,
                [{"Content-Type", "application/json"}],
                "{\"name\":\"rocko\", \"password\":\"artischocko\"}"),
            {Json} = jiffy:decode(Body),
            proplists:get_value(<<"name">>, Json)
        end).

```

running the tests for `src/couch` is easy, just run:

```
rebar -r eunit apps=couch
```

We should have one failing test now. Back to the session handler!

### Fixing the bug

When we take a second look at the `handle_session_req` which handles the POST-request we can see that we have access to a variable called `UserName` in our scope which is the username the user gave us!

[https://github.com/apache/couchdb-couch/blob/cb52507c1ced478e6900cae529584461c3d4910b/src/couch_httpd_auth.erl#L284](https://github.com/apache/couchdb-couch/blob/cb52507c1ced478e6900cae529584461c3d4910b/src/couch_httpd_auth.erl#L284)

This means that we can change

```erlang
{name, couch_util:get_value(<<"name">>, UserProps2, null)},
```

to

```erlang
{name, UserName},
```

When we now run our test suite again we should have a green tests and fixed our bug!


## Recap

We fixed a small bug on a clustered CouchDB and learned about:

- Pattern matching
- Modules and exporting functions
- implicit returns
- Macros
- logging debug messages
- EUnit

The article is based on a real-life pull-request: [https://github.com/apache/couchdb-couch/pull/16/](https://github.com/apache/couchdb-couch/pull/16/) - and the CouchDB Community is happy about all contributions! See [http://couchdb.apache.org/#contribute](http://couchdb.apache.org/#contribute) for further info.


Apache CouchDB is an Open Source Project under Apache 2.0 License. The code used in this article is from Apache CouchDB, licensed under Apache License, Version 2.0, January 2004. For details, see: [https://github.com/apache/couchdb/blob/master/LICENSE](https://github.com/apache/couchdb/blob/master/LICENSE)

<img src="http://vg09.met.vgwort.de/na/2dbf8d67bd4843ce9c6a9f3727f25c9a" width="1" height="1" alt="">
