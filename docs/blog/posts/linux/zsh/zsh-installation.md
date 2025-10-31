---
title: macOS切换使用zsh并安装ohmyzsh
authors:
  - xman
date:
    created: 2019-10-27T10:20:00
categories:
    - wiki
    - zsh
comments: true
---

macOS下切换 zsh 为默认 shell，并安装 oh-my-zsh。

<!-- more -->

## 查看系统支持的 Shells

终端执行 `cat /etc/shells` 命令可以查看系统支持几种 Shells；

```Shell
➜  ~ cat /etc/shells
# List of acceptable shells for chpass(1).
# Ftpd will not allow users to connect who are not using
# one of these shells.

/bin/bash
/bin/csh
/bin/ksh
/bin/sh
/bin/tcsh
/bin/zsh
```

macOS 预装了 zsh。

## 查看系统当前使用的 Shell

终端执行 `echo $SHELL` 命令可以查看 macOS 系统当前账户使用的默认 Shell：

```Shell
➜  ~ echo $SHELL
/bin/zsh
```

## 切换当前 Shell 为 zsh

终端执行 `chsh -s /bin/zsh` 命令可以切换默认 Shell 为更注重用户体验和交互的 zsh。

## zsh 配置 profile

### man

关于 zsh 的加载、启动和运作机制，建议通过 `man zsh` 手册。

可以阅读 INVOCATION、COMPATIBILITY、RESTRICTED SHELL 相关章节内容。

### FILES

参考 man bash 相关配置 [bash-FILES](./../profile/bash-FILES.md)、[macOS Env PATH](./../profile/macOS-Env-PATH.md) 的讨论。

关于 zsh 的启动加载配置流程机制，可以阅读 `man zsh` 手册中的 STARTUP/SHUTDOWN FILES、FILES 等章节。

```Shell
$ man zsh

FILES
       $ZDOTDIR/.zshenv
       $ZDOTDIR/.zprofile
       $ZDOTDIR/.zshrc
       $ZDOTDIR/.zlogin
       $ZDOTDIR/.zlogout
       ${TMPPREFIX}*   (default is /tmp/zsh*)
       /etc/zshenv
       /etc/zprofile
       /etc/zshrc
       /etc/zlogin
       /etc/zlogout    (installation-specific - /etc is the default)
```

If `ZDOTDIR` is unset, `HOME` is used instead. Files listed above as being in `/etc` may be in another directory, depending on the installation.

> 未设置环境变量 ZDOTDIR，默认就是 HOME 目录。

系统级配置文件 `/etc/zprofile` 和 `/etc/zshrc` 中有内容。

### startup

[Customizing the bash shell and its startup files](https://www.maths.cam.ac.uk/computing/linux/bash/adding)

[ohmyzsh/plugins/profiles/](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/profiles) allows you to create separate configuration files for zsh based on your long hostname (including the domain).

## 安装 [OMZ](https://ohmyz.sh/)（[Oh My ZSH](https://github.com/robbyrussell/oh-my-zsh)）

终端执行以下命令可通过 curl（或 wget、httpie）从 github 下载安装流行的 Zsh 配置 Oh My ZSH：

```Shell
# curl
$ sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
## 或者
$ curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | zsh

# wget
$ sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
## 或者
$ wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

# httpie（有待验证）
$ http --download https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh -c
## 或者
http --download https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | zsh
```

## 卸载 OMZ

在终端中运行 `uninstall_oh_my_zsh` 命令可以卸载 OMZ。

## Color Themes

robbyrussell/oh-my-zsh

https://github.com/robbyrussell/oh-my-zsh/wiki/themes

A list of Themes that don't come bundled with oh-my-zsh

https://github.com/robbyrussell/oh-my-zsh/wiki/External-themes

OMZ 提供了数百种主题，相关文件在 `~/.oh-my-zsh/themes` 目录下。

Themes are located in a themes folder and must end with .zsh-theme. The basename of the file is the name of the theme.

```Shell
    zsh_custom
    └── themes
        └── my_awesome_theme.zsh-theme
```

Then edit your `.zshrc` to use that theme.

```Shell
    ZSH_THEME="my_awesome_theme"
```

在 `.zshrc` 里通过 `ZSH_THEME` 键来设置主题，默认主题是：

```Shell
    ZSH_THEME=”robbyrussell”
```

### 推荐主题

- pygmalion (⭐️⭐️⭐️️⭐️⭐️️)  
- bira (⭐️⭐️⭐️️⭐️️)  
- bureau  
- agnoster  
- `random`  

## 参考

[macOS/Linux 安装 zsh & OMZ](https://segmentfault.com/a/1190000013857738)  
[Terminal & zsh & oh-my-zsh 配置](http://www.jianshu.com/p/6cb063d860ff)  
[bash 轉移 zsh (oh-my-zsh) 設定心得](http://icarus4.logdown.com/posts/177661-from-bash-to-zsh-setup-tips)  

[为什么说 zsh 是 shell 中的极品？](https://www.zhihu.com/question/21418449)  
[利用 Oh-My-Zsh 打造你的超级终端](https://blog.csdn.net/czg13548930186/article/details/72858289)  
[oh-my-zsh,让你的终端从未这么爽过](https://www.jianshu.com/p/d194d29e488c)  

[oh-my-zsh 配置你的 zsh 提高 shell 逼格终极选择](http://yijiebuyi.com/blog/b9b5e1ebb719f22475c38c4819ab8151.html)  
[iTerm2 + zsh + oh-my-zsh The Most Power Full of Terminal on macOS](https://medium.com/ayuth/iterm2-zsh-oh-my-zsh-the-most-power-full-of-terminal-on-macos-bdb2823fb04c)  
