---
layout: post
title: "Choosing the right stack: why we chose Hapi, CouchDB and Ansible"
description: "Why Hapi, CouchDB and Ansible make sense for our project"
category: ""
tags: [Node.js, Open Source, CouchDB, Configuration Management]
---
{% include JB/setup %}

Since 2014 we are organizing the [JS Unconf](http://jsunconf.eu). The edition for 2015 takes place in Hamburg on the 25th and 26th of April and tickets are currently on sale. It’s an Unconference with the main focus on JavaScript and Node.js but also community, health, workflow and workplace (and many more!) are topics. The two mornings of the event everyone attending will vote on each talk submitted. The team then creates a schedule based on the talks which got the most votes.

To make the voting easier and faster we are hosting [an application](http://contriboot.jsunconf.eu/) where attendees which are also possible speakers can submit a talk. It is also possible to submit an interest and to answer an interest with a talk. There is also a small „+1“ button for visitors, they are not used in the final voting but help everyone who submitted a talk to see a tendency regarding the interest for the topic. One day before the Unconference we are printing all submissions for the voting. It is still possible to submit something ad-hoc using a pencil during both days but the pre-printed submissions are making our job a bit easier.

## Our requirements

We wanted to focus on these topics for this year:

- high availability and possibility to fail-over
- high level of automation
- easy setup for our friends from other Unconference teams
- easy deployments
- easy testing, next to selenium-based integration tests
- easy theming, as we are using a different design each year
- easy backups
- no vendor-lock-in where it takes hours and hours to switch the platform
- cheap operation, we don’t want to pay > $100/month for hosting & services

The nice thing is that I am not alone this year and we are able to do a lot of pair-programming :)

## Deciding on technologies and app setup

### Why Hapi?

[Hapi](http://hapijs.com/) is a battle tested framework for Node.js made by Walmart. It is backed by a core team which get’s paid to maintain it and the framework is Open Source. Even during Black Friday the US Walmart’s Hapi.js servers are humming along nicely, the graphs they posted on twitter are so boring (which is a good thing) as they are basically all showing flat lines of minimal load.

Reported bugs are getting fixed immediately, the support is really great - also if you have questions. It has a nice and helpful community and great testing support for unit tests. Hapi has an awesome plugin system and the large amount of official plugins (e.g monitoring, logging, OAuth) is very well maintained.

The only thing I am not sure about is the configuration-over-convention approach of Hapi, many developers prefer convention-over-configuration. But after starting with Hapi it turned out that the configuration-based approach made the implementation of our requirement „theming“ quite easy.

#### Helps us regarding:

- high availability
- easy testing
- easy theming

### Why CouchDB?

I was quite late to the party but since I discovered CouchDB I really love the database. It is a perfect fit for the submissions as the usage characteristics for our app are a lot reading requests and just a few writing requests. Given CouchDB’s outstanding abilities regarding replication it’is very easy to replicate our data between servers and datacenters (basically one click in the Admin-Dashboard or one curl request to the API).

As it is all JSON it’s really easy for us as JS developers to write export scripts. We need the submissions printed at the Unconference for the voting and as someone who enjoys writing JS it’s more fun to create a CSV based on JSON instead of a SQL-dump.

A nice Bonus is the REST HTTP API of CouchDB - we get a REST API  for free.

#### Helps us regarding:

- high availability and possibility to fail-over
- easy backups
- no vendor-lock-in where it takes hours and hours to switch the platform
- cheap operation, we don’t want to pay > $100/month for hosting & services

### Why Ansible?

We want to have as much as our infrastructure easy and fast to setup. A server should be in a well defined state that can be automatically reproduced. I think it was Kris Köhntopp who once said something like: „If you have to manually login to your server to fix a problem, you did not automate enough tasks“. I think a common term I heard in the last years is „Infrastructure as Code“ regarding that topic, I already used Puppet and Chef in other setups and started using Ansible recently. I really like Ansible as it is really easy and fast to get started and I don’t need to setup a Puppetmaster or Chef-Server. I know that there is also chef-solo et al, but using a lightweight Ansible client I always had the feeling that I was moving faster. Writing everything in YAML felt a bit weird in the beginning but after a while I really enjoyed it.

#### Helps us regarding:

- high level of automation
- easy setup for our friends from other Unconference teams
- easy deployments

### App setup

After some discussion we decided on a quite common architecture:

```
                              +-----------+
                              |           |      +--------+
                      +------->  App      |      |        |
+----------------+    |       |           +------>        |
|                |    |       +-----------+      |        |
|  Load Balancer +----+                          |   DB   |
|                +----+       +-----------+      |        |
+----------------+    |       |           +------>        |
                      +------->  App      |      |        |
                              |           |      +--------+
                              +-----------+
```

We are currently running with two application servers but as they are stateless we could add more easily. This setup allows us to scale horizontally by adding more servers. As Hapi (and most other Node.js frameworks) is not using the [cluster module of Node.js](http://nodejs.org/api/cluster.html) for using multiple CPUs the cheap single-CPU boxes of DigitalOcean are perfect for us ($5/month each). Our LB is also running on one of them.

We are running plain Ubuntu as we (currently [Robin](https://github.com/robin-drexler) and me are developing the app) are used to Debian systems - Ubuntu is a nice choice for us as it provides easier access to newer packages. For Node.js we are using the famous Ubuntu PPA from Chris Lea.

We decided against hosting CouchDB on our own and decided for Cloudant, who are hosting clustered CouchDBs as a service. If we ever decide to host CouchDB on our own we can make use of the replication feature that I already mentioned to move our data away.

When we started our application we met 1-2x / week. Initially we had to do a lot of grunt work. We spent some time on the automatic bootstrap of a test-system with a new database for local development and selenium tests. When you kick off a dev system using [npm run dev](https://github.com/jsunconf/contriboot/blob/master/package.json#L11) we fill a [development database with fixtures](https://github.com/jsunconf/contriboot/blob/master/bootstrap.js#L13) and push all of our views to a local [CouchDB](https://github.com/jsunconf/contriboot/blob/master/bootstrap.js#L62). After that we compile our less to CSS and watch for any changes. If there are any changes, we [automatically regenerate the less/restart the server](https://github.com/jsunconf/contriboot/blob/master/Gulpfile.js). The bootstrap-code, including the selenium runner is the oldest part of the system and needs a refactoring soon.

While it cost some hours to get bootstrapped it definitely paid off in the end! We are able to deploy quite confident that we don’t break anything because we missed some edge cases we did not click through manually each time we make a (temporary) change.

When we fix a bug we add a test case to avoid any regressions in the future. After we had some boring hours when we started, we are now quite fast at implementing all kinds of serious changes, like [switching the DB client](https://github.com/jsunconf/contriboot/commit/81c89dcdbaab2aeae15fe69b46ab145b15da37ad) and [major framework version upgrades](https://github.com/jsunconf/contriboot/commit/25eb5abaf5082a92d479b3e6f7b92aeaf392a71d) - these tasks were completely finished in around 1hr instead of 3-4hrs or more. We are doing them after our „real“ daily job and they did not result in any downtimes as the tests are catching any bugs early in the process!

When we started, we created our Ansible playbooks for a [Vagrant Box](https://github.com/jsunconf/contriboot/blob/master/provisioning/dev-setup.yml), the initial idea was to test changes there before they go into production.

It turned out that provisioning and managing our servers was so easy and fast that it got common practice for us to just remove one app-server from the loadbalancer configuration, deploy our changes to the isolated server and then test everything on that server in production after our local tests were successful and the CI was green.

When everything was tested successful, we added the test-server to the configuration again and finally deployed the change to all machines.

We have are several different playbooks in our repository, to setup a fresh application server we are basically using [app-server.yml](https://github.com/jsunconf/contriboot/blob/master/provisioning/app-server.yml) - we get a fresh app-server with everything configured to our needs in around 3-4 minutes. If we mess it up, we throw it away. As already mentioned, we get a fresh new one where everything is configured for production usage after a few minutes.

Code deployments are done by [deploy-app-server.yml](https://github.com/jsunconf/contriboot/blob/master/provisioning/deploy-app-server.yml) - we are fetching the code from GitHub and reload the server. We are currently using this playbook the most  time I think.

The [loadbalancer](https://github.com/jsunconf/contriboot/blob/master/provisioning/loadbalancer.yml) is the last major part of our Ansible playbook collection. Depending on the apps in our inventory [we are adding app-servers to the configuration](https://github.com/jsunconf/contriboot/blob/master/provisioning/templates/haproxy.cfg.j2#L35).

By just changing our Ansible inventory it is quite easy for us to remove and add servers to the loadbalancer and/or to deploy just to a single server.

As getting a new box is so fast and easy, we sometimes just throw them away and provision a fresh new one.


#### Helps us regarding:

- high availability and possibility to fail-over
- high level of automation
- easy setup for our friends from other Unconference teams
- easy deployments
- easy testing of deployments
- easy backups
- no vendor-lock-in where it takes hours and hours to switch the platform
- cheap operation, we don’t want to pay > $100/month for hosting & services

## Conclusion

So far we are quite happy using Ansible, Node.js/Hapi and CouchDB. Our application is running at [contriboot.jsunconf.eu](http://contriboot.jsunconf.eu). We will add some new features in the future and refactor some of the older parts.

I would be really happy to chat with you about orchestration and Node.js in production, I am on twitter as [@robinson_k](https://twitter.com/robinson_k) - or let’s chat in person at [JS Unconf](http://jsunconf.eu)!
