---
title: git stash暂存代码
authors:
  - xman
date:
    created: 2018-09-05T10:00:00
    updated: 2019-06-02T11:35:00
categories:
    - git
tags:
    - git
    - stash
comments: true
---

本文记录了使用 git stash 命令暂存代码变更的基本操作方法。

<!-- more -->

## [git help stash](https://git-scm.com/docs/git-stash)

[7.3 Git Tools - Stashing and Cleaning](https://git-scm.com/book/en/v2/Git-Tools-Stashing-and-Cleaning)

```
# man git
       git-stash(1)
           Stash the changes in a dirty working directory away.

# git stash -h

usage: git stash list [<options>]
   or: git stash show [<stash>]
   or: git stash drop [-q|--quiet] [<stash>]
   or: git stash ( pop | apply ) [--index] [-q|--quiet] [<stash>]
   or: git stash branch <branchname> [<stash>]
   or: git stash save [--patch] [-k|--[no-]keep-index] [-q|--quiet]
		      [-u|--include-untracked] [-a|--all] [<message>]
   or: git stash [push [--patch] [-k|--[no-]keep-index] [-q|--quiet]
		       [-u|--include-untracked] [-a|--all] [-m <message>]
		       [-- <pathspec>...]]
   or: git stash clear
```

执行 `git help stash` 或 `man git-stash` 可查看 GIT-STASH 的 man-page。

git-stash - Stash the changes in a dirty working directory away

- `Save` your local modifications to a new stash entry;  
- `roll` them *back* to HEAD (in the working tree and in the index).  

## [git-stash commands](https://www.oschina.net/translate/useful-tricks-you-might-not-know-about-git-stash)

1. `git stash (push)`: **Save** your local modifications to a new stash entry and roll them back to HEAD  
2. `git stash list`: **List** the stash entries that you currently have.  
3. `git stash show`: **Show** the *changes* recorded in the stash entry as a diff between the stashed contents and the commit back when the stash entry was first created.  

    > 默认相当于 `--stat` 只显示 diff 概要，可以指定 `-p` 输出详细差异内容。

4. `git stash drop`: **Remove** a single stash entry from the list of stash entries.  
5. `git stash apply`: Like pop, but do **not** remove the state from the stash list.  
6. `git stash pop`: apply+drop, **Remove** a single stashed state from the stash list and **apply** it on top of the current working tree state.  
7. `git stash clear`: **Remove** *all* the stash entries.  

**说明**：

`git stash` 默认是 push 操作，可以指定 `-u | --include-untracked`。  
`git stash save` 已经 deprecated，使用 **`git stash push -m`** 替代。  

### push(save)

执行 `git stash [push [-m <message>]]` 将当前分支的改动贮藏到 stash 堆栈。

暂存的改动范畴包括：

1. 包括 not staged 的待 add 暂存 or checkout -- 还原的文件；  
2. 包括 staged 的待 commit 提交 or reset HEAD 进行 unstage 的文件；  
3. 不包括 untracked 未跟踪的文件；  
4. 不包括 ignored 忽略的文件；  

**`[-m <message>]`** 选项指定本次 stash 的信息，以便后面在 list/show 查看堆栈时识别。  

#### include

- `[-u|--include-untracked]`：包含 untracked 的文件。  
- `[-a|--all]`：包含 untracked 和 ignored 的文件。  

#### patch

如果增加 `[-p|--patch]` 选项，将以交互模式询问逐文件逐个改动区块（each hunk）的 stash 策略。

```
Stash this hunk [y,n,q,a,d,j,J,g,/,e,?]?
```

字母选项的意义具体参考 `git help add` 的 `INTERACTIVE MODE` patch 部分。

```
y - stage this hunk
n - do not stage this hunk
q - quit; do not stage this hunk or any of the remaining ones
a - stage this hunk and all later hunks in the file
d - do not stage this hunk or any of the later hunks in the file
g - select a hunk to go to
/ - search for a hunk matching the given regex
j - leave this hunk undecided, see next undecided hunk
J - leave this hunk undecided, see next hunk
k - leave this hunk undecided, see previous undecided hunk
K - leave this hunk undecided, see previous hunk
s - split the current hunk into smaller hunks
e - manually edit the current hunk
? - print help
```

- `y/n`：为 yes/no；  
- `q`：quit（include any of remaining ones）；  
- `a`：stage all（include all later hunks）；  
- `d`：do not stage（include any of later hunks）；  
- `g`：列举当前文件所有的 hunks，并提示选择一个要跳转的 hunk 索引编号；  
- `/`：正则匹配一个 hunk。——基于什么匹配？  
- `j/k`：在未决 hunk 之间跳转（next/previous）；  
- `e`：手动编辑当前 hunk；  

**注意**：q(uit) 为放弃所有；a/d 中是 stage/unstage 当前及之后所有。  

#### path

`[-- <pathspec>...]]`：double hyphen -- 符号之后可以续接要 stash 的指定文件（的相对路径）。

When pathspec is given to git stash push, the new stash entry records the modified states *only* for the files that match the pathspec.

> 如果包含 untracked 的文件，记得先添加 `-u` 选项。

关于 pathspec 指定语法（syntax）及匹配规则（Fileglobs），可参考 `git-add` 和 `gitglossary` 相关议题。

### show

#### list

执行 `git stash list` 命令，可以列举当前 stash 堆栈记录。  
也可执行 `git stash list | cat` 将结果重定向调用 cat 全部打印出来。  

git stash list 列表中每一次 stash 记录的样式为：

```
stash@{n}: On <branchname>: <message>
```

n 为从近到远的 stash 记录栈索引，最新 push 压入栈顶的索引为 0（`stash@{0}`）。

引用 stash 版本号格式：`stash@{<revision>}`

- `stash@{0}` is the most recently created stash,  
- `stash@{1}` is the one before it,  
- `stash@{2.hours.ago}` is also possible.  

Stashes may also be referenced by specifying just the stash index
(e.g. the integer `n` is equivalent to `stash@{n}`).

#### specific

`git stash show [<stash>]`

> `[<stash>]` 为可选参数，当不指定时 `git stash show` 默认显示栈顶记录信息。

查看栈顶最近一次 push-save 的 stash 记录：`git stash show stash@{0}`，也可简写为 `git stash show 0`。

`git stash show 1` 显示索引为1的 stash 改动概要信息。  

### apply/pop

`git stash ( pop | apply ) [--index] [-q|--quiet] [<stash>]`

### branch with stash

`git stash branch <branchname> [<stash>]`  

Creates and checks out a new branch named `<branchname>` starting from the commit at which the `<stash>` was originally created, applies the changes recorded in `<stash>` to the new working tree and index.

具体应用场景分析，参考《[git stash 详解](https://blog.csdn.net/stone_yw/article/details/80795669)》和《[git-stash 用法小结](https://www.cnblogs.com/tocy/p/git-stash-reference.html)》。

## git stash 用法详解

[git stash 用法](https://www.cnblogs.com/yanghaizhou/p/5269899.html)  
[git stash 作用及理解](https://www.jianshu.com/p/14afc9916dcb)  
[git stash 详解](https://blog.csdn.net/stone_yw/article/details/80795669)  
[git-stash 用法小结](https://www.cnblogs.com/tocy/p/git-stash-reference.html)  

## [使用 git stash 解决 git pull 时的冲突](https://wenku.baidu.com/view/6a25f40653d380eb6294dd88d0d233d4b14e3f35.html###)

git stash 可用来暂存当前正在进行的工作，比如想 pull 最新代码，又不想加新 commit；
或者另外一种情况，为了 fix 一个紧急的 bug，先 `stash` 使返回到自己上一个 commit，改完 bug 之后再 `stash pop`，继续原来的工作。

[使用 git stash 让突如其来的分支切换更加美好](https://blog.csdn.net/qq_32452623/article/details/76100140)  

**基础流程**：

```
$git stash
$do some work
$git stash pop
```

在使用 `git pull` 代码时，经常会碰到有冲突的情况，提示如下信息：

```
error: Your local changes to 'c/environ.c' would be overwritten by merge.
Aborting.Please, commit your changes or stash them before you can merge.
```

意思是说更新下来的内容和本地修改的内容有冲突，先提交你的改变或者先将本地修改暂时存储起来。
处理的方式非常简单，使用 `git stash` 命令进行处理，分成以下几个步骤进行处理。

1. 执行 **`git stash`** 将本地修改暂时存储起来；执行 `git stash list` 可以看到保存的信息，其中 `stash@{0}` 就是刚才保存的标记。  
2. 暂存了本地修改之后，就可以执行 **`git pull`** 了。   
3. 还原暂存的内容 `git stash pop stash@{0}`  
