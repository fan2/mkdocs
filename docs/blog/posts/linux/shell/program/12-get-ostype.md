---
title: Linux Shell Program - ostype
authors:
  - xman
date:
    created: 2019-11-06T10:30:00
categories:
    - linux
    - shell
comments: true
---

Linux 下的 Shell 编程之获取操作系统类型。

<!-- more -->

本文列举了一些获取系统类型和版本信息的命令和方式。

## uname

```Shell
# macOS
$ uname
Darwin
$ uname -mrs
Darwin 20.6.0 x86_64
$ uname -a
Darwin THOMASFAN-MB1 20.6.0 Darwin Kernel Version 20.6.0: Thu Jan 20 21:02:14 PST 2022; root:xnu-7195.141.20~1/RELEASE_X86_64 x86_64
```

```Shell
# ubuntu
$ uname
Linux
$ uname -mrs
Linux 5.13.0-1016-raspi aarch64
$ uname -a
Linux rpi4b-ubuntu 5.13.0-1016-raspi #18-Ubuntu SMP PREEMPT Thu Jan 20 08:53:01 UTC 2022 aarch64 aarch64 aarch64 GNU/Linux
```

```Shell
# raspbian
pi@raspberrypi:~$ uname
Linux

pi@raspberrypi:~$ uname -mrs
Linux 4.9.41-v7+ armv7l

pi@raspberrypi:~ $ uname -a
Linux raspberrypi 4.9.41-v7+ #1023 SMP Tue Aug 8 16:00:15 BST 2017 armv7l GNU/Linux
```

## OSTYPE

```Shell
# macOS
$ echo $OSTYPE
darwin20.0

# ubuntu
$ echo $OSTYPE
linux-gnu

# raspbian
$ echo $OSTYPE
linux-gnueabihf
```

## /proc/version

```Shell
# macOS 不存在
$ cat /proc/version
cat: /proc/version: No such file or directory
$ echo $?
1

# ubuntu
$ cat /proc/version
Linux version 5.13.0-1016-raspi (buildd@bos02-arm64-077) (gcc (Ubuntu 11.2.0-7ubuntu2) 11.2.0, GNU ld (GNU Binutils for Ubuntu) 2.37) #18-Ubuntu SMP PREEMPT Thu Jan 20 08:53:01 UTC 2022

# raspbian
$ cat /proc/version
Linux version 4.9.41-v7+ (dc4@dc4-XPS13-9333) (gcc version 4.9.3 (crosstool-NG crosstool-ng-1.22.0-88-g8460611) ) #1023 SMP Tue Aug 8 16:00:15 BST 2017
```

## /etc/issue

```Shell
# macOS 不存在
$ cat /etc/issue
cat: /etc/issue: No such file or directory

# ubuntu
$ cat /etc/issue
Ubuntu 21.10 \n \l

# raspbian
$ cat /etc/issue
Raspbian GNU/Linux 9 \n \l
```

## get_ostype

[Bash: Check Operating System is Mac](https://remarkablemark.org/blog/2020/10/31/bash-check-mac/)

```Shell
[[ $OSTYPE == 'darwin'* ]] && echo 'macOS'
```

[Detect operating system in shell script](https://megamorf.gitlab.io/2021/05/08/detect-operating-system-in-shell-script/)

[How to detect the OS from a Bash script?](https://stackoverflow.com/questions/394230/how-to-detect-the-os-from-a-bash-script)

- [如何从Bash脚本中检测操作系统？](https://blog.csdn.net/asdfgh0077/article/details/104083650)  
- [检测三种不同操作系统的Bash脚本](https://www.cnblogs.com/fnlingnzb-learner/p/10657285.html)  

具体参考整理的脚本 get_ostype.sh。

??? info "get_ostype.sh"

    ```Shell
    #!/bin/bash

    # https://stackoverflow.com/a/8597411
    function get_ostype_1 {
        local platform1='unknown'
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            platform1='linux'
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            platform1='macos'
        elif [[ "$OSTYPE" == "msys" ]]; then
            # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
            platform1='win(msys)'
        elif [[ "$OSTYPE" == "cygwin" ]]; then
            # POSIX compatibility layer and Linux environment emulation for Windows
            platform1='win(cygwin)'
        elif [[ "$OSTYPE" == "win32" ]]; then
            # I'm not sure this can happen.
            platform1='win32'
        elif [[ "$OSTYPE" == "freebsd"* ]]; then
            platform1='freebsd'
        fi
        echo "$platform1"
    }

    # https://stackoverflow.com/a/18434831
    function get_ostype_2 {
        local platform2='unknown'
        case "$OSTYPE" in
        linux*)
            platform2='linux'
            ;;
        darwin*)
            platform2='macos'
            ;;
        bsd*)
            platform2='bsd'
            ;;
        solaris*)
            platform2='solaris'
            ;;
        msys*)
            platform2='win(msys)'
            ;;
        cygwin*)
            platform2='win(cygwin)'
            ;;
        *) ;;
        esac
        echo "$platform2"
    }

    # Detect the platform (similar to $OSTYPE)
    get_ostype_3() {
        local OS="$(uname)"
        local platform3='unknown'
        case $OS in
        'Linux')
            platform3='linux'
            ;;
        'Darwin')
            platform3='macos'
            ;;
        'FreeBSD')
            platform3='freebsd'
            ;;
        'SunOS')
            platform3='solaris'
            ;;
        'WindowsNT')
            platform3='windows'
            ;;
        'AIX')
            OS='aix'
            ;;
        *) ;;
        esac
        echo "$platform3"
    }

    # https://stackoverflow.com/a/29239609
    if_os() {
        [[ $OSTYPE == *$1* ]]
    }

    if_nix() {
        case "$OSTYPE" in
        *linux* | *hurd* | *msys* | *cygwin* | *sua* | *interix*) sys="gnu" ;;
        *bsd* | *darwin*) sys="bsd" ;;
        *sunos* | *solaris* | *indiana* | *illumos* | *smartos*) sys="sun" ;;
        esac
        [[ "${sys}" == "$1" ]]
    }
    ```
