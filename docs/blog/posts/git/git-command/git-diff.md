---
title: git diff查看差异
authors:
  - xman
date:
    created: 2018-09-05T10:10:00
    updated: 2019-06-03T08:00:00
categories:
    - git
tags:
    - git
    - diff
comments: true
---

本文记录了使用 git diff 命令进行对比代码变动差异的基本用法。

<!-- more -->

## [git help diff](https://git-scm.com/docs/git-diff)

```Shell
GIT-DIFF(1)                                 Git Manual                                 GIT-DIFF(1)



NAME
       git-diff - Show changes between commits, commit and working tree, etc

SYNOPSIS
       git diff [<options>] [<commit>] [--] [<path>...]
       git diff [<options>] --cached [<commit>] [--] [<path>...]
       git diff [<options>] <commit> <commit> [--] [<path>...]
       git diff [<options>] <blob> <blob>
       git diff [<options>] --no-index [--] <path> <path>


DESCRIPTION
       Show changes between the working tree and the index or a tree, changes between the index
       and a tree, changes between two trees, changes between two blob objects, or changes between
       two files on disk.
```

[Git笔记：git diff 的用法](https://blog.csdn.net/clxjoseph/article/details/80213315)  
[Git diff 常见用法](https://www.cnblogs.com/qianqiannian/p/6010219.html)  
[Git查看版本改动 —— git diff](https://blog.csdn.net/asheandwine/article/details/78982919)  

## git diff

参考 [git不同阶段撤回](http://einverne.github.io/post/2017/12/git-reset.html)

`git diff`: 查看已修改，未暂存的内容  
`git diff --cached`: 查看已暂存，未提交的内容  
`git diff origin/master master`: 查看已提交，未推送的差异  

```
工作区             暂存区                        本地仓库                               远程仓库
    \            /      \                    /        \                             /
     \         /          \                 /           \                          /
     git diff             git diff --cached             git diff origin/master master
```

## git diff between commit

对比 HEAD 相对之前某次提交点的差异：

```Shell
$ git diff commit_id HEAD
```

查看本地仓库最近一次提交的变更：

```Shell
$ git diff HEAD^ HEAD
```

> HEAD 相对前一次 HEAD^ 的差异，即为 HEAD 这次提交的修改。

As of Git 1.8.5, `@` is an alias for `HEAD`, so you can use:

```Shell
$ git diff @~..@
```

由于默认的对比目标为 HEAD 可省略，故 `git diff commit_id` 等效于 `git diff commit_id HEAD`。

以下四种写法都等效于 `git diff HEAD^ HEAD`：

```Shell
git diff HEAD^
git diff HEAD~
git diff HEAD~1
git diff @^
git diff @~
git diff @~1
```

可以查看 HEAD 这次提交了哪些文件：

```Shell
$ git diff --name-status HEAD~1..HEAD
```

如果 HEAD 这次提交修改了 `include/liteif.h` 文件，则可以指定只查看这次提交该文件的修改：

```Shell
$ git diff HEAD^ HEAD include/liteif.h
$ git diff HEAD^ HEAD -- include/liteif.h
```

如果指定了一个不在本次提交中的文件，则以上对比输出为空。

---

Diff between first and third commit:

```Shell
$ git diff HEAD~2 HEAD
```

Diff between second and third commit:

```Shell
$ git diff HEAD~2 HEAD~1
```

## git diff between branches

[git 对比两个分支差异](https://blog.csdn.net/u011240877/article/details/52586664)  
[git diff 查看两个分支的区别并将结果输出到指定文件](https://segmentfault.com/q/1010000005033288)  

[git-diff - Show changes between commits, commit and working tree, etc](https://git-scm.com/docs/git-diff)  
[How to compare files from two different branches?](https://stackoverflow.com/questions/4099742/how-to-compare-files-from-two-different-branches)

```
ifan@FAN-MC1:~/Projects/git.code.com/scenario|dev-checkpskey⚡
⇒  git diff remote-upstream-branch dev-substream-branch -- src/static/js/util.js
```

对比子流（右）针对父流（左）的某个文件修改。


[How do I get araxis merge to work as a git difftool](https://stackoverflow.com/questions/35609655/how-do-i-get-araxis-merge-to-work-as-a-git-difftool)

[**Git Tree Compare**](https://marketplace.visualstudio.com/items?itemName=letmaik.git-tree-compare)  

[Compare branches (GitHub-style diff) ](https://github.com/eamodio/vscode-gitlens/issues/115)  
[How to compare different branches on Visual studio code](https://stackoverflow.com/questions/42112526/how-to-compare-different-branches-on-visual-studio-code)  

```shell
git diff origin/bugfix-pskeyerror origin/master >> ~/desktop-m_bugfix-pskeyerror.diff

git diff origin/bugfix-pskeyerror-m origin/master >> ~/core-doc_bugfix-pskeyerror-m.diff
```

## GIT_EXTERNAL_DIFF

[How can I get a side-by-side diff when I do “git diff”?](https://stackoverflow.com/questions/7669963/how-can-i-get-a-side-by-side-diff-when-i-do-git-diff)

There are two different ways to specify an external diff tool:

1. setting the `GIT_EXTERNAL_DIFF` and the `GIT_DIFF_OPTS` environment variables.  
2. configuring the external diff tool via `git config`  

以下为 macOS 下配置 [araxis merge](https://stackoverflow.com/questions/17353430/araxis-merge-for-mac-and-git-diff) 作为 git 外部 difftool。

命令行执行 `vim ~/.gitconfig` 打开编辑 git 配置

```Shell
[difftool]
    prompt = false
[diff]
    tool = araxis
[difftool "araxis"]
    path = /Applications/Araxis Merge.app/Contents/Utilities/compare

[mergetool]
    prompt = false
    keepTemporaries = false
    trustExitCode = false
    keepBackup = false
[merge]
    tool = araxis
[mergetool "araxis"]
    path = /Applications/Araxis Merge.app/Contents/Utilities/compare
```

配置好 git difftool 之后，就可以在命令行中执行 `git difftool`（替换 `git diff`），打开第三方对比工具对比代码差异。

---

对比 FATransferMgrUp 头文件及其实现文件当前的修改（尚未 staged）：

```Shell
$ git difftool -- Classes/module/FileService/FATransferMgrUp.*
```

对比 `Classes` 目录本地尚未 staged 和已经 staged 的代码差异：

```Shell
# Working Tree vs. index
$ git difftool -- Classes/

# index vs. HEAD(repo)
$ git difftool --staged Classes/
```

调起 difftool（Araxis Merge）打开查看最近一次提交的代码差异：

```Shell
$ git difftool HEAD^ HEAD
```

查看 5c54bc3a 这次提交的修改：

```Shell
$ git difftool 5c54bc3a^ 5c54bc3a

# 查看这次修改中具体某个路径（文件）的变更
git difftool 5c54bc3a^ 5c54bc3a -- Classes/module/FileService/AIOFileEventHandler.m
```

### exit

如果要对比的提交中包含多个文件，`git difftool` 会逐个打开文件对比，假如中途想退出，可以按下 `Ctrl-C` 中断退出。
