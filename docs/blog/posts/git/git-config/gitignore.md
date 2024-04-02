---
title: gitignore配置忽略文件
authors:
  - xman
date:
    created: 2018-09-05T08:00:00
    updated: 2019-06-02T22:56:00
categories:
    - git
tags:
    - git
    - config
comments: true
---

本文简单记录了 `.gitignore` 忽略文件配置和一些工程配置案例。

<!-- more -->

[.gitignore 详解](https://www.cnblogs.com/ShaYeBlog/p/5355951.html)  
[git 忽略规则 .gitignore 梳理](https://www.cnblogs.com/kevingrace/p/5690241.html)  

一定要养成在项目开始就创建配置 `.gitignore` 文件的习惯，否则一旦push，处理起来会非常麻烦。
如果不慎在创建 `.gitignore` 文件之前就push了项目，那么即使后续在 `.gitignore` 文件中写入新的过滤规则，这些规则也不会起作用，Git仍然会对所有文件进行版本管理。出现这种问题的原因就是 git 已经开始管理这些文件了，所以无法再通过过滤规则过滤它们。

## [git help ignore](https://git-scm.com/docs/gitignore)

```
GITIGNORE(5)                                Git Manual                                GITIGNORE(5)



NAME
       gitignore - Specifies intentionally untracked files to ignore

SYNOPSIS
       $XDG_CONFIG_HOME/git/ignore, $GIT_DIR/info/exclude, .gitignore

DESCRIPTION
       A gitignore file specifies intentionally untracked files that Git should ignore. Files
       already tracked by Git are not affected; see the NOTES below for details.

       Each line in a gitignore file specifies a pattern. When deciding whether to ignore a path,
       Git normally checks gitignore patterns from multiple sources, with the following order of
       precedence, from highest to lowest (within one level of precedence, the last matching
       pattern decides the outcome):
```

- 忽略具体文件：`.DS_Store`、`build.log`、`**/*.xcuserdatad/**`；  
- 忽略类型文件：`*.ipa`、`*.dSYM`、`*.log`、`*.obj`、`*.idb`、`*.pdb`；  
- 忽略文件夹：`build/`、`DerivedData/`、`**/xcshareddata/`、`**/xcuserdata/**`；  

### glob pattern

1. 一个星号 `*` 通配多个字符，即匹配多个任意字符。
2. 方括号 `[]` 包含单个字符的匹配列表，即匹配任何一个列在方括号中的字符。

    > `*.[oa]` 表示忽略后缀名为 `.o` 和 `.a` 的文件。

3. 两个星号 `**` 表示匹配任意中间目录。  
4. 叹号 `!` 表示不忽略(跟踪)匹配到的文件或目录，即要忽略指定模式以外的文件或目录。

## Xcode

以下为典型的 Xcode 项目需要忽略文件的 `.gitignore` 配置：

```
## macOS folder attributes
.DS_Store

## Xcode Build generated
build/
DerivedData/
build.log

## Obj-C/Swift specific
*.hmap
*.ipa
*.dSYM
*.dSYM.zip

## Various settings
*.pbxuser
!default.pbxuser
**/xcuserdata/**
**/*.xcuserdatad/**
**/xcshareddata/

*.moved-aside
*.xcuserstate

## Playgrounds
timeline.xctimeline
playground.xcworkspace

## Pods
Podfile.lock
Pods
```

## [Mars](https://github.com/Tencent/mars)

以下摘自 Mars 开源项目的 `.gitignore` 配置：

```
*.iml
.gradle/
/mars/local.properties
.idea/
.DS_Store
build/
/mars/captures
obj/

*.swp
*.pyc
xcuserdata
xcshareddata

/mars/comm/verinfo.h
/mars/libraries/*/
/mars/*/libs/
!/mars/boost/libs/

/mars/comm/win32proj/Debug/*.obj
/mars/comm/win32proj/Debug/*.idb
/mars/comm/win32proj/Debug/*.log
/mars/comm/win32proj/Debug/*.pdb
```
