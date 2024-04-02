---
title: git显示和查找分支
authors:
  - xman
date:
    created: 2018-09-06T11:40:00
    updated: 2019-06-02T11:43:00
categories:
    - git
tags:
    - git
    - branch
comments: true
---

本文梳理了如何查看和查找本地分支。

<!-- more -->

## [git show-branch](https://git-scm.com/docs/git-show-branch)

```
GIT-SHOW-BRANCH(1)                          Git Manual                          GIT-SHOW-BRANCH(1)



NAME
       git-show-branch - Show branches and their commits

SYNOPSIS
       git show-branch [-a|--all] [-r|--remotes] [--topo-order | --date-order]
                       [--current] [--color[=<when>] | --no-color] [--sparse]
                       [--more=<n> | --list | --independent | --merge-base]
                       [--no-name | --sha1-name] [--topics]
                       [(<rev> | <glob>)...]
       git show-branch (-g|--reflog)[=<n>[,<base>]] [--list] [<ref>]
```

## [git branch](https://git-scm.com/docs/git-branch)

```
GIT-BRANCH(1)                               Git Manual                               GIT-BRANCH(1)



NAME
       git-branch - List, create, or delete branches

SYNOPSIS
       git branch [--color[=<when>] | --no-color] [-r | -a]
               [--list] [-v [--abbrev=<length> | --no-abbrev]]
               [--column[=<options>] | --no-column] [--sort=<key>]
               [(--merged | --no-merged) [<commit>]]
               [--contains [<commit]] [--no-contains [<commit>]]
               [--points-at <object>] [--format=<format>] [<pattern>...]

       git branch --edit-description [<branchname>]

```

### description

执行 `vim .git/description` 可以查看当前仓库的描述：

```
 Unnamed repository; edit this file 'description' to name the repository.
```

可以执行 `git branch --edit-description [<branchname>]` 对指定（当前）branch 的描述信息进行编辑。
等效命令为 `git config branch.<branch name>.description`。

例如为 testEmptyApplication 分支添加描述，然后执行 `git config -l` 可以看到配置中有如下行：

```
branch.testEmptyApplication.description=test branch description
```

---

The `.git/description` file is only used in the Git-Web program.

- [Branch descriptions in Git](https://stackoverflow.com/questions/2108405/branch-descriptions-in-git)  
- [Changing repository description in git](https://stackoverflow.com/questions/15406274/changing-repository-description-in-git)  

### list branches

If `--list` is given, or if there are no non-option arguments, existing branches are listed;
the current branch will be highlighted with an asterisk.  

Option `-r` causes the remote-tracking branches to be listed, and  
option `-a` shows both local and remote branches.  

`git branch` 等效于 `git branch --list`，列举本地 checkout 出来的仓库，当前仓库会以星号 `*` 标记。  
`git branch -r` 列举远端仓库 remotes/origin/ 下的所有分支。  
`git branch -a` 列举本地（`--list`） + 远端（`-r`）的所有分支。  

[git 获取当前分支名](https://blog.csdn.net/liuqi332922337/article/details/79578849)

```
git symbolic-ref --short -q HEAD
```

[git查看当前分支所属](https://blog.csdn.net/wsclinux/article/details/54425458)

1. git config -l  
2. git branch -v  

#### pattern

`git branch --list '*NestFile*'`：本地名称中包含 NestFile 的分支；  
`git branch --list '*Send*Album*'`：本地名称中包含 Send 和 Album 的分支；  

### Find Parent Branch

[findParent.sh](https://gist.github.com/dkirrane/47c6856d060e19108315)  
[who_is_my_mummy.sh](https://gist.github.com/joechrysler/6073741)  

[find the parent branch](https://github.community/t5/How-to-use-Git-and-GitHub/Is-there-a-way-to-find-the-parent-branch-from-which-branch-HEAD/td-p/5928)  
[Git show parent branch](https://blog.liplex.de/git-show-parent-branch/)  

[Find the parent branch of a Git branch](https://code.i-harness.com/en/q/303c74) @[stackoverflow](https://stackoverflow.com/questions/3161204/find-the-parent-branch-of-a-git-branch)  

How to find the nearest parent of a Git branch?

```
git log --decorate \
  | grep 'commit' \
  | grep 'origin/' \
  | head -n 2 \
  | tail -n 1 \
  | awk '{ print $2 }' \
  | tr -d "\n"
```

针对以上 commit-sha1 再执行 git log -1 查看其 log。

[Git First-Parent--Have your messy history and eat it too](http://www.davidchudzicki.com/posts/first-parent/)  
