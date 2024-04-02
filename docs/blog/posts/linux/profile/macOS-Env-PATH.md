---
title: macOS环境变量
authors:
  - xman
date:
    created: 2019-10-26T08:20:00
categories:
    - wiki
    - macOS
tags:
    - bash
comments: true
---

macOS下的 bash 环境变量存放路径及覆盖生效层级。

<!-- more -->

`export`：显示所有环境变量
`set`：显示全部环境变量
`echo`：显示单个环境变量，例如 echo \$PATH，echo \$HOME，echo \$SHELL

由于export变量的父子传递特性，如果想一直保持一个UNIX环境变量，必须到 `/etc/profile` 或 `/etc/bashrc` 或  `~/.bash_profile`  或 `~/.bashrc` 或 `~/.profile` 中配置，在其他地方定义和 export 都不会生效。

**Mac系统的环境变量加载顺序为：**

1. `/etc/profile`  
2. `/etc/paths`  
3. `~/.bash_profile`  
4. `~/.bash_login`  
5. `~/.profile`  
6. `~/.bashrc`  

**说明：**

- `/etc/profile` 和 `/etc/paths` 是系统级别的，系统启动就会加载；后面4个是当前用户级的环境变量。  
- 3-5按照从前往后的顺序读取：  
	 - 如果 `~/.bash_profile` 文件存在，则后面2个文件就被忽略不读了；  
	 - 如果 `~/.bash_profile` 文件不存在，才会依此类推读取后面的文件。  
- `~/.bashrc` 没有上述规则，它是 bash shell 打开的时候载入的。  

**关于配置文件的加载顺序**：请重点阅读 `man bash` 手册中的 INVOCATION、RESTRICTED SHELL 和 FILES 等章节。

## /etc/profile

全局（公有）配置，不管是哪个用户，登录时都会读取该文件。

```
$ cat /etc/profile
# System-wide .profile for sh(1)

if [ -x /usr/libexec/path_helper ]; then
	eval `/usr/libexec/path_helper -s`
fi

if [ "${BASH-no}" != "no" ]; then
	[ -r /etc/bashrc ] && . /etc/bashrc
fi

```

可执行 `man path_helper` 查看相关说明。

> **建议不修改这个文件**

## /etc/bashrc

全局（公有）配置，bash shell执行时，不管是何种方式，都会读取此文件。

```
$ cat /etc/bashrc
# System-wide .bashrc file for interactive bash(1) shells.
if [ -z "$PS1" ]; then
   return
fi

PS1='\h:\W \u\$ '
# Make bash check its window size after a process completes
shopt -s checkwinsize

[ -r "/etc/bashrc_$TERM_PROGRAM" ] && . "/etc/bashrc_$TERM_PROGRAM"
```

**注意**： 

> 一般在这个文件中添加**系统级**环境变量。  
> 请不要在 `~/.bashrc` 中设置 PATH ，否则会导致 PATH 中目录的意外增长。因为每次打开一个新的 shell终端窗口，都会读取 `~/.bashrc`。  

## /etc/paths

编辑 paths，将环境变量添加到 paths文件中 ，一行一个路径。

```
$ cat /etc/paths
/usr/local/bin
/usr/bin
/bin
/usr/sbin
/sbin
```

> 全局建议修改这个文件

### /etc/paths.d

