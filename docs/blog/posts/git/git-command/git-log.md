---
title: git log查看日志
authors:
  - xman
date:
    created: 2018-09-05T09:30:00
    updated: 2019-06-02T11:35:00
categories:
    - git
tags:
    - git
    - log
comments: true
---

本文记录了使用 git log 命令查看代码提交日志的基本操作方法。

<!-- more -->

## [git help log](https://git-scm.com/docs/git-log)

执行 `git log -h` 查看概要 usage：

```Shell
$ git log -h
usage: git log [<options>] [<revision-range>] [[--] <path>...]
   or: git show [<options>] <object>...

    -q, --quiet           suppress diff output
    --source              show source
    --use-mailmap         Use mail map file
    --decorate-refs <pattern>
                          only decorate refs that match <pattern>
    --decorate-refs-exclude <pattern>
                          do not decorate refs that match <pattern>
    --decorate[=...]      decorate options
    -L <n,m:file>         Process line range n,m in file, counting from 1
```

执行 `git help log` 查看详细 man-page：

```Shell
GIT-LOG(1)                                  Git Manual                                  GIT-LOG(1)



NAME
       git-log - Show commit logs

SYNOPSIS
       git log [<options>] [<revision range>] [[--] <path>...]


DESCRIPTION
       Shows the commit logs.

       The command takes options applicable to the git rev-list command to control what is shown
       and how, and options applicable to the git diff-* commands to control how the changes each
       commit introduces are shown.
```

