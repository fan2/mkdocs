---
title: Linux Command - alias
authors:
  - xman
date:
    created: 2019-10-29T10:30:00
categories:
    - wiki
    - linux
tags:
    - alias
comments: true
---

linux 下的命令 alias 简介。

<!-- more -->

## [alias](http://man7.org/linux/man-pages/man1/alias.1p.html)

alias — define or display aliases

```Shell
OPERANDS         top
       The following operands shall be supported:

       alias-name
                 Write the alias definition to standard output.

       alias-name=string
                 Assign the value of string to the alias alias-name.

       If no operands are given, all alias definitions shall be written to standard output.
```

不带任何参数输入 `alias` 列举所有的关联命令。

```Shell
➜  ~ type -a ls
ls is an alias for ls -G
ls is a shell function from /Users/ifan/.oh-my-zsh/custom/plugins/ls/ls.plugin.zsh
ls is /bin/ls

➜  ~ type -a ll
ll is an alias for ls -lh
ll is a shell function from /Users/ifan/.oh-my-zsh/custom/plugins/ls/ls.plugin.zsh
```

## set

设置关联命令：

```Shell
➜  ~ alias ll='ls -lh'
➜  ~ alias ctags="`brew --prefix`/bin/ctags"
➜  ~ alias prefs='open /System/Applications/System\ Preferences.app'
```

### .bash_aliases

[How to Create and Remove alias in Linux](https://linoxide.com/linux-how-to/create-remove-alias-linux/)

考虑创建一个 `~/.bash_aliases` 将常用的便捷命令收集在一起，然后在 `~/.bashrc` 或 `~/.zshrc` 中 source 载入。

Create Permanent aliases

To define a permanent alias we must add it in `~/.bashrc` file.  
Also, we can have a separate file for all aliases (`~/.bash_aliases`) but to make this file to work we must append the following lines at the end of the `~/.bashrc` file, using any text editor:

```Shell
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases # source
fi
```

Also we can use the following command to add alias without opening the `~/.bash_aliases` file

```Shell
echo "alias vps='ssh user@ip_address_of_the_remote_server'" >> ~/.bash_aliases
```

this alias can help us to connect to our vps server via a three-letter command

Here are some examples of permanent aliases that can help in daily work

```Shell
alias update='sudo -- sh -c "apt update && apt upgrade"'    # update Ubuntu distro
alias netstat='netstat -tnlp'                               # set default options for netstat command
alias vnstat='vnstat -i eth0'                               # set eth0 as an interface for vnstat
alias flush_redis='redis-cli -h 127.0.0.1 FLUSHDB'          # flush redis cache for wp
```

All created aliases will work next time we log in to via ssh or open new terminal. To apply aliases immediately we can use the following command:

```Shell
source ~/.bash_aliases
# or
. ~/.bash_aliases
```

### common-aliases

oh-my-zsh 可以安装 [lol](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/lol)、[singlechar](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/singlechar)、[common-aliases](https://github.com/ohmyzsh/ohmyzsh/tree/02b52a03a5a78362c57d75c507240f69d4260d9a/plugins/common-aliases)、[systemadmin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/systemadmin) 插件，[common-aliases.plugin.zsh](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/common-aliases/common-aliases.plugin.zsh) 中定义了一些常用的 alias 替身命令。

可考虑在 ~/.zsh_aliases 中添加常用软件的便捷替身命令：

```Shell
# vim ~/.zsh_aliases

# 每次执行删除都需要确认
alias rm='rm -i'
# tnmp指定腾讯云源
alias tnpm='npm --registry https://mirrors.tencent.com/npm/'
# 快捷打开系统偏好设置，注意空格需要转义。
alias prefs='open /System/Applications/System\ Preferences.app'
# 快捷打开Android Studio，后面可接工程目录
alias AndroidStudio='open -a /Applications/Android\ Studio.app'
# 快捷打开 GoogleChrome 浏览器
alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
```

然后在 `~/.zshrc` 中引入加载 `~/.zsh_aliases`，以便在zsh中快速调起相关工具/软件。

```Shell
# vim ~/.zshrc

if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases # source
fi
```

## read

查看 ll 关联的命令：

```Shell
➜  ~ alias ll
ll='ls -lh'

➜  ~ alias prefs
prefs='open /System/Applications/System\ Preferences.app'
```

除此之外，对一个替身命令执行 which 时，也会打印其关联源信息：

```Shell
➜  ~ which AndroidStudio
AndroidStudio: aliased to open -a /Applications/Android\ Studio.app
```

oh-my-zsh 可以安装 [aliases](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/aliases) 插件，用法如下：

- `acs`: show all aliases by group.  
- `acs <keyword>`: filter aliases by `<keyword>` and highlight.  

## unset

[unalias](http://man7.org/linux/man-pages/man1/unalias.1p.html)

```
unalias alias-name...

DESCRIPTION

The unalias utility shall remove the definition for each alias name specified. See Alias Substitution . The aliases shall be removed from the current shell execution environment; see Shell Execution Environment .

unalias -a Removes All aliases
```

解除 ll 关联命令：

```
➜  ~ unalias ll
```

## refs

[Creating bash commands and aliases](https://shanelonergan.github.io/streamline-your-workflow-with-custom-bash-commands/)
