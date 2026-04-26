---
title: Linux Shell 简介
authors:
  - xman
date:
    created: 2019-10-22T08:30:00
    updated: 2026-04-26T22:00:00
categories:
    - wiki
    - linux
tags:
    - shell
comments: true
---

Linux Shell 初步认知。

<!-- more -->

终端执行 `cat /etc/shells` 查看支持的 shell：

```Shell
# macOS
faner@FAN-MB0:~|⇒  cat /etc/shells
# List of acceptable shells for chpass(1).
# Ftpd will not allow users to connect who are not using
# one of these shells.

/bin/bash
/bin/csh
/bin/ksh
/bin/sh
/bin/tcsh
/bin/zsh

# raspbian
pi@raspberrypi:~$ cat /etc/shells
cat /etc/shells
# /etc/shells: valid login shells
/bin/sh
/bin/dash
/bin/bash
/bin/rbash
/usr/bin/screen
```

终端执行 `env | grep 'SHELL'` 或 `echo $SHELL` 可查看当前账户正在使用的 shell：

```Shell
pi@raspberrypi:~$ env | grep 'SHELL'
SHELL=/bin/bash

faner@FAN-MB0:~|⇒  echo $SHELL
/bin/bash
```

## bash

macOS（BSD）、raspbian（Debian） 系统默认 Shell 均为 `/bin/bash`。

