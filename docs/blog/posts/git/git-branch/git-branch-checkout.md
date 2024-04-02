---
title: git检出分支代码
authors:
  - xman
date:
    created: 2018-09-06T11:00:00
    updated: 2020-11-22T11:16:00
categories:
    - git
tags:
    - git
    - branch
comments: true
---

如何基于指定版本创建分支，下载指定版本的文件？

<!-- more -->

## 基于指定版本创建分支

[Branch from a previous commit using Git](https://stackoverflow.com/questions/2816715/branch-from-a-previous-commit-using-git)

```
git checkout -b branchname <sha1-of-commit or HEAD~3>
```

[git下载指定版本的代码](https://blog.csdn.net/M_Eve/article/details/84327219)

例如，我们想将截至某次提交 7bf1f57f 的旧版本库 checkout 到本地分支 `local/FATVVideoPlayer` 以供翻阅，可以这样做：

```
# 切换到指定的版本号
git checkout 7bf1f57f
# 再新建分支
git checkout -b local/FATVVideoPlayer
```

也可通过这种方式：

```
git branch local/FATVVideoPlayer 7bf1f57f
git checkout local/FATVVideoPlayer
```

假如想将某次提交 66932f0c 之前的旧版本库 checkout 到本地分支 `local/before_iconv` 以供翻阅，可以这样做：

```
git checkout -b local/before_iconv 66932f0c^
```

## 下载指定版本的文件

[git-checkout older revision of a file under a new name](https://stackoverflow.com/questions/888414/git-checkout-older-revision-of-a-file-under-a-new-name)

检测 faner 提交的3次修改 .code.yml 记录：

```
$ git log -3 --author=faner --no-merges -- .code.yml
```

查看某次提交 `0e667edc` 的变动：

```
$ git diff 0e667edc^ 0e667edc -- .code.yml
$ git difftool 0e667edc^ 0e667edc -- .code.yml
```

checkout 这次提交前的文件到本地，可以这样：

```
$ git show 0e667edc^:.code.yml > ~/Downloads/old.code.yml
```

或者用更底层的 `cat-file` 命令：

```
$ git cat-file blob 0e667edc^:.code.yml > old.code.yml
```
