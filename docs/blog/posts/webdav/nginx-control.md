---
title: nginx查看日志及控制命令
authors:
  - xman
date:
    created: 2024-03-18T16:00:00
categories:
    - nginx
tags:
    - nginx
comments: true
---

nginx 配置文件在哪里？日志文件在哪里？如何实时滚动查看 nginx 日志？如何控制运行中的 nginx 进程？

<!-- more -->

执行 `nginx -h` 查看帮助：

```Shell
$ nginx -h
nginx version: nginx/1.18.0 (Ubuntu)
Usage: nginx [-?hvVtTq] [-s signal] [-c filename] [-p prefix] [-g directives]

Options:
  -?,-h         : this help
  -v            : show version and exit
  -V            : show version and configure options then exit
  -t            : test configuration and exit
  -T            : test configuration, dump it and exit
  -q            : suppress non-error messages during configuration testing
  -s signal     : send signal to a master process: stop, quit, reopen, reload
  -p prefix     : set prefix path (default: /usr/share/nginx/)
  -c filename   : set configuration file (default: /etc/nginx/nginx.conf)
  -g directives : set global directives out of configuration file

```

启动时可以通过 `-p` 选项指定工作目录，通过 `-c` 选项指定配置文件。

## start

    $ cd ~/workspace
    $ mkdir nginx && cd nginx
    $ mkdir conf && cd conf
    # touch nginx.conf
    $ vim nginx.conf

在 nginx.conf 中增加反向代理转发配置。

1.  检测配置文件：nginx -t -c `pwd`/nginx.conf
2.  启动nginx服务：nginx -p `pwd`/ -c nginx.conf

## log

### 日志文件在哪里？