> [Bash Keyboard Shortcuts](https://ss64.com/osx/syntax-bashkeyboard.html) @ss64  
> [20 Terminal shortcuts developers need to know](http://www.techrepublic.com/article/20-terminal-shortcuts-developers-need-to-know/)  
> [Using the Terminal keybindings with bash on macOS](https://superuser.com/questions/124336/using-the-terminal-keybindings-with-bash-on-macos)  
> [Shortcuts to move faster in Bash command line](http://teohm.com/blog/shortcuts-to-move-faster-in-bash-command-line/)  
> [The Best Keyboard Shortcuts for Bash (aka the Linux and macOS Terminal)](https://www.howtogeek.com/howto/ubuntu/keyboard-shortcuts-for-bash-command-shell-for-ubuntu-debian-suse-redhat-linux-etc/)  
> [List of default Mac OS X command-line editing bash keyboard shortcuts](https://maymay.net/blog/2007/07/18/list-of-default-mac-os-x-command-line-editing-bash-keyboard-shortcuts/)  

输入 `bash --version` 查看 bash 版本信息：

```Shell
# macOS
faner@FAN-MB0:~|⇒  bash --version
bash --version
GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin16)
Copyright (C) 2007 Free Software Foundation, Inc.

# raspbian
pi@raspberrypi:~$ bash --version
bash --version
GNU bash, version 4.4.12(1)-release (arm-unknown-linux-gnueabihf)
Copyright (C) 2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```

输入执行 `man bash` 或 `man 1 bash` 可以查看 bash 的说明文档——[GNU Bash manual](https://www.gnu.org/software/bash/manual/) | [Bash Reference Manual](https://www.gnu.org/software/bash/manual/bashref.html)。

### PROMPTING

When executing interactively, **bash** *displays* the <u>primary</u> prompt **PS1** when it is ready to read a command,  

> PS1 stands for "Prompt String One" or "Prompt Statement One", the first prompt string (that you see at a command line).  
> The default value is `'\s-\v\$'`, such as `bash-3.2$`.  

and the <u>secondary</u> prompt **PS2** when it needs more *input* to complete a command.  

> PS2 The secondary prompt string. ie for continued commands (those taking more than one line).  
> The default value is `'>'`.  

**Bash** displays **PS0** *after it reads* a command but *before executing* it.  

> [Why is bash's prompt variable called PS1?](https://unix.stackexchange.com/questions/32096/why-is-bashs-prompt-variable-called-ps1)  
> [Bash Shell: Take Control of PS1, PS2, PS3, PS4 and PROMPT_COMMAND](http://www.thegeekstuff.com/2008/09/bash-shell-take-control-of-ps1-ps2-ps3-ps4-and-prompt_command/)  
> [Echo expanded PS1](https://stackoverflow.com/questions/3451993/echo-expanded-ps1)  
> [Bash prompt basics](https://linuxconfig.org/bash-prompt-basics)  
> [Linux用户命令行字符环境变量](http://blog.csdn.net/cheungjustin/article/details/5825213)  
> [shell PS1 PS2 PS3 PS4界面提示符](http://blog.csdn.net/misskissc/article/details/8144283)  
> [Linux下PS1、PS2、PS3、PS4使用详解](http://os.51cto.com/art/201205/334954.htm)  

#### PS2

当输入命令未结束即换行时（continued commands more than one line），将换行以 PS2（**`>`**）提示续行输入：

例如 `telnet`，将会通过次提示符提示输入更多参数：

```Shell
faner@MBP-FAN % telnet
telnet>

# 输入 quit 退出
```

例如 `echo` 输入一个引号，将会通过次提示符提示输入数据，直到遇到另一个引号结束：

```Shell
{18-09-16 16:46}[]MBP-FAN:~ faner% echo 'hello
quote> world
quote> '
hello
world

{18-09-16 17:14}[]MBP-FAN:~ faner%
```

### command type

bash 内置的 **type** 命令可以查看某个命令是否为 bash 的内置命令。

例如 cd、ECHO(1) 命令为 bash 内置：

```Shell
pi@raspberrypi:~$ type -t cd
builtin

pi@raspberrypi:~$ type -a cd
cd is a shell builtin

# macOS 下对应 -w 选项
pi@raspberrypi:~$ type -t echo
builtin

pi@raspberrypi:~$ type -a echo
echo is a shell builtin
echo is /bin/echo
```

type（和 cd）命令的说明内含在 bash 的 man page 中（`type [-aftpP] name [name ...]`），没有对应的 manual page entry，且不支持 `-h(--help)` 选项查看帮助。

```Shell
# 以下为 raspbian 下的测试

pi@raspberrypi:~$ man type
No manual entry for type

pi@raspberrypi:~$ man cd
No manual entry for cd

# 以下为 macOS 下的测试

faner@MBP-FAN:~|⇒  type -h
type: bad option: -h
faner@MBP-FAN:~|⇒  type --help
type: bad option: -h

faner@MBP-FAN:~|⇒  cd -h
cd: no such file or directory: -h
faner@MBP-FAN:~|⇒  cd --help
cd: no such file or directory: --help
```

利用 tab 键的自动补齐功能，在 macOS 终端输入 `type -` 再按下 tab 键，即可列举出所有可能的备选输入项及其概要说明：

```Shell
faner@MBP-FAN:~|⇒  type -
-S  -- show steps in the resolution of symlinks
-a  -- print all occurrences in path
-f  -- output contents of functions
-m  -- treat the arguments as patterns
-p  -- always do a path search
-s  -- print symlink free path as well
-w  -- print command type
-
```

---

ECHO(1) 命令有 manual page，可执行 `man echo` 或  `man 1 echo` 查看。

SU(1)、SUDO(8)、NANO(1)、VIM(1)、SSH(1)、rsync(1)、SFTP(1)、IFCONFIG(8) 为外部命令：

```Shell
pi@raspberrypi:~$ type -t sudo
file
pi@raspberrypi:~$ type -p sudo
/usr/bin/sudo
pi@raspberrypi:~$ type -a sudo
sudo is /usr/bin/sudo

pi@raspberrypi:~$ type -t vim
file
pi@raspberrypi:~$ type -p vim
/usr/bin/vim
pi@raspberrypi:~$ type -a vim
vim is /usr/bin/vim

pi@raspberrypi:~$ type -t ifconfig
file
pi@raspberrypi:~$ type -p ifconfig
/sbin/ifconfig
pi@raspberrypi:~$ type -a ifconfig
ifconfig is /sbin/ifconfig
```

### command test

#### command -v: 检查命令是否存在

`command -v` 是一个 **内置的 shell 命令**，用于：

1. **检查命令是否存在**
2. **显示命令的类型和位置**

检查命令是否存在示例：

```bash
# 存在显示路径，退出码为0
$ command -v curl
/usr/bin/curl
echo $?
0

# 不存在无输出，且退出码非0
command -v wget

echo $?
1
```

显示命令的类型和位置示例：

```bash
# 1. 查找内置命令：command, cd, pwd, echo, which, test
# 注意：显示为命令名，而非路径
$ command -v cd
cd

# 2. 查找关键字: if, else, do, while
# 注意：显示关键字名
$ command -v if
if

# 3. 查找外部命令：ls, rm; nice, log, find, grep, awk, sed
$ command -v log
/usr/bin/log

# 4. 识别命令别名
$ command -v ls
alias ls='ls -G'
$ command -v rm
alias rm='rm -i'

# 5. 查找函数: 显示函数名
$ command -v omz
omz
$ command -v upgrade_oh_my_zsh
upgrade_oh_my_zsh
```

##### `command -v` vs. `which`

**相似性**：两者都用于查找命令路径

**关键区别**：

| 特性          | `command -v`                | `which`               |
|---------------|-----------------------------|-----------------------|
| 类型          | **shell 内置命令**          | **外部程序**          |
| POSIX         | 符合 POSIX 标准             | 不符合 POSIX          |
| 可移植性      | 高（所有 POSIX shell 都支持） | 较低（非所有系统都有）  |
| 效率          | 更快（不启动子进程）          | 较慢（需启动子进程）    |
| 处理别名/函数 | 能识别别名、函数、内置命令    | 通常只找可执行文件    |
| 退出码        | 找到返回0，没找到返回1       | 找到返回0，没找到返回1 |

#### command -V: 查看命令详细信息

显示命令的类型和定义。

```bash
$ command -V cd
cd is a shell builtin

$ command -V if
if is a reserved word

$ command -V log
log is /usr/bin/log

$ command -v rsync
/usr/bin/rsync
$ command -V rsync
rsync is /usr/bin/rsync
```

显示命令别名：

```bash
# Enable colorized output.
$ command -V ls
ls is an alias for ls -G
# Request confirmation before attempting
$ command -V rm
rm is an alias for rm -i

$ command -v python
alias python=/usr/bin/python3
$ command -V python
python is an alias for /usr/bin/python3

$ command -v cp
alias cp='nocorrect cp'
$ command -V cp
cp is an alias for nocorrect cp
```

显示安装的 brew、rclone 命令工具类型信息：

```bash
$ command -v brew
/opt/homebrew/bin/brew
$ command -V brew
brew is /opt/homebrew/bin/brew
```

```bash
$ command -v rclone
/opt/homebrew/bin/rclone
$ command -V rclone
rclone is /opt/homebrew/bin/rclone
```

显示 Oh-My-Zsh 插件命令，`omz` 和 `upgrade_oh_my_zsh` 是 shell funciton，且给出了定义所在脚本文件：

> 这个功能非常适用，可以帮助我们找到 shell 函数的定义位置。

```bash
$ command -V omz
omz is a shell function from /Users/cliff/.oh-my-zsh/lib/cli.zsh
$ command -V upgrade_oh_my_zsh
upgrade_oh_my_zsh is a shell function from /Users/cliff/.oh-my-zsh/lib/functions.zsh
```

#### command -p: 使用默认PATH中的原始命令

`ls`, `rm` 命令被定义成了带默认选项的 alias - `ls -G` 和 `rm -i`。 指定 `-p` 选项搜索默认 PATH，可以看到原始命令真身：

```bash
$ command -pv ls
/bin/ls
$ command -pv rm
/bin/rm
```

安转 brew 时，会将 `/opt/homebrew/bin` 添加到 `PATH` 头部，brew 安装的 python3 如下：

```bash
$ command -v python3
/opt/homebrew/bin/python3

$ command -V python3
python3 is /opt/homebrew/bin/python3

$ command python3 -V
Python 3.14.4
```

指定 `-p` 选项搜索默认 PATH，可以看到系统自带的 python3：

```bash
$ command -pv python3
/usr/bin/python3

$ command -pV python3
python3 is /usr/bin/python3

$ command -p python3 -V
Python 3.9.6
```

使用 command 绕过别名，执行原始命令：`command ls` 或 `command -p ls`。

#### command 命令在脚本中的使用示例

```bash
#!/bin/bash

# 检查命令是否存在的函数
cmd_exists() {
    # 将标准输出和标准错误都重定向到 `/dev/null`（丢弃）
    command -v "$1" &> /dev/null
}

# 最佳实践：检查命令是否存在
if cmd_exists "rsync"; then
    echo "使用 rsync"
    rsync -av source/ dest/
elif cmd_exists "cp"; then
    echo "使用 cp (rsync 不可用)"
    cp -r source/* dest/
else
    echo "错误: 没有可用的复制工具" >&2
    exit 1

# 批量检查命令是否存在
required_cmds=("bash" "git" "make" "curl")
missing_cmds=()

for cmd in "${required_cmds[@]}"; do
    if ! cmd_exists "$cmd"; then
        missing_cmds+=("$cmd")
    fi
done

if [ ${#missing_cmds[@]} -gt 0 ]; then
    echo "缺少的命令: ${missing_cmds[*]}"
    exit 1
fi
```

### Special keys

- `C-i` = Tab  
- `C-g` = Abort，放弃当前行，新起一行  
- `C-j` = Newline，运行当前行，新起一行  
- `C-[` = Escape  
- `C-m` = Enter  
- `C-_` / `<C-x>u` = Undo  

## zsh

终端执行以下命令可通过 curl 从 github 下载安装流行的 Zsh（兼容 bash） 配置 [oh-my-zsh](http://ohmyz.sh/)：

```Shell
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

输入 `zsh --version` 查看 zsh 版本信息：

```Shell
faner@FAN-MB0:~|⇒  zsh --version
zsh --version
zsh 5.2 (x86_64-apple-darwin16.0)
```

执行 `chsh -s /bin/zsh` 命令（重启生效）可切换为更注重用户体验和交互的 zsh。

> [使用 Zsh 的九个理由](http://blog.jobbole.com/28829/)  
> [Linux终极shell-Z Shell](http://blog.csdn.net/gatieme/article/details/52741221)  
> [为什么说 zsh 是 shell 中的极品？](https://www.zhihu.com/question/21418449)  
> [Mac下采用zsh代替bash](http://www.jianshu.com/p/ae378aa725cf)  
> [oh my zsh 相比 bash 的优势](https://www.zhihu.com/question/29977255)  

### zsh 下切回 bash

如果在 zsh 下执行 sh 脚本（例如 `./startup.sh`）报错，可以按照以下任何一种方式解决：

1. 指定在 bash 下执行脚本：`bash ./startup.sh`。  
2. 输入 bash 进入 bash 命令环境，然后再执行命令或脚本：`bash-3.2$ ./startup.sh`；通过快捷键 <C-d> 或输入 exit 退回默认 Shell（zsh）。  
3. Shell | New Command（<kbd>⇧</kbd><kbd>⌘</kbd><kbd>N</kbd>）输入 `/bin/bash`，新建 bash shell 临时窗口。  
4. 在终端执行 `chsh -s /bin/bash` 命令（重启生效）将 Shell 切回默认的 bash。  
