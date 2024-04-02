---
title: github同步fork上游
authors:
  - xman
date:
    created: 2018-09-03T08:00:00
categories:
    - git
tags:
    - github
    - fork
    - sync
comments: true
---

1. [Configuring a remote for a fork](https://help.github.com/articles/configuring-a-remote-for-a-fork/)  
2. [Syncing a fork](https://help.github.com/articles/syncing-a-fork/)  

<!-- more -->

## add upstream

```shell
~/Projects/git/framework/mars|master⚡
⇒  git remote -v
origin	git@github.com:fan2/mars.git (fetch)
origin	git@github.com:fan2/mars.git (push)

~/Projects/git/framework/mars|master⚡
⇒  git remote add upstream https://github.com/Tencent/mars

~/Projects/git/framework/mars|master⚡
⇒  git remote -v
origin	git@github.com:fan2/mars.git (fetch)
origin	git@github.com:fan2/mars.git (push)
upstream	https://github.com/Tencent/mars (fetch)
upstream	https://github.com/Tencent/mars (push)
```

> 执行 `git remote rm upstream` 可解除 upstream。

## fetch upstream

```shell
~/Projects/git/framework/mars|master⚡
⇒  git fetch upstream
remote: Counting objects: 149, done.
remote: Compressing objects: 100% (19/19), done.
remote: Total 149 (delta 103), reused 124 (delta 103), pack-reused 17
```

## merge upstream/branch

```shell
~/Projects/git/framework/mars|master⚡
⇒  git merge upstream/master
Merge made by the 'recursive' strategy.
 README.md                                                | 29 +++++++++++++++++++++++------
 mars/comm/dns/dns.cc                                     | 39 +++++++++++++++++++++------------------
 mars/comm/dns/dns.h                                      |  5 +++++
 mars/comm/network/getgateway.c                           |  2 +-
 mars/comm/socket/local_ipstack.cc                        |  4 ++--
 mars/comm/socket/socket_address.cc                       |  6 +++---
 mars/comm/socket/socket_address.h                        |  2 +-
 mars/comm/verinfo.h                                      |  8 ++++----
 mars/libraries/build_android.py                          | 10 ++++++++--
 mars/libraries/mars_android_sdk/gradle.properties        |  2 +-
 mars/libraries/mars_xlog_sdk/gradle.properties           |  2 +-
 mars/log/jni/Java2C_Xlog.cc                              |  3 ++-
 mars/sdt/src/checkimpl/dnsquery.cc                       |  2 +-
 samples/android/marsSampleChat/build.gradle              |  4 ++--
 samples/android/marsSampleChat/wrapper/gradle.properties |  2 +-
 samples/android/xlogSample/build.gradle                  |  2 +-
 16 files changed, 77 insertions(+), 45 deletions(-)
 mode change 100755 => 100644 mars/libraries/build_android.py
```

## merge upstream of libetpan

![merge_from_upstream_to_fork(libetpan)](../images/merge_from_upstream_to_fork(libetpan).png)
