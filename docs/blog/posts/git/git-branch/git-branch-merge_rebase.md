---
title: git merge & rebase
authors:
  - xman
date:
    created: 2018-09-06T12:00:00
    updated: 2019-06-02T11:47:00
categories:
    - git
tags:
    - git
    - branch
comments: true
---

本文梳理了 merge 合并分支和 rebase 基线的基本操作。

<!-- more -->

[3.2 Git Branching - Basic Branching and Merging](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging)

[git rebase & merge 将其他分支的修改合并到当前分支](https://blog.csdn.net/GW569453350game/article/details/52536928)

## merge

[Git 分支 - 分支的新建与合并](https://git-scm.com/book/zh/v1/Git-%E5%88%86%E6%94%AF-%E5%88%86%E6%94%AF%E7%9A%84%E6%96%B0%E5%BB%BA%E4%B8%8E%E5%90%88%E5%B9%B6)  

[分支的合并概述](https://backlog.com/git-tutorial/cn/stepup/stepup1_4.html)  

fetch完之后，可以将远程分支cache master分支merge合并到当前分支上  

```Shell
$ git merge origin/master
```

## rebase

[用 rebase 合并](https://backlog.com/git-tutorial/cn/stepup/stepup2_8.html)  
[rebase 代替合并](https://www.git-tower.com/learn/git/ebook/cn/command-line/advanced-topics/rebase)  

[代码合并：Merge、Rebase 的选择](https://github.com/geeeeeeeeek/git-recipes/wiki/5.1-%E4%BB%A3%E7%A0%81%E5%90%88%E5%B9%B6%EF%BC%9AMerge%E3%80%81Rebase-%E7%9A%84%E9%80%89%E6%8B%A9)  

fetch 完之后，可以将远程分支 cache master  分支 rebase 合并到当前分支上  

```Shell
$ git rebase origin/master
```

[使用 git rebase 避免无谓的 merge](https://ihower.tw/blog/archives/3843)

1. 把本地 repo. 從上次 pull 之後的變更暫存起來  
2. 回復到上次 pull 時的情況  
3. 套用遠端的變更  
4. 最後再套用剛暫存下來的本地變更  

## git pull -r

[聊下 git pull --rebase](https://www.cnblogs.com/wangiqngpei557/p/6056624.html)  
[对比 git pull 和 git pull --rebase](https://www.cnblogs.com/kevingrace/p/5896706.html)  

[git fetch, git pull, git pull -rebase区别](https://blog.csdn.net/duomengwuyou/article/details/51199597)  

如果认为 origin 是主要的，那么就加 `-r` | `--rebase`，用变基代替合并，最大程度的保证 origin 代码不被你错误修改。

## 综合案例

[git 团队合作， git 分支开发 、合并、冲突 实例](https://github.com/woai30231/webDevDetails/tree/master/13)  
[git分支开发，分支(feature)同步主干(master)代码，以及最终分支合并到主干的操作流程](https://blog.csdn.net/luolianxi/article/details/78281528)  