[Where can I find the error logs of nginx, using FastCGI and Django?](https://stackoverflow.com/questions/1706111/where-can-i-find-the-error-logs-of-nginx-using-fastcgi-and-django)

brew install 的 nginx-full，/usr/local/etc/nginx/nginx.conf 中没有开启 access\_log 和 error\_log，默认 log path 在哪里？

可以执行 `nginx -h`，在 `-c filename` 选项后面可以看到 default configuration file。

You can use `lsof` (list of open files) in most cases to find open log files without knowing the configuration.

```Shell
# macOS
~$ ps aux | grep nginx
faner            33741   0.0  0.0 35126068   3596   ??  S     7:34AM   0:00.30 nginx: worker process
root             33691   0.0  0.0 34425616   6392   ??  Ss    7:34AM   0:00.03 nginx: master process /usr/local/opt/nginx-full/bin/nginx -g daemon off;

~$ lsof -p 33741 | grep log
nginx   33741 faner    1u     REG              1,13        0            25121281 /usr/local/var/log/nginx.log
nginx   33741 faner    2w     REG              1,13    51695             3821144 /usr/local/var/log/nginx/error.log
nginx   33741 faner    4w     REG              1,13  2103983             3821142 /usr/local/var/log/nginx/access.log
nginx   33741 faner    5w     REG              1,13    51695             3821144 /usr/local/var/log/nginx/error.log
```

### 日志重定向到标准输出

[Nginx日志重定向到标准输出](https://blog.csdn.net/Free_time_/article/details/104655214)

    daemon off;
    error_log /dev/stdout warn;
    access_log /dev/stdout main;

### tail实时滚动显示log

[tail实时滚动显示log文件内容](https://blog.csdn.net/tterminator/article/details/45077035?%3E)

Linux 中有一个 `tail` 命令，常用来显示一个文件的最后n行文档内容。

但在更多情况下，我们要在服务器端运行程序，并且需要实时监控运行日志，这时候有什么办法实时滚动显示log文件内容？

`tail` 命令加 `-f` 参数可以满足这一需求，具体用法如下：

```Shell
# macOS
tail -f /usr/local/var/log/nginx/error.log
# ubuntu
tail -f /var/log/nginx/webdav.error.log
```

## nginx -s

[Controlling NGINX Processes at Runtime](https://docs.nginx.com/nginx/admin-guide/basic-functionality/runtime-control/)

To reload your configuration, you can stop or restart NGINX, or send signals to the master process. A signal can be sent by running the `nginx` command (invoking the NGINX executable) with the `-s` argument.

    nginx -s <SIGNAL>

where `<SIGNAL>` can be one of the following:

*   `quit` – Shut down gracefully (the `SIGQUIT` signal)
*   `reload` – Reload the configuration file (the `SIGHUP` signal)
*   `reopen` – Reopen log files (the `SIGUSR1` signal)
*   `stop` – Shut down immediately (or fast shutdown, the `SIGTERM` singal)

For more information about advanced signals (for performing live binary upgrades, for example), see [Controlling nginx](https://nginx.org/en/docs/control.html) at **nginx.org**.

`nginx -s` 命令：

```Shell
# Shut down gracefully (the `SIGQUIT` signal)
nginx -s quit
# Shut down immediately (or fast shutdown, the `SIGTERM` singal)
nginx -s stop
# Reload the configuration file (the `SIGHUP` signal)
nginx -s reload
# Reopen log files (the `SIGUSR1` signal)  
nginx -s reopen
```

## kill -SIG

The `kill` utility can also be used to send a signal directly to the master process. The process ID of the master process is written, by default, to the **nginx.pid** file, which is located in the **/usr/local/nginx/logs** or **/var/run** directory.

### pid

The process ID of the *master* process is written to the file `/usr/local/nginx/logs/nginx.pid` by default. This name may be changed at configuration time, or in `nginx.conf` using the **pid** directive.

> macOS 下通过 brew 安装的nginx 默认pid存储路径是  `/usr/local/var/run/nginx.pid`

```Shell
# 查看pid文件中存储的 master_pid
$ cat /usr/local/var/run/nginx.pid
7524

# 查询nginx进程
$ ps -lef | grep -i nginx:
  501  7524     1        4   0  31  0  4337568    692 -      Ss                  0 ??         0:00.00 nginx: master pr  7:32AM
  501  7525  7524        4   0  31  0  4337628    812 -      S                   0 ??         0:00.00 nginx: worker pr  7:32AM

# 查询提取nginx进程号
$ ps -lef | grep -i nginx: | awk '{ print $2}'
7524
7525
```

### SIG

nginx can be controlled with signals.

关于信号量，可以 man signal 查看说明文档：

| No | Name    | Default Action    | Description                 |
| -- | ------- | ----------------- | --------------------------- |
| 1  | SIGHUP  | terminate process | terminal line hangup        |
| 2  | SIGINT  | terminate process | interrupt program           |
| 3  | SIGQUIT | create core image | quit program                |
| 9  | SIGKILL | terminate process | kill program                |
| 15 | SIGTERM | terminate process | software termination signal |
| 30 | SIGUSR1 | terminate process | User defined signal 1       |

[nginx启动、重启、关闭](https://www.cnblogs.com/clphp/p/8057771.html)
[How to stop nginx on Mac OS X](https://serverfault.com/questions/141975/how-to-stop-nginx-on-mac-os-x)

若 nginx.conf 配置了主进程pid（master\_pid）的存储路径，则可以通过读取pid执行kill命令发送信号。

调用 `kill` 命令发送信号操控nginx进程：

    # 从容停止主进程
    kill -QUIT `cat /usr/local/var/run/nginx.pid`
    # 快速停止主进程
    kill -TERM `cat /usr/local/var/run/nginx.pid`
    kill -INT `cat /usr/local/var/run/nginx.pid`
    # 平滑重启
    kill -HUP `cat /usr/local/var/run/nginx.pid`
    # 强制停止名称包含nginx的进程
    pkill -KILL nginx  
    # 强制停止所有nginx进程
    ps -lef | grep -i nginx: | awk '{ print $2}' | xargs kill -KILL  

## services

在具体的操作系统平台上，提供了相应的服务管理工具，例如 brew services 在 macOS 上调用 launchctl，在 linux 下调用 systemctl 来管理服务。

```Shell
$ brew help services
Usage: brew services [subcommand]

Manage background services with macOS' launchctl(1) daemon manager or Linux's
systemctl(1) service manager.
```

## refs

[nginx for Mac install、start、stop 、reload实践](https://zhuanlan.zhihu.com/p/38485095)

[nginx reload 报错，彻底杀死nginx进程](https://blog.csdn.net/palmer_kai/article/details/104014595)
