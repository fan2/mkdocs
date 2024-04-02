---
title: Linux Shell Program - daemon 2
authors:
  - xman
date:
    created: 2019-11-06T11:20:00
categories:
    - linux
    - shell
comments: true
---

Linux 下的 Shell 编程之后台执行守护进程。

<!-- more -->

vscode 在 `launch.json` 中，通过 preLaunchTask 指定 `tasks.json` 中配置的 task label（isBackground），实现预启动 proxy daemon。  
Android Studio 可通过 `Before launch` 启动 proxy sh 脚本，如何在 Run 运行完时，proxy 程序依旧在后台守护（daemon）不退出？  

> Android Studio - [创建和修改运行/调试配置](https://developer.android.com/studio/run/rundebugconfig) -[定义启动之前的操作](https://developer.android.com/studio/run/rundebugconfig#definingbefore)  

## demo

用例1：while true 循环每隔3s向控制台输出一句日志，同时通过 tee 将日志重定向一份到日志文件。

```Shell
$ cat while_loop.sh
#!/usr/bin/env bash

while true; do
    echo "$(date): loop" | tee while_loop.log
    sleep 3
done
```

用例2：通过 `python3 -m` 启动 http.server 模块，运行 Web Server Daemon，并将输出重定向到日志文件。

```Shell
$ cat serve_daemon.sh
#!/usr/bin/env bash

python3 -m http.server 8000 -b 0.0.0.0 -d ../web 2>&1 | tee serve_daemon.log
```

可新建Terminal tab运行sh脚本，手动关闭tab或输入 `exit` 退出当前shell。
也可在当前Terminal tab中执行 `bash` 新建子shell运行测试，执行 `exit` 退出子shell。

当 bash exit 或 Terminal tab或window 窗口关闭后：

1. 可执行 `tail -f *.log` 滚动查看日志，以确认daemon是否还在运行。  
2. 通过 `ps | grep` 匹配查找 CMD 对应的进程 PID：

```Shell
ps -ef | grep while_loop | grep -v grep
```

3. 可进一步执行 `ps | grep | xargs kill` 杀掉后台进程：

```Shell
ps -ef | grep while_loop | grep -v grep | awk '{print $2}' | xargs kill -KILL
```

## &

man bash - SHELL GRAMMAR - Lists

> If a command is terminated by the control operator `&`, the shell executes the command in the *background* in a **subshell**. 
> The shell does not wait for the command to ﬁnish, and the return status is 0.

在命令后面加上 `&` 符号，即可将命令切换到后台子shell进程执行，但命令的stdout和stderr仍会输出。

```Shell
command &
```

后台命令时不时输出信息到当前shell，会阻碍在当前shell流畅清晰地执行其他命令任务，可考虑将输出重定向到日志文件。

```Shell
# redirect both stdout and stderr to the same file
command1 > output.log 2>&1 &
# redirect stdout and stderr to two different files
command2 > stdout.log 2> stderr.log &
```

也可将重定向到 `/dev/null`，忽略输出信息：

```Shell
# redirects stdout to /dev/null and stderr to stdout
command > /dev/null 2>&1 &
# suppress the `stdout` and `stderr` messages, keeps screen clear
command &> /dev/null &
```

### sh

当然，在命令行运行sh脚本时，也可在这句运行命令后面加上 `&`，将整个sh脚本的运行切到后台运行。

```Shell
script.sh &
```

后台sh时不时输出信息到当前shell，会阻碍在当前shell流畅清晰地执行其他命令任务，可考虑将输出重定向到日志文件。

```Shell
# redirect both stdout and stderr to the same file
./a.sh > output.log 2>&1 &
# redirect stdout and stderr to two different files
./a.sh > stdout.log 2> stderr.log &
```

也可将重定向到 `/dev/null`，忽略输出信息：

```Shell
# ignore noisy output
./a.sh > /dev/null 2>&1 &
./b.sh &> /dev/null &
```

```Shell
# run in a subshell to remove notifications
(&>/dev/null c.sh &)
# run the script in a linux kickstart
sh /tmp/script.sh > /dev/null 2>&1 < /dev/null &
```

### test

测试1：在 while_loop.sh 中 done 末尾添加 `&`，然后执行 `./while_loop.sh`。  
测试2：执行 `./while_loop.sh &`。  

执行sh后，通过 `ps | grep` 查看进程信息：

```Shell
$ ps -ef | grep while_loop | grep -v grep
#  UID   PID  PPID   C STIME   TTY           TIME CMD
  501 52498     1   0  9:05AM ttys015    0:00.01 bash ./while_loop.sh
```

当执行sh所在的子bash shell执行exit退出时TTY还在，当bash shell所在Terminal tab关闭时TTY变为??。

```Shell
$ ps -ef | grep while_loop | grep -v grep
#  UID   PID  PPID   C STIME   TTY           TIME CMD
  501 52498     1   0  9:05AM ??         0:00.02 bash ./while_loop.sh
```

测试1：

- exit当前bash shell或关闭当前Terminal tab，或关闭整个Terminal windown进程时，sh脚本进程依然在后台执行。

测试2：

- exit当前bash shell或关闭当前Terminal tab，sh脚本后台子进程也将退出；
- 执行bash打开新shell，依次exit子bash shell、bash shell（或关闭当前Terminal tab），或关闭整个Terminal windown进程时，sh脚本进程依然在后台执行。

## nohup

`nohup` 意即 no hang up，当所在的 Terminal window 进程关闭时，忽略 Terminal 父进程发出的 SIGHUP 信号。

> 当关闭 Terminal window 进程时，sh脚本后台进程不会退出。

```Shell
NAME
     nohup -- invoke a utility immune to hangups

SYNOPSIS
     nohup [--] utility [arguments]

DESCRIPTION
     The nohup utility invokes utility with its arguments and at this time sets the signal SIGHUP to be
     ignored.  If the standard output is a terminal, the standard output is appended to the file nohup.out
     in the current directory.  If standard error is a terminal, it is directed to the same place as the
     standard output.
```

Use `nohup` if your background job takes a long time to finish.

```Shell
nohup command &
# 相当于
nohup command &> nohup.out &
```

To send a command or script in the background and keep it running, use the syntax.

```Shell
# it works in background and does not show any output.
$ nohup sh prog.sh proglog.log 2>&1 &
```

redirect the stdout and stderr to `/dev/null` to ignore the output.

```Shell
$ nohup command &>/dev/null &
$ nohup script.sh &>/dev/null &
$ nohup script.sh > /dev/null 2>&1 &
```