[git log cheatsheet](https://devhints.io/git-log)

---

[What are commit-ish and tree-ish in Git?](https://stackoverflow.com/questions/23303549/what-are-commit-ish-and-tree-ish-in-git)

`<sha1>`：  
`<refname>`：  
`<refname>@{<date>}`：master@{yesterday}, HEAD@{5 minutes ago}  
`<refname>@{upstream}` / `master@{u}`：  

## [git log 详细使用参数](https://blog.csdn.net/helloxiaozhe/article/details/80563427)

选项 | 说明
----|---------
`--graph` | 以 ASCII 字符图形显示分支提交合并历史。
`--abbrev-commit` | 仅显示 SHA-1 的前几个字符，而非所有的 40 个字符
`--relative-date` | 使用较短的相对时间显示，例如 “2 weeks ago”

### gitrevisions

执行 `git help revisions` 或 `man gitrevisions` 查看 gitrevisions 议题相关手册。

```Shell
GITREVISIONS(7)                                                           Git Manual                                                          GITREVISIONS(7)



NAME
       gitrevisions - Specifying revisions and ranges for Git

SYNOPSIS
       gitrevisions
```

```
       <revision range>
           Show only commits in the specified revision range. When no <revision
           range> is specified, it defaults to HEAD (i.e. the whole history
           leading to the current commit).  origin..HEAD specifies all the
           commits reachable from the current commit (i.e.  HEAD), but not from
           origin. For a complete list of ways to spell <revision range>, see the
           Specifying Ranges section of gitrevisions(7).
```

`git log <>`

[ORIG_HEAD, FETCH_HEAD, MERGE_HEAD etc](https://stackoverflow.com/questions/17595524/orig-head-fetch-head-merge-head-etc)  

### limit

选项 | 说明
----|---------
**`-(n)`** | 仅显示最近的 n 条提交: git log -n 2 或 git log -2  
`--skip` | 指定跳过前几条日志

### date

选项 | 说明
----|---------
`--since`, `--after` | 仅显示指定时间之后的提交  
`--until`, `--before` | 仅显示指定时间之前的提交  

```Shell
       --since=<date>, --after=<date>
           Show commits more recent than a specific date.

       --until=<date>, --before=<date>
           Show commits older than a specific date.
```

综合示例：

查看 fan2 在 2019年11月4日之后的提交：

```Shell
git log --author="fan2" --after="2019-11-04"
```

查看 fan2 自 2017年1月1日 之后的提交：

```Shell
git log --author=fan2 --since="2017-01-01"

commit 9156d24ec9008d2a13a47a8409746f13100450df (HEAD -> master)
Merge: cdc58a8a 1b5559ad
Author: fan2 <929683282@qq.com>
Date:   Mon Nov 4 18:45:07 2019 +0800

    Merge remote-tracking branch 'upstream/master'

commit cdc58a8a241e972f969bdfdd55a4b867a9bb4687 (origin/master, origin/HEAD)
Author: fan2 <929683282@qq.com>
Date:   Sat Feb 23 15:06:27 2019 +0800

    补充 mars 参考。
```

查看 fan2 在 2019年11月4日之后、2019年11月8日之前 的提交：

```Shell
git log --author="fan2" --since="2019-11-04" --until="2019-11-08"
```

> [git log with date range or before after](https://community.atlassian.com/t5/Bitbucket-questions/git-log-with-date-range-or-before-after/qaq-p/603965)  
> [How to checkout in Git by date?](https://stackoverflow.com/questions/6990484/how-to-checkout-in-git-by-date)  
> [How does git log --since count?](https://stackoverflow.com/questions/14618022/how-does-git-log-since-count)  
> [How to change Git log date formats](https://stackoverflow.com/questions/7853332/how-to-change-git-log-date-formats)  

### message

选项 | 说明
----|---------
`--name-only` | 仅显示修改的文件清单（不包含相对路径）
`--name-status` | 显示修改文件清单，行首以 M、D 等标记变更状态
`--shortstat` | 仅显示 --stat 最后的增删改概要信息
**`--stat`** | 显示修改的文件列表（相对路径）及增删改统计信息
`-p`  | 按补丁格式显示每个文件之间的差异（diff）

> `git log -p` 相当于多次调用 `git show [commit_hashid]`。

#### pretty

`git log --pretty`：使用其他格式显示历史提交信息。可用的选项包括 oneline，short，full，fuller 和 format（后跟指定格式）。

#### decorate graph

[git查看各个branch之间的关系图](https://www.jianshu.com/p/2619830b6e3f)

```Shell
$ git log --graph --decorate --oneline --simplify-by-decoration --all
```

**说明**：

`--decorate`：标记会让 git log 显示每个 commit 的引用(如 分支、tag 等)   
`--oneline`：一行显示  
`--simplify-by-decoration`：只显示被branch或tag引用的commit  
`--all`：表示显示所有的branch。这里也可以选择，比如指向显示分支 ABC 的关系，则将 --all 替换为 branchA branchB branchC 即可。

### search

选项 | 说明
----|---------
`--author` | 仅显示指定作者相关的提交  
`--committer` | 仅显示指定提交者相关的提交  
`--grep` | 仅显示含指定关键字的提交  
`-S` | 仅显示添加或移除了某个关键字的提交  

#### mutil-author

同时过滤多个作者的提交日志：

```Shell
$ git log --author='zhangsan' --author='lisi' --merges
```

["git log" does not work for multiple author filtering](https://forums.freebsd.org/threads/git-log-does-not-work-for-multiple-author-filtering.58555/)

```Shell
$ git config --global grep.extendedRegexp true
```

[GIT: filter log by group of authors](https://stackoverflow.com/questions/22968710/git-filter-log-by-group-of-authors)

```Shell
$ git log --perl-regexp --author='zhangsan|lisi' --merges
```

## 查看某个文件的日志

```Shell
       [--] <path>...
           Show only commits that are enough to explain how the files that match
           the specified paths came to be. See History Simplification below for
           details and other simplification modes.

           Paths may need to be prefixed with -- to separate them from options or
           the revision range, when confusion arises.
```

查看文件 `include/liteif.h` 最近3次的提交日志：

```Shell
$ #git log -3 --stat include/liteif.h | cat
$ git log -3 --stat -- include/liteif.h | cat
```

### -p

`git log [[--] <path>...]`，其中 **path** 为当前目录相对路径

```Shell
~/Projects/github/libNET/mars
0 master % git log mars/comm/messagequeue/message_queue.cc
```

`git log -p <path>`：查看指定文件日志，并打印详细的 `--full-diff`。

查看某次 commit-sha1 的具体修改（显示 diff-patch 详情）

```
git log -p -1 ff26476c7d42bf80f268ccf8b0b7ed1fcf39962c
```

## 查看某次提交的日志

git log 指定某次 commit 的 HASH 值，即可查看某次提交及之前的日志：

```Shell
~/Projects/github/libNET/mars
0 master % git log c6938ef4c3b308c6aa423938678599b200100451
```

默认显示自某次提交之前的日志，添加 `-n 1` 选项限定只查看某一次的提交。

查看 `66932f0c` 这一次提交及之前那一次的日志：

```
$ git log 66932f0c -2 | cat
```

查看 `66932f0c` 这一次提交的日志：

```
$ git log 66932f0c -1 | cat
```

查看 `66932f0c` 这一次提交之前的那一次的日志：

```
$ git log 66932f0c^ -1 | cat
```

## 查看合并的提交记录

- `--merges` 过滤出 Merge Request 提交；  
- `--no-merges` 过滤出非 Merge Request 的原始提交；  

```
git log --author="fan2" --merges
```

**综合示例**：查看 fan2 在一段时间内的 merge 和 非merge 提交：

```
$ git log --author="fan2" --merges --since="2019-11-01" --until="2019-11-10"
$ git log --author="fan2" --no-merges --since="2019-11-01" --until="2019-11-10"
```

## 查看指定仓库的提交记录

`git log` 默认查看的是本地当前仓库的日志。

### 查看本地仓库的提交记录

查看 `git branch`(--list) 本地仓库中指定仓库的日志。

```
git log feature/8.0.8_PCSendMobileAlbum --author="fan2" --stat
```

### 查看远端仓库的提交记录

查看 `git branch -r` 远端仓库（origin）中当前仓库的日志，以便对比本地尚未同步的差异。

```
iq git/feature/8.0.8_PCSendMobileAlbum2
❯ git log origin/feature/8.0.8_PCSendMobileAlbum --author="fan2" --stat
```

指定其他仓库，查询相应 commit hash，以便执行 `git cherry-pick` 将某些提交合入当前分支。

[Log of remote history](https://stackoverflow.com/questions/16315379/log-of-remote-history)

```
git fetch
git log FETCH_HEAD
```

### 查看指定分支的提交记录

[How do I run git log to see changes only for a specific branch?](https://stackoverflow.com/questions/4649356/how-do-i-run-git-log-to-see-changes-only-for-a-specific-branch)

[Git log to get commits only for a specific branch](https://stackoverflow.com/questions/14848274/git-log-to-get-commits-only-for-a-specific-branch)

指定参数 `--first-parent` 查看 `feature/8.1.0_NewUI` 分支的日志：

```
git log --author="fan2" --graph --abbrev-commit --decorate --first-parent feature/8.1.0_NewUI
```