[/etc/paths vs /etc/paths.d](https://discussions.apple.com/thread/5809159)

以下摘录自 `man path_helper`：

```
DESCRIPTION
     The path_helper utility reads the contents of the files in the directories /etc/paths.d and /etc/manpaths.d
     and appends their contents to the PATH and MANPATH environment variables respectively.  (The MANPATH envi-
     ronment variable will not be modified unless it is already set in the environment.)

     Files in these directories should contain one path element per line.

     Prior to reading these directories, default PATH and MANPATH values are obtained from the files /etc/paths
     and /etc/manpaths respectively.
```

[How to use /etc/paths.d to add executable files to my path?](https://apple.stackexchange.com/questions/128897/how-to-use-etc-paths-d-to-add-executable-files-to-my-path)

The paths in `/etc/paths.d/` are added to the path by `/usr/libexec/path_helper`, which is run from `/etc/profile`, `/etc/zprofile`, and `/etc/csh.login`.

[Use /etc/paths or /etc/paths.d to add items to the PATH in macOS Sierra?](https://unix.stackexchange.com/questions/342574/use-etc-paths-or-etc-paths-d-to-add-items-to-the-path-in-macos-sierra)

Use `/etc/paths.d`.  
The primary reason is that `/etc/paths` will be modified and/or replaced by system upgrades. `/etc/paths.d/` items will not.  
Files are generally named with the pattern index-source. E.g., `99-mypaths`. Paths are appended in order*.  
It's a lot easier to simply add/remove a file than programmatically editing one idempotently without bugs.

The default `/etc/profile`, `/etc/zprofile` and `/etc/csh.login` on macOS all load *path_helper*.

[How can one use /etc/paths.d to add a path with spaces in it to $PATH?](https://apple.stackexchange.com/questions/313520/how-can-one-use-etc-paths-d-to-add-a-path-with-spaces-in-it-to-path)  

### demo

以下为 macOS ZSH 下的 PATH 变量：

```Shell
# print为默认动作，可省略
$ echo $PATH | awk 'BEGIN{RS=":"} {print}'
# 省略在 ~/.zshrc 中追加在 PATH 前面的配置
/usr/local/bin
/usr/bin
/bin
/usr/sbin
/sbin
/opt/X11/bin
/Library/Apple/usr/bin
/Applications/Wireshark.app/Contents/MacOS
# 省略在 ~/.zshrc 中追加在 PATH 后面的配置
```

前面5个为 `/etc/paths` 中预定义的路径；后面3个为 `/etc/paths.d` 中配置的环境变量：

```
$ ls -1 /etc/paths.d/
100-rvictl
40-XQuartz
Wireshark
```

每个文件里面包含一行可执行路径，被 `/etc/profile` 或 `/etc/zprofile` 执行 path_helper 加载到 PATH 环境变量中：

```
$ cat /etc/paths.d/40-XQuartz
/opt/X11/bin
$ cat /etc/paths.d/100-rvictl
/Library/Apple/usr/bin
$ cat /etc/paths.d/Wireshark
/Applications/Wireshark.app/Contents/MacOS
```

## ~/.bash_profile

当 bash shell 是以 login 方式执行时，才会读取此文件，该文件仅仅执行一次。

> 一般在这个文件中添加**用户级**环境变量

## refs

### Linux

[Linux下环境变量设置](https://www.cnblogs.com/Joans/p/7760378.html)  
[Linux设置环境变量的三种方法](https://zongxp.blog.csdn.net/article/details/82187899)  
[Linux操作系统下三种配置环境变量的方法](https://www.cnblogs.com/lidabo/p/4344184.html)  
[设置Linux环境变量的方法和区别_Ubuntu](https://www.cnblogs.com/zhuixinshaonian/p/5521699.html)  

### macOS

[Where is the default terminal $PATH located on Mac?](https://stackoverflow.com/questions/9832770/where-is-the-default-terminal-path-located-on-mac)  
[How To Edit Your PATH Environment Variables On Mac OS X](http://hathaway.cc/post/69201163472/how-to-edit-your-path-environment-variables-on-mac)  

[MY MAC OSX BASH PROFILE](http://natelandau.com/my-mac-osx-bash_profile/)  
[MAC OS X上找不到.bash_profile？](http://blog.csdn.net/hsyj_0001/article/details/5403939)  
[Creating a .bash_profile on your mac](http://redfinsolutions.com/blog/creating-bashprofile-your-mac)  

[macOS 设置环境变量的方法](https://recomm.cnblogs.com/blogpost/3721616)  
[macOS 设置环境变量 PATH](https://www.cnblogs.com/jiumengmeng/p/9837624.html)  
[macOS 添加环境变量的三种方法](https://yijiebuyi.com/blog/41ee3bab0c5bf1d43c7a8ccc7f0fe44e.html)  

[How To Add /usr/local/bin In $PATH On Mac](https://izziswift.com/how-to-add-usr-local-bin-in-path-on-mac/)  
[Setting PATH environment variable in OSX permanently](https://stackoverflow.com/questions/22465332/setting-path-environment-variable-in-osx-permanently)  
[How do I set the global PATH environment variable on OS X?](https://serverfault.com/questions/16355/how-do-i-set-the-global-path-environment-variable-on-os-x)  
