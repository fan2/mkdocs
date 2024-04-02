---
title: git生成补丁和应用补丁
authors:
  - xman
date:
    created: 2018-09-05T10:20:00
    updated: 2020-11-22T11:17:00
categories:
    - git
tags:
    - git
    - diff
    - patch
comments: true
---

本文记录了使用 git diff 命令生成 patch 和 git appy 应用 patch 的基本操作方法。

<!-- more -->

## git diff 生成 patch

[git 生成patch和使用patch](https://blog.csdn.net/maybe_windleave/article/details/8703778)  

```Shell
git diff > patch
git diff --staged > patch
```

```Shell
git diff -- Classes > ~/bugfix/Classes.patch
git diff --staged -- Classes > ~/bugfix/Classes.patch

git stash show stash@{1} --patch > patch
```

## git appy 应用 patch

检查patch文件：

```Shell
$ git apply --stat ~/bugfix/FAViewController.patch
```

查看是否能应用成功：

```Shell
$ git apply --check ~/bugfix/FAViewController.patch
```

应用 patch：

```Shell
$ git am -s < ~/bugfix/FAViewController.patch
```

中途放弃：`git am --abort`

## refs

[git format-patch 生成指定commit的补丁](https://blog.csdn.net/sinat_29891353/article/details/80803103)  
[使用 git format-patch 生成patch和应用patch](https://www.jianshu.com/p/814fb6606734)  

[如何使用 git 生成patch 和打入patch](https://blog.csdn.net/liuhaomatou/article/details/54410361)  
[**Git 打补丁-- patch 和 diff 的使用**](https://juejin.im/post/5b5851976fb9a04f844ad0f4)  

