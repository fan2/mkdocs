---
title: git配置语言等选项
authors:
  - xman
date:
    created: 2018-09-05T09:00:00
    updated: 2019-06-02T22:55:00
categories:
    - git
tags:
    - git
    - config
comments: true
---

本文记录了 git status 显示乱码、修改语言和区分大小写等 git 配置解决方案。

<!-- more -->

[Git Status 中文乱码解决](http://blog.crhan.com/2012/09/git-status-%E4%B8%AD%E6%96%87%E4%B9%B1%E7%A0%81%E8%A7%A3%E5%86%B3/)  

## 中文乱码

[git 正常显示中文文件名](https://www.jianshu.com/p/297ff9b730cf)  
[git status 显示中文和解决中文乱码](https://www.cnblogs.com/tielemao/p/9492638.html)  

不对0x80以上的字符进行quote，解决git status/commit时中文文件名乱码

```Shell
$ git config --global core.quotepath false
```

## 日志 ESC

[How to fix ESC\[ in your terminal](http://excid3.com/blog/how-to-fix-esc-in-your-terminal)

[How to get rid of ESC\[ characters when using git diff on Mac OS X Mavericks?](https://stackoverflow.com/questions/20414596/how-to-get-rid-of-esc-characters-when-using-git-diff-on-mac-os-x-mavericks)

如果之前有配置导出 LESS，可将 `~/.zshrc` 中的相关配置项屏蔽掉即可：

```Shell
LESS='-Pslines %lt-%lb bytes %bt-%bb %Pb\% of file %f';
export LESS
```

或者单独设置 git 分页器（core.pager）为 `less -R`：

```Shell
# read
$ git config --global core.pager

# write
$ git config --global core.pager "less -R"

# read
$ git config --global core.pager
less -R
```

## 修改语言

[How does one change the language of the command line interface of Git?](https://stackoverflow.com/questions/10633564/how-does-one-change-the-language-of-the-command-line-interface-of-git)  
[Change git's language to English without changing the locale](https://askubuntu.com/questions/320661/change-gits-language-to-english-without-changing-the-locale)  

[Git 2.19 对Diff、Branch和Grep等做了改进](http://www.infoq.com/cn/news/2018/09/git-2.19-released)  
[如何更改Git的命令行界面的语言？](https://codeday.me/bug/20170821/64386.html) [让 git 显示英文](https://blog.csdn.net/RonnyJiang/article/details/53509727)  

在当前命令行中执行 `LAGN=en_GB` 临时设置语言，关闭终端失效。

或在 bash 或 zsh 中启动 git 之前修改语言变量 LANG：

```Shell
$ echo "alias git='LANG=en_GB git'" >> ~/.bashrc
```

**恢复中文**：在 `~/.bashrc`（或 `~/.zshrc`） 中注释掉以上即可。

## 区分大小写

[关于git不区分文件名大小写的处理](http://www.cnblogs.com/rollenholt/p/4060238.html)

[如何配置Git支持大小写敏感和修改文件名中大小写字母呢？](http://blog.hexu.org/archives/1909.shtml)


如何解决Git的大小不敏感问题呢？

- 方案一：配置git大小写敏感：

```Shell
$ git config core.ignorecase false
```

- 方案二是先删除文件，再添加进去：

```Shell
$ git rm ; git add ;  git commit -m "rename file"
```
