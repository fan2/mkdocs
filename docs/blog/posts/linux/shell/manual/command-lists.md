---
title: Linux Command Lists
authors:
  - xman
date:
    created: 2019-10-28T11:30:00
categories:
    - wiki
    - linux
comments: true
---

Linux command lists —— ;, &&, ||.

<!-- more -->

## continuous

使用空格或分号（**`;`**）可执行无相关性的连续命令：

```bash
faner@FAN-MB0:~|⇒  test1='test 1' test2='test 2'
faner@FAN-MB0:~|⇒  echo $test1
test 1
faner@FAN-MB0:~|⇒  echo $test2
test 2
faner@FAN-MB0:~|⇒  echo $test1;echo $test2
test 1
test 2

faner@MBP-FAN:~|⇒  testShellVar=string; cd ~/Downloads
faner@MBP-FAN:~/Downloads|⇒  echo $testShellVar 
string
faner@MBP-FAN:~/Downloads|⇒ 
```

> Commands separated by a `;` are executed sequentially

## AND/OR

**`&&`** 和 **`||`** 则可连续执行相关性的命令。

> AND and OR lists are sequences of one or more pipelines separated by the **&&** and **||** control operators, respectively. AND and OR lists are executed with left associativity.

`command1 || command2`：在逻辑上只要有第一条命令执行成功就不会执行第二条命令，只有第一条命令执行失败才会启动执行第二条命令。

> command2 is executed if and only if command1 returns a non-zero exit status.

`command1 && command2`：只有在第一条命令执行成功时才会启动执行第二条命令。

> command2 is executed if, and only if, command1 returns an exit status of zero.

```bash
mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master
```

`mkdir homebrew` 正确执行完毕，即成功创建目录 `homebrew`，才会启动执行后面的 `curl -L` 命令。  

这些符号为 BASH 的 token(control operator)。

## demo

1. 下面的 bash 系统级配置 `/etc/profile` 的内容：

```bash
$ cat /etc/profile

# System-wide .profile for sh(1)

if [ -x /usr/libexec/path_helper ]; then
	eval `/usr/libexec/path_helper -s`
fi

if [ "${BASH-no}" != "no" ]; then
    # 当 `/etc/bashrc` 文件存在且可读时，source 引入。
	[ -r /etc/bashrc ] && . /etc/bashrc
fi
```

2. [vim-interaction.plugin.zsh](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/vim-interaction/vim-interaction.plugin.zsh) 中判等串联执行命令：

```bash
  # If before or after commands begin with : and don't end with <cr>, append it
  [[ ${after}  = :* && ${after}  != *\<cr\> ]] && after+="<cr>"
  [[ ${before} = :* && ${before} != *\<cr\> ]] && before+="<cr>"
  # Open files passed (:A means abs path resolving symlinks, :q means quoting special chars)
  [[ $# -gt 0 ]] && files=':args! '"${@:A:q}<cr>"
```

3. 发送 2 次 ping 请求，每次最长等待 500ms，只要收到一个响应即退出。

    - 2*500ms 内收到响应，命令成功返回（`$?` 为 0），执行 && 后面的命令，输出 “Google: ping OK”。
    - 否则，命令执行失败（`$?` 为 1 或其他非零值），则短路执行 || 后面的命令，输出 “Google: ping fail”。

```bash
ping -o -c 2 -W 500 www.google.com > /dev/null 2>&1\
    && echo "Google: ping OK"\
    || echo "Google: ping fail"
```

4. 下面是 RapaNui - [getopts-12523979.sh](https://stackoverflow.com/a/12523979) 中判断串联、并联执行命令：

```bash
[ $OPTIND -ge 1 ] && optind=$(expr $OPTIND - 1) || optind=$OPTIND
```

5. 当前目录下如果有 `forms-debug` 文件夹则进入，否则先创建再进入。

    - [Check if a directory exists in a shell script](https://stackoverflow.com/questions/59838/check-if-a-directory-exists-in-a-shell-script)  
    - [Linux / UNIX: Find Out If a Directory Exists or Not](https://www.cyberciti.biz/tips/find-out-if-directory-exists.html)  

```bash
([ -d forms-debug ] || mkdir forms-debug) && cd forms-debug
```
