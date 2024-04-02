---
title: Linux Command - ps, kill
authors:
  - xman
date:
    created: 2019-10-29T11:00:00
categories:
    - wiki
    - linux
    - command
tags:
    - ps
    - kill
comments: true
---

linux 下的命令 ps, kill 简介。

<!-- more -->

## ps

以下为为各大平台 ps 命令在线手册：

- unix/POSIX - [ps - report process status](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/ps.html)  
- FreeBSD/Darwin - [ps -- process status](https://www.freebsd.org/cgi/man.cgi?query=ps)  
- linux - [ps - report a snapshot of the current processes](https://man7.org/linux/man-pages/man1/ps.1.html)  
- debian - [ps - report a snapshot of the current processes](https://manpages.debian.org/bullseye/procps/ps.1.en.html)  
- ubuntu - [ps - report a snapshot of the current processes](https://manpages.ubuntu.com/manpages/jammy/en/man1/ps.1.html)  
- windows - [tasklist - Displays a list of currently running processes](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/tasklist)  

```Shell
$ man ps # macOS

PS(1)                     BSD General Commands Manual                    PS(1)

NAME
     ps -- process status

SYNOPSIS
     ps [-AaCcEefhjlMmrSTvwXx] [-O fmt | -o fmt] [-G gid[,gid...]] [-g grp[,grp...]] [-u uid[,uid...]]
        [-p pid[,pid...]] [-t tty[,tty...]] [-U user[,user...]]
     ps [-L]
```

`ps` 只列举当前用户进程，`ps -A` 或 `ps -e` 则会列举其他用户进程。

```Shell
$ ps
  PID TTY           TIME CMD
 1701 ttys000    0:00.10 /bin/zsh -l
 4338 ttys004    0:03.58 /Applications/Xcode.app/Contents/Developer/usr/bin/xcdevice observe --both
13387 ttys005    0:01.47 -zsh
 9710 ttys007    0:00.29 ssh pifan@rpi4b-ubuntu.local
```

```Shell
$ ps x
  PID   TT  STAT      TIME COMMAND
 1701 s000  Ss+    0:00.10 /bin/zsh -l
 4338 s004  Ss+    0:03.58 /Applications/Xcode.app/Contents/Developer/usr/bin/xcdevice observe --both
13386 s005  Ss     0:00.06 /usr/bin/login -fpl faner /Applications/iTerm.app/Contents/MacOS/ShellLauncher --launch_shell
13387 s005  S      0:01.57 -zsh
16312 s005  R+     0:00.00 ps x
 9710 s007  Ss+    0:00.29 ssh pifan@rpi4b-ubuntu.local
```

### pstree

```Shell
$ man pstree # on macOS

PSTREE(1)                 BSD General Commands Manual                PSTREE(1)

NAME
     pstree -- list processes as a tree

SYNOPSIS
     pstree [-Uw] [-f file] [-g n] [-l n] [-p pid] [-s string] [-u user] [rootpid ...]
```

### top

```Shell
$ man top # macOS

TOP(1)                    BSD General Commands Manual                   TOP(1)

NAME
     top -- display sorted information about processes

SYNOPSIS
     top [-a | -d | -e | -c mode]
         [-F | -f]
         [-h]
         [-i interval]
         [-l samples]
         [-ncols columns]
         [-o key | -O skey]
         [-R | -r]
         [-S]
         [-s delay-secs]
         [-n nprocs]
         [-stats keys]
         [-pid processid]
         [-user username]
         [-U username]
         [-u]
```

## kill

```Shell
$ man kill # macOS

KILL(1)                   BSD General Commands Manual                  KILL(1)

NAME
     kill -- terminate or signal a process

SYNOPSIS
     kill [-s signal_name] pid ...
     kill -l [exit_status]
     kill -signal_name pid ...
     kill -signal_number pid ...
```

### pgrep/pkill

```Shell
$ man pkill # macOS

PKILL(1)                  BSD General Commands Manual                 PKILL(1)

NAME
     pgrep, pkill -- find or signal processes by name

SYNOPSIS
     pgrep [-Lafilnoqvx] [-F pidfile] [-G gid] [-P ppid] [-U uid] [-d delim] [-g pgrp] [-t tty] [-u euid] pattern ...
     pkill [-signal] [-ILafilnovx] [-F pidfile] [-G gid] [-P ppid] [-U uid] [-g pgrp] [-t tty] [-u euid] pattern ...
```

[Bash: Killing all processes in subprocess](https://stackoverflow.com/questions/41508640/bash-killing-all-processes-in-subprocess)

You can set a trap in the subshell to kill any active jobs before exiting:

```Shell
(trap 'kill $(jobs -p)' EXIT; sleep 5; echo done ) & pid=$!
```

> This does not work for me. What is jobs -p supposed to output? It doesn't output anything when I run it.

I don't know exactly why that sleep process gets orphaned, anyway instead kill you can use pkill with -P flag to also kill all children

```Shell
pkill -TERM -P $pid
```

EDIT: that means that in order to kill a process and all it's children you should use instead

```Shell
# gets pids of child processes
CPIDS=`pgrep -P $pid`
kill -KILL $pid
for cpid in $CPIDS ; do kill -9 $cpid ; done
```

### pslist/rkill

- [FreeBSD - pslist](https://www.freebsd.org/cgi/man.cgi?query=pslist)  
- [debian - pslist](https://manpages.debian.org/bullseye/pslist/pslist.1.en.html)  

```Shell
PSLIST(1)                  BSD General Commands Manual                 PSLIST(1)

NAME
     pslist -- control processes and their descendants

SYNOPSIS
     pslist [pid/name...]
     pslist -h | --help
     pslist -v | --version

     rkill [-SIG] pid/name...

     rrenice [+/-]pri pid/name...
```

[Bash: Killing all processes in subprocess](https://stackoverflow.com/questions/41508640/bash-killing-all-processes-in-subprocess)

You can have a look at `rkill` that seems to meet your requirements :

> Works, though `pslist`/`rkill` does not seem to be standard tool installed on most Linux systems

## systemadmin

[ohmyzsh/plugins/systemadmin/](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/systemadmin) 提供了一些 ps 和 kill 的便捷封装。

pkill 杀死指定process name，kill则基于PID杀进程。

```Shell
# 杀死挂起进程
kill_run() {
    pkill -KILL nginx # default SIGTERM
    pgrep -f 'dart run.*SHELF_PROXY' | xargs kill -KILL
    pgrep -f 'flutter run.*NGINX_REVERSE_PROXY' | xargs kill -KILL
#     ps -ef | grep '(dart|flutter) run' | grep -v grep | awk '{ print $2}' | xargs kill -KILL
}
```

[查看 Linux TCP Port 被哪隻程式(Process)佔用](https://blog.longwin.com.tw/2013/12/linux-port-process-check-2013/)  
[Finding the PID of the Process Using a Specific Port](https://www.baeldung.com/linux/find-process-using-port)  
[Linux Find Out Which Process Is Listening Upon a Port](https://www.cyberciti.biz/faq/what-process-has-open-linux-port/)  
[3 Ways to Find Out Which Process Listening on a Particular Port](https://www.tecmint.com/find-out-which-process-listening-on-a-particular-port/)  

```Shell
lsof -i :8010 | awk 'NR>1 {print $2}' | xargs kill -KILL
```