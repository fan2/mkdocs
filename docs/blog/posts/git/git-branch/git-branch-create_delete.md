---
title: git创建分支和管理分支
authors:
  - xman
date:
    created: 2018-09-06T11:30:00
    updated: 2019-06-02T11:40:00
categories:
    - git
tags:
    - git
    - branch
comments: true
---

本文梳理了创建、删除、重命名和清理分支的基本操作。

<!-- more -->

[Git远程操作详解](http://www.ruanyifeng.com/blog/2014/06/git_remote.html)

## [git help branch](https://git-scm.com/docs/git-branch)

`git help branch`

```shell
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
       git branch [--track | --no-track] [-f] <branchname> [<start-point>]
       git branch (--set-upstream-to=<upstream> | -u <upstream>) [<branchname>]
       git branch --unset-upstream [<branchname>]
       git branch (-m | -M) [<oldbranch>] <newbranch>
       git branch (-c | -C) [<oldbranch>] <newbranch>
       git branch (-d | -D) [-r] <branchname>...
       git branch --edit-description [<branchname>]

DESCRIPTION
       The command's second form creates a new branch head named <branchname> which points to the current
       HEAD, or <start-point> if given.

       Note that this will create the new branch, but it will not switch the working tree to it; use "git
       checkout <newbranch>" to switch to the new branch.
```

如果要基于 master（parent_branch）创建子分支，需要先 checkout 到 master（parent_branch）。

## create

[How do you create a remote Git branch?](https://stackoverflow.com/questions/1519006/how-do-you-create-a-remote-git-branch)  
[Create a new branch with git and manage branches](https://github.com/Kunena/Kunena-Forum/wiki/Create-a-new-branch-with-git-and-manage-branches)  

[git拷贝指定分支到新分支](https://blog.csdn.net/qq_27563511/article/details/82456121)  

### checkout -b

```
NOTES
       If you are creating a branch that you want to checkout immediately, it is easier to use the git
       checkout command with its -b option to create a branch and check it out with a single command.
```

`git checkout -b new_branch`：基于当前分支新建子流并 checkout。

等效于以下两步：

1. `git branch new_branch`  
2. `git checkout new_branch`  

> git checkout -b <local-branch-name> <remote-name>/<remote-branch-name>
>> remote-name：默认为 origin；  
>> remote-branch-name：默认等同 local-branch-name。  

再执行 `git push`（**`git push origin new_branch`**, `git push -u origin new_branch`？） 即可推送到服务器。

> git push <remote-name> <local-branch-name>:<remote-branch-name>
>> remote-branch-name：默认等同 local-branch-name。  

### demo

[Git复制已有分支到新分支开发](https://www.cnblogs.com/wangfajun/p/10789231.html)  
[git从已有分支拉新分支开发](https://www.cnblogs.com/lingear/p/6062093.html)  

#### branch -u

`git help branch` 查看 git branch 命令中关于 track 和 upstream 的相关选项：

```
# git help branch

SYNOPSIS

       git branch [--track | --no-track] [-f] <branchname> [<start-point>]
       git branch (--set-upstream-to=<upstream> | -u <upstream>) [<branchname>]
       git branch --unset-upstream [<branchname>]

OPTIONS

       --set-upstream
           As this option had confusing syntax, it is no longer supported. Please use --track or
           --set-upstream-to instead.

       -u <upstream>, --set-upstream-to=<upstream>
           Set up <branchname>'s tracking information so <upstream> is considered <branchname>'s
           upstream branch. If no <branchname> is specified, then it defaults to the current
           branch.

       --unset-upstream
           Remove the upstream information for <branchname>. If no branch is specified it defaults
           to the current branch.
```

执行 `git branch -u <upstream>`（等效于 `git branch --set-upstream-to=<upstream>`）：

```shell
# 1. git checkout -b
➜  docs-mp git:(master) ✗ git checkout -b bugfix-67434255
Switched to a new branch 'bugfix-67434255'

# 2. git push
➜  docs-mp git:(bugfix-67434255) ✗ git push origin bugfix-67434255
Total 0 (delta 0), reused 0 (delta 0)
remote: Processing changes: done
remote: Updating references: 100% (1/1)
To http://git.code.com/docs-mp
 * [new branch]      bugfix-67434255 -> bugfix-67434255

# git pull
➜  docs-mp git:(bugfix-67434255) ✗ git pull
There is no tracking information for the current branch.
Please specify which branch you want to merge with.
See git-pull(1) for details.

    git pull <remote> <branch>

If you wish to set tracking information for this branch you can do so with:

    git branch --set-upstream-to=origin/<branch> bugfix-67434255

# git remote 
➜  docs-mp git:(bugfix-67434255) ✗ git remote -v
origin  http://git.code.com/docs-mp (fetch)
origin  http://git.code.com/docs-mp (push)

# 3. git branch --set-upstream-to
➜  docs-mp git:(bugfix-67434255) ✗ git branch --set-upstream-to=origin/bugfix-67434255 bugfix-67434255
Branch 'bugfix-67434255' set up to track remote branch 'bugfix-67434255' from 'origin'.
➜  docs-mp git:(bugfix-67434255) ✗ git pull
Already up to date.

```

#### push -u

`git help push` 查看 git push 命令中关于 upstream 的相关选项：

```
# git help push

       -u, --set-upstream
           For every branch that is up to date or successfully pushed, add upstream (tracking)
           reference, used by argument-less git-pull(1) and other commands. For more information,
           see branch.<name>.merge in git-config(1).
```

执行 `git push -u origin new_branch`（`-u` 等效于 `--set-upstream`）：

```shell
# 1. git checkout -b
 [git::master] [ifan@MBPFAN-MC1] [19:16]
> git checkout -b bugfix-67359785
Switched to a new branch 'bugfix-67359785'

# 2. git push --set-upstream
 [git::bugfix-67359785] [ifan@MBPFAN-MC1] [19:17]
> git push --set-upstream origin bugfix-67359785
Total 0 (delta 0), reused 0 (delta 0)
remote: Processing changes: done
remote: Updating references: 100% (1/1)
To http://git.code.com/coredoc
 * [new branch]        bugfix-67359785 -> bugfix-67359785
Branch 'bugfix-67359785' set up to track remote branch 'bugfix-67359785' from 'origin'.

 [git::bugfix-67359785] [ifan@MBPFAN-MC1] [19:18]
> git remote -v
origin  http://git.code.com/coredoc (fetch)
origin  http://git.code.com/coredoc (push)

 [git::bugfix-67359785] [ifan@MBPFAN-MC1] [19:18]
> git pull
Already up to date.
```

## delete

### delete local

`git help branch` 查看 git branch 命令中关于删除的选项：

```
# git help branch

       With a -d or -D option, <branchname> will be deleted. You may specify more than one branch
       for deletion. If the branch currently has a reflog then the reflog will also be deleted.

       Use -r together with -d to delete remote-tracking branches. Note, that it only makes sense
       to delete remote-tracking branches if they no longer exist in the remote repository or if
       git fetch was configured not to fetch them again.

OPTIONS
       -f, --force
           Reset <branchname> to <startpoint>, even if <branchname> exists already. Without -f,
           git branch refuses to change an existing branch. In combination with -d (or --delete),
           allow deleting the branch irrespective of its merged status. In combination with -m (or
           --move), allow renaming the branch even if the new branch name already exists, the same
           applies for -c (or --copy).

       -d, --delete
           Delete a branch. The branch must be fully merged in its upstream branch, or in HEAD if
           no upstream was set with --track or --set-upstream-to.

       -D
           Shortcut for --delete --force.
```

以下为操作示例：

```shell
MBP-FAN :: Projects/git.code/core-sheet ‹master› % git branch -a | grep 'dev-login-weblog'
  dev-login-weblog
  remotes/origin/dev-login-weblog

MBP-FAN :: Projects/git.code/core-sheet ‹master› % git branch -dr origin/dev-login-weblog
Deleted remote-tracking branch origin/dev-login-weblog (was 73e226bc).

MBP-FAN :: Projects/git.code/core-sheet ‹master› % git branch -a | grep 'dev-login-weblog'
  dev-login-weblog

MBP-FAN :: Projects/git.code/core-sheet ‹master› % git branch -d dev-login-weblog
error: The branch 'dev-login-weblog' is not fully merged.
If you are sure you want to delete it, run 'git branch -D dev-login-weblog'.

MBP-FAN :: Projects/git.code/core-sheet ‹master› % git branch -D dev-login-weblog
Deleted branch dev-login-weblog (was 73e226bc).

MBP-FAN :: Projects/git.code/core-sheet ‹master*› % git branch -a | grep 'dev-login-weblog'
MBP-FAN :: Projects/git.code/core-sheet ‹master*› %

```

**`git branch -D`** 只是删除本地仓库里的，重新执行 `git fetch origin` 还能拉下来。

### delete remote

`git help push` 查看 git push 命令中关于删除的选项：

```
# git help push

       -d, --delete
           All listed refs are deleted from the remote repository. This is the same as prefixing
           all refs with a colon.

       git push origin :experimental
           Find a ref that matches experimental in the origin repository (e.g.
           refs/heads/experimental), and delete it.
```

**`git push origin :[retired_branch]`**： 移除远程仓库 origin 上的 `retired_branch` 分支。

```shell
MBP-FAN :: Projects/git.code/core-sheet ‹master› % git push origin :dev-login-weblog
remote: Processing changes: done
remote: Updating references: 100% (1/1)
To http://git.code.com/core-sheet.git
 - [deleted]           dev-login-weblog
```

## rename

```
       With a -m or -M option, <oldbranch> will be renamed to <newbranch>. If <oldbranch> had a
       corresponding reflog, it is renamed to match <newbranch>, and a reflog entry is created to
       remember the branch renaming. If <newbranch> exists, -M must be used to force the rename to
       happen.

       The -c and -C options have the exact same semantics as -m and -M, except instead of the
       branch being renamed it along with its config and reflog will be copied to a new name.

OPTIONS
       -f, --force
           Reset <branchname> to <startpoint>, even if <branchname> exists already. Without -f,
           git branch refuses to change an existing branch. In combination with -d (or --delete),
           allow deleting the branch irrespective of its merged status. In combination with -m (or
           --move), allow renaming the branch even if the new branch name already exists, the same
           applies for -c (or --copy).

       -m, --move
           Move/rename a branch and the corresponding reflog.

       -M
           Shortcut for --move --force.

       -c, --copy
           Copy a branch and the corresponding reflog.

       -C
           Shortcut for --copy --force.
```

[How do I rename a local Git branch?](https://stackoverflow.com/questions/6591213/how-do-i-rename-a-local-git-branch)  
[rename git branch locally and remotely](https://gist.github.com/lttlrck/9628955)  
[How To Rename a Local and Remote Git Branch](https://linuxize.com/post/how-to-rename-local-and-remote-git-branch/)  
[How to rename git local and remote branches](https://www.w3docs.com/snippets/git/how-to-rename-git-local-and-remote-branches.html)

### Rename your local branch

If you are on the branch you want to rename:

```
// old-name 缺省为当前 branch name: 
#git checkout <old_name>
git branch -m new-name
```

If you are on a different branch:

```
git branch -m old-name new-name
```

### Track a new remote branch

```
# Delete the old-name remote branch and push the new-name local branch

git push origin :<old_name>
#git push origin :<old-name> <new-name>
git push origin --delete <old_name>

# Reset the upstream branch for the new-name local branch

git push -u origin <new_name>
#git push --set-upstream origin <new_name>
```

## prune

```
# git help push

       --prune
           Remove remote branches that don't have a local counterpart. For example a remote branch
           tmp will be removed if a local branch with the same name doesn't exist any more. This
           also respects refspecs, e.g.  git push --prune remote refs/heads/*:refs/tmp/* would
           make sure that remote refs/tmp/foo will be removed if refs/heads/foo doesn't exist.
```

[reference broken](https://github.com/desktop/desktop/issues/3838)

[**Git error on git pull (unable to update local ref)**](https://stackoverflow.com/questions/10068640/git-error-on-git-pull-unable-to-update-local-ref)

1. `git gc --prune=now` - didn't do anything  
2. **`git remote prune origin`** - solved  

[git pull fails “unable to resolve reference” “unable to update local ref”](https://stackoverflow.com/questions/2998832/git-pull-fails-unable-to-resolve-reference-unable-to-update-local-ref)

### fetch error

执行 gfo，报错：

```shell
error: cannot lock ref 'refs/remotes/origin/release/20180726': 'refs/remotes/origin/release' exists; cannot create 'refs/remotes/origin/release/20180726'
From http://github.com/fan2/repo
 ! [new branch]        release/20180726 -> origin/release/20180726  (unable to update local ref)
error: cannot lock ref 'refs/remotes/origin/release/20180730': 'refs/remotes/origin/release' exists; cannot create 'refs/remotes/origin/release/20180730'

 ! [new branch]        release/20180910 -> origin/release/20180910  (unable to update local ref)
error: cannot lock ref 'refs/remotes/origin/release/20180913': 'refs/remotes/origin/release' exists; cannot create 'refs/remotes/origin/release/20180913'
 ! [new branch]        release/20180913 -> origin/release/20180913  (unable to update local ref)
```

### remote prune

```shell
⇒  git remote prune origin
Pruning origin
URL: http://github.com/fan2/repo

 * [pruned] origin/bugfix-64144175
 * [pruned] origin/bugfix-64534787
 * [pruned] origin/bugfix-64665173

 * [pruned] origin/dev-account-unbinding

 * [pruned] origin/dev-font

 * [pruned] origin/dev-preview

 * [pruned] origin/dev-sourcemap

 * [pruned] origin/feature-redDot
```

重新 fetch 恢复正常：

```shell
⇒  gfo
From http://github.com/fan2/repo
 * [new branch]        release/20180726 -> origin/release/20180726
 * [new branch]        release/20180730 -> origin/release/20180730
 * [new branch]        release/20180802 -> origin/release/20180802
 * [new branch]        release/20180806 -> origin/release/20180806
 * [new branch]        release/20180809 -> origin/release/20180809
 * [new branch]        release/20180813 -> origin/release/20180813
 * [new branch]        release/20180816 -> origin/release/20180816
 * [new branch]        release/20180820 -> origin/release/20180820
 * [new branch]        release/20180823 -> origin/release/20180823
 * [new branch]        release/20180827 -> origin/release/20180827
 * [new branch]        release/20180830 -> origin/release/20180830
 * [new branch]        release/20180903 -> origin/release/20180903
 * [new branch]        release/20180906 -> origin/release/20180906
 * [new branch]        release/20180910 -> origin/release/20180910
 * [new branch]        release/20180913 -> origin/release/20180913
```
