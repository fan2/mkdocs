---
title: git reset撤销提交
authors:
  - xman
date:
    created: 2018-09-05T11:00:00
    updated: 2020-11-22T11:22:00
categories:
    - git
tags:
    - git
    - reset
comments: true
---

本文梳理了解决 git 冲突的基本操作方法。

<!-- more -->

```
# man git
       git-reset(1)
           Reset current HEAD to the specified state.
```

[git撤销修改各种情况](https://cloud.tencent.com/developer/article/1028781)  

`HEAD` 表示当前版本，也就是最新的提交。  
`HEAD^` 表示上一个版本，`HEAD^^` 表示上上一个版本。  

往上100个版本写成 100 个 `^` 比较麻烦，一般简写成 `HEAD~100`。  
`HEAD~1` 相当于 `HEAD^`，`HEAD~2` 相当于 `HEAD^^`。  

## [git不同阶段撤回](http://einverne.github.io/post/2017/12/git-reset.html)

[Git的4个阶段的撤销更改](https://www.fengerzh.com/git-reset/)

### 撤销工作区修改

本地工作区中修改了文件的内容，尚未使用 `git add` 将修改提交到暂存区：

- `git checkout -- <file>` 撤销某文件的修改；  
- `git checkout .`：撤销所有本地的修改；  

    > `git add .` 对应 `git checkout .`

### 撤销暂存区修改

如果已经执行了 `git add`，意味着暂存区中已经有了修改，但是需要丢弃暂存区的修改，那么可以执行 `git reset`。

- 对于已经被 Git 追踪的文件，可以使用 **`git reset <file>`** 来单独将文件从暂存区中丢弃，将修改放回到工作区。  

    > `git reset <file>` 默认携带 `--soft` 选项。

- 对于从来没有被 Git 追踪过，是新增文件（new file），则需要使用 **`git reset HEAD <file>`** 来将新文件从暂存区中取出放回到工作区。  

如果确定暂存区中的修改完全不需要，则可以使用 **`git reset --hard`**，不会将暂存内容回放到工作区，直接丢弃。

> 由于暂存区中所有修改都会被丢弃，修改的内容也不会被重新放回工作区，因此请谨慎使用 `–-hard` 命令选项！

### 撤销本地提交

若已经执行 git add 和 git commit，修改已经提交进入了本地仓库。如何撤销最近一次或多次的本地提交？

```
git reset --hard origin/master
```

同样还是 `git reset` 命令，但是多了 `origin/master`：**origin** 为远端仓库的默认名字，可能也有其他的名字（如 `upstream`），`origin/master` 表示远程仓库。

既然本地的修改已经不再需要，那么从远端将代码 **拉回覆盖还原** 即可。

---

不过不建议直接使用 `git reset --hard origin/master` 这样强大的命令。如果想要撤销本地最近的一次提交，建议使用

```
git reset --soft HEAD~1
```

这行命令表示将最近一次提交 `HEAD~1` 从本地仓库 **回退** 到暂存区。

> `--soft` 不会丢弃修改，而是将修改放回暂存区，后续可继续修改或者丢弃。

如果要撤销本地最近的两次修改，则改成 `HEAD~2` 即可，以此类推。

> **注意**：已经提交到远端的提交，不要使用 `git reset` 来修改，对于多人协作项目会给其他人带来很多不必要的麻烦。

### 撤销远端仓库修改

对于已经执行 push 推送到服务器的修改，原则上是不建议撤销的。不过 Git 给了使用者充分的自由，在明确自己在做什么的情况下，可以执行 **`git push -f`** 使用 `-f`(`--force`) 选项来将本地仓库强制 push 覆盖远端仓库。

```
// 先恢复本地仓库
git reset --hard HEAD^
// 再强制push到远程仓库
git push -f
```

对于个人项目使用这样的方式，并没有太大问题。但是对于多人协作项目，如果你强行改变了远端仓库，别人再使用的时候就会出现很多问题，所以使用 `git push -f` 时一定要想清楚自己在做什么事情。

## references

[Git各种错误操作撤销的方法](https://zhuanlan.zhihu.com/p/28130254)  

[5.2 代码回滚：Reset、Checkout、Revert 的选择](https://github.com/geeeeeeeeek/git-recipes/wiki/5.2-%E4%BB%A3%E7%A0%81%E5%9B%9E%E6%BB%9A%EF%BC%9AReset%E3%80%81Checkout%E3%80%81Revert-%E7%9A%84%E9%80%89%E6%8B%A9)
